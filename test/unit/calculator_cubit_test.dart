import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';

void main() {
  late CalculatorCubit cubit;

  setUp(() {
    cubit = CalculatorCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('CalculatorCubit - Basic Operations', () {
    test('Initial state is empty', () {
      expect(cubit.state.expression, '');
      expect(cubit.state.result, isNull);
      expect(cubit.state.isResultComputed, isFalse);
    });

    test('Appending digits updates expression and live preview', () {
      cubit.appendDigit('1');
      cubit.appendDigit('2');
      expect(cubit.state.expression, '12');
    });

    test('Calculation on equals produces correct result', () {
      cubit.appendDigit('4');
      cubit.appendDigit('3');
      cubit.appendOperator('+');
      cubit.appendDigit('4');
      cubit.appendDigit('3');
      cubit.calculateEquals();

      expect(cubit.state.isResultComputed, isTrue);
      expect(cubit.state.result, '86');
      expect(cubit.state.errorMessage, isNull);
    });

    test('Post-result rule: Tapping operator continues from result', () {
      cubit.appendDigit('4');
      cubit.appendDigit('3');
      cubit.appendOperator('+');
      cubit.appendDigit('4');
      cubit.appendDigit('3');
      cubit.calculateEquals();

      // Now tap '+'
      cubit.appendOperator('+');
      expect(cubit.state.expression, '86 + ');
      expect(cubit.state.isResultComputed, isFalse);
    });

    test('Post-result rule: Tapping digit starts a fresh calculation', () {
      cubit.appendDigit('5');
      cubit.appendOperator('×');
      cubit.appendDigit('5');
      cubit.calculateEquals();
      expect(cubit.state.result, '25');

      // Now tap digit '7'
      cubit.appendDigit('7');
      expect(cubit.state.expression, '7');
      expect(cubit.state.isResultComputed, isFalse);
      expect(cubit.state.result, isNull);
    });

    test('Operator replacement when consecutive operators entered', () {
      cubit.appendDigit('8');
      cubit.appendOperator('+');
      expect(cubit.state.expression, '8 + ');

      cubit.appendOperator('×');
      expect(cubit.state.expression, '8 × ');
    });

    test('Decimal point prevents multiple points in same number', () {
      cubit.appendDigit('3');
      cubit.appendDecimal();
      cubit.appendDigit('1');
      cubit.appendDecimal(); // Should be ignored
      cubit.appendDigit('4');
      expect(cubit.state.expression, '3.14');
    });

    test('Toggle sign negates single number', () {
      cubit.appendDigit('4');
      cubit.appendDigit('2');
      cubit.toggleSign();
      expect(cubit.state.expression, '−42');

      cubit.toggleSign();
      expect(cubit.state.expression, '42');
    });

    test('Backspace removes last character', () {
      cubit.appendDigit('1');
      cubit.appendDigit('2');
      cubit.appendDigit('3');
      cubit.backspace();
      expect(cubit.state.expression, '12');
    });

    test('Clear resets calculator to empty state', () {
      cubit.appendDigit('9');
      cubit.appendOperator('+');
      cubit.appendDigit('1');
      cubit.clear();
      expect(cubit.state.expression, '');
      expect(cubit.state.result, isNull);
      expect(cubit.state.isResultComputed, isFalse);
    });

    test('Division by zero displays error state gracefully', () {
      cubit.appendDigit('7');
      cubit.appendOperator('÷');
      cubit.appendDigit('0');
      cubit.calculateEquals();

      expect(cubit.state.errorMessage, 'Cannot divide by zero');
      expect(cubit.state.isResultComputed, isFalse);
    });
  });
}
