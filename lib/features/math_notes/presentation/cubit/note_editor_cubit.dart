import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  NoteEditorCubit({
    required MathNote initialNote,
    required this.noteRepository,
    required this.sessionRepository,
    this.isNewNote = false,
  }) : super(
         NoteEditorState(
           note: initialNote,
           activeBlockType: initialNote.blocks.isNotEmpty
               ? initialNote.blocks.first.type
               : NoteBlockType.body,
         ),
       ) {
    // Save initial state for undo
    _undoStack.add(initialNote);
  }

  final NoteRepository noteRepository;
  final NoteSessionRepository sessionRepository;
  final bool isNewNote;

  final List<MathNote> _undoStack = [];
  final List<MathNote> _redoStack = [];
  Timer? _autosaveTimer;
  static const Duration _autosaveDebounce = Duration(milliseconds: 300);

  void _recordSnapshot(MathNote note) {
    if (_undoStack.isNotEmpty && _undoStack.last == note) return;
    _undoStack.add(note);
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    _updateUndoRedoStatus();
  }

  void _updateUndoRedoStatus() {
    emit(
      state.copyWith(
        canUndo: _undoStack.length > 1,
        canRedo: _redoStack.isNotEmpty,
      ),
    );
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () {
      saveNow();
    });
  }

  /// Sets the note title.
  void setTitle(String title) {
    if (state.note.title == title) return;
    final updatedNote = state.note.copyWith(title: title);
    _recordSnapshot(updatedNote);
    emit(state.copyWith(note: updatedNote));
    _scheduleAutosave();
  }

  /// Sets the active block index and syncs formatting attributes.
  void setActiveBlockIndex(int index) {
    if (index < 0 || index >= state.note.blocks.length) return;
    final block = state.note.blocks[index];
    emit(state.copyWith(activeBlockIndex: index, activeBlockType: block.type));
  }

  /// Updates plain text content of a block at [index], preserving or applying inline styles.
  void updateBlockText(int index, String text) {
    if (index < 0 || index >= state.note.blocks.length) return;
    final blocks = List<NoteBlock>.from(state.note.blocks);
    final currentBlock = blocks[index];

    // Create or update text span
    final span = TextSpanData(
      text: text,
      isBold: state.isBold,
      isItalic: state.isItalic,
      isUnderline: state.isUnderline,
      colorHex: state.textColorHex,
    );

    blocks[index] = currentBlock.copyWith(spans: [span]);
    final updatedNote = state.note.copyWith(blocks: blocks);
    _recordSnapshot(updatedNote);
    emit(state.copyWith(note: updatedNote));
    _scheduleAutosave();
  }

  /// Changes the block type (e.g. title, heading, body, bullet) of the current block.
  void setBlockType(NoteBlockType type, {int? index}) {
    final targetIndex = index ?? state.activeBlockIndex;
    if (targetIndex < 0 || targetIndex >= state.note.blocks.length) return;

    final blocks = List<NoteBlock>.from(state.note.blocks);
    blocks[targetIndex] = blocks[targetIndex].copyWith(type: type);

    final updatedNote = state.note.copyWith(blocks: blocks);
    _recordSnapshot(updatedNote);
    emit(state.copyWith(note: updatedNote, activeBlockType: type));
    _scheduleAutosave();
  }

  /// Toggles bullet list formatting on the active block.
  void toggleBulletList() {
    final nextType = state.activeBlockType == NoteBlockType.bullet
        ? NoteBlockType.body
        : NoteBlockType.bullet;
    setBlockType(nextType);
  }

  /// Handles Enter key in the rich text editor.
  ///
  /// - If the current block is a bullet and is empty, exits bullet mode.
  /// - If the current block is a populated bullet, creates a new bullet block.
  /// - Otherwise, creates a new standard body block.
  void handleEnter(int index) {
    if (index < 0 || index >= state.note.blocks.length) return;
    final currentBlock = state.note.blocks[index];
    final blocks = List<NoteBlock>.from(state.note.blocks);

    if (currentBlock.type == NoteBlockType.bullet &&
        currentBlock.plainText.trim().isEmpty) {
      // Empty bullet -> exit bullet mode to body
      blocks[index] = currentBlock.copyWith(type: NoteBlockType.body);
      final updatedNote = state.note.copyWith(blocks: blocks);
      _recordSnapshot(updatedNote);
      emit(
        state.copyWith(note: updatedNote, activeBlockType: NoteBlockType.body),
      );
      _scheduleAutosave();
      return;
    }

    // Insert new block
    final nextType = currentBlock.type == NoteBlockType.bullet
        ? NoteBlockType.bullet
        : NoteBlockType.body;

    final newBlock = NoteBlock(
      id: 'block_${DateTime.now().microsecondsSinceEpoch}',
      type: nextType,
      spans: [
        TextSpanData(
          text: '',
          isBold: state.isBold,
          isItalic: state.isItalic,
          isUnderline: state.isUnderline,
          colorHex: state.textColorHex,
        ),
      ],
    );

    blocks.insert(index + 1, newBlock);
    final updatedNote = state.note.copyWith(blocks: blocks);
    _recordSnapshot(updatedNote);
    emit(
      state.copyWith(
        note: updatedNote,
        activeBlockIndex: index + 1,
        activeBlockType: nextType,
      ),
    );
    _scheduleAutosave();
  }

  /// Removes an empty block if backspace is pressed and multiple blocks exist.
  void removeBlockIfEmpty(int index) {
    if (state.note.blocks.length <= 1) return;
    if (index < 0 || index >= state.note.blocks.length) return;
    final block = state.note.blocks[index];
    if (block.plainText.isNotEmpty) return;

    final blocks = List<NoteBlock>.from(state.note.blocks);
    blocks.removeAt(index);
    final nextIndex = (index - 1).clamp(0, blocks.length - 1);

    final updatedNote = state.note.copyWith(blocks: blocks);
    _recordSnapshot(updatedNote);
    emit(
      state.copyWith(
        note: updatedNote,
        activeBlockIndex: nextIndex,
        activeBlockType: blocks[nextIndex].type,
      ),
    );
    _scheduleAutosave();
  }

  // --- Inline formatting toggles ---

  void toggleBold() {
    final next = !state.isBold;
    emit(state.copyWith(isBold: next));
    _reapplyCurrentBlockStyles();
  }

  void toggleItalic() {
    final next = !state.isItalic;
    emit(state.copyWith(isItalic: next));
    _reapplyCurrentBlockStyles();
  }

  void toggleUnderline() {
    final next = !state.isUnderline;
    emit(state.copyWith(isUnderline: next));
    _reapplyCurrentBlockStyles();
  }

  void setTextColor(String? hex) {
    emit(state.copyWith(textColorHex: hex, clearTextColor: hex == null));
    _reapplyCurrentBlockStyles();
  }

  void _reapplyCurrentBlockStyles() {
    final idx = state.activeBlockIndex;
    if (idx >= 0 && idx < state.note.blocks.length) {
      final block = state.note.blocks[idx];
      updateBlockText(idx, block.plainText);
    }
  }

  // --- Drawing operations ---

  void toggleDrawingMode() {
    emit(state.copyWith(isDrawingMode: !state.isDrawingMode));
  }

  void setDrawingMode(bool enabled) {
    emit(state.copyWith(isDrawingMode: enabled));
  }

  void setDrawingColor(String hex) {
    emit(state.copyWith(drawingColorHex: hex));
  }

  void setDrawingStrokeWidth(double width) {
    emit(state.copyWith(drawingStrokeWidth: width));
  }

  void startStroke(double x, double y) {
    emit(
      state.copyWith(
        currentStrokePoints: [StrokePoint(x: x, y: y)],
      ),
    );
  }

  void addStrokePoint(double x, double y) {
    final points = List<StrokePoint>.from(state.currentStrokePoints)
      ..add(StrokePoint(x: x, y: y));
    emit(state.copyWith(currentStrokePoints: points));
  }

  void endStroke() {
    if (state.currentStrokePoints.isEmpty) return;
    final stroke = DrawingStroke(
      points: List<StrokePoint>.from(state.currentStrokePoints),
      colorHex: state.drawingColorHex,
      strokeWidth: state.drawingStrokeWidth,
    );

    final drawings = List<DrawingStroke>.from(state.note.drawings)..add(stroke);
    final updatedNote = state.note.copyWith(drawings: drawings);
    _recordSnapshot(updatedNote);

    emit(state.copyWith(note: updatedNote, currentStrokePoints: const []));
    _scheduleAutosave();
  }

  void clearDrawings() {
    if (state.note.drawings.isEmpty) return;
    final updatedNote = state.note.copyWith(drawings: const []);
    _recordSnapshot(updatedNote);
    emit(state.copyWith(note: updatedNote));
    _scheduleAutosave();
  }

  // --- Undo / Redo ---

  void undo() {
    if (_undoStack.length <= 1) return;
    final current = _undoStack.removeLast();
    _redoStack.add(current);
    final previous = _undoStack.last;

    emit(
      state.copyWith(
        note: previous,
        activeBlockIndex: state.activeBlockIndex.clamp(
          0,
          previous.blocks.length - 1,
        ),
        activeBlockType: previous.blocks.isNotEmpty
            ? previous
                  .blocks[state.activeBlockIndex.clamp(
                    0,
                    previous.blocks.length - 1,
                  )]
                  .type
            : NoteBlockType.body,
      ),
    );
    _updateUndoRedoStatus();
    _scheduleAutosave();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    _undoStack.add(next);

    emit(
      state.copyWith(
        note: next,
        activeBlockIndex: state.activeBlockIndex.clamp(
          0,
          next.blocks.length - 1,
        ),
        activeBlockType: next.blocks.isNotEmpty
            ? next
                  .blocks[state.activeBlockIndex.clamp(
                    0,
                    next.blocks.length - 1,
                  )]
                  .type
            : NoteBlockType.body,
      ),
    );
    _updateUndoRedoStatus();
    _scheduleAutosave();
  }

  // --- Persistence & Autosave ---

  Future<void> saveNow() async {
    _autosaveTimer?.cancel();
    if (state.isAutosaving) return;

    emit(state.copyWith(isAutosaving: true));
    try {
      if (!state.note.isEmpty) {
        await noteRepository.saveNote(state.note);
        await sessionRepository.saveSession(
          NoteEditingSession(
            draftNote: state.note,
            isNewNote: isNewNote,
            savedAt: DateTime.now(),
          ),
        );
      }
    } catch (_) {
      // Handled gracefully without crash
    } finally {
      emit(state.copyWith(isAutosaving: false));
    }
  }

  /// Called when user leaves the editor: saves if non-empty, clears draft session.
  Future<void> closeAndFlush() async {
    _autosaveTimer?.cancel();
    if (!state.note.isEmpty) {
      await noteRepository.saveNote(state.note);
    }
    await sessionRepository.clearSession();
  }

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }
}
