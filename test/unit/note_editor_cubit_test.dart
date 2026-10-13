import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/math_notes/data/repositories/local_note_repository.dart';
import 'package:easy_calculator/features/math_notes/data/repositories/local_note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_cubit.dart';

void main() {
  late Directory tempDir;
  late LocalNoteRepository noteRepo;
  late LocalNoteSessionRepository sessionRepo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('note_editor_test_');
    noteRepo = LocalNoteRepository(directoryProvider: () async => tempDir);
    sessionRepo = LocalNoteSessionRepository(
      directoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('NoteEditorCubit - Rich Text Formatting & Operations', () {
    test(
      'Sets title and applies block styling (Heading, Subheading, Title, Body)',
      () {
        final initialNote = MathNote.empty(id: 'test_1');
        final cubit = NoteEditorCubit(
          initialNote: initialNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
        );

        cubit.setTitle('My Geometry Notes');
        expect(cubit.state.note.title, 'My Geometry Notes');

        // Change block type to heading
        cubit.setBlockType(NoteBlockType.heading);
        expect(cubit.state.activeBlockType, NoteBlockType.heading);
        expect(cubit.state.note.blocks.first.type, NoteBlockType.heading);

        // Change block type to subheading
        cubit.setBlockType(NoteBlockType.subheading);
        expect(cubit.state.activeBlockType, NoteBlockType.subheading);
        expect(cubit.state.note.blocks.first.type, NoteBlockType.subheading);

        cubit.close();
      },
    );

    test('Applies inline formatting: bold, italic, underline, and custom text color', () {
      final initialNote = MathNote.empty(id: 'test_2');
      final cubit = NoteEditorCubit(
        initialNote: initialNote,
        noteRepository: noteRepo,
        sessionRepository: sessionRepo,
      );

      cubit.toggleBold();
      cubit.toggleItalic();
      cubit.toggleUnderline();
      cubit.setTextColor('#64AFFA');

      expect(cubit.state.isBold, isTrue);
      expect(cubit.state.isItalic, isTrue);
      expect(cubit.state.isUnderline, isTrue);
      expect(cubit.state.textColorHex, '#64AFFA');

      cubit.updateBlockText(0, 'Hypotenuse formula');
      final span = cubit.state.note.blocks.first.spans.first;
      expect(span.text, 'Hypotenuse formula');
      expect(span.isBold, isTrue);
      expect(span.isItalic, isTrue);
      expect(span.isUnderline, isTrue);
      expect(span.colorHex, '#64AFFA');

      cubit.close();
    });

    test(
      'Bullet list: Populated bullet on Enter creates next bullet block',
      () {
        final initialNote = MathNote.empty(id: 'test_bullet_1');
        final cubit = NoteEditorCubit(
          initialNote: initialNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
        );

        // Toggle bullet list
        cubit.toggleBulletList();
        expect(cubit.state.activeBlockType, NoteBlockType.bullet);

        // Populate bullet text
        cubit.updateBlockText(0, 'First list item');

        // Press Enter on populated bullet
        cubit.handleEnter(0);

        expect(cubit.state.note.blocks.length, 2);
        expect(cubit.state.note.blocks[0].type, NoteBlockType.bullet);
        expect(cubit.state.note.blocks[0].plainText, 'First list item');
        expect(cubit.state.note.blocks[1].type, NoteBlockType.bullet);
        expect(cubit.state.note.blocks[1].plainText, '');
        expect(cubit.state.activeBlockIndex, 1);
        expect(cubit.state.activeBlockType, NoteBlockType.bullet);

        cubit.close();
      },
    );

    test(
      'Bullet list: Empty bullet on Enter exits bullet list mode to body',
      () {
        final initialNote = MathNote.empty(id: 'test_bullet_2');
        final cubit = NoteEditorCubit(
          initialNote: initialNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
        );

        cubit.toggleBulletList();
        expect(cubit.state.activeBlockType, NoteBlockType.bullet);

        // Current bullet is empty -> press Enter
        cubit.handleEnter(0);

        expect(cubit.state.note.blocks.length, 1);
        expect(cubit.state.note.blocks.first.type, NoteBlockType.body);
        expect(cubit.state.activeBlockType, NoteBlockType.body);

        cubit.close();
      },
    );
  });

  group('NoteEditorCubit - Freehand Drawing & Vector Preservation', () {
    test(
      'Draws freehand strokes, preserves vector geometry, color, and width',
      () {
        final initialNote = MathNote.empty(id: 'test_draw');
        final cubit = NoteEditorCubit(
          initialNote: initialNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
        );

        cubit.setDrawingMode(true);
        cubit.setDrawingColor('#EF4444');
        cubit.setDrawingStrokeWidth(4.5);

        cubit.startStroke(10.0, 20.0);
        cubit.addStrokePoint(15.0, 25.0);
        cubit.addStrokePoint(30.0, 40.0);
        cubit.endStroke();

        expect(cubit.state.note.drawings.length, 1);
        final stroke = cubit.state.note.drawings.first;
        expect(stroke.colorHex, '#EF4444');
        expect(stroke.strokeWidth, 4.5);
        expect(stroke.points.length, 3);
        expect(stroke.points[0].x, 10.0);
        expect(stroke.points[0].y, 20.0);
        expect(stroke.points[2].x, 30.0);
        expect(stroke.points[2].y, 40.0);

        // Drawing does not corrupt or erase typed blocks
        expect(cubit.state.note.blocks.isNotEmpty, isTrue);

        cubit.close();
      },
    );

    test('Clears drawings properly', () {
      final initialNote = MathNote.empty(id: 'test_draw_clear');
      final cubit = NoteEditorCubit(
        initialNote: initialNote,
        noteRepository: noteRepo,
        sessionRepository: sessionRepo,
      );

      cubit.startStroke(5, 5);
      cubit.endStroke();
      expect(cubit.state.note.drawings.length, 1);

      cubit.clearDrawings();
      expect(cubit.state.note.drawings, isEmpty);

      cubit.close();
    });
  });

  group('NoteEditorCubit - Undo & Redo', () {
    test('Undo reverses typing and formatting edits, redo reapplies them', () {
      final initialNote = MathNote.empty(id: 'test_undo');
      final cubit = NoteEditorCubit(
        initialNote: initialNote,
        noteRepository: noteRepo,
        sessionRepository: sessionRepo,
      );

      expect(cubit.state.canUndo, isFalse);

      cubit.setTitle('Original Title');
      expect(cubit.state.canUndo, isTrue);

      cubit.setTitle('Updated Title');
      expect(cubit.state.note.title, 'Updated Title');

      cubit.undo();
      expect(cubit.state.note.title, 'Original Title');
      expect(cubit.state.canRedo, isTrue);

      cubit.redo();
      expect(cubit.state.note.title, 'Updated Title');

      cubit.close();
    });
  });

  group('NoteEditorCubit - Autosave & Session Draft Persistence', () {
    test('Autosaves note to repository and saves session draft', () async {
      final initialNote = MathNote.empty(id: 'test_autosave');
      final cubit = NoteEditorCubit(
        initialNote: initialNote,
        noteRepository: noteRepo,
        sessionRepository: sessionRepo,
        isNewNote: true,
      );

      cubit.setTitle('Autosave Note');
      cubit.updateBlockText(0, 'Important mathematical thoughts');

      // Force immediate flush
      await cubit.saveNow();

      final saved = await noteRepo.getNoteById('test_autosave');
      expect(saved, isNotNull);
      expect(saved!.title, 'Autosave Note');
      expect(saved.plainTextPreview, 'Important mathematical thoughts');

      // Session draft was also persisted
      final session = await sessionRepo.loadSession();
      expect(session, isNotNull);
      expect(session!.draftNote.id, 'test_autosave');
      expect(session.isNewNote, isTrue);

      // Exiting editor via closeAndFlush clears the temporary draft session
      await cubit.closeAndFlush();
      final sessionAfterClose = await sessionRepo.loadSession();
      expect(sessionAfterClose, isNull);

      await cubit.close();
    });
  });
}
