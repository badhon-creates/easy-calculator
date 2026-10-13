import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/currency_calculator.dart';

void main() {
  group('CurrencyCalculator - Core Math & Cross-Rates', () {
    late ExchangeRatesSnapshot snapshot;

    setUp(() {
      snapshot = ExchangeRatesSnapshot(
        baseCurrency: 'USD',
        date: '2026-10-13',
        rates: {
          'USD': 1.0,
          'BDT': 123.16,
          'EUR': 0.89335,
          'GBP': 0.75508,
          'INR': 95.87,
          'JPY': 158.48,
        },
        timestamp: DateTime(2026, 10, 13, 12, 0),
        isCached: false,
      );
    });

    test('Direct conversion from base currency (USD -> BDT)', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 100.0,
        fromCode: 'USD',
        toCode: 'BDT',
        snapshot: snapshot,
      );

      expect(result, isNotNull);
      expect(result!.rate, equals(123.16));
      expect(result.targetAmount, closeTo(12316.0, 0.001));
      expect(result.formattedTarget, equals('12,316'));
      expect(result.isSameCurrency, isFalse);
    });

    test('Inverted conversion to base currency (BDT -> USD)', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 12316.0,
        fromCode: 'BDT',
        toCode: 'USD',
        snapshot: snapshot,
      );

      expect(result, isNotNull);
      expect(result!.rate, closeTo(1.0 / 123.16, 0.00001));
      expect(result.targetAmount, closeTo(100.0, 0.01));
    });

    test(
      'Cross-rate calculation between two non-base currencies (EUR -> BDT)',
      () {
        // 1 EUR in USD = 1 / 0.89335
        // in BDT = (1 / 0.89335) * 123.16 = 123.16 / 0.89335 ≈ 137.863
        final result = CurrencyCalculator.convert(
          sourceAmount: 50.0,
          fromCode: 'EUR',
          toCode: 'BDT',
          snapshot: snapshot,
        );

        expect(result, isNotNull);
        const expectedRate = 123.16 / 0.89335;
        expect(result!.rate, closeTo(expectedRate, 0.0001));
        expect(result.targetAmount, closeTo(50.0 * expectedRate, 0.01));
      },
    );

    test('Same-currency conversion returns 1:1 rate and exact amount', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 250.75,
        fromCode: 'BDT',
        toCode: 'BDT',
        snapshot: snapshot,
      );

      expect(result, isNotNull);
      expect(result!.rate, equals(1.0));
      expect(result.targetAmount, equals(250.75));
      expect(result.isSameCurrency, isTrue);
    });

    test('Zero amount conversion returns 0 target amount', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 0.0,
        fromCode: 'USD',
        toCode: 'EUR',
        snapshot: snapshot,
      );

      expect(result, isNotNull);
      expect(result!.targetAmount, equals(0.0));
      expect(result.formattedTarget, equals('0'));
    });

    test('Decimal amount input is preserved and accurately calculated', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 0.5,
        fromCode: 'USD',
        toCode: 'BDT',
        snapshot: snapshot,
      );

      expect(result, isNotNull);
      expect(result!.targetAmount, equals(61.58));
    });

    test('Missing or unsupported currency returns null without throwing', () {
      final result = CurrencyCalculator.convert(
        sourceAmount: 100.0,
        fromCode: 'USD',
        toCode: 'XYZ', // Unsupported
        snapshot: snapshot,
      );

      expect(result, isNull);
    });

    test('Non-positive or invalid rate returns null', () {
      final badSnapshot = ExchangeRatesSnapshot(
        baseCurrency: 'USD',
        date: '2026-10-13',
        rates: {'BAD': -5.0},
        timestamp: DateTime.now(),
      );

      final result = CurrencyCalculator.convert(
        sourceAmount: 10.0,
        fromCode: 'USD',
        toCode: 'BAD',
        snapshot: badSnapshot,
      );

      expect(result, isNull);
    });
  });

  group('CurrencyCalculator - Input Parsing & Formatting', () {
    test(
      'parseInputAmount parses valid integers, decimals, and edge inputs',
      () {
        expect(CurrencyCalculator.parseInputAmount('123'), equals(123.0));
        expect(CurrencyCalculator.parseInputAmount('12.5'), equals(12.5));
        expect(CurrencyCalculator.parseInputAmount('0.75'), equals(0.75));
        expect(CurrencyCalculator.parseInputAmount('12.'), equals(12.0));
        expect(CurrencyCalculator.parseInputAmount('.'), equals(0.0));
        expect(CurrencyCalculator.parseInputAmount(''), equals(0.0));
        expect(CurrencyCalculator.parseInputAmount('invalid'), equals(0.0));
      },
    );

    test(
      'formatCurrencyValue formats numbers cleanly without trailing zeros',
      () {
        expect(CurrencyCalculator.formatCurrencyValue(1234.0), equals('1,234'));
        expect(
          CurrencyCalculator.formatCurrencyValue(1234.50),
          equals('1,234.5'),
        );
        expect(
          CurrencyCalculator.formatCurrencyValue(1234.56),
          equals('1,234.56'),
        );
        expect(CurrencyCalculator.formatCurrencyValue(0.0), equals('0'));
        expect(
          CurrencyCalculator.formatCurrencyValue(0.00812),
          equals('0.00812'),
        );
      },
    );

    test('formatRateText produces clear equality equation', () {
      expect(
        CurrencyCalculator.formatRateText(
          fromCode: 'USD',
          toCode: 'BDT',
          rate: 123.16,
        ),
        equals('1 USD = 123.16 BDT'),
      );
      expect(
        CurrencyCalculator.formatRateText(
          fromCode: 'USD',
          toCode: 'USD',
          rate: 1.0,
        ),
        equals('1 USD = 1 USD'),
      );
    });
  });
}
