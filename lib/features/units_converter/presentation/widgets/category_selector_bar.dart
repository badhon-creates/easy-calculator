import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';

/// Horizontally scrollable selector bar displaying all 15 conversion categories.
class CategorySelectorBar extends StatefulWidget {
  const CategorySelectorBar({
    super.key,
    required this.activeCategory,
    required this.onSelectCategory,
  });

  final UnitCategory activeCategory;
  final ValueChanged<UnitCategory> onSelectCategory;

  @override
  State<CategorySelectorBar> createState() => _CategorySelectorBarState();
}

class _CategorySelectorBarState extends State<CategorySelectorBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant CategorySelectorBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCategory != widget.activeCategory) {
      _scrollToActive();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive() {
    if (!_scrollController.hasClients) return;
    final index = UnitCategory.values.indexOf(widget.activeCategory);
    final targetOffset = (index * 92.0) - 40.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? colors.operatorButton
        : colors.accentHighContrast;

    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Row(
          children: [
            for (int i = 0; i < UnitCategory.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final category = UnitCategory.values[i];
                  final isSelected = category == widget.activeCategory;

                  return InkWell(
                    key: ValueKey('category_tab_${category.name}'),
                    onTap: () => widget.onSelectCategory(category),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: isDark
                                    ? colors.textSecondary.withValues(
                                        alpha: 0.2,
                                      )
                                    : colors.numberButtonBorder,
                                width: 1,
                              ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
