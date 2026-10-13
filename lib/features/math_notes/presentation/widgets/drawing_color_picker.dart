import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/note_editor_state.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_canvas_view.dart';

/// Toolbar presented when freehand drawing mode is active.
/// Lets the user select stroke color, stroke width, clear canvas, or finish drawing.
class DrawingColorPickerToolbar extends StatelessWidget {
  const DrawingColorPickerToolbar({
    super.key,
    required this.cubit,
    required this.state,
  });

  final NoteEditorCubit cubit;
  final NoteEditorState state;

  static const List<String> _colors = [
    '#64AFFA', // Approved brand blue
    '#FFFFFF', // White
    '#000000', // Black
    '#EF4444', // Red
    '#10B981', // Green
    '#F59E0B', // Amber
    '#8B5CF6', // Purple
  ];

  static const List<double> _widths = [2.0, 4.0, 7.0];

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Color chips
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _colors.map((hex) {
                    final isSelected = state.drawingColorHex == hex;
                    final color = parseHexColor(hex);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => cubit.setDrawingColor(hex),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? colors.operatorButton
                                  : (isDark ? Colors.white24 : Colors.black26),
                              width: isSelected ? 2.5 : 1.0,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: color.computeLuminance() > 0.5
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
            ),
            const SizedBox(width: 8),

            // Stroke widths
            Row(
              children: _widths.map((w) {
                final isSelected = state.drawingStrokeWidth == w;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: GestureDetector(
                    onTap: () => cubit.setDrawingStrokeWidth(w),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.operatorButton.withValues(alpha: 0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: w * 2.2,
                        height: w * 2.2,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.operatorButton
                              : colors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 6),

            // Clear button
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
              tooltip: 'Clear drawings',
              onPressed: () {
                cubit.clearDrawings();
              },
            ),

            // Done drawing button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.operatorButton,
                foregroundColor: colors.operatorText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(56, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => cubit.setDrawingMode(false),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
