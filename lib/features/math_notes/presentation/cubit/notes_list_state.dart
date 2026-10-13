import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

enum NotesListStatus { initial, loading, loaded, error }

class NotesListState {
  const NotesListState({
    this.status = NotesListStatus.initial,
    this.notes = const [],
    this.searchQuery = '',
    this.newestFirst = true,
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.errorMessage,
  });

  final NotesListStatus status;
  final List<MathNote> notes;
  final String searchQuery;
  final bool newestFirst;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final String? errorMessage;

  bool get isLoading => status == NotesListStatus.loading;
  bool get isLoaded => status == NotesListStatus.loaded;
  bool get hasActiveSearch => searchQuery.trim().isNotEmpty;

  NotesListState copyWith({
    NotesListStatus? status,
    List<MathNote>? notes,
    String? searchQuery,
    bool? newestFirst,
    bool? isSelectionMode,
    Set<String>? selectedIds,
    String? errorMessage,
  }) {
    return NotesListState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      newestFirst: newestFirst ?? this.newestFirst,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
