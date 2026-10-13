import 'package:easy_calculator/features/currency_converter/domain/models/conversion_result.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';

enum CurrencyConverterStatus { initial, loading, success, refreshing, error }

class CurrencyConverterState {
  const CurrencyConverterState({
    this.status = CurrencyConverterStatus.initial,
    this.currencies = const [],
    this.sourceCurrency = const Currency(
      code: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      flag: '🇺🇸',
    ),
    this.targetCurrency = const Currency(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      flag: '🇧🇩',
    ),
    this.amountInput = '1',
    this.snapshot,
    this.conversionResult,
    this.errorMessage,
  });

  final CurrencyConverterStatus status;
  final List<Currency> currencies;
  final Currency sourceCurrency;
  final Currency targetCurrency;
  final String amountInput;
  final ExchangeRatesSnapshot? snapshot;
  final ConversionResult? conversionResult;
  final String? errorMessage;

  bool get isLoading => status == CurrencyConverterStatus.loading;
  bool get isRefreshing => status == CurrencyConverterStatus.refreshing;
  bool get hasError => status == CurrencyConverterStatus.error;

  CurrencyConverterState copyWith({
    CurrencyConverterStatus? status,
    List<Currency>? currencies,
    Currency? sourceCurrency,
    Currency? targetCurrency,
    String? amountInput,
    ExchangeRatesSnapshot? snapshot,
    ConversionResult? conversionResult,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CurrencyConverterState(
      status: status ?? this.status,
      currencies: currencies ?? this.currencies,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      amountInput: amountInput ?? this.amountInput,
      snapshot: snapshot ?? this.snapshot,
      conversionResult: conversionResult ?? this.conversionResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
