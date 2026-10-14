import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_color_picker.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_color_picker_dialog.dart';

class _FakeNoteRepo implements NoteRepository {
  @override
  Future<List<MathNote>> getAllNotes({bool newestFirst = true}) async => [];
  @override
  Future<MathNote?> getNoteById(String id) async => null;
  @override
  Future<void> saveNote(MathNote note) async {}
  @override
  Future<void> deleteNotes(List<String> ids) async {}
  @override
  Future<List<MathNote>> searchNotes(
    String query, {
    bool newestFirst = true,
  }) async => [];
}

class _FakeSessionRepo implements NoteSessionRepository {
  @override
  Future<void> saveSession(NoteEditingSession session) async {}
  @override
  Future<NoteEditingSession?> loadSession() async => null;
  @override
  Future<void> clearSession() async {}
}

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('DrawingColorPickerToolbar & Dialog Widget Tests', () {
    late NoteEditorCubit cubit;
    late MathNote testNote;

    setUp(() {
      testNote = MathNote(
        id: 'test_note',
        title: 'Drawing Test',
        blocks: const [],
        drawings: const [
          DrawingStroke(
            colorHex: '#000000',
            strokeWidth: 3.0,
            points: [StrokePoint(x: 10, y: 10)],
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      cubit = NoteEditorCubit(
        initialNote: testNote,
        noteRepository: _FakeNoteRepo(),
        sessionRepository: _FakeSessionRepo(),
      );
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets(
      'Renders toolbar with color wheel button, presets, and widths',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            DrawingColorPickerToolbar(cubit: cubit, state: cubit.state),
          ),
        );

        // Verify color wheel button icon is present
        expect(find.byIcon(Icons.palette_outlined), findsOneWidget);

        // Verify done and clear buttons
        expect(find.text('Done'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      },
    );

    testWidgets('Tapping color wheel button opens DrawingColorPickerDialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DrawingColorPickerToolbar(cubit: cubit, state: cubit.state),
        ),
      );

      // Tap the palette button
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(DrawingColorPickerDialog), findsOneWidget);
      expect(find.text('Drawing Color'), findsOneWidget);
      expect(find.byType(HueRingPicker), findsOneWidget);
      expect(find.text('Opacity'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('Cancelling color picker retains previous drawing color', (
      tester,
    ) async {
      final initialColor = cubit.state.drawingColorHex;

      await tester.pumpWidget(
        buildTestableWidget(
          DrawingColorPickerToolbar(cubit: cubit, state: cubit.state),
        ),
      );

      // Open dialog
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog is dismissed and color has not changed
      expect(find.byType(DrawingColorPickerDialog), findsNothing);
      expect(cubit.state.drawingColorHex, initialColor);
    });

    testWidgets('Applying color picker returns confirmed color to cubit', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DrawingColorPickerToolbar(cubit: cubit, state: cubit.state),
        ),
      );

      // Open dialog
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.byType(DrawingColorPickerDialog), findsNothing);
      // Existing drawings are unchanged
      expect(cubit.state.note.drawings.length, 1);
      expect(cubit.state.note.drawings.first.colorHex, '#000000');
    });

    testWidgets(
      'Changing active drawing color does not recolor existing strokes',
      (tester) async {
        cubit.setDrawingColor('#80EF4444');
        expect(cubit.state.drawingColorHex, '#80EF4444');

        // Previous stroke in note.drawings is still #000000
        expect(cubit.state.note.drawings.first.colorHex, '#000000');
      },
    );
  });
}
