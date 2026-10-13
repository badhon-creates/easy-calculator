import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';

/// Repository interface for autosaving and restoring in-progress note drafts.
abstract interface class NoteSessionRepository {
  /// Saves the active in-progress editing session.
  Future<void> saveSession(NoteEditingSession session);

  /// Loads the active in-progress editing session, if any.
  Future<NoteEditingSession?> loadSession();

  /// Clears the active editing session when editing finishes or cancels.
  Future<void> clearSession();
}
