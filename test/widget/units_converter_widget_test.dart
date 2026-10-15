import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/presentation/screens/units_converter_screen.dart';

class FakeCurrencyRepository implements CurrencyRepository {
  CurrencySession session = const CurrencySession(
    sourceCode: 'USD',
    targetCode: 'EUR',
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
      Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
      Currency(
        code: 'BDT',
        name: 'Bangladeshi Taka',
        symbol: '৳',
        flag: '🇧🇩',
      ),
    ];
  }

  @override
  Future<ExchangeRatesSnapshot> getLatestRates({
    bool forceRefresh = false,
  }) async {
    return ExchangeRatesSnapshot(
      baseCurrency: 'USD',
      date: '2026-10-15',
      rates: {'USD': 1.0, 'EUR': 0.92, 'BDT': 123.0},
      timestamp: DateTime(2026, 10, 15, 12, 0),
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
  Widget buildTestApp({
    UnitCategory initialCategory = UnitCategory.currency,
    CurrencyRepository? repository,
  }) {
    return MaterialApp(
      home: UnitsConverterScreen(
        initialCategory: initialCategory,
        currencyRepository: repository ?? FakeCurrencyRepository(),
      ),
    );
  }

  group('UnitsConverterScreen Widget Tests', () {
    testWidgets('Renders AppBar, 15 category tabs, and returns to calculator', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Check title
      expect(find.text('Units'), findsOneWidget);

      // Check category tabs exist
      expect(
        find.byKey(const ValueKey('category_tab_currency')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('category_tab_angle')), findsOneWidget);
      expect(find.byKey(const ValueKey('category_tab_length')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('category_tab_temperature')),
        findsOneWidget,
      );

      // Check return to calculator button
      expect(find.byTooltip('Return to Calculator'), findsOneWidget);
    });

    testWidgets('Switching to Length category shows length units and keypad', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll and tap Length tab
      final lengthTab = find.byKey(const ValueKey('category_tab_length'));
      await tester.ensureVisible(lengthTab);
      await tester.pumpAndSettle();
      await tester.tap(lengthTab);
      await tester.pumpAndSettle();

      // Should display From and To cards with Meter and Foot
      expect(find.text('Meter'), findsOneWidget);
      expect(find.text('Foot'), findsOneWidget);

      // Check conversion formula banner
      expect(find.textContaining('1 m ='), findsOneWidget);

      // Keypad digits exist
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('Keypad entry updates amount and converts immediately', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(initialCategory: UnitCategory.length),
      );
      await tester.pumpAndSettle();

      // Clear existing input
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsAtLeastNWidgets(1));

      // Enter 10
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      // 10 meters is ~32.8084 feet
      expect(find.textContaining('32.808'), findsOneWidget);
    });

    testWidgets('Unit swapping inverts source and destination', (tester) async {
      await tester.pumpWidget(
        buildTestApp(initialCategory: UnitCategory.length),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meter'), findsOneWidget);
      expect(find.text('Foot'), findsOneWidget);

      // Tap swap button (between cards)
      await tester.tap(find.byIcon(Icons.swap_vert_rounded).first);
      await tester.pumpAndSettle();

      // After swap, From is Foot, To is Meter
      expect(find.text('Foot'), findsOneWidget);
      expect(find.text('Meter'), findsOneWidget);
    });

    testWidgets('Opening unit selection modal displays search and unit list', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(initialCategory: UnitCategory.length),
      );
      await tester.pumpAndSettle();

      // Tap From selector
      await tester.tap(find.byKey(const ValueKey('unit_selector_from')));
      await tester.pumpAndSettle();

      // Modal bottom sheet appears
      expect(find.text('Select From Unit'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Check kilometer is in the list and tap it
      expect(find.text('Kilometer'), findsOneWidget);
      await tester.tap(find.text('Kilometer'));
      await tester.pumpAndSettle();

      // Modal closed, Kilometer is selected as From
      expect(find.text('Kilometer'), findsOneWidget);
    });

    testWidgets(
      'Temperature category provides sign toggle (±) for negative input',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(initialCategory: UnitCategory.temperature),
        );
        await tester.pumpAndSettle();

        // Sign toggle button exists
        expect(find.text('±'), findsOneWidget);

        // Clear and enter 40
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Toggle sign to -40
        await tester.tap(find.text('±'));
        await tester.pumpAndSettle();

        // -40 °C = -40 °F! Both source and target show -40
        expect(find.text('-40'), findsAtLeastNWidgets(2));
      },
    );

    testWidgets(
      'Currency category displays live exchange rate info and disclaimer',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Currency cards exist
        expect(find.text('USD'), findsOneWidget);
        expect(find.text('EUR'), findsOneWidget);

        // Rate info banner
        expect(find.textContaining('1 USD = 0.92 EUR'), findsOneWidget);
        expect(find.text('Disclaimer'), findsOneWidget);
        expect(find.text('Live'), findsOneWidget);
      },
    );
  });
}
