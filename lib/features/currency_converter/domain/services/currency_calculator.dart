import 'package:intl/intl.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/conversion_result.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/exchange_rate.dart';

/// Pure computation and formatting logic for currency conversions.
class CurrencyCalculator {
  const CurrencyCalculator._();

  /// Converts [sourceAmount] from [fromCode] to [toCode] using [snapshot].
  ///
  /// Returns null if exchange rate is missing or invalid.
  static ConversionResult? convert({
    required double sourceAmount,
    required String fromCode,
    required String toCode,
    required ExchangeRatesSnapshot snapshot,
  }) {
    final from = fromCode.trim().toUpperCase();
    final to = toCode.trim().toUpperCase();

    // Same currency conversion
    if (from == to) {
      return ConversionResult(
        sourceAmount: sourceAmount,
        targetAmount: sourceAmount,
        sourceCode: from,
        targetCode: to,
        rate: 1.0,
        isSameCurrency: true,
        date: snapshot.date,
        timestamp: snapshot.timestamp,
        isCached: snapshot.isCached,
        formattedTarget: formatCurrencyValue(sourceAmount),
      );
    }

    final rate = snapshot.getRate(fromCode: from, toCode: to);
    if (rate == null || rate.isNaN || rate.isInfinite || rate <= 0) {
      return null;
    }

    final targetAmount = sourceAmount * rate;
    if (targetAmount.isNaN || targetAmount.isInfinite) {
      return null;
    }

    return ConversionResult(
      sourceAmount: sourceAmount,
      targetAmount: targetAmount,
      sourceCode: from,
      targetCode: to,
      rate: rate,
      isSameCurrency: false,
      date: snapshot.date,
      timestamp: snapshot.timestamp,
      isCached: snapshot.isCached,
      formattedTarget: formatCurrencyValue(targetAmount),
    );
  }

  /// Parses user string input (e.g. "12.5") into a safe double.
  static double parseInputAmount(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || trimmed == '.') return 0.0;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) return 0.0;
    return parsed;
  }

  /// Formats a currency value cleanly:
  /// - Groups thousands (e.g., 1,234,567.89)
  /// - Removes unnecessary trailing zeros (e.g. 100 instead of 100.00)
  /// - Preserves precision for small fractions (e.g., 0.00812)
  static String formatCurrencyValue(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    if (value == 0) return '0';

    final absVal = value.abs();

    if (absVal >= 1e14) {
      return NumberFormat.scientificPattern().format(value);
    }

    // Determine decimal precision based on magnitude
    final int maxDecimals;
    if (absVal >= 100) {
      maxDecimals = 2;
    } else if (absVal >= 1) {
      maxDecimals = 4;
    } else if (absVal >= 0.001) {
      maxDecimals = 6;
    } else {
      maxDecimals = 8;
    }

    final formatter = NumberFormat('#,##0.${'#' * maxDecimals}');
    return formatter.format(value);
  }

  /// Formats rate line for display (e.g. "1 USD = 123.16 BDT").
  static String formatRateText({
    required String fromCode,
    required String toCode,
    required double rate,
  }) {
    if (fromCode == toCode) return '1 $fromCode = 1 $toCode';
    final formattedRate = formatCurrencyValue(rate);
    return '1 $fromCode = $formattedRate $toCode';
  }
}
