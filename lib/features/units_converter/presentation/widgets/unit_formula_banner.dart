import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_converter_engine.dart';

/// Informational banner showing conversion relationship, active formula, or validation errors.
class UnitFormulaBanner extends StatelessWidget {
  const UnitFormulaBanner({super.key, required this.result});

  final UnitConversionResult? result;

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final formula = result?.formulaText ?? 'Select units to calculate';
    final isValid = result?.isValid ?? true;
    final errorMessage = result?.errorMessage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232020) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isValid
              ? (isDark
                    ? colors.textSecondary.withValues(alpha: 0.1)
                    : colors.numberButtonBorder)
              : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.swap_horiz_rounded : Icons.info_outline_rounded,
            size: 18,
            color: isValid
                ? (isDark ? colors.operatorButton : colors.accentHighContrast)
                : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValid ? formula : (errorMessage ?? formula),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isValid ? colors.textPrimary : Colors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
