import 'dart:async';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_calculator/core/utils/number_formatter.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_engine.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_session.dart';
import 'package:easy_calculator/features/calculator/domain/repositories/session_repository.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';
import 'package:easy_calculator/features/history/domain/repositories/history_repository.dart';

/// Cubit managing calculator input, evaluation, memory, mode state, and persistence.
class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({
    CalculatorEngine? engine,
    this.historyRepository,
    this.sessionRepository,
    bool autoRestore = false,
  }) : _engine = engine ?? const CalculatorEngine(),
       super(const CalculatorState()) {
    if (autoRestore) {
      restoreSession();
    }
  }

  final CalculatorEngine _engine;
  final HistoryRepository? historyRepository;
  final SessionRepository? sessionRepository;

  Timer? _debounceTimer;
  bool _isRestoring = false;
  bool _isFlushingImmediately = false;
  static int _historyCounter = 0;

  /// Appends a digit ('0' - '9') to the expression.
  void appendDigit(String digit) {
    if (state.isResultComputed) {
      // Post-result rule: Tapping a digit starts a fresh calculation
      emit(
        state.copyWith(
          expression: digit,
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final newExpr = state.expression + digit;
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearResult: live == null,
        clearError: true,
      ),
    );
  }

  /// Appends or replaces an operator ('+', '−', '×', '÷', '^').
  void appendOperator(String op) {
    if (state.isResultComputed) {
      // Post-result rule: Tapping an operator continues from the previous result
      final base = state.result ?? '0';
      final newExpr = '$base $op ';
      emit(
        state.copyWith(
          expression: newExpr,
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final trimmed = state.expression.trimRight();
    if (trimmed.isEmpty) {
      if (op == '−' || op == '-') {
        // Leading negative number allowed
        emit(state.copyWith(expression: '−', clearError: true));
      }
      return;
    }

    // Check if expression already ends with an operator (replace it)
    final lastChar = trimmed[trimmed.length - 1];
    if (lastChar == '+' ||
        lastChar == '−' ||
        lastChar == '-' ||
        lastChar == '×' ||
        lastChar == '*' ||
        lastChar == '÷' ||
        lastChar == '/' ||
        lastChar == '^') {
      final withoutLast = trimmed.substring(0, trimmed.length - 1).trimRight();
      final newExpr = withoutLast.isEmpty ? op : '$withoutLast $op ';
      emit(state.copyWith(expression: newExpr, clearError: true));
      return;
    }

    final newExpr = '$trimmed $op ';
    emit(state.copyWith(expression: newExpr, clearError: true));
  }

  /// Appends a decimal point ('.') safely without duplicates in the current number.
  void appendDecimal() {
    if (state.isResultComputed) {
      emit(
        state.copyWith(
          expression: '0.',
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final expr = state.expression;
    if (expr.isEmpty || expr.endsWith(' ') || expr.endsWith('(')) {
      emit(state.copyWith(expression: '${expr}0.', clearError: true));
      return;
    }

    // Check current number segment for existing decimal point
    final segments = expr.split(RegExp(r'[ +−\-×*÷/^()]'));
    final lastSegment = segments.isNotEmpty ? segments.last : '';
    if (lastSegment.contains('.')) {
      return;
    }

    emit(state.copyWith(expression: '$expr.', clearError: true));
  }

  /// Appends a percentage sign ('%').
  void appendPercent() {
    if (state.isResultComputed && state.result != null) {
      final newExpr = '${state.result}%';
      final calc = _engine.evaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: calc.formattedResult,
          isResultComputed: true,
          errorMessage: calc.errorMessage,
        ),
      );
      return;
    }

    final trimmed = state.expression.trimRight();
    if (trimmed.isEmpty) return;
    final lastChar = trimmed[trimmed.length - 1];
    if (RegExp(r'[0-9)πe!]').hasMatch(lastChar)) {
      final newExpr = '$trimmed%';
      final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: live?.formattedResult,
          clearError: true,
        ),
      );
    }
  }

  /// Appends an open or close parenthesis.
  void appendParenthesis(String paren) {
    if (paren == '(') {
      if (state.isResultComputed) {
        emit(
          state.copyWith(
            expression: '(',
            clearResult: true,
            isResultComputed: false,
            clearError: true,
          ),
        );
        return;
      }
      final newExpr = '${state.expression}(';
      emit(state.copyWith(expression: newExpr, clearError: true));
    } else {
      // Closing parenthesis
      if (state.expression.isEmpty) return;
      final newExpr = '${state.expression})';
      final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: live?.formattedResult,
          clearError: true,
        ),
      );
    }
  }

  /// Appends a prefix function like sin, cos, tan, ln, log, sqrt.
  void appendFunction(String fnName) {
    if (state.isResultComputed) {
      // Post-result rule: wrap result or start new function
      final base = state.result;
      if (base != null && base.isNotEmpty) {
        final newExpr = '$fnName($base)';
        final calc = _engine.evaluate(newExpr, angleMode: state.angleMode);
        emit(
          state.copyWith(
            expression: newExpr,
            result: calc.formattedResult,
            isResultComputed: true,
            errorMessage: calc.errorMessage,
          ),
        );
        return;
      }
    }

    final expr = state.expression;
    final newExpr = '$expr$fnName(';
    emit(state.copyWith(expression: newExpr, clearError: true));
  }

  /// Appends a power expression (e.g. ^2, ^3, ^).
  void appendPower(String powerExpr) {
    if (state.isResultComputed && state.result != null) {
      final newExpr = '${state.result}$powerExpr';
      final calc = _engine.evaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: calc.formattedResult,
          isResultComputed: true,
          errorMessage: calc.errorMessage,
        ),
      );
      return;
    }

    final trimmed = state.expression.trimRight();
    if (trimmed.isEmpty) return;
    final newExpr = '$trimmed$powerExpr';
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  /// Appends a reciprocal operation (1/x).
  void appendReciprocal() {
    if (state.isResultComputed && state.result != null) {
      final newExpr = '1/(${state.result})';
      final calc = _engine.evaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: calc.formattedResult,
          isResultComputed: true,
          errorMessage: calc.errorMessage,
        ),
      );
      return;
    }

    final expr = state.expression.trimRight();
    if (expr.isEmpty) {
      emit(state.copyWith(expression: '1/(', clearError: true));
      return;
    }

    final newExpr = '1/($expr)';
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  /// Appends a root expression (e.g. ²√, ³√, ʸ√).
  void appendRoot(String rootSymbol) {
    if (rootSymbol == 'ʸ√') {
      appendOperator('ʸ√');
      return;
    }

    if (state.isResultComputed && state.result != null) {
      final newExpr = '$rootSymbol(${state.result})';
      final calc = _engine.evaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: calc.formattedResult,
          isResultComputed: true,
          errorMessage: calc.errorMessage,
        ),
      );
      return;
    }

    final expr = state.expression;
    final newExpr = '$expr$rootSymbol(';
    emit(state.copyWith(expression: newExpr, clearError: true));
  }

  /// Appends a factorial postfix operator (!).
  void appendFactorial() {
    if (state.isResultComputed && state.result != null) {
      final newExpr = '${state.result}!';
      final calc = _engine.evaluate(newExpr, angleMode: state.angleMode);
      emit(
        state.copyWith(
          expression: newExpr,
          result: calc.formattedResult,
          isResultComputed: true,
          errorMessage: calc.errorMessage,
        ),
      );
      return;
    }

    final trimmed = state.expression.trimRight();
    if (trimmed.isEmpty) return;
    final newExpr = '$trimmed!';
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  /// Appends mathematical constants like π or e.
  void appendConstant(String constant) {
    if (state.isResultComputed) {
      emit(
        state.copyWith(
          expression: constant,
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final newExpr = '${state.expression}$constant';
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  /// Appends scientific notation exponent operator (EE).
  void appendScientificNotation() {
    if (state.isResultComputed && state.result != null) {
      final newExpr = '${state.result}E';
      emit(
        state.copyWith(
          expression: newExpr,
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final trimmed = state.expression.trimRight();
    if (trimmed.isEmpty) return;
    final newExpr = '${trimmed}E';
    emit(state.copyWith(expression: newExpr, clearError: true));
  }

  /// Appends a random decimal number between 0 and 1.
  void appendRandom([double? mockVal]) {
    final randVal = mockVal ?? math.Random().nextDouble();
    final formatted = NumberFormatter.format(randVal);
    if (state.isResultComputed) {
      emit(
        state.copyWith(
          expression: formatted,
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final newExpr = '${state.expression}$formatted';
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  /// Toggles between Degrees and Radians angle modes.
  void toggleAngleMode() {
    final newMode = state.angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;

    if (state.isResultComputed && state.expression.isNotEmpty) {
      final calc = _engine.evaluate(state.expression, angleMode: newMode);
      emit(
        state.copyWith(
          angleMode: newMode,
          result: calc.formattedResult,
          errorMessage: calc.errorMessage,
        ),
      );
    } else {
      final live = _engine.tryLiveEvaluate(
        state.expression,
        angleMode: newMode,
      );
      emit(state.copyWith(angleMode: newMode, result: live?.formattedResult));
    }
  }

  /// Toggles secondary scientific functions (2nd).
  void toggleSecondary() {
    emit(state.copyWith(isSecondary: !state.isSecondary));
  }

  // --- Memory Operations ---

  /// Clears the memory register (mc).
  void memoryClear() {
    emit(state.copyWith(memoryValue: 0.0, hasMemory: false));
  }

  /// Adds current value to memory register (m+).
  void memoryAdd() {
    final val = _getActiveNumericValue();
    if (val != null) {
      final newMemory = state.memoryValue + val;
      emit(state.copyWith(memoryValue: newMemory, hasMemory: true));
    }
  }

  /// Subtracts current value from memory register (m−).
  void memorySubtract() {
    final val = _getActiveNumericValue();
    if (val != null) {
      final newMemory = state.memoryValue - val;
      emit(state.copyWith(memoryValue: newMemory, hasMemory: true));
    }
  }

  /// Recalls the stored memory register value into the expression (mr).
  void memoryRecall() {
    if (!state.hasMemory) return;
    final formatted = NumberFormatter.format(state.memoryValue);
    if (state.isResultComputed) {
      emit(
        state.copyWith(
          expression: formatted,
          clearResult: true,
          isResultComputed: false,
          clearError: true,
        ),
      );
      return;
    }

    final newExpr = '${state.expression}$formatted';
    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  double? _getActiveNumericValue() {
    if (state.isResultComputed && state.result != null) {
      return double.tryParse(state.result!);
    }
    if (state.expression.isNotEmpty) {
      final calc = _engine.evaluate(
        state.expression,
        angleMode: state.angleMode,
      );
      if (calc.isSuccess) {
        return calc.value;
      }
    }
    return null;
  }

  /// Toggles positive/negative sign ('±') on the current number or result.
  void toggleSign() {
    if (state.isResultComputed && state.result != null) {
      final val = double.tryParse(state.result!);
      if (val != null) {
        final negated = (-val);
        final formatted = NumberFormatter.format(negated);
        emit(state.copyWith(expression: formatted, result: formatted));
      }
      return;
    }

    final expr = state.expression.trim();
    if (expr.isEmpty) {
      emit(state.copyWith(expression: '−'));
      return;
    }

    // Toggle leading minus on a single number
    if (expr.startsWith('−')) {
      emit(state.copyWith(expression: expr.substring(1)));
    } else if (expr.startsWith('-')) {
      emit(state.copyWith(expression: expr.substring(1)));
    } else if (!expr.contains(' ')) {
      emit(state.copyWith(expression: '−$expr'));
    }
  }

  /// Deletes the last character.
  void backspace() {
    if (state.isResultComputed) {
      emit(state.copyWith(isResultComputed: false, clearError: true));
      return;
    }

    final expr = state.expression;
    if (expr.isEmpty) return;

    var newExpr = expr.trimRight();
    if (newExpr.isNotEmpty) {
      // If ends with a multi-letter function like 'sin(', remove the whole function call prefix
      final fnMatch = RegExp(
        r'(sinh⁻¹\(|cosh⁻¹\(|tanh⁻¹\(|sin⁻¹\(|cos⁻¹\(|tan⁻¹\(|sinh\(|cosh\(|tanh\(|sin\(|cos\(|tan\(|log₁₀\(|log2\(|ln\(|²√\(|³√\(|e\^\(|10\^\(|2\^\()$',
      );
      if (fnMatch.hasMatch(newExpr)) {
        newExpr = newExpr.replaceFirst(fnMatch, '');
      } else {
        newExpr = newExpr.substring(0, newExpr.length - 1).trimRight();
      }
    }

    final live = _engine.tryLiveEvaluate(newExpr, angleMode: state.angleMode);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearError: true,
      ),
    );
  }

  /// Clears the calculator session (All Clear).
  void clear() {
    emit(
      state.copyWith(
        expression: '',
        clearResult: true,
        clearError: true,
        isResultComputed: false,
      ),
    );
  }

  /// Finalizes the calculation on equals ('=').
  Future<void> calculateEquals() async {
    final expr = state.expression.trim();
    if (expr.isEmpty) return;

    // Prevent duplicate history entries if repeatedly tapping equals on an already evaluated calculation
    if (state.isResultComputed && state.result != null) return;

    final evalResult = _engine.evaluate(expr, angleMode: state.angleMode);
    if (evalResult.isSuccess) {
      final resultStr = evalResult.formattedResult ?? '';
      _isFlushingImmediately = true;
      emit(
        state.copyWith(
          result: resultStr,
          isResultComputed: true,
          clearError: true,
        ),
      );

      // Record completed calculation to history
      await _recordHistory(expr, resultStr);

      // Save session immediately on calculation completion
      await flushSession();
      _isFlushingImmediately = false;
    } else {
      emit(
        state.copyWith(
          errorMessage: evalResult.errorMessage ?? 'Error',
          isResultComputed: false,
        ),
      );
    }
  }

  Future<void> _recordHistory(String expr, String resultStr) async {
    if (historyRepository == null) return;
    final item = HistoryItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_historyCounter++}',
      expression: expr,
      result: resultStr,
      timestamp: DateTime.now(),
      mode: state.mode == CalculatorMode.scientific ? 'scientific' : 'basic',
    );
    await historyRepository!.addEntry(item);
  }

  /// Switches active calculator mode.
  Future<void> setMode(CalculatorMode mode) async {
    _isFlushingImmediately = true;
    emit(state.copyWith(mode: mode));
    // Immediately flush session state on mode change
    await flushSession();
    _isFlushingImmediately = false;
  }

  /// Restores a previously saved in-progress session.
  /// Does NOT create duplicate history entries.
  Future<void> restoreSession() async {
    if (sessionRepository == null) return;
    try {
      final session = await sessionRepository!.loadSession();
      if (session != null) {
        _isRestoring = true;
        emit(session.toState());
        _isRestoring = false;
      }
    } catch (e) {
      debugPrint('CalculatorCubit: Failed to restore session: $e');
    }
  }

  /// Loads a calculation from history into active calculation state.
  /// Does NOT record another history entry.
  Future<void> reuseHistoryItem(HistoryItem item) async {
    _isFlushingImmediately = true;
    emit(
      state.copyWith(
        expression: item.expression,
        result: item.result,
        isResultComputed: true,
        clearError: true,
      ),
    );
    await flushSession();
    _isFlushingImmediately = false;
  }

  /// Immediately flushes any pending debounced session save.
  Future<void> flushSession() async {
    _debounceTimer?.cancel();
    if (sessionRepository != null && !_isRestoring) {
      await sessionRepository!.saveSession(CalculatorSession.fromState(state));
    }
  }

  @override
  void onChange(Change<CalculatorState> change) {
    super.onChange(change);
    if (!_isRestoring && !_isFlushingImmediately && sessionRepository != null) {
      _scheduleSaveSession(change.nextState);
    }
  }

  void _scheduleSaveSession(CalculatorState nextState) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      sessionRepository?.saveSession(CalculatorSession.fromState(nextState));
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
