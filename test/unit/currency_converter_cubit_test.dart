import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/presentation/cubit/currency_converter_cubit.dart';
import 'package:easy_calculator/features/currency_converter/presentation/cubit/currency_converter_state.dart';

class MockCurrencyRepository implements CurrencyRepository {
  CurrencySession session = const CurrencySession(
    sourceCode: 'USD',
    targetCode: 'BDT',
    amountInput: '10',
  );

  bool failRates = false;

  @override
  Future<List<Currency>> getCurrencies() async {
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
      Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
    ];
  }

  @override
  Future<ExchangeRatesSnapshot> getLatestRates({
    bool forceRefresh = false,
  }) async {
    if (failRates) throw Exception('Rate service offline');
    return ExchangeRatesSnapshot(
      baseCurrency: 'USD',
      date: '2026-10-13',
      rates: {'USD': 1.0, 'BDT': 123.16, 'EUR': 0.89335, 'GBP': 0.75508},
      timestamp: DateTime(2026, 10, 13, 12, 0),
      isCached: false,
    );
  }

  @override
  Future<CurrencySession> getSession() async => session;

  @override
  Future<void> saveSession(CurrencySession newSession) async {
    session = newSession;
  }
}

void main() {
  group('CurrencyConverterCubit', () {
    late MockCurrencyRepository mockRepo;
    late CurrencyConverterCubit cubit;

    setUp(() {
      mockRepo = MockCurrencyRepository();
      cubit = CurrencyConverterCubit(repository: mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test(
      'initialize loads session, currencies, rates, and initial conversion',
      () async {
        await cubit.initialize();

        expect(cubit.state.status, equals(CurrencyConverterStatus.success));
        expect(cubit.state.sourceCurrency.code, equals('USD'));
        expect(cubit.state.targetCurrency.code, equals('BDT'));
        expect(cubit.state.amountInput, equals('10'));
        expect(cubit.state.conversionResult, isNotNull);
        expect(
          cubit.state.conversionResult!.targetAmount,
          closeTo(1231.6, 0.01),
        );
      },
    );

    test(
      'Keypad actions: appendDigit, appendDecimal, deleteDigit, clear',
      () async {
        await cubit.initialize();

        cubit.clear();
        expect(cubit.state.amountInput, equals('0'));
        expect(cubit.state.conversionResult!.targetAmount, equals(0.0));

        cubit.appendDigit('5');
        expect(cubit.state.amountInput, equals('5'));

        cubit.appendDecimal();
        expect(cubit.state.amountInput, equals('5.'));

        cubit.appendDigit('2');
        expect(cubit.state.amountInput, equals('5.2'));
        expect(
          cubit.state.conversionResult!.targetAmount,
          closeTo(5.2 * 123.16, 0.01),
        );

        // Duplicate decimal is ignored
        cubit.appendDecimal();
        expect(cubit.state.amountInput, equals('5.2'));

        cubit.deleteDigit();
        expect(cubit.state.amountInput, equals('5.'));

        cubit.deleteDigit();
        expect(cubit.state.amountInput, equals('5'));

        cubit.deleteDigit();
        expect(cubit.state.amountInput, equals('0'));
      },
    );

    test(
      'swapCurrencies swaps source and target and recalculates immediately',
      () async {
        await cubit.initialize();

        expect(cubit.state.sourceCurrency.code, equals('USD'));
        expect(cubit.state.targetCurrency.code, equals('BDT'));

        cubit.swapCurrencies();

        expect(cubit.state.sourceCurrency.code, equals('BDT'));
        expect(cubit.state.targetCurrency.code, equals('USD'));
        expect(cubit.state.conversionResult, isNotNull);
        // 10 BDT in USD = 10 / 123.16 ≈ 0.0812
        expect(
          cubit.state.conversionResult!.targetAmount,
          closeTo(10 / 123.16, 0.001),
        );
      },
    );

    test(
      'setSourceCurrency and setTargetCurrency update state and recalculate',
      () async {
        await cubit.initialize();

        const eur = Currency(
          code: 'EUR',
          name: 'Euro',
          symbol: '€',
          flag: '🇪🇺',
        );
        cubit.setSourceCurrency(eur);
        expect(cubit.state.sourceCurrency.code, equals('EUR'));

        // 10 EUR in BDT
        const expectedRate = 123.16 / 0.89335;
        expect(
          cubit.state.conversionResult!.targetAmount,
          closeTo(10 * expectedRate, 0.01),
        );

        const gbp = Currency(
          code: 'GBP',
          name: 'British Pound',
          symbol: '£',
          flag: '🇬🇧',
        );
        cubit.setTargetCurrency(gbp);
        expect(cubit.state.targetCurrency.code, equals('GBP'));
        // 10 EUR in GBP
        const eurToGbp = 0.75508 / 0.89335;
        expect(
          cubit.state.conversionResult!.targetAmount,
          closeTo(10 * eurToGbp, 0.01),
        );
      },
    );

    test('refreshRates updates rates snapshot with forceRefresh', () async {
      await cubit.initialize();

      await cubit.refreshRates();
      expect(cubit.state.status, equals(CurrencyConverterStatus.success));
      expect(cubit.state.errorMessage, isNull);
    });

    test(
      'refreshRates failure keeps previous rates and displays error',
      () async {
        await cubit.initialize();
        mockRepo.failRates = true;

        await cubit.refreshRates();
        expect(cubit.state.status, equals(CurrencyConverterStatus.success));
        expect(cubit.state.errorMessage, contains('Refresh failed'));
        expect(cubit.state.conversionResult, isNotNull);
      },
    );
  });
}
