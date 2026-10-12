import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/core/utils/number_formatter.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_engine.dart';

void main() {
  late CalculatorEngine engine;

  setUp(() {
    engine = const CalculatorEngine();
  });

  group('CalculatorEngine - Basic Arithmetic', () {
    test('Addition of two integers', () {
      final result = engine.evaluate('43 + 43');
      expect(result.isSuccess, isTrue);
      expect(result.formattedResult, '86');
      expect(result.value, 86.0);
    });

    test('Subtraction', () {
      final result = engine.evaluate('100 − 42');
      expect(result.isSuccess, isTrue);
      expect(result.formattedResult, '58');
    });

    test('Standard minus character subtraction', () {
      final result = engine.evaluate('100 - 42');
      expect(result.isSuccess, isTrue);
      expect(result.formattedResult, '58');
    });

    test('Multiplication with × and *', () {
      expect(engine.evaluate('7 × 8').formattedResult, '56');
      expect(engine.evaluate('7 * 8').formattedResult, '56');
    });

    test('Division with ÷ and /', () {
      expect(engine.evaluate('45 ÷ 9').formattedResult, '5');
      expect(engine.evaluate('45 / 9').formattedResult, '5');
      expect(engine.evaluate('10 ÷ 4').formattedResult, '2.5');
    });
  });

  group('CalculatorEngine - Precedence & Associativity', () {
    test('Multiplication before addition', () {
      final result = engine.evaluate('2 + 3 × 4');
      expect(result.formattedResult, '14');
    });

    test('Division before subtraction', () {
      final result = engine.evaluate('20 − 10 ÷ 2');
      expect(result.formattedResult, '15');
    });

    test('Left-to-right evaluation for same precedence', () {
      final result = engine.evaluate('10 − 5 − 2');
      expect(result.formattedResult, '3');
      final divResult = engine.evaluate('24 ÷ 4 ÷ 2');
      expect(divResult.formattedResult, '3');
    });

    test('Exponents have higher precedence and right associativity', () {
      expect(engine.evaluate('2 + 3 ^ 2').formattedResult, '11');
      expect(
        engine.evaluate('2 ^ 3 ^ 2').formattedResult,
        '512',
      ); // 2^(3^2) = 2^9 = 512
    });
  });

  group('CalculatorEngine - Parentheses', () {
    test('Overriding precedence with parentheses', () {
      final result = engine.evaluate('(2 + 3) × 4');
      expect(result.formattedResult, '20');
    });

    test('Nested parentheses', () {
      final result = engine.evaluate('((2 + 3) × (4 + 1))');
      expect(result.formattedResult, '25');
    });

    test('Implicit multiplication with parentheses', () {
      expect(engine.evaluate('2(3 + 4)').formattedResult, '14');
      expect(engine.evaluate('(2 + 3)(4)').formattedResult, '20');
      expect(engine.evaluate('(2)(3)').formattedResult, '6');
    });

    test('Mismatched open parenthesis error', () {
      final result = engine.evaluate('(2 + 3');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('parentheses'));
    });

    test('Mismatched close parenthesis error', () {
      final result = engine.evaluate('2 + 3)');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('parentheses'));
    });
  });

  group('CalculatorEngine - Negative Numbers & Unary Minus', () {
    test('Leading unary minus', () {
      expect(engine.evaluate('-5 + 3').formattedResult, '-2');
      expect(engine.evaluate('−5 + 3').formattedResult, '-2');
    });

    test('Unary minus after operator', () {
      expect(engine.evaluate('5 × -3').formattedResult, '-15');
      expect(engine.evaluate('10 - -5').formattedResult, '15');
    });

    test('Unary minus inside parentheses', () {
      expect(engine.evaluate('(-5) × 3').formattedResult, '-15');
      expect(engine.evaluate('-(5 + 3)').formattedResult, '-8');
    });
  });

  group('CalculatorEngine - Decimals & Precision', () {
    test('Floating-point rounding avoids artifacts (0.1 + 0.2 = 0.3)', () {
      final result = engine.evaluate('0.1 + 0.2');
      expect(result.formattedResult, '0.3');
    });

    test('Leading decimal point without zero', () {
      expect(engine.evaluate('.5 × 4').formattedResult, '2');
    });

    test('Number with multiple decimal points is rejected', () {
      final result = engine.evaluate('1.2.3 + 4');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('decimal'));
    });
  });

  group('CalculatorEngine - Percentage', () {
    test('Standalone percentage evaluates to value / 100', () {
      expect(engine.evaluate('50%').formattedResult, '0.5');
      expect(engine.evaluate('25%').formattedResult, '0.25');
    });

    test('Multiplication with percentage', () {
      expect(engine.evaluate('200 × 15%').formattedResult, '30');
    });
  });

  group('CalculatorEngine - Errors & Edge Cases', () {
    test('Division by zero returns clean error', () {
      final result = engine.evaluate('10 ÷ 0');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'Cannot divide by zero');
    });

    test('Empty expression returns error', () {
      final result = engine.evaluate('');
      expect(result.isSuccess, isFalse);
    });

    test('Incomplete expression returns error', () {
      final result = engine.evaluate('5 +');
      expect(result.isSuccess, isFalse);
    });

    test('Live evaluation returns null for incomplete expressions', () {
      expect(engine.tryLiveEvaluate('5 +'), isNull);
      expect(engine.tryLiveEvaluate('('), isNull);
      expect(engine.tryLiveEvaluate('5 + 3')?.formattedResult, '8');
    });
  });

  group('NumberFormatter', () {
    test('Trims unnecessary trailing zeros', () {
      expect(NumberFormatter.format(5.0), '5');
      expect(NumberFormatter.format(5.100), '5.1');
      expect(NumberFormatter.format(-0.0), '0');
    });

    test('Formats very large numbers into scientific notation', () {
      expect(NumberFormatter.format(1e13), contains('e13'));
    });
  });
}
