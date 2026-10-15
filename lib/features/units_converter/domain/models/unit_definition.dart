import 'package:flutter/foundation.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';

/// Type of mathematical conversion behavior.
enum ConversionType {
  /// Standard linear scaling: valueInBase = value * toBaseMultiplier
  linear,

  /// Temperature conversion with scale and offset (°C, °F, K)
  temperature,

  /// Reciprocal / fuel economy conversions (km/L, L/100 km, mpg US, mpg Imp)
  fuel,
}

/// Represents a single unit of measurement within a category.
@immutable
class UnitDefinition {
  const UnitDefinition({
    required this.id,
    required this.name,
    required this.symbol,
    required this.category,
    this.toBaseMultiplier = 1.0,
    this.conversionType = ConversionType.linear,
    this.isBase = false,
  });

  /// Unique identifier (e.g. 'meter', 'kilometer', 'celsius').
  final String id;

  /// Human-readable unit name (e.g. 'Meter', 'Kilometer', 'Celsius').
  final String name;

  /// Standard symbol or abbreviation (e.g. 'm', 'km', '°C').
  final String symbol;

  /// The category this unit belongs to.
  final UnitCategory category;

  /// Linear factor converting this unit into the base unit of the category.
  /// (e.g. for millimeter -> meter, factor is 0.001).
  final double toBaseMultiplier;

  /// Special conversion type for non-linear formulas (temperature, fuel).
  final ConversionType conversionType;

  /// Whether this unit is the canonical reference base of its category.
  final bool isBase;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category;

  @override
  int get hashCode => Object.hash(id, category);

  @override
  String toString() => '$name ($symbol)';
}
