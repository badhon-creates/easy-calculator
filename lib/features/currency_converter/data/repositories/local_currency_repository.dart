import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/exchange_rate_provider.dart';

/// Concrete [CurrencyRepository] providing local-first caching in app-private storage.
class LocalCurrencyRepository implements CurrencyRepository {
  LocalCurrencyRepository({
    required this.provider,
    Future<Directory> Function()? getDirectory,
    this.currenciesCacheFileName = 'currencies_cache.json',
    this.ratesCacheFileName = 'rates_cache.json',
    this.sessionFileName = 'currency_session.json',
  }) : _getDirectory = getDirectory ?? getApplicationSupportDirectory;

  final ExchangeRateProvider provider;
  final Future<Directory> Function() _getDirectory;
  final String currenciesCacheFileName;
  final String ratesCacheFileName;
  final String sessionFileName;

  List<Currency>? _memoryCurrencies;
  ExchangeRatesSnapshot? _memorySnapshot;

  Future<File> _getFile(String fileName) async {
    final dir = await _getDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(dir.path, fileName));
  }

  @override
  Future<List<Currency>> getCurrencies() async {
    if (_memoryCurrencies != null && _memoryCurrencies!.isNotEmpty) {
      return _memoryCurrencies!;
    }

    // Try reading disk cache
    try {
      final file = await _getFile(currenciesCacheFileName);
      if (await file.exists()) {
        final content = await file.readAsString();
        final dynamic decoded = jsonDecode(content);
        if (decoded is List) {
          final cached = decoded
              .whereType<Map<String, dynamic>>()
              .map(Currency.fromJson)
              .where((c) => c.code.isNotEmpty)
              .toList();
          if (cached.isNotEmpty) {
            _memoryCurrencies = cached;
            return cached;
          }
        }
      }
    } catch (e) {
      debugPrint(
        'LocalCurrencyRepository: Cache read failed for currencies: $e',
      );
    }

    // Fetch from provider
    try {
      final fetched = await provider.fetchCurrencies();
      if (fetched.isNotEmpty) {
        _memoryCurrencies = fetched;
        await _saveCurrenciesCache(fetched);
        return fetched;
      }
    } catch (e) {
      debugPrint(
        'LocalCurrencyRepository: Provider fetch failed for currencies: $e',
      );
    }

    // If both failed, return fallback
    return const [
      Currency(
        code: 'USD',
        name: 'United States Dollar',
        symbol: '\$',
        flag: '🇺🇸',
      ),
      Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
      Currency(
        code: 'BDT',
        name: 'Bangladeshi Taka',
        symbol: '৳',
        flag: '🇧🇩',
      ),
      Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
      Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    ];
  }

  Future<void> _saveCurrenciesCache(List<Currency> currencies) async {
    try {
      final file = await _getFile(currenciesCacheFileName);
      final jsonList = currencies.map((c) => c.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList), flush: true);
    } catch (e) {
      debugPrint(
        'LocalCurrencyRepository: Failed to save currencies cache: $e',
      );
    }
  }

  @override
  Future<ExchangeRatesSnapshot> getLatestRates({
    bool forceRefresh = false,
  }) async {
    // If not forcing refresh, check memory snapshot first
    if (!forceRefresh && _memorySnapshot != null) {
      return _memorySnapshot!;
    }

    // If not forcing refresh, check disk cache
    if (!forceRefresh) {
      final cached = await _loadRatesCache();
      if (cached != null) {
        _memorySnapshot = cached.copyWith(isCached: true);
        return _memorySnapshot!;
      }
    }

    // Attempt live fetch from provider
    try {
      final liveSnapshot = await provider.fetchLatestRates(base: 'USD');
      _memorySnapshot = liveSnapshot;
      await _saveRatesCache(liveSnapshot);
      return liveSnapshot;
    } catch (networkError) {
      debugPrint(
        'LocalCurrencyRepository: Live fetch failed, attempting cached fallback: $networkError',
      );
      // On live fetch failure, check disk cache as fallback
      final cached = await _loadRatesCache();
      if (cached != null) {
        _memorySnapshot = cached.copyWith(isCached: true);
        return _memorySnapshot!;
      }
      // If neither live nor cached is available, rethrow
      rethrow;
    }
  }

  Future<ExchangeRatesSnapshot?> _loadRatesCache() async {
    try {
      final file = await _getFile(ratesCacheFileName);
      if (await file.exists()) {
        final content = await file.readAsString();
        final dynamic decoded = jsonDecode(content);
        if (decoded is Map<String, dynamic>) {
          return ExchangeRatesSnapshot.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('LocalCurrencyRepository: Failed to load rates cache: $e');
    }
    return null;
  }

  Future<void> _saveRatesCache(ExchangeRatesSnapshot snapshot) async {
    try {
      final file = await _getFile(ratesCacheFileName);
      await file.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
    } catch (e) {
      debugPrint('LocalCurrencyRepository: Failed to save rates cache: $e');
    }
  }

  @override
  Future<CurrencySession> getSession() async {
    try {
      final file = await _getFile(sessionFileName);
      if (await file.exists()) {
        final content = await file.readAsString();
        final dynamic decoded = jsonDecode(content);
        if (decoded is Map<String, dynamic>) {
          return CurrencySession.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('LocalCurrencyRepository: Failed to restore session: $e');
    }
    return const CurrencySession();
  }

  @override
  Future<void> saveSession(CurrencySession session) async {
    try {
      final file = await _getFile(sessionFileName);
      await file.writeAsString(jsonEncode(session.toJson()), flush: true);
    } catch (e) {
      debugPrint('LocalCurrencyRepository: Failed to persist session: $e');
    }
  }
}
