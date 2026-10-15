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

/// Full-featured Currency Converter screen providing real-time conversions,
/// currency selection, exchange rate caching, offline fallback, and squircle keypad.
class CurrencyConverterScreen extends StatelessWidget {
  CurrencyConverterScreen({super.key, CurrencyRepository? repository})
    : repository =
          repository ??
          LocalCurrencyRepository(provider: FrankfurterExchangeRateProvider());

  final CurrencyRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CurrencyConverterCubit(repository: repository)..initialize(),
      child: const _CurrencyConverterView(),
    );
  }
}

class _CurrencyConverterView extends StatelessWidget {
  const _CurrencyConverterView();

  void _onReturnToCalculator(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
    final cubit = context.read<CurrencyConverterCubit>();

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
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

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
              'Convert',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [
              // Return to calculator button
              IconButton(
                icon: Icon(Icons.calculate_outlined, color: colors.textPrimary),
                tooltip: 'Return to Calculator',
                onPressed: () => _onReturnToCalculator(context),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: state.isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colors.operatorButton),
                      const SizedBox(height: 16),
                      Text(
                        'Loading currency exchange rates...',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: isLandscape
                        ? Row(
                            children: [
                              Expanded(
                                flex: 48,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 4),
                                      CurrencyCard(
                                        label: 'From',
                                        currency: state.sourceCurrency,
                                        amountText: state.amountInput,
                                        isSource: true,
                                        onSelectCurrency: () =>
                                            _selectSourceCurrency(
                                              context,
                                              cubit,
                                              state,
                                            ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Center(
                                            child: Material(
                                              color: colors.operatorButton,
                                              shape: const SquircleBorder(),
                                              elevation: 2,
                                              child: InkWell(
                                                customBorder:
                                                    const SquircleBorder(),
                                                onTap: cubit.swapCurrencies,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
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
                                      ),
                                      CurrencyCard(
                                        label: 'To',
                                        currency: state.targetCurrency,
                                        amountText:
                                            state
                                                .conversionResult
                                                ?.formattedTarget ??
                                            '—',
                                        isSource: false,
                                        onSelectCurrency: () =>
                                            _selectTargetCurrency(
                                              context,
                                              cubit,
                                              state,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
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
                                ),
                              ),
                              Container(
                                width: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 8.0,
                                ),
                                color:
                                    colors.numberButtonBorder !=
                                        Colors.transparent
                                    ? colors.numberButtonBorder
                                    : colors.textSecondary.withValues(
                                        alpha: 0.15,
                                      ),
                              ),
                              const Expanded(
                                flex: 52,
                                child: Center(
                                  child: ConverterKeypad(isLandscape: true),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Scrollable/flexible upper display cards
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 4),

                                      // Source (From) Card
                                      CurrencyCard(
                                        label: 'From',
                                        currency: state.sourceCurrency,
                                        amountText: state.amountInput,
                                        isSource: true,
                                        onSelectCurrency: () =>
                                            _selectSourceCurrency(
                                              context,
                                              cubit,
                                              state,
                                            ),
                                      ),

                                      // Swap button in between
                                      Transform.translate(
                                        offset: const Offset(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Center(
                                            child: Material(
                                              color: colors.operatorButton,
                                              shape: const SquircleBorder(),
                                              elevation: 2,
                                              child: InkWell(
                                                customBorder:
                                                    const SquircleBorder(),
                                                onTap: cubit.swapCurrencies,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
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
                                      ),

                                      // Target (To) Card
                                      CurrencyCard(
                                        label: 'To',
                                        currency: state.targetCurrency,
                                        amountText:
                                            state
                                                .conversionResult
                                                ?.formattedTarget ??
                                            '—',
                                        isSource: false,
                                        onSelectCurrency: () =>
                                            _selectTargetCurrency(
                                              context,
                                              cubit,
                                              state,
                                            ),
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
                                ),
                              ),

                              // Keypad Section
                              const ConverterKeypad(),
                              const SizedBox(height: 6),
                            ],
                          ),
                  ),
                ),
        );
      },
    );
  }
}
