import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

/// Interactive card tile displaying a Math Note summary in the notes list.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  final MathNote note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF2A2626) : const Color(0xFFF7F7F7);
    final borderColor = isSelected
        ? colors.operatorButton
        : (isDark ? Colors.white10 : Colors.black12);

    final titleText = note.title.trim().isNotEmpty
        ? note.title.trim()
        : 'Untitled Note';
    final previewText = note.plainTextPreview.trim();
    final formattedDate = _formatDate(note.updatedAt);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSelectionMode) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 2.0),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? colors.operatorButton
                          : colors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titleText,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                fontStyle: note.title.trim().isEmpty
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (note.hasDrawings) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.operatorButton.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.brush_rounded,
                                    size: 13,
                                    color: colors.operatorButton,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Draw',
                                    style: TextStyle(
                                      color: colors.operatorButton,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (previewText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          previewText,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(localDate.year, localDate.month, localDate.day);

    if (noteDay == today) {
      return 'Today, ${DateFormat.jm().format(localDate)}';
    } else if (noteDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat.jm().format(localDate)}';
    } else if (now.year == localDate.year) {
      return DateFormat('MMM d, h:mm a').format(localDate);
    } else {
      return DateFormat('MMM d, y, h:mm a').format(localDate);
    }
  }
}
