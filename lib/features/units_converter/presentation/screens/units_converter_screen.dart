import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/core/theme/squircle_border.dart';
import 'package:easy_calculator/features/currency_converter/data/providers/frankfurter_exchange_rate_provider.dart';
import 'package:easy_calculator/features/currency_converter/data/repositories/local_currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/presentation/cubit/currency_converter_cubit.dart';
import 'package:easy_calculator/features/currency_converter/presentation/cubit/currency_converter_state.dart';
import 'package:easy_calculator/features/currency_converter/presentation/widgets/converter_keypad.dart';
import 'package:easy_calculator/features/currency_converter/presentation/widgets/currency_card.dart';
import 'package:easy_calculator/features/currency_converter/presentation/widgets/currency_selection_modal.dart';
import 'package:easy_calculator/features/currency_converter/presentation/widgets/rate_info_banner.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/presentation/cubit/units_converter_cubit.dart';
import 'package:easy_calculator/features/units_converter/presentation/cubit/units_converter_state.dart';
import 'package:easy_calculator/features/units_converter/presentation/widgets/category_selector_bar.dart';
import 'package:easy_calculator/features/units_converter/presentation/widgets/unit_card.dart';
import 'package:easy_calculator/features/units_converter/presentation/widgets/unit_formula_banner.dart';
import 'package:easy_calculator/features/units_converter/presentation/widgets/unit_keypad.dart';
import 'package:easy_calculator/features/units_converter/presentation/widgets/unit_selection_modal.dart';

/// Full-featured multi-category Units Converter screen.
/// Implements all 15 conversion categories while seamlessly preserving Phase 6 Currency Converter.
class UnitsConverterScreen extends StatelessWidget {
  UnitsConverterScreen({
    super.key,
    this.initialCategory = UnitCategory.currency,
    CurrencyRepository? currencyRepository,
  }) : currencyRepository =
           currencyRepository ??
           LocalCurrencyRepository(provider: FrankfurterExchangeRateProvider());

  final UnitCategory initialCategory;
  final CurrencyRepository currencyRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UnitsConverterCubit(initialCategory: initialCategory),
        ),
        BlocProvider(
          create: (context) =>
              CurrencyConverterCubit(repository: currencyRepository)
                ..initialize(),
        ),
      ],
      child: const _UnitsConverterView(),
    );
  }
}

class _UnitsConverterView extends StatelessWidget {
  const _UnitsConverterView();

  void _onReturnToCalculator(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _selectSourceUnit(
    BuildContext context,
    UnitsConverterCubit cubit,
    UnitsConverterState state,
  ) async {
    final selected = await UnitSelectionModal.show(
      context,
      category: state.activeCategory,
      selectedUnit: state.currentSourceUnit,
      title: 'Select From Unit',
    );
    if (selected != null) {
      cubit.setSourceUnit(selected);
    }
  }

  Future<void> _selectTargetUnit(
    BuildContext context,
    UnitsConverterCubit cubit,
    UnitsConverterState state,
  ) async {
    final selected = await UnitSelectionModal.show(
      context,
      category: state.activeCategory,
      selectedUnit: state.currentTargetUnit,
      title: 'Select To Unit',
    );
    if (selected != null) {
      cubit.setTargetUnit(selected);
    }
  }

  Future<void> _selectSourceCurrency(
    BuildContext context,
    CurrencyConverterCubit cubit,
    CurrencyConverterState state,
  ) async {
    final selected = await CurrencySelectionModal.show(
      context,
      currencies: state.currencies,
      selectedCurrency: state.sourceCurrency,
      title: 'Select Source Currency',
    );
    if (selected != null) {
      cubit.setSourceCurrency(selected);
    }
  }

  Future<void> _selectTargetCurrency(
    BuildContext context,
    CurrencyConverterCubit cubit,
    CurrencyConverterState state,
  ) async {
    final selected = await CurrencySelectionModal.show(
      context,
      currencies: state.currencies,
      selectedCurrency: state.targetCurrency,
      title: 'Select Target Currency',
    );
    if (selected != null) {
      cubit.setTargetCurrency(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final unitsCubit = context.read<UnitsConverterCubit>();
    final currencyCubit = context.read<CurrencyConverterCubit>();

    return BlocBuilder<UnitsConverterCubit, UnitsConverterState>(
      builder: (context, unitsState) {
        final isCurrency = unitsState.activeCategory == UnitCategory.currency;

        return Scaffold(
          backgroundColor: colors.backgroundColor,
          appBar: AppBar(
            backgroundColor: colors.backgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Units',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.calculate_outlined, color: colors.textPrimary),
                tooltip: 'Return to Calculator',
                onPressed: () => _onReturnToCalculator(context),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  // Horizontal Category Selector Tab Bar
                  CategorySelectorBar(
                    activeCategory: unitsState.activeCategory,
                    onSelectCategory: unitsCubit.selectCategory,
                  ),
                  const SizedBox(height: 10),

                  // Content Area
                  Expanded(
                    child: isCurrency
                        ? _buildCurrencyContent(context, currencyCubit)
                        : _buildUnitsContent(context, unitsCubit, unitsState),
                  ),

                  // Keypad Section
                  isCurrency ? const ConverterKeypad() : const UnitKeypad(),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitsContent(
    BuildContext context,
    UnitsConverterCubit cubit,
    UnitsConverterState state,
  ) {
    final colors = context.calcColors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Source (From) Unit Card
          UnitCard(
            label: 'From',
            unit: state.currentSourceUnit,
            amountText: state.amountInput,
            isSource: true,
            onSelectUnit: () => _selectSourceUnit(context, cubit, state),
          ),

          // Swap button in between
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Center(
              child: Material(
                color: colors.operatorButton,
                shape: const SquircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const SquircleBorder(),
                  onTap: cubit.swapUnits,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: colors.operatorText,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Target (To) Unit Card
          UnitCard(
            label: 'To',
            unit: state.currentTargetUnit,
            amountText: state.conversionResult?.formattedTarget ?? '—',
            isSource: false,
            onSelectUnit: () => _selectTargetUnit(context, cubit, state),
          ),

          const SizedBox(height: 10),

          // Formula / Relationship banner
          UnitFormulaBanner(result: state.conversionResult),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildCurrencyContent(
    BuildContext context,
    CurrencyConverterCubit cubit,
  ) {
    final colors = context.calcColors;

    return BlocConsumer<CurrencyConverterCubit, CurrencyConverterState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: colors.operatorButton),
                const SizedBox(height: 16),
                Text(
                  'Loading currency exchange rates...',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Source (From) Card
              CurrencyCard(
                label: 'From',
                currency: state.sourceCurrency,
                amountText: state.amountInput,
                isSource: true,
                onSelectCurrency: () =>
                    _selectSourceCurrency(context, cubit, state),
              ),

              // Swap button in between
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: Material(
                    color: colors.operatorButton,
                    shape: const SquircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const SquircleBorder(),
                      onTap: cubit.swapCurrencies,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: colors.operatorText,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Target (To) Card
              CurrencyCard(
                label: 'To',
                currency: state.targetCurrency,
                amountText: state.conversionResult?.formattedTarget ?? '—',
                isSource: false,
                onSelectCurrency: () =>
                    _selectTargetCurrency(context, cubit, state),
              ),

              const SizedBox(height: 10),

              // Rate Info Banner
              RateInfoBanner(
                sourceCurrency: state.sourceCurrency,
                targetCurrency: state.targetCurrency,
                result: state.conversionResult,
                snapshot: state.snapshot,
                onRefresh: cubit.refreshRates,
                isRefreshing: state.isRefreshing,
              ),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}
