/// Utility for clean, high-precision formatting of numbers without IEEE-754 artifacts.
abstract final class NumberFormatter {
  /// Maximum display precision before scientific notation is considered.
  static const int maxDisplayPrecision = 12;

  /// Formats a [num] into a clean, human-readable calculator result string.
  static String format(num value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) {
      return value.isNegative ? '-Infinity' : 'Infinity';
    }

    // Normalize negative zero
    if (value == 0 || value == -0.0) return '0';

    final double dVal = value.toDouble();
    final double absVal = dVal.abs();

    // Very large or very small magnitudes use scientific notation
    if (absVal >= 1e12 || (absVal < 1e-9 && absVal > 0)) {
      return _formatScientific(dVal);
    }

    // Clean floating-point artifacts by rounding to maxDisplayPrecision
    final precisionString = dVal.toStringAsPrecision(maxDisplayPrecision);
    final cleanedDouble = double.parse(precisionString);

    // If it's an integer value, return without decimal point
    if (cleanedDouble == cleanedDouble.truncateToDouble()) {
      return cleanedDouble.toInt().toString();
    }

    // Otherwise format as decimal and strip unnecessary trailing zeros
    var str = cleanedDouble.toString();
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }

  static String _formatScientific(double value) {
    var str = value.toStringAsExponential(6);
    // e+05 -> e5, e-05 -> e-5
    str = str.replaceAll(RegExp(r'e\+?0*'), 'e');
    str = str.replaceAll(RegExp(r'e-0*'), 'e-');
    // Remove trailing zeros in mantissa before 'e'
    final parts = str.split('e');
    var mantissa = parts[0];
    if (mantissa.contains('.')) {
      mantissa = mantissa.replaceAll(RegExp(r'0+$'), '');
      mantissa = mantissa.replaceAll(RegExp(r'\.$'), '');
    }
    return '${mantissa}e${parts[1]}';
  }
}
