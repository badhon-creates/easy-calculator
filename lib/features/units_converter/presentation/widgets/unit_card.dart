import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_definition.dart';

/// Reusable interactive card displaying unit metadata, selector trigger, and formatted value.
class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.label,
    required this.unit,
    required this.amountText,
    required this.onSelectUnit,
    required this.isSource,
  });

  final String label;
  final UnitDefinition unit;
  final String amountText;
  final VoidCallback onSelectUnit;
  final bool isSource;

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282525) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isSource
              ? (isDark
                    ? colors.operatorButton.withValues(alpha: 0.35)
                    : colors.operatorButton)
              : (isDark
                    ? colors.textSecondary.withValues(alpha: 0.15)
                    : colors.numberButtonBorder),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Label pill and Unit selector button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSource
                      ? (isDark
                            ? colors.operatorButton.withValues(alpha: 0.15)
                            : colors.operatorButton.withValues(alpha: 0.22))
                      : (isDark
                            ? colors.textSecondary.withValues(alpha: 0.12)
                            : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isSource
                        ? (isDark
                              ? colors.operatorButton
                              : colors.accentHighContrast)
                        : (isDark
                              ? colors.textSecondary
                              : const Color(0xFF334155)),
                  ),
                ),
              ),
              const Spacer(),

              // Unit Selector trigger
              InkWell(
                key: ValueKey('unit_selector_${isSource ? 'from' : 'to'}'),
                onTap: onSelectUnit,
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF383535) : Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isDark
                          ? colors.textSecondary.withValues(alpha: 0.2)
                          : colors.numberButtonBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unit.symbol.isNotEmpty ? unit.symbol : unit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textPrimary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom row: Full Unit Name + Amount display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Full Unit Name
              Expanded(
                flex: 4,
                child: Text(
                  unit.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Amount display
              Expanded(
                flex: 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      amountText,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isSource
                            ? colors.textPrimary
                            : (isDark
                                  ? colors.operatorButton
                                  : colors.accentHighContrast),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
