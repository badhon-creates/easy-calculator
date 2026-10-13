import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/currency_calculator.dart';
import 'package:easy_calculator/features/currency_converter/presentation/cubit/currency_converter_state.dart';

/// Cubit managing currency conversion state, user input, rate fetching, and persistence.
class CurrencyConverterCubit extends Cubit<CurrencyConverterState> {
  CurrencyConverterCubit({required this.repository})
    : super(const CurrencyConverterState());

  final CurrencyRepository repository;
  Timer? _sessionSaveDebounce;

  /// Loads initial session, currencies, and exchange rates.
  Future<void> initialize() async {
    emit(
      state.copyWith(status: CurrencyConverterStatus.loading, clearError: true),
    );

    try {
      // 1. Restore session
      final session = await repository.getSession();

      // 2. Load currencies
      final currencies = await repository.getCurrencies();

      // Resolve source & target currencies
      final source = currencies.firstWhere(
        (c) => c.code.toUpperCase() == session.sourceCode.toUpperCase(),
        orElse: () => currencies.isNotEmpty
            ? currencies.firstWhere(
                (c) => c.code == 'USD',
                orElse: () => currencies.first,
              )
            : state.sourceCurrency,
      );

      final target = currencies.firstWhere(
        (c) => c.code.toUpperCase() == session.targetCode.toUpperCase(),
        orElse: () => currencies.isNotEmpty
            ? currencies.firstWhere(
                (c) => c.code == 'BDT',
                orElse: () =>
                    currencies.length > 1 ? currencies[1] : currencies.first,
              )
            : state.targetCurrency,
      );

      final amountInput = session.amountInput.isNotEmpty
          ? session.amountInput
          : '1';

      // 3. Load latest rates (from cache if available)
      final snapshot = await repository.getLatestRates(forceRefresh: false);

      final sourceAmount = CurrencyCalculator.parseInputAmount(amountInput);
      final result = CurrencyCalculator.convert(
        sourceAmount: sourceAmount,
        fromCode: source.code,
        toCode: target.code,
        snapshot: snapshot,
      );

      emit(
        state.copyWith(
          status: CurrencyConverterStatus.success,
          currencies: currencies,
          sourceCurrency: source,
          targetCurrency: target,
          amountInput: amountInput,
          snapshot: snapshot,
          conversionResult: result,
          clearError: true,
        ),
      );
    } catch (e) {
      // Still populate currencies if available
      List<Currency> fallbackCurrencies = [];
      try {
        fallbackCurrencies = await repository.getCurrencies();
      } catch (_) {}

      emit(
        state.copyWith(
          status: CurrencyConverterStatus.error,
          currencies: fallbackCurrencies.isNotEmpty
              ? fallbackCurrencies
              : state.currencies,
          errorMessage: 'Unable to load exchange rates: $e',
        ),
      );
    }
  }

  /// Manually refreshes rates from the network.
  Future<void> refreshRates() async {
    if (state.isRefreshing) return;

    emit(
      state.copyWith(
        status: CurrencyConverterStatus.refreshing,
        clearError: true,
      ),
    );

    try {
      final snapshot = await repository.getLatestRates(forceRefresh: true);
      final sourceAmount = CurrencyCalculator.parseInputAmount(
        state.amountInput,
      );
      final result = CurrencyCalculator.convert(
        sourceAmount: sourceAmount,
        fromCode: state.sourceCurrency.code,
        toCode: state.targetCurrency.code,
        snapshot: snapshot,
      );

      emit(
        state.copyWith(
          status: CurrencyConverterStatus.success,
          snapshot: snapshot,
          conversionResult: result,
          clearError: true,
        ),
      );
    } catch (e) {
      // Keep existing snapshot if present, but display error
      emit(
        state.copyWith(
          status: CurrencyConverterStatus.success,
          errorMessage: 'Refresh failed: $e. Using previous rates.',
        ),
      );
    }
  }

  /// Sets the source (From) currency.
  void setSourceCurrency(Currency currency) {
    if (state.sourceCurrency == currency) return;
    emit(state.copyWith(sourceCurrency: currency));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Sets the target (To) currency.
  void setTargetCurrency(Currency currency) {
    if (state.targetCurrency == currency) return;
    emit(state.copyWith(targetCurrency: currency));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Swaps source and target currencies and immediately recalculates.
  void swapCurrencies() {
    final oldSource = state.sourceCurrency;
    final oldTarget = state.targetCurrency;

    emit(state.copyWith(sourceCurrency: oldTarget, targetCurrency: oldSource));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Appends a digit (0-9) to the amount input.
  void appendDigit(String digit) {
    if (state.amountInput.length >= 15) return; // Prevent excessive input

    String newInput;
    if (state.amountInput == '0') {
      newInput = digit;
    } else {
      newInput = state.amountInput + digit;
    }

    emit(state.copyWith(amountInput: newInput));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Appends a decimal point if one is not already present.
  void appendDecimal() {
    if (state.amountInput.contains('.')) return;

    final newInput = state.amountInput.isEmpty ? '0.' : '${state.amountInput}.';
    emit(state.copyWith(amountInput: newInput));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Deletes the trailing character, resetting to '0' if empty.
  void deleteDigit() {
    if (state.amountInput.isEmpty || state.amountInput == '0') return;

    String newInput;
    if (state.amountInput.length == 1) {
      newInput = '0';
    } else {
      newInput = state.amountInput.substring(0, state.amountInput.length - 1);
      if (newInput.isEmpty) newInput = '0';
    }

    emit(state.copyWith(amountInput: newInput));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Clears the input, resetting to '0'.
  void clear() {
    emit(state.copyWith(amountInput: '0'));
    _recalculate();
    _scheduleSessionSave();
  }

  /// Recalculates conversion with current state.
  void _recalculate() {
    final snapshot = state.snapshot;
    final sourceAmount = CurrencyCalculator.parseInputAmount(state.amountInput);

    if (snapshot == null) {
      // If same currency, can convert even without snapshot
      if (state.sourceCurrency.code == state.targetCurrency.code) {
        emit(
          state.copyWith(
            conversionResult: CurrencyCalculator.convert(
              sourceAmount: sourceAmount,
              fromCode: state.sourceCurrency.code,
              toCode: state.targetCurrency.code,
              snapshot: ExchangeRatesSnapshot(
                baseCurrency: 'USD',
                date: DateTime.now().toIso8601String().substring(0, 10),
                rates: const <String, double>{},
                timestamp: DateTime.now(),
              ),
            ),
          ),
        );
      }
      return;
    }

    final result = CurrencyCalculator.convert(
      sourceAmount: sourceAmount,
      fromCode: state.sourceCurrency.code,
      toCode: state.targetCurrency.code,
      snapshot: snapshot,
    );

    emit(state.copyWith(conversionResult: result));
  }

  void _scheduleSessionSave() {
    _sessionSaveDebounce?.cancel();
    _sessionSaveDebounce = Timer(const Duration(milliseconds: 300), () {
      repository.saveSession(
        CurrencySession(
          sourceCode: state.sourceCurrency.code,
          targetCode: state.targetCurrency.code,
          amountInput: state.amountInput,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _sessionSaveDebounce?.cancel();
    return super.close();
  }
}
