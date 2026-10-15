import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_registry.dart';
import 'package:easy_calculator/features/units_converter/presentation/cubit/units_converter_cubit.dart';

void main() {
  group('UnitsConverterCubit Tests', () {
    late UnitsConverterCubit cubit;

    setUp(() {
      cubit = UnitsConverterCubit(initialCategory: UnitCategory.length);
    });

    tearDown(() {
      cubit.close();
    });

    test('Initializes with default length units and recalculates', () {
      expect(cubit.state.activeCategory, UnitCategory.length);
      expect(cubit.state.currentSourceUnit.id, 'meter');
      expect(cubit.state.currentTargetUnit.id, 'foot');
      expect(cubit.state.conversionResult, isNotNull);
      expect(cubit.state.conversionResult!.isValid, isTrue);
    });

    test('Appending digits and decimal updates amount and recalculates', () {
      cubit.clear();
      cubit.appendDigit('2');
      cubit.appendDigit('5');
      cubit.appendDecimal();
      cubit.appendDigit('4');

      expect(cubit.state.amountInput, '25.4');
      expect(cubit.state.conversionResult!.sourceValue, 25.4);
    });

    test('Swapping units inverts source and target and recalculates', () {
      final initialSrc = cubit.state.currentSourceUnit;
      final initialTgt = cubit.state.currentTargetUnit;

      cubit.swapUnits();

      expect(cubit.state.currentSourceUnit.id, initialTgt.id);
      expect(cubit.state.currentTargetUnit.id, initialSrc.id);
    });

    test('Category switching preserves remembered units per category', () {
      // Set length source to inch
      final inch = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'inch');
      cubit.setSourceUnit(inch);
      expect(cubit.state.currentSourceUnit.id, 'inch');

      // Switch to temperature
      cubit.selectCategory(UnitCategory.temperature);
      expect(cubit.state.activeCategory, UnitCategory.temperature);
      expect(cubit.state.currentSourceUnit.id, 'celsius');

      // Switch back to length - inch should be remembered!
      cubit.selectCategory(UnitCategory.length);
      expect(cubit.state.activeCategory, UnitCategory.length);
      expect(cubit.state.currentSourceUnit.id, 'inch');
    });

    test('Sign toggle only applies to temperature', () {
      // Length does not support negative
      cubit.clear();
      cubit.appendDigit('5');
      cubit.toggleSign();
      expect(cubit.state.amountInput, '5'); // Ignored for length

      // Switch to temperature
      cubit.selectCategory(UnitCategory.temperature);
      cubit.toggleSign();
      expect(cubit.state.amountInput, '-5');

      // Toggle back to positive
      cubit.toggleSign();
      expect(cubit.state.amountInput, '5');
    });

    test('Deleting digit removes character or resets to 0', () {
      cubit.clear();
      cubit.appendDigit('4');
      cubit.appendDigit('2');
      expect(cubit.state.amountInput, '42');

      cubit.deleteDigit();
      expect(cubit.state.amountInput, '4');

      cubit.deleteDigit();
      expect(cubit.state.amountInput, '0');
    });
  });
}
