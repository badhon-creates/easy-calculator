import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/notes_list_state.dart';

class NotesListCubit extends Cubit<NotesListState> {
  NotesListCubit({required this.noteRepository})
    : super(const NotesListState());

  final NoteRepository noteRepository;

  /// Loads all notes, applying current search query and sort preference.
  Future<void> loadNotes() async {
    emit(state.copyWith(status: NotesListStatus.loading));
    try {
      final notes = state.hasActiveSearch
          ? await noteRepository.searchNotes(
              state.searchQuery,
              newestFirst: state.newestFirst,
            )
          : await noteRepository.getAllNotes(newestFirst: state.newestFirst);

      emit(state.copyWith(status: NotesListStatus.loaded, notes: notes));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotesListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Sets live search query and updates visible notes.
  Future<void> setSearchQuery(String query) async {
    emit(state.copyWith(searchQuery: query));
    await loadNotes();
  }

  /// Clears the current search query.
  Future<void> clearSearch() async {
    emit(state.copyWith(searchQuery: ''));
    await loadNotes();
  }

  /// Toggles sort order between newest first and oldest first.
  Future<void> toggleSortOrder() async {
    final nextNewestFirst = !state.newestFirst;
    emit(state.copyWith(newestFirst: nextNewestFirst));
    await loadNotes();
  }

  /// Sets specific sort order.
  Future<void> setSortOrder({required bool newestFirst}) async {
    if (state.newestFirst == newestFirst) return;
    emit(state.copyWith(newestFirst: newestFirst));
    await loadNotes();
  }

  /// Enters selection mode, optionally selecting an initial note.
  void enterSelectionMode([String? initialId]) {
    emit(
      state.copyWith(
        isSelectionMode: true,
        selectedIds: initialId != null ? {initialId} : {},
      ),
    );
  }

  /// Exits selection mode and clears selected note IDs.
  void exitSelectionMode() {
    emit(state.copyWith(isSelectionMode: false, selectedIds: {}));
  }

  /// Toggles selection of a note by ID.
  void toggleSelection(String id) {
    final current = Set<String>.from(state.selectedIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }

    emit(
      state.copyWith(
        selectedIds: current,
        isSelectionMode: current.isNotEmpty || state.isSelectionMode,
      ),
    );
  }

  /// Selects all currently visible notes.
  void selectAll() {
    final allIds = state.notes.map((n) => n.id).toSet();
    emit(state.copyWith(isSelectionMode: true, selectedIds: allIds));
  }

  /// Permanently deletes currently selected notes and refreshes list.
  Future<void> deleteSelectedNotes() async {
    if (state.selectedIds.isEmpty) return;
    try {
      await noteRepository.deleteNotes(state.selectedIds.toList());
      emit(state.copyWith(selectedIds: {}, isSelectionMode: false));
      await loadNotes();
    } catch (e) {
      emit(
        state.copyWith(
          status: NotesListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Permanently deletes a single note by ID.
  Future<void> deleteSingleNote(String id) async {
    try {
      await noteRepository.deleteNotes([id]);
      await loadNotes();
    } catch (e) {
      emit(
        state.copyWith(
          status: NotesListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
