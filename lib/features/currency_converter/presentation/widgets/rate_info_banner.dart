import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/conversion_result.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';
import 'package:easy_calculator/features/currency_converter/domain/services/currency_calculator.dart';

/// Informational banner displaying active rate equations, freshness badge, and provider disclaimer.
class RateInfoBanner extends StatelessWidget {
  const RateInfoBanner({
    super.key,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.result,
    required this.snapshot,
    required this.onRefresh,
    required this.isRefreshing,
  });

  final Currency sourceCurrency;
  final Currency targetCurrency;
  final ConversionResult? result;
  final ExchangeRatesSnapshot? snapshot;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  String _formatTimestamp(DateTime time) {
    return DateFormat('MMM d, yyyy h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasRate = result != null && result!.rate > 0;
    final isSame = sourceCurrency.code == targetCurrency.code;
    final isCached = snapshot?.isCached ?? false;

    final primaryRateText = hasRate
        ? CurrencyCalculator.formatRateText(
            fromCode: sourceCurrency.code,
            toCode: targetCurrency.code,
            rate: result!.rate,
          )
        : 'Rate unavailable for ${sourceCurrency.code} → ${targetCurrency.code}';

    final inverseRate = (hasRate && !isSame && result!.rate > 0)
        ? 1.0 / result!.rate
        : null;

    final inverseRateText = inverseRate != null
        ? CurrencyCalculator.formatRateText(
            fromCode: targetCurrency.code,
            toCode: sourceCurrency.code,
            rate: inverseRate,
          )
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232020) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rate calculation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryRateText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (inverseRateText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        inverseRateText,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Freshness badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCached
                      ? Colors.orange.withValues(alpha: 0.15)
                      : (hasRate
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.red.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCached
                            ? Colors.orange
                            : (hasRate ? Colors.green : Colors.red),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isCached ? 'Cached' : (hasRate ? 'Live' : 'Unavailable'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCached
                            ? Colors.orange.shade800
                            : (hasRate
                                  ? Colors.green.shade800
                                  : Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Manual refresh button
              IconButton(
                icon: isRefreshing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.operatorButton,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: colors.operatorButton,
                        size: 20,
                      ),
                tooltip: 'Refresh exchange rates',
                onPressed: isRefreshing ? null : onRefresh,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          if (snapshot != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isCached
                              ? 'Last updated: ${_formatTimestamp(snapshot!.timestamp)}'
                              : 'Market date: ${snapshot!.date}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: ConversionResult.disclaimer,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Disclaimer',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary.withValues(alpha: 0.8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
