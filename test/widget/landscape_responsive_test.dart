import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/main.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/scientific_landscape_keypad.dart';
import 'package:easy_calculator/features/currency_converter/presentation/screens/currency_converter_screen.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency_session.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/presentation/screens/units_converter_screen.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/math_notes_home_screen.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/note_editor_screen.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';

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

class FakeNoteRepository implements NoteRepository {
  final List<MathNote> _notes = [];

  @override
  Future<List<MathNote>> getAllNotes({bool newestFirst = true}) async =>
      List.from(_notes);

  @override
  Future<MathNote?> getNoteById(String id) async {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveNote(MathNote note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _notes[idx] = note;
    } else {
      _notes.insert(0, note);
    }
  }

  @override
  Future<void> deleteNotes(List<String> ids) async {
    _notes.removeWhere((n) => ids.contains(n.id));
  }

  @override
  Future<List<MathNote>> searchNotes(
    String query, {
    bool newestFirst = true,
  }) async => _notes;
}

class FakeNoteSessionRepository implements NoteSessionRepository {
  @override
  Future<NoteEditingSession?> loadSession() async => null;

  @override
  Future<void> saveSession(NoteEditingSession session) async {}

  @override
  Future<void> clearSession() async {}
}

void main() {
  group('Phase 9: Landscape Responsive Layout Tests', () {
    testWidgets(
      'Basic Calculator adapts cleanly to landscape without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(2400, 1080);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const EasyCalculatorApp());
        await tester.pumpAndSettle();

        // Ensure no RenderFlex overflow
        expect(tester.takeException(), isNull);

        // Verify numbers and operators are visible and tappable
        expect(find.widgetWithText(SquircleButton, '7'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, '9'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, '='), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, '+'), findsOneWidget);

        // Tap numbers to verify layout interaction
        await tester.tap(find.widgetWithText(SquircleButton, '8'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SquircleButton, '+'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SquircleButton, '5'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Scientific Calculator renders unified 10-column keypad in landscape without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(2400, 1080);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const EasyCalculatorApp());
        await tester.pumpAndSettle();

        // Switch to Scientific mode
        await tester.tap(find.byTooltip('Select mode'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Scientific'));
        await tester.pumpAndSettle();

        // Verify ScientificLandscapeKeypad is used
        expect(find.byType(ScientificLandscapeKeypad), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Check scientific buttons exist in landscape
        expect(find.widgetWithText(SquircleButton, 'sin'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'cos'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'tan'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'ln'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'log₁₀'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, '²√x'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'π'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'e'), findsOneWidget);
        expect(find.widgetWithText(SquircleButton, 'DEG'), findsOneWidget);

        // Tap DEG to switch to RAD
        await tester.tap(find.widgetWithText(SquircleButton, 'DEG'));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(SquircleButton, 'RAD'), findsOneWidget);

        // Calculate cos(0)
        await tester.tap(find.widgetWithText(SquircleButton, 'cos'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SquircleButton, '0'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SquircleButton, '='));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Units Converter renders 2-column landscape layout', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(2400, 1080);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: UnitsConverterScreen(
            initialCategory: UnitCategory.length,
            currencyRepository: FakeCurrencyRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(UnitsConverterScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify keypad and cards are both rendered in landscape
      expect(find.widgetWithText(SquircleButton, '1'), findsOneWidget);
      expect(find.widgetWithText(SquircleButton, '5'), findsOneWidget);
      expect(find.byIcon(Icons.swap_vert_rounded), findsWidgets);

      // Tap keypad
      await tester.tap(find.widgetWithText(SquircleButton, '5'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Currency Converter renders 2-column landscape layout', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(2400, 1080);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: CurrencyConverterScreen(repository: FakeCurrencyRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyConverterScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify cards and keypad are visible
      expect(find.widgetWithText(SquircleButton, '2'), findsOneWidget);
      expect(find.byIcon(Icons.swap_vert_rounded), findsWidgets);

      await tester.tap(find.widgetWithText(SquircleButton, '2'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Math Notes Home & Editor adapt gracefully to landscape', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(2400, 1080);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final noteRepo = FakeNoteRepository();
      final sessionRepo = FakeNoteSessionRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: MathNotesHomeScreen(
            noteRepository: noteRepo,
            sessionRepository: sessionRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MathNotesHomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Create new note
      await tester.tap(find.byTooltip('New note'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Open drawing canvas
      await tester.tap(find.byTooltip('Freehand drawing'));
      await tester.pumpAndSettle();

      expect(find.text('Drawing Canvas'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Finish drawing
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
