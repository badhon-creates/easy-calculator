import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';

class NoteEditorState {
  const NoteEditorState({
    required this.note,
    this.activeBlockIndex = 0,
    this.activeBlockType = NoteBlockType.body,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.textColorHex,
    this.isDrawingMode = false,
    this.drawingColorHex = '#64AFFA',
    this.drawingStrokeWidth = 3.0,
    this.currentStrokePoints = const [],
    this.canUndo = false,
    this.canRedo = false,
    this.isAutosaving = false,
  });

  final MathNote note;
  final int activeBlockIndex;
  final NoteBlockType activeBlockType;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final String? textColorHex;

  final bool isDrawingMode;
  final String drawingColorHex;
  final double drawingStrokeWidth;
  final List<StrokePoint> currentStrokePoints;

  final bool canUndo;
  final bool canRedo;
  final bool isAutosaving;

  NoteEditorState copyWith({
    MathNote? note,
    int? activeBlockIndex,
    NoteBlockType? activeBlockType,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    String? textColorHex,
    bool clearTextColor = false,
    bool? isDrawingMode,
    String? drawingColorHex,
    double? drawingStrokeWidth,
    List<StrokePoint>? currentStrokePoints,
    bool? canUndo,
    bool? canRedo,
    bool? isAutosaving,
  }) {
    return NoteEditorState(
      note: note ?? this.note,
      activeBlockIndex: activeBlockIndex ?? this.activeBlockIndex,
      activeBlockType: activeBlockType ?? this.activeBlockType,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      textColorHex: clearTextColor ? null : (textColorHex ?? this.textColorHex),
      isDrawingMode: isDrawingMode ?? this.isDrawingMode,
      drawingColorHex: drawingColorHex ?? this.drawingColorHex,
      drawingStrokeWidth: drawingStrokeWidth ?? this.drawingStrokeWidth,
      currentStrokePoints: currentStrokePoints ?? this.currentStrokePoints,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      isAutosaving: isAutosaving ?? this.isAutosaving,
    );
  }
}
