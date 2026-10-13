import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/currency_converter/data/providers/frankfurter_exchange_rate_provider.dart';
import 'package:easy_calculator/features/currency_converter/data/repositories/local_currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/exchange_rate_provider.dart';

class FakeExchangeRateProvider implements ExchangeRateProvider {
  bool shouldThrow = false;
  int fetchRatesCallCount = 0;

  @override
  Future<List<Currency>> fetchCurrencies() async {
    if (shouldThrow) throw const CurrencyApiException('Offline');
    return const [
      Currency(
        code: 'USD',
        name: 'United States Dollar',
        symbol: '\$',
        flag: '🇺🇸',
      ),
      Currency(
        code: 'BDT',
        name: 'Bangladeshi Taka',
        symbol: '৳',
        flag: '🇧🇩',
      ),
      Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    ];
  }

  @override
  Future<ExchangeRatesSnapshot> fetchLatestRates({String base = 'USD'}) async {
    fetchRatesCallCount++;
    if (shouldThrow) throw const CurrencyApiException('Network failure');
    return ExchangeRatesSnapshot(
      baseCurrency: base,
      date: '2026-10-13',
      rates: {'USD': 1.0, 'BDT': 123.16, 'EUR': 0.89},
      timestamp: DateTime(2026, 10, 13, 10, 0),
      isCached: false,
    );
  }
}

void main() {
  group('LocalCurrencyRepository - Caching & Offline Fallback', () {
    late Directory tempDir;
    late FakeExchangeRateProvider fakeProvider;
    late LocalCurrencyRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('currency_test_');
      fakeProvider = FakeExchangeRateProvider();
      repository = LocalCurrencyRepository(
        provider: fakeProvider,
        getDirectory: () async => tempDir,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'getCurrencies caches to disk and returns cached currencies',
      () async {
        final currencies = await repository.getCurrencies();
        expect(currencies.length, equals(3));
        expect(currencies[0].code, equals('USD'));

        // Simulate provider error on second call; should load from disk/memory cache
        fakeProvider.shouldThrow = true;
        final cachedCurrencies = await repository.getCurrencies();
        expect(cachedCurrencies.length, equals(3));
        expect(cachedCurrencies[1].code, equals('BDT'));
      },
    );

    test('getLatestRates fetches live rates and writes to cache', () async {
      final snapshot = await repository.getLatestRates(forceRefresh: true);
      expect(snapshot.rates['BDT'], equals(123.16));
      expect(snapshot.isCached, isFalse);
      expect(fakeProvider.fetchRatesCallCount, equals(1));

      // Second call without forceRefresh returns in-memory snapshot without hitting provider
      final memorySnapshot = await repository.getLatestRates(
        forceRefresh: false,
      );
      expect(memorySnapshot.rates['BDT'], equals(123.16));
      expect(fakeProvider.fetchRatesCallCount, equals(1));

      // Separate repository instance loads from disk cache with isCached: true
      final diskRepo = LocalCurrencyRepository(
        provider: fakeProvider,
        getDirectory: () async => tempDir,
      );
      final diskCachedSnapshot = await diskRepo.getLatestRates(
        forceRefresh: false,
      );
      expect(diskCachedSnapshot.isCached, isTrue);
      expect(diskCachedSnapshot.rates['BDT'], equals(123.16));
      expect(fakeProvider.fetchRatesCallCount, equals(1));
    });

    test(
      'Offline fallback: returns cached rates when live refresh fails',
      () async {
        // 1. Initial live fetch
        await repository.getLatestRates(forceRefresh: true);

        // 2. Network goes down
        fakeProvider.shouldThrow = true;

        // 3. Requesting rates with forceRefresh should fall back safely to cached snapshot
        final fallbackSnapshot = await repository.getLatestRates(
          forceRefresh: true,
        );
        expect(fallbackSnapshot.isCached, isTrue);
        expect(fallbackSnapshot.rates['BDT'], equals(123.16));
      },
    );

    test('Throws exception if live fetch fails and no cache exists', () async {
      fakeProvider.shouldThrow = true;
      expect(
        () => repository.getLatestRates(forceRefresh: true),
        throwsA(isA<CurrencyApiException>()),
      );
    });

    test(
      'Session persistence saves and restores active state correctly',
      () async {
        const session = CurrencySession(
          sourceCode: 'EUR',
          targetCode: 'BDT',
          amountInput: '75.5',
        );

        await repository.saveSession(session);
        final restored = await repository.getSession();

        expect(restored.sourceCode, equals('EUR'));
        expect(restored.targetCode, equals('BDT'));
        expect(restored.amountInput, equals('75.5'));
      },
    );
  });
}
