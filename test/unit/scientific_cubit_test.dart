import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';

void main() {
  group('CalculatorCubit - Scientific Features & State', () {
    late CalculatorCubit cubit;

    setUp(() {
      cubit = CalculatorCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test(
      'Mode switching: preserves expression and calculation across modes',
      () {
        cubit.appendDigit('1');
        cubit.appendDigit('5');
        cubit.appendOperator('+');
        cubit.appendDigit('2');
        cubit.appendDigit('5');
        expect(cubit.state.expression, '15 + 25');
        expect(cubit.state.result, '40');

        // Switch to Scientific
        cubit.setMode(CalculatorMode.scientific);
        expect(cubit.state.mode, CalculatorMode.scientific);
        expect(cubit.state.expression, '15 + 25');
        expect(cubit.state.result, '40');

        // Switch back to Basic
        cubit.setMode(CalculatorMode.basic);
        expect(cubit.state.mode, CalculatorMode.basic);
        expect(cubit.state.expression, '15 + 25');
        expect(cubit.state.result, '40');
      },
    );

    test(
      'AngleMode toggle: switches degrees/radians and updates evaluation',
      () {
        expect(cubit.state.angleMode, AngleMode.degrees);

        cubit.appendFunction('sin');
        cubit.appendDigit('3');
        cubit.appendDigit('0');
        cubit.appendParenthesis(')');
        cubit.calculateEquals();

        // In degrees: sin(30) = 0.5
        expect(cubit.state.result, '0.5');

        // Toggle to radians
        cubit.toggleAngleMode();
        expect(cubit.state.angleMode, AngleMode.radians);
        // Re-evaluated result in radians
        expect(cubit.state.result, isNotNull);
        expect(cubit.state.result, isNot('0.5'));

        // Toggle back to degrees
        cubit.toggleAngleMode();
        expect(cubit.state.angleMode, AngleMode.degrees);
        expect(cubit.state.result, '0.5');
      },
    );

    test(
      'Secondary toggle (2nd): activates and deactivates secondary state',
      () {
        expect(cubit.state.isSecondary, isFalse);

        cubit.toggleSecondary();
        expect(cubit.state.isSecondary, isTrue);

        cubit.toggleSecondary();
        expect(cubit.state.isSecondary, isFalse);
      },
    );

    test('Memory operations: m+, m-, mr, mc', () {
      expect(cubit.state.hasMemory, isFalse);
      expect(cubit.state.memoryValue, 0.0);

      // Enter 50 and add to memory
      cubit.appendDigit('5');
      cubit.appendDigit('0');
      cubit.memoryAdd();
      expect(cubit.state.hasMemory, isTrue);
      expect(cubit.state.memoryValue, 50.0);

      // Clear input and enter 20 to subtract from memory
      cubit.clear();
      cubit.appendDigit('2');
      cubit.appendDigit('0');
      cubit.memorySubtract();
      expect(cubit.state.memoryValue, 30.0);

      // Clear screen and recall memory
      cubit.clear();
      cubit.memoryRecall();
      expect(cubit.state.expression, '30');

      // Clear memory register
      cubit.memoryClear();
      expect(cubit.state.hasMemory, isFalse);
      expect(cubit.state.memoryValue, 0.0);
    });

    test('Parentheses input: evaluates expression with nested parentheses', () {
      cubit.appendDigit('2');
      cubit.appendOperator('×');
      cubit.appendParenthesis('(');
      cubit.appendDigit('3');
      cubit.appendOperator('+');
      cubit.appendDigit('4');
      cubit.appendParenthesis(')');
      cubit.calculateEquals();

      // 2 * (3 + 4) = 14
      expect(cubit.state.result, '14');
    });

    test('Powers & roots input: calculates 2^4 and square root', () {
      cubit.appendDigit('2');
      cubit.appendPower('^4');
      cubit.calculateEquals();
      expect(cubit.state.result, '16');

      cubit.clear();
      cubit.appendRoot('²√');
      cubit.appendDigit('6');
      cubit.appendDigit('4');
      cubit.appendParenthesis(')');
      cubit.calculateEquals();
      expect(cubit.state.result, '8');
    });

    test('Scientific notation input (EE)', () {
      cubit.appendDigit('5');
      cubit.appendScientificNotation();
      cubit.appendDigit('3');
      cubit.calculateEquals();
      expect(cubit.state.result, '5000');
    });

    test('Random number input', () {
      cubit.appendRandom(0.42);
      expect(cubit.state.expression, '0.42');
    });

    test('Backspace removes entire function prefix (e.g. sin()', () {
      cubit.appendFunction('sin');
      expect(cubit.state.expression, 'sin(');

      cubit.backspace();
      expect(cubit.state.expression, '');
    });
  });
}
