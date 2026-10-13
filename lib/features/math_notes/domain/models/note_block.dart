/// Supported block types for Math Notes content.
enum NoteBlockType {
  title,
  heading,
  subheading,
  body,
  bullet;

  String get displayName {
    switch (this) {
      case NoteBlockType.title:
        return 'Title';
      case NoteBlockType.heading:
        return 'Heading';
      case NoteBlockType.subheading:
        return 'Subheading';
      case NoteBlockType.body:
        return 'Body';
      case NoteBlockType.bullet:
        return 'Bullet';
    }
  }

  static NoteBlockType fromString(String? val) {
    switch (val) {
      case 'title':
        return NoteBlockType.title;
      case 'heading':
        return NoteBlockType.heading;
      case 'subheading':
        return NoteBlockType.subheading;
      case 'bullet':
        return NoteBlockType.bullet;
      case 'body':
      default:
        return NoteBlockType.body;
    }
  }
}

/// A formatted text segment with inline styles and color.
class TextSpanData {
  const TextSpanData({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.colorHex,
  });

  final String text;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final String? colorHex;

  Map<String, dynamic> toJson() => {
    'text': text,
    'isBold': isBold,
    'isItalic': isItalic,
    'isUnderline': isUnderline,
    if (colorHex != null) 'colorHex': colorHex,
  };

  factory TextSpanData.fromJson(Map<String, dynamic> json) {
    return TextSpanData(
      text: json['text'] as String? ?? '',
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      colorHex: json['colorHex'] as String?,
    );
  }

  TextSpanData copyWith({
    String? text,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    String? colorHex,
  }) {
    return TextSpanData(
      text: text ?? this.text,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSpanData &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isBold == other.isBold &&
          isItalic == other.isItalic &&
          isUnderline == other.isUnderline &&
          colorHex == other.colorHex;

  @override
  int get hashCode =>
      Object.hash(text, isBold, isItalic, isUnderline, colorHex);
}

/// A structural block (paragraph, heading, bullet line) in a note.
class NoteBlock {
  const NoteBlock({
    required this.id,
    this.type = NoteBlockType.body,
    this.spans = const [],
  });

  final String id;
  final NoteBlockType type;
  final List<TextSpanData> spans;

  /// Plain text content of this block.
  String get plainText => spans.map((s) => s.text).join();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'spans': spans.map((s) => s.toJson()).toList(),
  };

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    return NoteBlock(
      id: json['id'] as String? ?? '',
      type: NoteBlockType.fromString(json['type'] as String?),
      spans: (json['spans'] as List<dynamic>? ?? [])
          .map((s) => TextSpanData.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  NoteBlock copyWith({
    String? id,
    NoteBlockType? type,
    List<TextSpanData>? spans,
  }) {
    return NoteBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      spans: spans ?? this.spans,
    );
  }
}
