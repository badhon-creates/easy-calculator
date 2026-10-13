import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';

/// Complete domain representation of a Math Note.
class MathNote {
  const MathNote({
    required this.id,
    required this.title,
    this.blocks = const [],
    this.drawings = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<NoteBlock> blocks;
  final List<DrawingStroke> drawings;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether the note has any freehand drawings.
  bool get hasDrawings => drawings.isNotEmpty;

  /// Whether the note has no title, no blocks with text, and no drawings.
  bool get isEmpty =>
      title.trim().isEmpty &&
      blocks.every((b) => b.plainText.trim().isEmpty) &&
      drawings.isEmpty;

  /// Plain text preview of the note content (combining first few blocks).
  String get plainTextPreview {
    final buffer = StringBuffer();
    for (final block in blocks) {
      final text = block.plainText.trim();
      if (text.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write(' ');
        if (block.type == NoteBlockType.bullet) {
          buffer.write('• ');
        }
        buffer.write(text);
      }
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'blocks': blocks.map((b) => b.toJson()).toList(),
    'drawings': drawings.map((d) => d.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MathNote.fromJson(Map<String, dynamic> json) {
    return MathNote(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .map((b) => NoteBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
      drawings: (json['drawings'] as List<dynamic>? ?? [])
          .map((d) => DrawingStroke.fromJson(d as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MathNote copyWith({
    String? id,
    String? title,
    List<NoteBlock>? blocks,
    List<DrawingStroke>? drawings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MathNote(
      id: id ?? this.id,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      drawings: drawings ?? this.drawings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a blank note with a default body block.
  factory MathNote.empty({String? id}) {
    final now = DateTime.now();
    final noteId = id ?? 'note_${now.millisecondsSinceEpoch}';
    return MathNote(
      id: noteId,
      title: '',
      blocks: const [
        NoteBlock(
          id: 'block_0',
          type: NoteBlockType.body,
          spans: [TextSpanData(text: '')],
        ),
      ],
      drawings: const [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
