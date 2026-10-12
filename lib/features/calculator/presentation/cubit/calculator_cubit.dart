import 'package:bloc/bloc.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_engine.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';

/// Cubit managing calculator input, evaluation, and mode state.
class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({CalculatorEngine? engine})
    : _engine = engine ?? const CalculatorEngine(),
      super(const CalculatorState());

  final CalculatorEngine _engine;

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
    final live = _engine.tryLiveEvaluate(newExpr);
    emit(
      state.copyWith(
        expression: newExpr,
        result: live?.formattedResult,
        clearResult: live == null,
        clearError: true,
      ),
    );
  }

  /// Appends or replaces an operator ('+', '−', '×', '÷').
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
        lastChar == '/') {
      // Replace the trailing operator
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
      return; // Prevent multiple decimal points in a single number
    }

    emit(state.copyWith(expression: '$expr.', clearError: true));
  }

  /// Appends a percentage sign ('%').
  void appendPercent() {
    if (state.isResultComputed && state.result != null) {
      final newExpr = '${state.result}%';
      final calc = _engine.evaluate(newExpr);
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
    if (RegExp(r'[0-9)πe]').hasMatch(lastChar)) {
      final newExpr = '$trimmed%';
      final live = _engine.tryLiveEvaluate(newExpr);
      emit(
        state.copyWith(
          expression: newExpr,
          result: live?.formattedResult,
          clearError: true,
        ),
      );
    }
  }

  /// Toggles positive/negative sign ('±') on the current number or result.
  void toggleSign() {
    if (state.isResultComputed && state.result != null) {
      final val = double.tryParse(state.result!);
      if (val != null) {
        final negated = (-val);
        final formatted = negated.toInt() == negated
            ? negated.toInt().toString()
            : negated.toString();
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
      newExpr = newExpr.substring(0, newExpr.length - 1).trimRight();
    }

    final live = _engine.tryLiveEvaluate(newExpr);
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
    emit(const CalculatorState());
  }

  /// Finalizes the calculation on equals ('=').
  void calculateEquals() {
    final expr = state.expression.trim();
    if (expr.isEmpty) return;

    final evalResult = _engine.evaluate(expr);
    if (evalResult.isSuccess) {
      emit(
        state.copyWith(
          result: evalResult.formattedResult,
          isResultComputed: true,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          errorMessage: evalResult.errorMessage ?? 'Error',
          isResultComputed: false,
        ),
      );
    }
  }

  /// Switches active calculator mode.
  void setMode(CalculatorMode mode) {
    emit(state.copyWith(mode: mode));
  }
}
