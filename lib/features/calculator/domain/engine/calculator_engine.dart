import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/core/utils/number_formatter.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_evaluator.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_lexer.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_parser.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculation_result.dart';

/// Facade engine providing expression parsing, evaluation, and live preview.
class CalculatorEngine {
  const CalculatorEngine({
    this.lexer = const CalculatorLexer(),
    this.parser = const CalculatorParser(),
    this.evaluator = const CalculatorEvaluator(),
  });

  final CalculatorLexer lexer;
  final CalculatorParser parser;
  final CalculatorEvaluator evaluator;

  /// Evaluates an [expression] string and returns a [CalculationResult].
  CalculationResult evaluate(String expression) {
    try {
      final tokens = lexer.tokenize(expression);
      final rpn = parser.parseToRpn(tokens);
      final value = evaluator.evaluateRpn(rpn);
      final formatted = NumberFormatter.format(value);
      return CalculationResult.success(
        value: value,
        formattedResult: formatted,
      );
    } on CalculationException catch (e) {
      return CalculationResult.failure(e.message);
    } catch (_) {
      return const CalculationResult.failure('Invalid expression');
    }
  }

  /// Attempts to evaluate the expression live for preview.
  /// Returns null if the expression is incomplete or cannot be evaluated yet.
  CalculationResult? tryLiveEvaluate(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return null;

    // Do not attempt if ends with a binary operator
    final lastChar = trimmed[trimmed.length - 1];
    if (lastChar == '+' ||
        lastChar == '-' ||
        lastChar == '−' ||
        lastChar == '×' ||
        lastChar == '*' ||
        lastChar == '÷' ||
        lastChar == '/' ||
        lastChar == '(') {
      return null;
    }

    try {
      final tokens = lexer.tokenize(trimmed);
      final rpn = parser.parseToRpn(tokens);
      final value = evaluator.evaluateRpn(rpn);
      final formatted = NumberFormatter.format(value);
      return CalculationResult.success(
        value: value,
        formattedResult: formatted,
      );
    } catch (_) {
      return null;
    }
  }
}
