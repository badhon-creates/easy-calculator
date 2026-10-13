import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/math_notes/data/repositories/local_note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';

void main() {
  late Directory tempDir;
  late LocalNoteRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('math_notes_test_');
    repository = LocalNoteRepository(directoryProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalNoteRepository - Core Persistence & Rich Content', () {
    test(
      'Saves, retrieves, and updates notes with full rich text and drawings',
      () async {
        final initialNotes = await repository.getAllNotes();
        expect(initialNotes, isEmpty);

        final note = MathNote(
          id: 'note_1',
          title: 'Trigonometry Notes',
          blocks: const [
            NoteBlock(
              id: 'b1',
              type: NoteBlockType.heading,
              spans: [
                TextSpanData(
                  text: 'Unit Circle Overview',
                  isBold: true,
                  colorHex: '#64AFFA',
                ),
              ],
            ),
            NoteBlock(
              id: 'b2',
              type: NoteBlockType.bullet,
              spans: [
                TextSpanData(text: 'sin(x)^2 + cos(x)^2 = 1', isItalic: true),
              ],
            ),
          ],
          drawings: const [
            DrawingStroke(
              points: [StrokePoint(x: 10, y: 10), StrokePoint(x: 50, y: 50)],
              colorHex: '#64AFFA',
              strokeWidth: 3.5,
            ),
          ],
          createdAt: DateTime(2026, 10, 1),
          updatedAt: DateTime(2026, 10, 1),
        );

        await repository.saveNote(note);

        final retrieved = await repository.getAllNotes();
        expect(retrieved.length, 1);
        final loaded = retrieved.first;
        expect(loaded.id, 'note_1');
        expect(loaded.title, 'Trigonometry Notes');
        expect(loaded.blocks.length, 2);
        expect(loaded.blocks[0].type, NoteBlockType.heading);
        expect(loaded.blocks[0].spans.first.isBold, isTrue);
        expect(loaded.blocks[0].spans.first.colorHex, '#64AFFA');
        expect(loaded.blocks[1].type, NoteBlockType.bullet);
        expect(loaded.blocks[1].spans.first.isItalic, isTrue);
        expect(loaded.drawings.length, 1);
        expect(loaded.drawings.first.strokeWidth, 3.5);
        expect(loaded.drawings.first.points.length, 2);
      },
    );

    test(
      'Searches notes by title and body content (case-insensitive)',
      () async {
        final note1 = MathNote(
          id: 'n1',
          title: 'Calculus Derivatives',
          blocks: const [
            NoteBlock(
              id: 'b1',
              type: NoteBlockType.body,
              spans: [TextSpanData(text: 'Power rule: d/dx(x^n) = n*x^(n-1)')],
            ),
          ],
          createdAt: DateTime(2026, 10, 2),
          updatedAt: DateTime(2026, 10, 2),
        );

        final note2 = MathNote(
          id: 'n2',
          title: 'Physics Mechanics',
          blocks: const [
            NoteBlock(
              id: 'b2',
              type: NoteBlockType.body,
              spans: [TextSpanData(text: 'Newton second law F = ma')],
            ),
          ],
          createdAt: DateTime(2026, 10, 3),
          updatedAt: DateTime(2026, 10, 3),
        );

        await repository.saveNote(note1);
        await repository.saveNote(note2);

        // Search by title
        final searchTitle = await repository.searchNotes('calculus');
        expect(searchTitle.length, 1);
        expect(searchTitle.first.id, 'n1');

        // Search by content
        final searchContent = await repository.searchNotes('newton');
        expect(searchContent.length, 1);
        expect(searchContent.first.id, 'n2');

        // Search matching both
        final searchEmpty = await repository.searchNotes('   ');
        expect(searchEmpty.length, 2);

        // Search matching none
        final searchNone = await repository.searchNotes('astronomy');
        expect(searchNone, isEmpty);
      },
    );

    test(
      'Sorts notes correctly by updated date (newest first vs oldest first)',
      () async {
        final noteOld = MathNote(
          id: 'old',
          title: 'Old Note',
          createdAt: DateTime(2026, 10, 1),
          updatedAt: DateTime(2026, 10, 1),
        );
        final noteNew = MathNote(
          id: 'new',
          title: 'New Note',
          createdAt: DateTime(2026, 10, 5),
          updatedAt: DateTime(2026, 10, 5),
        );

        await repository.saveNote(noteOld);
        await repository.saveNote(noteNew);

        final newest = await repository.getAllNotes(newestFirst: true);
        expect(newest.first.id, 'new');
        expect(newest.last.id, 'old');

        final oldest = await repository.getAllNotes(newestFirst: false);
        expect(oldest.first.id, 'old');
        expect(oldest.last.id, 'new');
      },
    );

    test(
      'Permanently deletes selected notes and drawing data without returning',
      () async {
        final note1 = MathNote(
          id: 'del_1',
          title: 'To Delete 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final note2 = MathNote(
          id: 'del_2',
          title: 'To Delete 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final noteKeep = MathNote(
          id: 'keep',
          title: 'To Keep',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.saveNote(note1);
        await repository.saveNote(note2);
        await repository.saveNote(noteKeep);

        // Delete two notes
        await repository.deleteNotes(['del_1', 'del_2']);

        final remaining = await repository.getAllNotes();
        expect(remaining.length, 1);
        expect(remaining.first.id, 'keep');

        // Simulate app restart with a fresh repository instance
        final restartRepo = LocalNoteRepository(
          directoryProvider: () async => tempDir,
        );
        final reloaded = await restartRepo.getAllNotes();
        expect(reloaded.length, 1);
        expect(reloaded.first.id, 'keep');
      },
    );

    test('Notes NEVER expire after 7 calendar days', () async {
      // Create a note with timestamp from 30 calendar days ago
      final ancientNote = MathNote(
        id: 'ancient',
        title: 'Ancient Note From A Month Ago',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      await repository.saveNote(ancientNote);

      final loaded = await repository.getAllNotes();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'ancient');
      expect(loaded.first.title, 'Ancient Note From A Month Ago');
    });

    test(
      'Recovers gracefully from corrupted or malformed file without crash',
      () async {
        final file = File('${tempDir.path}/easy_calc_notes.json');
        await file.writeAsString('{ corrupted json payload !!!@@@###');

        final notes = await repository.getAllNotes();
        expect(notes, isEmpty);

        // Can save a new note normally after corruption
        final validNote = MathNote(
          id: 'recovered',
          title: 'Valid Note',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveNote(validNote);
        final afterSave = await repository.getAllNotes();
        expect(afterSave.length, 1);
        expect(afterSave.first.id, 'recovered');
      },
    );
  });
}
