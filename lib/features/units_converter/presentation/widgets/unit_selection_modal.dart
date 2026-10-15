import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_definition.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_registry.dart';

/// Modal bottom sheet for selecting a unit, inspired by the iOS Units reference screenshots.
class UnitSelectionModal extends StatefulWidget {
  const UnitSelectionModal({
    super.key,
    required this.initialCategory,
    required this.selectedUnit,
    required this.title,
  });

  final UnitCategory initialCategory;
  final UnitDefinition selectedUnit;
  final String title;

  static Future<UnitDefinition?> show(
    BuildContext context, {
    required UnitCategory category,
    required UnitDefinition selectedUnit,
    String title = 'Units',
  }) {
    return showModalBottomSheet<UnitDefinition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnitSelectionModal(
        initialCategory: category,
        selectedUnit: selectedUnit,
        title: title,
      ),
    );
  }

  @override
  State<UnitSelectionModal> createState() => _UnitSelectionModalState();
}

class _UnitSelectionModalState extends State<UnitSelectionModal> {
  late UnitCategory _activeCategory;
  late UnitDefinition _selectedUnit;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _activeCategory = widget.initialCategory;
    _selectedUnit = widget.selectedUnit;
    _searchController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveCategory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveCategory() {
    if (!_categoryScrollController.hasClients) return;
    final index = UnitCategory.values.indexOf(_activeCategory);
    if (index > 0) {
      final targetOffset = (index * 85.0) - 40.0;
      _categoryScrollController.animateTo(
        targetOffset.clamp(
          0.0,
          _categoryScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<UnitDefinition> _getVisibleUnits() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      return UnitRegistry.searchUnits(query);
    }
    return UnitRegistry.getUnits(_activeCategory);
  }

  void _onCategorySelected(UnitCategory category) {
    if (category == UnitCategory.currency) {
      // If user taps currency inside unit selector, let parent handle or close
      return;
    }
    setState(() {
      _activeCategory = category;
      _searchController.clear();
      _selectedUnit = UnitRegistry.getDefaultSource(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? colors.operatorButton
        : colors.accentHighContrast;

    final visibleUnits = _getVisibleUnits();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.disabledColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Centered "Units" Title & Right Circular Checkmark
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: accentColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(_selectedUnit),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Horizontal Category Selector Tab Bar
            SizedBox(
              height: 40,
              child: ListView.separated(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: UnitCategory.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = UnitCategory.values[index];
                  if (cat == UnitCategory.currency) {
                    return const SizedBox.shrink();
                  }

                  final isSelected = cat == _activeCategory;

                  return InkWell(
                    onTap: () => _onCategorySelected(cat),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
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
                      child: Center(
                        child: Text(
                          cat.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: isDark
                  ? colors.textSecondary.withValues(alpha: 0.15)
                  : colors.numberButtonBorder.withValues(alpha: 0.5),
            ),

            // Unit List with Left Checkmark indicator
            Expanded(
              child: visibleUnits.isEmpty
                  ? Center(
                      child: Text(
                        'No units found',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: visibleUnits.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 48,
                        endIndent: 20,
                        color: isDark
                            ? colors.textSecondary.withValues(alpha: 0.12)
                            : colors.numberButtonBorder.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final unit = visibleUnits[index];
                        final isSelected = unit.id == _selectedUnit.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedUnit = unit;
                            });
                            Navigator.of(context).pop(unit);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                // Selection indicator checkmark on the left
                                SizedBox(
                                  width: 28,
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: accentColor,
                                          size: 22,
                                        )
                                      : null,
                                ),

                                // Full Name and Symbol
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        unit.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? accentColor
                                              : colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        unit.symbol.isNotEmpty
                                            ? '${unit.symbol} • ${unit.category.displayName}'
                                            : unit.category.displayName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Search Bar at the bottom (matching screenshots)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search all units...',
                  hintStyle: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textPrimary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: colors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2E2B2B)
                      : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: isDark
                        ? BorderSide.none
                        : BorderSide(
                            color: colors.numberButtonBorder,
                            width: 1,
                          ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
