import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_state.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_color_picker.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/text_formatting_bottom_sheet.dart';

/// Bottom formatting toolbar for Math Notes editor:
/// - Aa: Text formatting menu (Color, Title, Heading, Subheading, Body, B, I, U)
/// - Bullet: Bullet-list tool
/// - Pencil: Freehand drawing tool
/// NOTE: Explicitly does NOT include an attachment icon as per PRD requirements.
class FormattingToolbar extends StatelessWidget {
  const FormattingToolbar({
    super.key,
    required this.cubit,
    required this.state,
  });

  final NoteEditorCubit cubit;
  final NoteEditorState state;

  @override
  Widget build(BuildContext context) {
    if (state.isDrawingMode) {
      return DrawingColorPickerToolbar(cubit: cubit, state: state);
    }

    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBulletActive = state.activeBlockType == NoteBlockType.bullet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Aa - Text Formatting Tool
            _buildToolbarButton(
              context,
              tooltip: 'Text formatting (Aa)',
              isActive:
                  state.isBold ||
                  state.isItalic ||
                  state.isUnderline ||
                  state.textColorHex != null ||
                  state.activeBlockType != NoteBlockType.body,
              child: Text(
                'Aa',
                style: TextStyle(
                  color:
                      (state.isBold ||
                          state.isItalic ||
                          state.isUnderline ||
                          state.textColorHex != null ||
                          state.activeBlockType != NoteBlockType.body)
                      ? colors.operatorText
                      : colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) =>
                      TextFormattingBottomSheet(cubit: cubit, state: state),
                );
              },
            ),

            // Bullet List Tool
            _buildToolbarButton(
              context,
              tooltip: 'Bullet list',
              isActive: isBulletActive,
              child: Icon(
                Icons.format_list_bulleted_rounded,
                color: isBulletActive
                    ? colors.operatorText
                    : colors.textPrimary,
                size: 22,
              ),
              onTap: cubit.toggleBulletList,
            ),

            // Pencil / Drawing Tool
            _buildToolbarButton(
              context,
              tooltip: 'Freehand drawing',
              isActive: state.isDrawingMode,
              child: Icon(
                Icons.edit_rounded,
                color: colors.textPrimary,
                size: 22,
              ),
              onTap: cubit.toggleDrawingMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(
    BuildContext context, {
    required Widget child,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colors = context.calcColors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: isActive ? colors.operatorButton : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
