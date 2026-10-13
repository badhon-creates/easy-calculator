import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/math_notes_home_screen.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/note_editor_screen.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/note_card.dart';

class FakeNoteRepository implements NoteRepository {
  final List<MathNote> _notes = [];

  @override
  Future<List<MathNote>> getAllNotes({bool newestFirst = true}) async {
    final copy = List<MathNote>.from(_notes);
    copy.sort(
      (a, b) => newestFirst
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.updatedAt.compareTo(b.updatedAt),
    );
    return copy;
  }

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
  }) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return getAllNotes(newestFirst: newestFirst);
    return _notes.where((n) {
      return n.title.toLowerCase().contains(clean) ||
          n.plainTextPreview.toLowerCase().contains(clean);
    }).toList();
  }
}

class FakeNoteSessionRepository implements NoteSessionRepository {
  NoteEditingSession? _session;

  @override
  Future<void> saveSession(NoteEditingSession session) async {
    _session = session;
  }

  @override
  Future<NoteEditingSession?> loadSession() async {
    return _session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }
}

void main() {
  late FakeNoteRepository noteRepo;
  late FakeNoteSessionRepository sessionRepo;

  setUp(() {
    noteRepo = FakeNoteRepository();
    sessionRepo = FakeNoteSessionRepository();
  });

  Widget buildApp(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: child,
    );
  }

  group('Math Notes Screen & UI Widget Tests', () {
    testWidgets(
      'Renders empty notes screen with search bar, new note button, and calculator icon',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            MathNotesHomeScreen(
              noteRepository: noteRepo,
              sessionRepository: sessionRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Math Notes'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(
          find.byIcon(Icons.edit_rounded),
          findsOneWidget,
        ); // New note button
        expect(
          find.byIcon(Icons.calculate_outlined),
          findsOneWidget,
        ); // Calculator return icon
        expect(find.text('No Math Notes Yet'), findsOneWidget);
      },
    );

    testWidgets(
      'Displays saved notes, searches, and shows empty search state',
      (tester) async {
        await noteRepo.saveNote(
          MathNote(
            id: '1',
            title: 'Matrix Multiplication',
            blocks: const [
              NoteBlock(
                id: 'b1',
                type: NoteBlockType.body,
                spans: [TextSpanData(text: 'Row by column product rules')],
              ),
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await tester.pumpWidget(
          buildApp(
            MathNotesHomeScreen(
              noteRepository: noteRepo,
              sessionRepository: sessionRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Matrix Multiplication'), findsOneWidget);
        expect(find.byType(NoteCard), findsOneWidget);

        // Search for non-existent note
        await tester.enterText(find.byType(TextField), 'Quantum');
        await tester.pumpAndSettle();

        expect(find.text('Matrix Multiplication'), findsNothing);
        expect(find.text('No Matching Notes'), findsOneWidget);

        // Clear search
        await tester.tap(find.byIcon(Icons.clear_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Matrix Multiplication'), findsOneWidget);
      },
    );

    testWidgets(
      'Opens NoteEditorScreen, edits title, and interacts with formatting toolbar',
      (tester) async {
        final note = MathNote.empty(id: 'note_editor_ui');

        await tester.pumpWidget(
          buildApp(
            NoteEditorScreen(
              note: note,
              noteRepository: noteRepo,
              sessionRepository: sessionRepo,
              isNewNote: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Top bar controls: Undo, Redo, Share, Calculator
        expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
        expect(find.byIcon(Icons.redo_rounded), findsOneWidget);
        expect(find.byIcon(Icons.share_rounded), findsOneWidget);
        expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);

        // Title field
        expect(find.text('Title'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextField, 'Title'),
          'Algebra Basics',
        );
        await tester.pumpAndSettle();

        expect(find.text('Algebra Basics'), findsOneWidget);

        // Formatting toolbar
        expect(find.text('Aa'), findsOneWidget);
        expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);
        expect(find.byIcon(Icons.edit_rounded), findsOneWidget); // Drawing tool

        // Tap Aa to open bottom sheet
        await tester.tap(find.text('Aa'));
        await tester.pumpAndSettle();

        expect(find.text('Text Formatting'), findsOneWidget);
        expect(find.text('Title'), findsWidgets);
        expect(find.text('Heading'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('I'), findsOneWidget);
        expect(find.text('U'), findsOneWidget);

        // Close bottom sheet
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        // Tap drawing pencil to activate drawing mode
        await tester.tap(find.byIcon(Icons.edit_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Drawing Canvas'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);

        // Tap Done
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(find.text('Drawing Canvas'), findsNothing);
      },
    );

    testWidgets('Dark theme displays #1F1C1C background', (tester) async {
      await tester.pumpWidget(
        buildApp(
          MathNotesHomeScreen(
            noteRepository: noteRepo,
            sessionRepository: sessionRepo,
          ),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF1F1C1C));
    });

    testWidgets(
      'Delete notes shows confirmation dialog and removes note upon confirm',
      (tester) async {
        await noteRepo.saveNote(
          MathNote(
            id: 'del_me',
            title: 'Delete Me Note',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await tester.pumpWidget(
          buildApp(
            MathNotesHomeScreen(
              noteRepository: noteRepo,
              sessionRepository: sessionRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Delete Me Note'), findsOneWidget);

        // Long press card to enter selection mode
        await tester.longPress(find.byType(NoteCard));
        await tester.pumpAndSettle();

        expect(find.text('1 selected'), findsOneWidget);
        expect(find.byIcon(Icons.delete_rounded), findsOneWidget);

        // Tap delete
        await tester.tap(find.byIcon(Icons.delete_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Delete Selected Notes?'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        // Confirm delete
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Delete Me Note'), findsNothing);
        expect(find.text('No Math Notes Yet'), findsOneWidget);
      },
    );
  });
}
