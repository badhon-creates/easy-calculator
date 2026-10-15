import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_state.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_canvas_view.dart';

/// Bottom modal/panel exposing rich text formatting controls:
/// - Styles: Title, Heading, Subheading, Body
/// - Inline toggles: Bold, Italic, Underline
/// - Text color picker
class TextFormattingBottomSheet extends StatelessWidget {
  const TextFormattingBottomSheet({
    super.key,
    required this.cubit,
    required this.state,
  });

  final NoteEditorCubit cubit;
  final NoteEditorState state;

  static const List<Map<String, String>> _palette = [
    {'name': 'Default', 'hex': ''},
    {'name': 'Blue', 'hex': '#64AFFA'},
    {'name': 'Green', 'hex': '#10B981'},
    {'name': 'Red', 'hex': '#EF4444'},
    {'name': 'Purple', 'hex': '#8B5CF6'},
    {'name': 'Orange', 'hex': '#F59E0B'},
    {'name': 'Black', 'hex': '#000000'},
    {'name': 'White', 'hex': '#FFFFFF'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.disabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Text Formatting',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Style selector: Title, Heading, Subheading, Body
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStyleChip(
                      context,
                      type: NoteBlockType.title,
                      label: 'Title',
                      isSelected: state.activeBlockType == NoteBlockType.title,
                    ),
                    const SizedBox(width: 8),
                    _buildStyleChip(
                      context,
                      type: NoteBlockType.heading,
                      label: 'Heading',
                      isSelected:
                          state.activeBlockType == NoteBlockType.heading,
                    ),
                    const SizedBox(width: 8),
                    _buildStyleChip(
                      context,
                      type: NoteBlockType.subheading,
                      label: 'Subheading',
                      isSelected:
                          state.activeBlockType == NoteBlockType.subheading,
                    ),
                    const SizedBox(width: 8),
                    _buildStyleChip(
                      context,
                      type: NoteBlockType.body,
                      label: 'Body',
                      isSelected: state.activeBlockType == NoteBlockType.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Inline styles: Bold, Italic, Underline
              Row(
                children: [
                  _buildFormatButton(
                    context,
                    label: 'B',
                    isBoldLabel: true,
                    isActive: state.isBold,
                    tooltip: 'Bold',
                    onTap: cubit.toggleBold,
                  ),
                  const SizedBox(width: 12),
                  _buildFormatButton(
                    context,
                    label: 'I',
                    isItalicLabel: true,
                    isActive: state.isItalic,
                    tooltip: 'Italic',
                    onTap: cubit.toggleItalic,
                  ),
                  const SizedBox(width: 12),
                  _buildFormatButton(
                    context,
                    label: 'U',
                    isUnderlineLabel: true,
                    isActive: state.isUnderline,
                    tooltip: 'Underline',
                    onTap: cubit.toggleUnderline,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color picker row
              Text(
                'Text Color',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _palette.map((item) {
                    final hex = item['hex']!;
                    final isDefault = hex.isEmpty;
                    final isSelected = isDefault
                        ? state.textColorHex == null
                        : state.textColorHex == hex;

                    Color chipColor;
                    if (isDefault) {
                      chipColor = isDark ? Colors.white : Colors.black;
                    } else {
                      chipColor = parseHexColor(hex);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          cubit.setTextColor(isDefault ? null : hex);
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: chipColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? colors.operatorButton
                                  : (isDark ? Colors.white24 : Colors.black26),
                              width: isSelected ? 3.0 : 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: (chipColor.computeLuminance() > 0.5)
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleChip(
    BuildContext context, {
    required NoteBlockType type,
    required String label,
    required bool isSelected,
  }) {
    final colors = context.calcColors;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? colors.operatorText : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      selectedColor: colors.operatorButton,
      backgroundColor: colors.numberButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: isSelected ? colors.operatorButton : colors.numberButtonBorder,
        ),
      ),
      onSelected: (_) => cubit.setBlockType(type),
    );
  }

  Widget _buildFormatButton(
    BuildContext context, {
    required String label,
    bool isBoldLabel = false,
    bool isItalicLabel = false,
    bool isUnderlineLabel = false,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final colors = context.calcColors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? colors.operatorButton : colors.numberButton,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isActive
                  ? colors.operatorButton
                  : colors.numberButtonBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? colors.operatorText : colors.textPrimary,
              fontSize: 16,
              fontWeight: isBoldLabel || isActive
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: isItalicLabel ? FontStyle.italic : FontStyle.normal,
              decoration: isUnderlineLabel
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
