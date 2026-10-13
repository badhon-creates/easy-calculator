import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/exchange_rate_provider.dart';

/// Exception thrown when the exchange rate provider encounters an error.
class CurrencyApiException implements Exception {
  const CurrencyApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'CurrencyApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Implementation of [ExchangeRateProvider] backed by the Frankfurter open API (v2 / v1).
class FrankfurterExchangeRateProvider implements ExchangeRateProvider {
  FrankfurterExchangeRateProvider({
    http.Client? client,
    this.baseUrl = 'https://api.frankfurter.dev/v2',
    this.timeout = const Duration(seconds: 8),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  @override
  Future<List<Currency>> fetchCurrencies() async {
    final uri = Uri.parse('$baseUrl/currencies');

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode != 200) {
        throw CurrencyApiException(
          'Failed to fetch currencies from provider.',
          statusCode: response.statusCode,
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Currency> currencies = [];

      if (decoded is List) {
        // v2 API format: [{"iso_code": "USD", "name": "...", "symbol": "..."}, ...]
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final currency = Currency.fromJson(item);
            if (currency.code.isNotEmpty) {
              currencies.add(currency);
            }
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        // v1 API format: {"USD": "United States Dollar", ...}
        for (final entry in decoded.entries) {
          final code = entry.key.toUpperCase();
          final name = entry.value.toString();
          currencies.add(
            Currency(
              code: code,
              name: name,
              symbol: _defaultSymbol(code),
              flag: Currency.flagForCode(code),
            ),
          );
        }
      }

      if (currencies.isEmpty) {
        return _fallbackCurrencies();
      }

      // Sort alphabetically by code
      currencies.sort((a, b) => a.code.compareTo(b.code));
      return currencies;
    } on SocketException catch (e) {
      throw CurrencyApiException('Network unavailable: ${e.message}');
    } on TimeoutException {
      throw const CurrencyApiException(
        'Connection timed out while fetching currencies.',
      );
    } on FormatException catch (e) {
      throw CurrencyApiException(
        'Invalid response from currency provider: ${e.message}',
      );
    } catch (e) {
      if (e is CurrencyApiException) rethrow;
      throw CurrencyApiException('Error fetching currencies: $e');
    }
  }

  @override
  Future<ExchangeRatesSnapshot> fetchLatestRates({String base = 'USD'}) async {
    final cleanBase = base.trim().toUpperCase();
    final uri = Uri.parse('$baseUrl/rates?base=$cleanBase');

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 404) {
        throw CurrencyApiException(
          'Base currency $cleanBase is not supported by the reference rates provider.',
          statusCode: 404,
        );
      }

      if (response.statusCode != 200) {
        throw CurrencyApiException(
          'Failed to fetch latest exchange rates.',
          statusCode: response.statusCode,
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final Map<String, double> rates = {cleanBase: 1.0};
      String publicationDate = '';

      if (decoded is List) {
        // v2 API format: [{"date": "2026-10-13", "base": "USD", "quote": "BDT", "rate": 123.16}, ...]
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final quote = item['quote']?.toString().toUpperCase();
            final rateVal = item['rate'];
            if (publicationDate.isEmpty && item['date'] != null) {
              publicationDate = item['date'].toString();
            }
            if (quote != null && rateVal is num) {
              rates[quote] = rateVal.toDouble();
            }
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        // v1 API format: {"amount": 1.0, "base": "USD", "date": "2026-10-13", "rates": {...}}
        publicationDate = (decoded['date'] ?? '').toString();
        final rawRates = decoded['rates'];
        if (rawRates is Map<String, dynamic>) {
          for (final entry in rawRates.entries) {
            final val = entry.value;
            if (val is num) {
              rates[entry.key.toUpperCase()] = val.toDouble();
            }
          }
        }
      }

      if (rates.isEmpty ||
          (rates.length == 1 && rates.containsKey(cleanBase))) {
        throw const CurrencyApiException(
          'No exchange rates returned by provider.',
        );
      }

      return ExchangeRatesSnapshot(
        baseCurrency: cleanBase,
        date: publicationDate.isNotEmpty
            ? publicationDate
            : DateTime.now().toIso8601String().substring(0, 10),
        rates: rates,
        timestamp: DateTime.now(),
        isCached: false,
      );
    } on SocketException catch (e) {
      throw CurrencyApiException('Network unavailable: ${e.message}');
    } on TimeoutException {
      throw const CurrencyApiException(
        'Connection timed out while fetching exchange rates.',
      );
    } on FormatException catch (e) {
      throw CurrencyApiException(
        'Malformed exchange rate data received: ${e.message}',
      );
    } catch (e) {
      if (e is CurrencyApiException) rethrow;
      throw CurrencyApiException('Error fetching rates: $e');
    }
  }

  /// Default symbol mapping for standard world currencies
  static String _defaultSymbol(String code) {
    switch (code) {
      case 'USD':
      case 'CAD':
      case 'AUD':
      case 'NZD':
      case 'SGD':
      case 'HKD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'BDT':
        return '৳';
      case 'INR':
        return '₹';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'CHF':
        return 'CHF';
      case 'KRW':
        return '₩';
      case 'TRY':
        return '₺';
      case 'BRL':
        return 'R\$';
      case 'RUB':
        return '₽';
      case 'THB':
        return '฿';
      case 'PHP':
        return '₱';
      case 'VND':
        return '₫';
      case 'MYR':
        return 'RM';
      case 'IDR':
        return 'Rp';
      case 'SAR':
      case 'AED':
        return 'د.إ';
      default:
        return code;
    }
  }

  /// Fallback curated list of major world currencies (guarantees offline availability)
  static List<Currency> _fallbackCurrencies() {
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
      Currency(
        code: 'CAD',
        name: 'Canadian Dollar',
        symbol: '\$',
        flag: '🇨🇦',
      ),
      Currency(
        code: 'AUD',
        name: 'Australian Dollar',
        symbol: '\$',
        flag: '🇦🇺',
      ),
      Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
      Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
      Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', flag: '🇨🇭'),
      Currency(
        code: 'SGD',
        name: 'Singapore Dollar',
        symbol: '\$',
        flag: '🇸🇬',
      ),
      Currency(
        code: 'MYR',
        name: 'Malaysian Ringgit',
        symbol: 'RM',
        flag: '🇲🇾',
      ),
      Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪'),
      Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦'),
    ];
  }
}
