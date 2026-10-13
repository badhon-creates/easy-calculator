import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';

/// Repository contract managing currency directory, exchange rate caching, and session persistence.
abstract class CurrencyRepository {
  /// Returns the available currencies, loading from cache or fetching live if cache is empty.
  Future<List<Currency>> getCurrencies();

  /// Returns the latest exchange rates snapshot.
  ///
  /// If [forceRefresh] is false and a valid cache exists, cached rates are returned.
  /// If [forceRefresh] is true or cache is missing, attempts live network fetch and caches the result.
  /// If network fails during [forceRefresh], returns cached data if available, throwing only if no cache exists.
  Future<ExchangeRatesSnapshot> getLatestRates({bool forceRefresh = false});

  /// Retrieves the persisted session state (source currency, target currency, amount input).
  Future<CurrencySession> getSession();

  /// Persists the active session state.
  Future<void> saveSession(CurrencySession session);
}
