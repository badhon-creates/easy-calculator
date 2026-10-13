import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:easy_calculator/features/currency_converter/data/providers/frankfurter_exchange_rate_provider.dart';

void main() {
  group('FrankfurterExchangeRateProvider', () {
    test('fetchCurrencies parses v2 JSON array response correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/currencies'));
        return http.Response(
          jsonEncode([
            {'iso_code': 'USD', 'name': 'United States Dollar', 'symbol': '\$'},
            {'iso_code': 'BDT', 'name': 'Bangladeshi Taka', 'symbol': '৳'},
            {'iso_code': 'EUR', 'name': 'Euro', 'symbol': '€'},
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = FrankfurterExchangeRateProvider(client: mockClient);
      final currencies = await provider.fetchCurrencies();

      expect(currencies.length, equals(3));
      // Currencies should be sorted alphabetically by code
      expect(currencies[0].code, equals('BDT'));
      expect(currencies[0].symbol, equals('৳'));
      expect(currencies[0].flag, equals('🇧🇩'));
      expect(currencies[1].code, equals('EUR'));
      expect(currencies[2].code, equals('USD'));
    });

    test('fetchCurrencies parses v1 JSON map response as fallback', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'USD': 'United States Dollar', 'EUR': 'Euro'}),
          200,
        );
      });

      final provider = FrankfurterExchangeRateProvider(client: mockClient);
      final currencies = await provider.fetchCurrencies();

      expect(currencies.length, equals(2));
      expect(currencies[0].code, equals('EUR'));
      expect(currencies[1].code, equals('USD'));
    });

    test('fetchLatestRates parses v2 JSON array response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['base'], equals('USD'));
        return http.Response(
          jsonEncode([
            {
              'date': '2026-10-13',
              'base': 'USD',
              'quote': 'BDT',
              'rate': 123.16,
            },
            {
              'date': '2026-10-13',
              'base': 'USD',
              'quote': 'EUR',
              'rate': 0.89335,
            },
          ]),
          200,
        );
      });

      final provider = FrankfurterExchangeRateProvider(client: mockClient);
      final snapshot = await provider.fetchLatestRates(base: 'USD');

      expect(snapshot.baseCurrency, equals('USD'));
      expect(snapshot.date, equals('2026-10-13'));
      expect(snapshot.rates['BDT'], equals(123.16));
      expect(snapshot.rates['EUR'], equals(0.89335));
      expect(snapshot.rates['USD'], equals(1.0));
      expect(snapshot.isCached, isFalse);
    });

    test('fetchLatestRates parses v1 JSON map response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'base': 'USD',
            'date': '2026-10-13',
            'rates': {'EUR': 0.89335, 'GBP': 0.75508},
          }),
          200,
        );
      });

      final provider = FrankfurterExchangeRateProvider(client: mockClient);
      final snapshot = await provider.fetchLatestRates(base: 'USD');

      expect(snapshot.baseCurrency, equals('USD'));
      expect(snapshot.rates['EUR'], equals(0.89335));
      expect(snapshot.rates['GBP'], equals(0.75508));
    });

    test(
      'fetchLatestRates throws CurrencyApiException on 404 unsupported base',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final provider = FrankfurterExchangeRateProvider(client: mockClient);
        expect(
          () => provider.fetchLatestRates(base: 'XYZ'),
          throwsA(isA<CurrencyApiException>()),
        );
      },
    );

    test(
      'fetchLatestRates throws CurrencyApiException on non-200 HTTP failure',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final provider = FrankfurterExchangeRateProvider(client: mockClient);
        expect(
          () => provider.fetchLatestRates(base: 'USD'),
          throwsA(isA<CurrencyApiException>()),
        );
      },
    );

    test(
      'fetchLatestRates throws CurrencyApiException on malformed JSON',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('<html>Error</html>', 200);
        });

        final provider = FrankfurterExchangeRateProvider(client: mockClient);
        expect(
          () => provider.fetchLatestRates(base: 'USD'),
          throwsA(isA<CurrencyApiException>()),
        );
      },
    );
  });
}
