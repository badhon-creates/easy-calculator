import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

/// Represents an active or unfinished note editing session.
class NoteEditingSession {
  const NoteEditingSession({
    required this.draftNote,
    required this.isNewNote,
    required this.savedAt,
  });

  final MathNote draftNote;
  final bool isNewNote;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'draftNote': draftNote.toJson(),
    'isNewNote': isNewNote,
    'savedAt': savedAt.toIso8601String(),
  };

  factory NoteEditingSession.fromJson(Map<String, dynamic> json) {
    return NoteEditingSession(
      draftNote: MathNote.fromJson(json['draftNote'] as Map<String, dynamic>),
      isNewNote: json['isNewNote'] as bool? ?? false,
      savedAt: json['savedAt'] != null
          ? DateTime.tryParse(json['savedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
