import 'package:easy_calculator/features/units_converter/domain/models/unit_definition.dart';

/// Calculation result for a unit conversion.
class UnitConversionResult {
  const UnitConversionResult({
    required this.sourceValue,
    required this.targetValue,
    required this.formattedTarget,
    required this.formulaText,
    this.isValid = true,
    this.errorMessage,
  });

  final double sourceValue;
  final double targetValue;
  final String formattedTarget;
  final String formulaText;
  final bool isValid;
  final String? errorMessage;
}

/// Deterministic, high-precision mathematical engine for unit conversions.
abstract final class UnitConverterEngine {
  /// Converts [sourceValue] from [from] unit to [to] unit.
  static UnitConversionResult convert({
    required double sourceValue,
    required UnitDefinition from,
    required UnitDefinition to,
  }) {
    // 1. Guard against non-finite values
    if (sourceValue.isNaN || sourceValue.isInfinite) {
      return UnitConversionResult(
        sourceValue: sourceValue,
        targetValue: 0.0,
        formattedTarget: '—',
        formulaText: '${from.symbol} → ${to.symbol}',
        isValid: false,
        errorMessage: 'Invalid number',
      );
    }

    // 2. Identity check
    if (from.id == to.id) {
      return UnitConversionResult(
        sourceValue: sourceValue,
        targetValue: sourceValue,
        formattedTarget: formatValue(sourceValue),
        formulaText: '1 ${from.symbol} = 1 ${to.symbol}',
      );
    }

    // 3. Category negative guard
    if (sourceValue < 0 && !from.category.supportsNegative) {
      return UnitConversionResult(
        sourceValue: sourceValue,
        targetValue: 0.0,
        formattedTarget: '—',
        formulaText: '${from.name} cannot be negative',
        isValid: false,
        errorMessage: 'Negative values not permitted',
      );
    }

    // 4. Branch by conversion type
    if (from.conversionType == ConversionType.temperature) {
      return _convertTemperature(sourceValue, from, to);
    }

    if (from.conversionType == ConversionType.fuel) {
      return _convertFuel(sourceValue, from, to);
    }

    // 5. Standard linear conversion
    return _convertLinear(sourceValue, from, to);
  }

  /// Linear factor conversion via base unit.
  static UnitConversionResult _convertLinear(
    double value,
    UnitDefinition from,
    UnitDefinition to,
  ) {
    if (to.toBaseMultiplier == 0.0) {
      return UnitConversionResult(
        sourceValue: value,
        targetValue: 0.0,
        formattedTarget: '—',
        formulaText: 'Error',
        isValid: false,
        errorMessage: 'Invalid unit divisor',
      );
    }

    final baseValue = value * from.toBaseMultiplier;
    final targetValue = baseValue / to.toBaseMultiplier;

    // Calculate 1-unit reference formula
    final refBase = 1.0 * from.toBaseMultiplier;
    final refTarget = refBase / to.toBaseMultiplier;
    final formula = '1 ${from.symbol} = ${formatValue(refTarget)} ${to.symbol}';

    return UnitConversionResult(
      sourceValue: value,
      targetValue: targetValue,
      formattedTarget: formatValue(targetValue),
      formulaText: formula,
    );
  }

