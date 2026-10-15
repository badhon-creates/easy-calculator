import 'package:flutter/foundation.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_definition.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_converter_engine.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_registry.dart';

/// State representation for the multi-category Units Converter.
@immutable
class UnitsConverterState {
  const UnitsConverterState({
    this.activeCategory = UnitCategory.currency,
    this.selectedSourceUnits = const {},
    this.selectedTargetUnits = const {},
    this.amountInput = '1',
    this.conversionResult,
  });

  /// The currently active category tab.
  final UnitCategory activeCategory;

  /// Map of selected source units per category.
  final Map<UnitCategory, UnitDefinition> selectedSourceUnits;

  /// Map of selected target units per category.
  final Map<UnitCategory, UnitDefinition> selectedTargetUnits;

  /// User input text for amount.
  final String amountInput;

  /// The active unit conversion result (for non-currency categories).
  final UnitConversionResult? conversionResult;

  /// Returns the selected source unit for the current category.
  UnitDefinition get currentSourceUnit {
    return selectedSourceUnits[activeCategory] ??
        UnitRegistry.getDefaultSource(activeCategory);
  }

  /// Returns the selected target unit for the current category.
  UnitDefinition get currentTargetUnit {
    return selectedTargetUnits[activeCategory] ??
        UnitRegistry.getDefaultTarget(activeCategory);
  }

  UnitsConverterState copyWith({
    UnitCategory? activeCategory,
    Map<UnitCategory, UnitDefinition>? selectedSourceUnits,
    Map<UnitCategory, UnitDefinition>? selectedTargetUnits,
    String? amountInput,
    UnitConversionResult? conversionResult,
  }) {
    return UnitsConverterState(
      activeCategory: activeCategory ?? this.activeCategory,
      selectedSourceUnits: selectedSourceUnits ?? this.selectedSourceUnits,
      selectedTargetUnits: selectedTargetUnits ?? this.selectedTargetUnits,
      amountInput: amountInput ?? this.amountInput,
      conversionResult: conversionResult ?? this.conversionResult,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitsConverterState &&
          runtimeType == other.runtimeType &&
          activeCategory == other.activeCategory &&
          mapEquals(selectedSourceUnits, other.selectedSourceUnits) &&
          mapEquals(selectedTargetUnits, other.selectedTargetUnits) &&
          amountInput == other.amountInput &&
          conversionResult?.targetValue == other.conversionResult?.targetValue;

  @override
  int get hashCode =>
      Object.hash(activeCategory, amountInput, conversionResult?.targetValue);
}
