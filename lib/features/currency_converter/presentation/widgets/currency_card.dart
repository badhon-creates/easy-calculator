import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';

/// Interactive card displaying currency metadata, flag, selector trigger, and amount.
class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    super.key,
    required this.label,
    required this.currency,
    required this.amountText,
    required this.onSelectCurrency,
    required this.isSource,
    this.secondaryText,
  });

  final String label;
  final Currency currency;
  final String amountText;
  final VoidCallback onSelectCurrency;
  final bool isSource;
  final String? secondaryText;

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
              ? colors.operatorButton.withValues(alpha: 0.35)
              : colors.textSecondary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Label & Currency selector button
          Row(
            children: [
              // Label pill (e.g. From / To)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSource
                      ? colors.operatorButton.withValues(alpha: 0.15)
                      : colors.textSecondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isSource
                        ? colors.operatorButton
                        : colors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),

              // Currency Selector trigger button
              InkWell(
                key: ValueKey('currency_selector_${isSource ? 'from' : 'to'}'),
                onTap: onSelectCurrency,
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
                      color: colors.textSecondary.withValues(alpha: 0.2),
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
                        currency.flag.isNotEmpty ? currency.flag : '🌐',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currency.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom row: Full currency name + Amount display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Currency name
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (secondaryText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondaryText!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
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
                            : colors.operatorButton,
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
