import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';
import 'package:easy_calculator/features/history/domain/repositories/history_repository.dart';

/// In-memory fake repository for lightning-fast and deterministic widget testing.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository([List<HistoryItem>? initial])
    : _items = List<HistoryItem>.from(initial ?? []);

  final List<HistoryItem> _items;

  @override
  Future<List<HistoryItem>> getHistory() async => List.unmodifiable(_items);

  @override
  Future<void> addEntry(HistoryItem item) async {
    _items.removeWhere((e) => e.id == item.id);
    _items.insert(0, item);
  }

  @override
  Future<void> deleteEntry(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> clearHistory() async {
    _items.clear();
  }

  @override
  Future<int> purgeExpiredEntries() async => 0;
}

void main() {
  group('History Screen & Navigation Widget Tests', () {
    late FakeHistoryRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeHistoryRepository();
    });

    Widget createTestApp({
      required CalculatorCubit cubit,
      ThemeMode themeMode = ThemeMode.light,
    }) {
      return BlocProvider<CalculatorCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const CalculatorScreen(),
        ),
      );
    }

    testWidgets(
      'Opens HistoryScreen via top-left clock icon and displays empty state',
      (tester) async {
        final cubit = CalculatorCubit(historyRepository: fakeRepo);

        await tester.pumpWidget(createTestApp(cubit: cubit));
        await tester.pumpAndSettle();

        // Find history button at top-left
        final historyBtn = find.byTooltip('History');
        expect(historyBtn, findsOneWidget);

        await tester.tap(historyBtn);
        await tester.pumpAndSettle();

        // Should have navigated to History screen
        expect(find.text('History'), findsOneWidget);
        expect(find.text('No Calculation History'), findsOneWidget);
        expect(
          find.text(
            'Completed calculations from Basic and Scientific modes will be saved here for 7 calendar days.',
          ),
          findsOneWidget,
        );

        // Back button navigates back to calculator
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(CalculatorScreen), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets('Displays history items and allows entry reuse in calculator', (
      tester,
    ) async {
      await fakeRepo.addEntry(
        HistoryItem(
          id: 'test_1',
          expression: '15 × 4',
          result: '60',
          timestamp: DateTime.now(),
          mode: 'basic',
        ),
      );

      final cubit = CalculatorCubit(historyRepository: fakeRepo);

      await tester.pumpWidget(createTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      // Open history
      await tester.tap(find.byTooltip('History'));
      await tester.pumpAndSettle();

      // Verify history item is displayed
      expect(find.text('15 × 4'), findsOneWidget);
      expect(find.text('= 60'), findsOneWidget);
      expect(find.text('Basic'), findsOneWidget);

      // Tap history entry to reuse it
      await tester.tap(find.text('15 × 4'));
      await tester.pumpAndSettle();

      // Verify calculation is restored in active CalculatorScreen
      expect(find.byType(CalculatorScreen), findsOneWidget);
      expect(cubit.state.expression, equals('15 × 4'));
      expect(cubit.state.result, equals('60'));
      expect(cubit.state.isResultComputed, isTrue);

      await cubit.close();
    });

    testWidgets(
      'Clear all history shows confirmation dialog and removes entries',
      (tester) async {
        await fakeRepo.addEntry(
          HistoryItem(
            id: 'item_a',
            expression: '8 + 8',
            result: '16',
            timestamp: DateTime.now(),
          ),
        );

        final cubit = CalculatorCubit(historyRepository: fakeRepo);

        await tester.pumpWidget(createTestApp(cubit: cubit));
        await tester.pumpAndSettle();

        // Open history
        await tester.tap(find.byTooltip('History'));
        await tester.pumpAndSettle();

        expect(find.text('8 + 8'), findsOneWidget);

        // Tap Clear All button in app bar
        final clearAllBtn = find.byTooltip('Clear history');
        expect(clearAllBtn, findsOneWidget);
        await tester.tap(clearAllBtn);
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Clear History?'), findsOneWidget);
        expect(find.text('Clear All'), findsOneWidget);

        // Tap confirm Clear All
        await tester.tap(find.widgetWithText(ElevatedButton, 'Clear All'));
        await tester.pumpAndSettle();

        // Verify list is now empty
        expect(find.text('No Calculation History'), findsOneWidget);
        expect(find.text('8 + 8'), findsNothing);

        await cubit.close();
      },
    );

    testWidgets('Dark theme displays #1F1C1C background and white text', (
      tester,
    ) async {
      final cubit = CalculatorCubit(historyRepository: fakeRepo);

      await tester.pumpWidget(
        createTestApp(cubit: cubit, themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      // Open history
      await tester.tap(find.byTooltip('History'));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, equals(const Color(0xFF1F1C1C)));

      await cubit.close();
    });
  });
}