  /// Temperature conversion with exact offset arithmetic.
  static UnitConversionResult _convertTemperature(
    double value,
    UnitDefinition from,
    UnitDefinition to,
  ) {
    // Convert to Celsius base
    double celsius;
    switch (from.id) {
      case 'celsius':
        celsius = value;
        break;
      case 'fahrenheit':
        celsius = (value - 32.0) * (5.0 / 9.0);
        break;
      case 'kelvin':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    // Convert Celsius to target
    double target;
    switch (to.id) {
      case 'celsius':
        target = celsius;
        break;
      case 'fahrenheit':
        target = (celsius * 9.0 / 5.0) + 32.0;
        break;
      case 'kelvin':
        target = celsius + 273.15;
        break;
      default:
        target = celsius;
    }

    // Generate descriptive formula for reference
    String formula;
    if (from.id == 'celsius' && to.id == 'fahrenheit') {
      formula = '°F = (°C × 9/5) + 32';
    } else if (from.id == 'fahrenheit' && to.id == 'celsius') {
      formula = '°C = (°F − 32) × 5/9';
    } else if (from.id == 'celsius' && to.id == 'kelvin') {
      formula = 'K = °C + 273.15';
    } else if (from.id == 'kelvin' && to.id == 'celsius') {
      formula = '°C = K − 273.15';
    } else if (from.id == 'fahrenheit' && to.id == 'kelvin') {
      formula = 'K = (°F − 32) × 5/9 + 273.15';
    } else if (from.id == 'kelvin' && to.id == 'fahrenheit') {
      formula = '°F = (K − 273.15) × 9/5 + 32';
    } else {
      formula = '${from.symbol} → ${to.symbol}';
    }

    return UnitConversionResult(
      sourceValue: value,
      targetValue: target,
      formattedTarget: formatValue(target),
      formulaText: formula,
    );
  }

  /// Fuel economy conversion with reciprocal handling for L/100 km.
  static UnitConversionResult _convertFuel(
    double value,
    UnitDefinition from,
    UnitDefinition to,
  ) {
    // Fuel economy cannot be 0 or negative for reciprocal operations
    if (value <= 0) {
      return UnitConversionResult(
        sourceValue: value,
        targetValue: 0.0,
        formattedTarget: '—',
        formulaText: 'Fuel economy must be greater than 0',
        isValid: false,
        errorMessage: 'Value must be positive',
      );
    }

    // 1. Convert input to base: km/L
    double kmPerLiter;
    switch (from.id) {
      case 'km_per_liter':
        kmPerLiter = value;
        break;
      case 'liters_per_100km':
        kmPerLiter = 100.0 / value;
        break;
      case 'mpg_us':
        kmPerLiter = value * (1.609344 / 3.785411784);
        break;
      case 'mpg_imp':
        kmPerLiter = value * (1.609344 / 4.54609);
        break;
      default:
        kmPerLiter = value;
    }

    // 2. Convert km/L to target
    double target;
    switch (to.id) {
      case 'km_per_liter':
        target = kmPerLiter;
        break;
      case 'liters_per_100km':
        target = 100.0 / kmPerLiter;
        break;
      case 'mpg_us':
        target = kmPerLiter / (1.609344 / 3.785411784);
        break;
      case 'mpg_imp':
        target = kmPerLiter / (1.609344 / 4.54609);
        break;
      default:
        target = kmPerLiter;
    }

    String formula;
    if (from.id == 'liters_per_100km' || to.id == 'liters_per_100km') {
      formula = 'Reciprocal conversion: 100 ÷ (consumption × factor)';
    } else {
      final ratio = target / value;
      formula = '1 ${from.symbol} = ${formatValue(ratio)} ${to.symbol}';
    }

    return UnitConversionResult(
      sourceValue: value,
      targetValue: target,
      formattedTarget: formatValue(target),
      formulaText: formula,
    );
  }

  /// Parses text input safely into a double.
  static double parseInputAmount(String input) {
    final cleaned = input.replaceAll(' ', '').trim();
    if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') return 0.0;
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Formats a double value with up to 8 significant figures,
  /// avoiding exponential notation for human-scale values.
  static String formatValue(double value) {
    if (value == 0.0) return '0';
    if (value.isNaN || value.isInfinite) return '—';

    final absVal = value.abs();

    // Use scientific notation only for astronomically large or microscopic values
    if (absVal >= 1e12 || (absVal < 1e-6 && absVal > 0)) {
      final exp = value.toStringAsExponential(5);
      return exp.replaceAll(RegExp(r'0+e'), 'e').replaceAll('.e', 'e');
    }

    // If whole number
    if (value == value.roundToDouble() && absVal < 1e12) {
      return value.toInt().toString();
    }

    // Determine precision dynamically
    int decimals = 6;
    if (absVal >= 1000) {
      decimals = 3;
    } else if (absVal >= 100) {
      decimals = 4;
    } else if (absVal >= 1) {
      decimals = 6;
    } else {
      decimals = 8;
    }

    String formatted = value.toStringAsFixed(decimals);

    // Strip trailing zeros after decimal point
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    // Clean negative zero
    if (formatted == '-0') return '0';

    return formatted;
  }
}
