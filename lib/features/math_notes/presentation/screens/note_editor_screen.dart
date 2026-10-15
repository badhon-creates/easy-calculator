import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/services/pdf_document_generator.dart';
import 'package:easy_calculator/features/math_notes/domain/services/note_share_service.dart';
import 'package:easy_calculator/features/math_notes/data/services/pdf_note_generator.dart';
import 'package:easy_calculator/features/math_notes/data/services/share_plus_note_share_service.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_state.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_canvas_view.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/formatting_toolbar.dart';

/// Full-featured Note Editor screen supporting rich text, bullet lists,
/// freehand drawings, undo/redo, continuous autosave, and PDF sharing.
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.note,
    required this.noteRepository,
    required this.sessionRepository,
    this.isNewNote = false,
    this.pdfGenerator = const PdfNoteGenerator(),
    this.shareService,
  });

  final MathNote note;
  final NoteRepository noteRepository;
  final NoteSessionRepository sessionRepository;
  final bool isNewNote;
  final PdfDocumentGenerator pdfGenerator;
  final NoteShareService? shareService;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen>
    with WidgetsBindingObserver {
  late final NoteEditorCubit _cubit;
  late final TextEditingController _titleController;
  late final NoteShareService _shareService;
  bool _isSharing = false;
  final Map<int, TextEditingController> _blockControllers = {};
  final Map<int, FocusNode> _blockFocusNodes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = NoteEditorCubit(
      initialNote: widget.note,
      noteRepository: widget.noteRepository,
      sessionRepository: widget.sessionRepository,
      isNewNote: widget.isNewNote,
    );
    _titleController = TextEditingController(text: widget.note.title);
    _shareService = widget.shareService ?? SharePlusNoteShareService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _cubit.saveNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    for (final c in _blockControllers.values) {
      c.dispose();
    }
    for (final f in _blockFocusNodes.values) {
      f.dispose();
    }
    _cubit.closeAndFlush();
    _cubit.close();
    super.dispose();
  }

  TextEditingController _getControllerForBlock(int index, String text) {
    if (!_blockControllers.containsKey(index)) {
      _blockControllers[index] = TextEditingController(text: text);
    } else {
      // Sync if remote/undo changed it
      if (_blockControllers[index]!.text != text) {
        _blockControllers[index]!.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
    return _blockControllers[index]!;
  }

  FocusNode _getFocusNodeForBlock(int index) {
    if (!_blockFocusNodes.containsKey(index)) {
      _blockFocusNodes[index] = FocusNode();
      _blockFocusNodes[index]!.addListener(() {
        if (_blockFocusNodes[index]!.hasFocus) {
          _cubit.setActiveBlockIndex(index);
        }
      });
    }
    return _blockFocusNodes[index]!;
  }

  void _onReturnToCalculator() {
    _cubit.closeAndFlush();
    // Return to the first route in navigator (CalculatorScreen)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onSharePressed() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Sync latest title and flush in-progress edits
      _cubit.setTitle(_titleController.text);
      await _cubit.saveNow();

      final currentNote = _cubit.state.note;
      final pdfBytes = await widget.pdfGenerator.generatePdf(currentNote);

      if (!mounted) return;
      await _shareService.shareNotePdf(currentNote, pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<NoteEditorCubit, NoteEditorState>(
        listener: (context, state) {
          // If title was undone/redone
          if (_titleController.text != state.note.title) {
            _titleController.text = state.note.title;
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) {
                _cubit.closeAndFlush();
              }
            },
            child: Scaffold(
              backgroundColor: colors.backgroundColor,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: colors.backgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: colors.textPrimary,
                  ),
                  tooltip: 'Back to notes',
                  onPressed: () {
                    _cubit.closeAndFlush();
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  // Calculator return icon
                  IconButton(
                    icon: Icon(
                      Icons.calculate_outlined,
                      color: colors.textPrimary,
                    ),
                    tooltip: 'Return to calculator',
                    onPressed: _onReturnToCalculator,
                  ),
                  // Undo button
                  IconButton(
                    icon: Icon(
                      Icons.undo_rounded,
                      color: state.canUndo
                          ? colors.textPrimary
                          : colors.disabledColor,
                    ),
                    tooltip: 'Undo',
                    onPressed: state.canUndo ? _cubit.undo : null,
                  ),
                  // Redo button
                  IconButton(
                    icon: Icon(
                      Icons.redo_rounded,
                      color: state.canRedo
                          ? colors.textPrimary
                          : colors.disabledColor,
                    ),
                    tooltip: 'Redo',
                    onPressed: state.canRedo ? _cubit.redo : null,
                  ),
                  // Share button (Phase 5)
                  IconButton(
                    icon: _isSharing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.textPrimary,
                            ),
                          )
                        : Icon(Icons.share_rounded, color: colors.textPrimary),
                    tooltip: _isSharing
                        ? 'Generating PDF...'
                        : 'Share note as PDF',
                    onPressed: _isSharing ? null : _onSharePressed,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Main note scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? 860
                                  : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Note Title field
                                TextField(
                                  controller: _titleController,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Title',
                                    hintStyle: TextStyle(
                                      color: colors.textSecondary.withValues(
                                        alpha: isDark ? 0.5 : 0.7,
                                      ),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: _cubit.setTitle,
                                ),
                                const SizedBox(height: 16),

                                // Rich Text Blocks
                                ...List.generate(state.note.blocks.length, (
                                  index,
                                ) {
                                  return _buildBlockField(
                                    context,
                                    state,
                                    index,
                                  );
                                }),

                                const SizedBox(height: 16),

                                // Freehand Drawing Section
                                if (state.isDrawingMode) ...[
                                  Text(
                                    'Drawing Canvas',
                                    style: TextStyle(
                                      color: colors.operatorButton,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2626)
                                          : const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: colors.operatorButton,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: DrawingCanvasView(
                                      strokes: state.note.drawings,
                                      currentPoints: state.currentStrokePoints,
                                      activeColorHex: state.drawingColorHex,
                                      activeStrokeWidth:
                                          state.drawingStrokeWidth,
                                      isInteractive: true,
                                      height:
                                          MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          ? 190
                                          : 260,
                                      onPanStart: (pos) =>
                                          _cubit.startStroke(pos.dx, pos.dy),
                                      onPanUpdate: (pos) =>
                                          _cubit.addStrokePoint(pos.dx, pos.dy),
                                      onPanEnd: _cubit.endStroke,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ] else if (state.note.hasDrawings) ...[
                                  // Rendered drawings viewer when not actively drawing
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Drawings',
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Edit Drawing',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () =>
                                            _cubit.setDrawingMode(true),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2626)
                                          : const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white12
                                            : colors.numberButtonBorder,
                                      ),
                                    ),
                                    child: DrawingCanvasView(
                                      strokes: state.note.drawings,
                                      isInteractive: false,
                                      height:
                                          MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          ? 170
                                          : 220,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom formatting toolbar
                    FormattingToolbar(cubit: _cubit, state: state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockField(
    BuildContext context,
    NoteEditorState state,
    int index,
  ) {
    final colors = context.calcColors;
    final block = state.note.blocks[index];
    final controller = _getControllerForBlock(index, block.plainText);
    final focusNode = _getFocusNodeForBlock(index);

    // Compute text style according to block type and spans
    TextStyle style = _getTextStyleForBlock(colors, block);

    final isBullet = block.type == NoteBlockType.bullet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBullet)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Text(
                '•',
                style: TextStyle(
                  color: colors.operatorButton,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: style,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: isBullet
                    ? 'List item...'
                    : (index == 0 ? 'Start typing...' : ''),
                hintStyle: TextStyle(
                  color: colors.textSecondary.withValues(alpha: 0.4),
                  fontSize: style.fontSize,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
              ),
              onChanged: (text) => _cubit.updateBlockText(index, text),
              onSubmitted: (_) {
                _cubit.handleEnter(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getTextStyleForBlock(CalculatorColors colors, NoteBlock block) {
    double fontSize = 16.0;
    FontWeight fontWeight = FontWeight.normal;

    switch (block.type) {
      case NoteBlockType.title:
        fontSize = 26.0;
        fontWeight = FontWeight.bold;
        break;
      case NoteBlockType.heading:
        fontSize = 22.0;
        fontWeight = FontWeight.bold;
        break;
      case NoteBlockType.subheading:
        fontSize = 18.0;
        fontWeight = FontWeight.w600;
        break;
      case NoteBlockType.body:
      case NoteBlockType.bullet:
        fontSize = 16.0;
        fontWeight = FontWeight.normal;
        break;
    }

    bool isItalic = false;
    bool isUnderline = false;
    Color textColor = colors.textPrimary;

    if (block.spans.isNotEmpty) {
      final span = block.spans.first;
      if (span.isBold) fontWeight = FontWeight.bold;
      if (span.isItalic) isItalic = true;
      if (span.isUnderline) isUnderline = true;
      if (span.colorHex != null) {
        textColor = parseHexColor(span.colorHex!, fallback: colors.textPrimary);
      }
    }

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
      height: 1.4,
    );
  }
}
