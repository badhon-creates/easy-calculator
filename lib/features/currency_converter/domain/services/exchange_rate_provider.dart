import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';

/// Abstract contract for fetching currency and exchange rate data from an external provider.
abstract class ExchangeRateProvider {
  /// Fetches the list of all currencies supported by the provider.
  Future<List<Currency>> fetchCurrencies();

  /// Fetches the latest exchange rates against the given [base] currency code.
  Future<ExchangeRatesSnapshot> fetchLatestRates({String base = 'USD'});
}
