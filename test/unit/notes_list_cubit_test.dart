import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/math_notes/data/repositories/local_note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/notes_list_cubit.dart';

void main() {
  late Directory tempDir;
  late LocalNoteRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notes_list_cubit_test_');
    repository = LocalNoteRepository(directoryProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('NotesListCubit - List, Search, Sort & Selection', () {
    test('Loads notes and updates live search query', () async {
      await repository.saveNote(
        MathNote(
          id: '1',
          title: 'Linear Algebra',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repository.saveNote(
        MathNote(
          id: '2',
          title: 'Discrete Math',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final cubit = NotesListCubit(noteRepository: repository);
      await cubit.loadNotes();

      expect(cubit.state.notes.length, 2);

      // Search for 'Linear'
      await cubit.setSearchQuery('Linear');
      expect(cubit.state.notes.length, 1);
      expect(cubit.state.notes.first.title, 'Linear Algebra');

      // Clear search
      await cubit.clearSearch();
      expect(cubit.state.notes.length, 2);

      await cubit.close();
    });

    test('Toggles sort order', () async {
      final cubit = NotesListCubit(noteRepository: repository);
      expect(cubit.state.newestFirst, isTrue);

      await cubit.toggleSortOrder();
      expect(cubit.state.newestFirst, isFalse);

      await cubit.close();
    });

    test('Multi-selection mode and deleting selected notes', () async {
      await repository.saveNote(
        MathNote(
          id: 'n1',
          title: 'Note 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repository.saveNote(
        MathNote(
          id: 'n2',
          title: 'Note 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final cubit = NotesListCubit(noteRepository: repository);
      await cubit.loadNotes();

      expect(cubit.state.isSelectionMode, isFalse);

      cubit.enterSelectionMode('n1');
      expect(cubit.state.isSelectionMode, isTrue);
      expect(cubit.state.selectedIds, contains('n1'));

      cubit.toggleSelection('n2');
      expect(cubit.state.selectedIds.length, 2);

      // Delete selected notes
      await cubit.deleteSelectedNotes();

      expect(cubit.state.isSelectionMode, isFalse);
      expect(cubit.state.selectedIds, isEmpty);
      expect(cubit.state.notes, isEmpty);

      // Verify in repository
      final inRepo = await repository.getAllNotes();
      expect(inRepo, isEmpty);

      await cubit.close();
    });

    test('Select All selects all visible notes', () async {
      await repository.saveNote(
        MathNote(
          id: 'n1',
          title: 'Note 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repository.saveNote(
        MathNote(
          id: 'n2',
          title: 'Note 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final cubit = NotesListCubit(noteRepository: repository);
      await cubit.loadNotes();

      cubit.selectAll();
      expect(cubit.state.isSelectionMode, isTrue);
      expect(cubit.state.selectedIds.length, 2);

      cubit.exitSelectionMode();
      expect(cubit.state.isSelectionMode, isFalse);
      expect(cubit.state.selectedIds, isEmpty);

      await cubit.close();
    });
  });
}
