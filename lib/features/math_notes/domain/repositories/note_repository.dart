import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

/// Repository interface for persisting and querying Math Notes.
abstract interface class NoteRepository {
  /// Retrieves all saved notes, sorted by updated date.
  Future<List<MathNote>> getAllNotes({bool newestFirst = true});

  /// Retrieves a specific note by ID, or null if not found.
  Future<MathNote?> getNoteById(String id);

  /// Saves or updates a note.
  Future<void> saveNote(MathNote note);

  /// Permanently deletes notes by their IDs.
  Future<void> deleteNotes(List<String> ids);

  /// Searches notes whose title or text content contains [query].
  Future<List<MathNote>> searchNotes(String query, {bool newestFirst = true});
}
