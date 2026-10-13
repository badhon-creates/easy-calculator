import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/currency_converter/presentation/screens/currency_converter_screen.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

class FakeCurrencyRepository implements CurrencyRepository {
  CurrencySession session = const CurrencySession(
    sourceCode: 'USD',
    targetCode: 'BDT',
    amountInput: '10',
  );

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
  Widget buildTestApp(CurrencyRepository repository) {
    return MaterialApp(home: CurrencyConverterScreen(repository: repository));
  }

  group('CurrencyConverterScreen Widget Tests', () {
    testWidgets(
      'Renders AppBar, currency cards, rate banner, and squircle keypad',
      (tester) async {
        final repo = FakeCurrencyRepository();
        await tester.pumpWidget(buildTestApp(repo));
        await tester.pumpAndSettle();

        // Check AppBar
        expect(find.text('Convert'), findsOneWidget);
        expect(find.byTooltip('Return to Calculator'), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);

        // Check Cards
        expect(find.text('FROM'), findsOneWidget);
        expect(find.text('TO'), findsOneWidget);
        expect(find.text('USD'), findsWidgets);
        expect(find.text('BDT'), findsWidgets);

        // Check Amount input and initial calculated output (10 * 123.16 = 1,231.6)
        expect(find.text('10'), findsOneWidget);
        expect(find.text('1,231.6'), findsOneWidget);

        // Check Keypad digits
        expect(find.text('1'), findsWidgets);
        expect(find.text('9'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping keypad digits updates amount and recalculates conversion',
      (tester) async {
        final repo = FakeCurrencyRepository();
        await tester.pumpWidget(buildTestApp(repo));
        await tester.pumpAndSettle();

        // Tap Clear 'C'
        await tester.tap(find.widgetWithText(SquircleButton, 'C'));
        await tester.pumpAndSettle();
        expect(find.text('0'), findsWidgets);

        // Tap '5'
        await tester.tap(find.widgetWithText(SquircleButton, '5'));
        await tester.pumpAndSettle();
        // Converted: 5 * 123.16 = 615.8
        expect(find.text('615.8'), findsOneWidget);

        // Tap '.' then '5' -> 5.5
        await tester.tap(find.widgetWithText(SquircleButton, '.'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SquircleButton, '5'));
        await tester.pumpAndSettle();
        expect(find.text('5.5'), findsOneWidget);
        // Converted: 5.5 * 123.16 = 677.38
        expect(find.text('677.38'), findsOneWidget);
      },
    );

    testWidgets('Swap button swaps currencies and recalculates', (
      tester,
    ) async {
      final repo = FakeCurrencyRepository();
      await tester.pumpWidget(buildTestApp(repo));
      await tester.pumpAndSettle();

      // Tap swap icon between cards
      await tester.tap(find.byIcon(Icons.swap_vert_rounded).first);
      await tester.pumpAndSettle();

      // Now From is BDT, To is USD
      // 10 BDT in USD = 10 / 123.16 ≈ 0.081195
      expect(find.text('0.081195'), findsOneWidget);
    });

    testWidgets(
      'Opening currency selector bottom sheet filters and selects currency',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.5;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = FakeCurrencyRepository();
        await tester.pumpWidget(buildTestApp(repo));
        await tester.pumpAndSettle();

        // Ensure target selector is visible and tap
        final selectorFinder = find.byKey(
          const ValueKey('currency_selector_to'),
        );
        await tester.ensureVisible(selectorFinder);
        await tester.pumpAndSettle();
        await tester.tap(selectorFinder);
        await tester.pumpAndSettle();

        // Modal bottom sheet should be visible
        expect(find.text('Select Target Currency'), findsOneWidget);
        expect(find.text('EUR'), findsOneWidget);

        // Search for 'Euro'
        await tester.enterText(find.byType(TextField), 'Euro');
        await tester.pumpAndSettle();

        // Tap Euro in list
        await tester.tap(find.text('EUR'));
        await tester.pumpAndSettle();

        // Modal is dismissed, Target card now shows EUR
        expect(find.text('Select Target Currency'), findsNothing);
        expect(find.text('EUR'), findsWidgets);
        // 10 USD in EUR = 10 * 0.89335 = 8.9335
        expect(find.text('8.9335'), findsOneWidget);
      },
    );
  });
}
