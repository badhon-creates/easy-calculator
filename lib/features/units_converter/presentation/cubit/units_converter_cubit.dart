import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_definition.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_converter_engine.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_registry.dart';
import 'package:easy_calculator/features/units_converter/presentation/cubit/units_converter_state.dart';

/// Cubit managing multi-category unit conversions, category selection, and amount entry.
class UnitsConverterCubit extends Cubit<UnitsConverterState> {
  UnitsConverterCubit({UnitCategory initialCategory = UnitCategory.currency})
    : super(UnitsConverterState(activeCategory: initialCategory)) {
    _initializeDefaults();
  }

  void _initializeDefaults() {
    final sources = <UnitCategory, UnitDefinition>{};
    final targets = <UnitCategory, UnitDefinition>{};

    for (final cat in UnitCategory.values) {
      if (cat == UnitCategory.currency) continue;
      sources[cat] = UnitRegistry.getDefaultSource(cat);
      targets[cat] = UnitRegistry.getDefaultTarget(cat);
    }

    emit(
      state.copyWith(
        selectedSourceUnits: sources,
        selectedTargetUnits: targets,
      ),
    );

    _recalculate();
  }

  /// Switches active category tab.
  void selectCategory(UnitCategory category) {
    if (state.activeCategory == category) return;

    // Reset amount to '0' if it had a negative sign but new category does not support negatives
    var amount = state.amountInput;
    if (amount.startsWith('-') && !category.supportsNegative) {
      amount = amount.replaceFirst('-', '');
      if (amount.isEmpty) amount = '0';
    }

    emit(state.copyWith(activeCategory: category, amountInput: amount));
    _recalculate();
  }

  /// Sets source unit for the currently active category.
  void setSourceUnit(UnitDefinition unit) {
    final updatedSources = Map<UnitCategory, UnitDefinition>.from(
      state.selectedSourceUnits,
    );
    updatedSources[state.activeCategory] = unit;

    emit(state.copyWith(selectedSourceUnits: updatedSources));
    _recalculate();
  }

  /// Sets target unit for the currently active category.
  void setTargetUnit(UnitDefinition unit) {
    final updatedTargets = Map<UnitCategory, UnitDefinition>.from(
      state.selectedTargetUnits,
    );
    updatedTargets[state.activeCategory] = unit;

    emit(state.copyWith(selectedTargetUnits: updatedTargets));
    _recalculate();
  }

  /// Swaps source and target units for the currently active category.
  void swapUnits() {
    final currentSrc = state.currentSourceUnit;
    final currentTgt = state.currentTargetUnit;

    final updatedSources = Map<UnitCategory, UnitDefinition>.from(
      state.selectedSourceUnits,
    );
    final updatedTargets = Map<UnitCategory, UnitDefinition>.from(
      state.selectedTargetUnits,
    );

    updatedSources[state.activeCategory] = currentTgt;
    updatedTargets[state.activeCategory] = currentSrc;

    emit(
      state.copyWith(
        selectedSourceUnits: updatedSources,
        selectedTargetUnits: updatedTargets,
      ),
    );
    _recalculate();
  }

  /// Appends digit (0-9).
  void appendDigit(String digit) {
    if (state.amountInput.length >= 15) return;

    String newInput;
    if (state.amountInput == '0') {
      newInput = digit;
    } else if (state.amountInput == '-0') {
      newInput = '-$digit';
    } else {
      newInput = state.amountInput + digit;
    }

    emit(state.copyWith(amountInput: newInput));
    _recalculate();
  }

  /// Appends a decimal point.
  void appendDecimal() {
    if (state.amountInput.contains('.')) return;

    final newInput = state.amountInput.isEmpty ? '0.' : '${state.amountInput}.';
    emit(state.copyWith(amountInput: newInput));
    _recalculate();
  }

  /// Toggles sign for categories that support negative numbers (e.g. Temperature).
  void toggleSign() {
    if (!state.activeCategory.supportsNegative) return;

    String newInput;
    if (state.amountInput.startsWith('-')) {
      newInput = state.amountInput.substring(1);
      if (newInput.isEmpty) newInput = '0';
    } else {
      newInput = '-${state.amountInput}';
    }

    emit(state.copyWith(amountInput: newInput));
    _recalculate();
  }

  /// Deletes trailing digit.
  void deleteDigit() {
    if (state.amountInput.isEmpty || state.amountInput == '0') return;

    String newInput;
    if (state.amountInput.length == 1 ||
        (state.amountInput.length == 2 && state.amountInput.startsWith('-'))) {
      newInput = '0';
    } else {
      newInput = state.amountInput.substring(0, state.amountInput.length - 1);
      if (newInput.isEmpty || newInput == '-') newInput = '0';
    }

    emit(state.copyWith(amountInput: newInput));
    _recalculate();
  }

  /// Clears the input to '0'.
  void clear() {
    emit(state.copyWith(amountInput: '0'));
    _recalculate();
  }

  void _recalculate() {
    if (state.activeCategory == UnitCategory.currency) return;

    final val = UnitConverterEngine.parseInputAmount(state.amountInput);
    final result = UnitConverterEngine.convert(
      sourceValue: val,
      from: state.currentSourceUnit,
      to: state.currentTargetUnit,
    );

    emit(state.copyWith(conversionResult: result));
  }
}
