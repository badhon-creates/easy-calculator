import 'dart:math' as math;

import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_definition.dart';

/// Central repository of all supported unit definitions and conversion constants.
abstract final class UnitRegistry {
  static final Map<UnitCategory, List<UnitDefinition>> _unitsByCategory = {
    // 1. Angle (Base: Radian)
    UnitCategory.angle: const [
      UnitDefinition(
        id: 'degree',
        name: 'Degree',
        symbol: '°',
        category: UnitCategory.angle,
        toBaseMultiplier: math.pi / 180.0,
      ),
      UnitDefinition(
        id: 'radian',
        name: 'Radian',
        symbol: 'rad',
        category: UnitCategory.angle,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'gradian',
        name: 'Gradian',
        symbol: 'grad',
        category: UnitCategory.angle,
        toBaseMultiplier: math.pi / 200.0,
      ),
    ],

    // 2. Area (Base: Square Meter)
    UnitCategory.area: const [
      UnitDefinition(
        id: 'square_millimeter',
        name: 'Square Millimeter',
        symbol: 'mm²',
        category: UnitCategory.area,
        toBaseMultiplier: 1e-6,
      ),
      UnitDefinition(
        id: 'square_centimeter',
        name: 'Square Centimeter',
        symbol: 'cm²',
        category: UnitCategory.area,
        toBaseMultiplier: 1e-4,
      ),
      UnitDefinition(
        id: 'square_meter',
        name: 'Square Meter',
        symbol: 'm²',
        category: UnitCategory.area,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'square_kilometer',
        name: 'Square Kilometer',
        symbol: 'km²',
        category: UnitCategory.area,
        toBaseMultiplier: 1e6,
      ),
      UnitDefinition(
        id: 'square_inch',
        name: 'Square Inch',
        symbol: 'sq in',
        category: UnitCategory.area,
        toBaseMultiplier: 0.00064516,
      ),
      UnitDefinition(
        id: 'square_foot',
        name: 'Square Foot',
        symbol: 'sq ft',
        category: UnitCategory.area,
        toBaseMultiplier: 0.09290304,
      ),
      UnitDefinition(
        id: 'square_yard',
        name: 'Square Yard',
        symbol: 'sq yd',
        category: UnitCategory.area,
        toBaseMultiplier: 0.83612736,
      ),
      UnitDefinition(
        id: 'acre',
        name: 'Acre',
        symbol: 'ac',
        category: UnitCategory.area,
        toBaseMultiplier: 4046.8564224,
      ),
      UnitDefinition(
        id: 'hectare',
        name: 'Hectare',
        symbol: 'ha',
        category: UnitCategory.area,
        toBaseMultiplier: 10000.0,
      ),
    ],

    // 3. Currency (Special handling via CurrencyRepository)
    UnitCategory.currency: const [],

    // 4. Data (Base: Byte) - Explicit SI & IEC definitions
    UnitCategory.data: const [
      UnitDefinition(
        id: 'bit',
        name: 'Bit',
        symbol: 'b',
        category: UnitCategory.data,
        toBaseMultiplier: 0.125,
      ),
      UnitDefinition(
        id: 'byte',
        name: 'Byte',
        symbol: 'B',
        category: UnitCategory.data,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      // Decimal SI (10^3)
      UnitDefinition(
        id: 'kilobit',
        name: 'Kilobit (SI)',
        symbol: 'kb',
        category: UnitCategory.data,
        toBaseMultiplier: 125.0, // 1000 / 8
      ),
      UnitDefinition(
        id: 'kilobyte',
        name: 'Kilobyte (SI)',
        symbol: 'kB',
        category: UnitCategory.data,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'megabit',
        name: 'Megabit (SI)',
        symbol: 'Mb',
        category: UnitCategory.data,
        toBaseMultiplier: 125000.0, // 1e6 / 8
      ),
      UnitDefinition(
        id: 'megabyte',
        name: 'Megabyte (SI)',
        symbol: 'MB',
        category: UnitCategory.data,
        toBaseMultiplier: 1e6,
      ),
      UnitDefinition(
        id: 'gigabit',
        name: 'Gigabit (SI)',
        symbol: 'Gb',
        category: UnitCategory.data,
        toBaseMultiplier: 1.25e8, // 1e9 / 8
      ),
      UnitDefinition(
        id: 'gigabyte',
        name: 'Gigabyte (SI)',
        symbol: 'GB',
        category: UnitCategory.data,
        toBaseMultiplier: 1e9,
      ),
      UnitDefinition(
        id: 'terabit',
        name: 'Terabit (SI)',
        symbol: 'Tb',
        category: UnitCategory.data,
        toBaseMultiplier: 1.25e11, // 1e12 / 8
      ),
      UnitDefinition(
        id: 'terabyte',
        name: 'Terabyte (SI)',
        symbol: 'TB',
        category: UnitCategory.data,
        toBaseMultiplier: 1e12,
      ),
      // Binary IEC (2^10)
      UnitDefinition(
        id: 'kibibyte',
        name: 'Kibibyte (IEC)',
        symbol: 'KiB',
        category: UnitCategory.data,
        toBaseMultiplier: 1024.0,
      ),
      UnitDefinition(
        id: 'mebibyte',
        name: 'Mebibyte (IEC)',
        symbol: 'MiB',
        category: UnitCategory.data,
        toBaseMultiplier: 1048576.0,
      ),
      UnitDefinition(
        id: 'gibibyte',
        name: 'Gibibyte (IEC)',
        symbol: 'GiB',
        category: UnitCategory.data,
        toBaseMultiplier: 1073741824.0,
      ),
      UnitDefinition(
        id: 'tebibyte',
        name: 'Tebibyte (IEC)',
        symbol: 'TiB',
        category: UnitCategory.data,
        toBaseMultiplier: 1099511627776.0,
      ),
    ],

    // 5. Energy (Base: Joule)
    UnitCategory.energy: const [
      UnitDefinition(
        id: 'joule',
        name: 'Joule',
        symbol: 'J',
        category: UnitCategory.energy,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'kilojoule',
        name: 'Kilojoule',
        symbol: 'kJ',
        category: UnitCategory.energy,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'calorie',
        name: 'Calorie',
        symbol: 'cal',
        category: UnitCategory.energy,
        toBaseMultiplier: 4.184,
      ),
      UnitDefinition(
        id: 'kilocalorie',
        name: 'Kilocalorie',
        symbol: 'kcal',
        category: UnitCategory.energy,
        toBaseMultiplier: 4184.0,
      ),
      UnitDefinition(
        id: 'watt_hour',
        name: 'Watt-hour',
        symbol: 'Wh',
        category: UnitCategory.energy,
        toBaseMultiplier: 3600.0,
      ),
      UnitDefinition(
        id: 'kilowatt_hour',
        name: 'Kilowatt-hour',
        symbol: 'kWh',
        category: UnitCategory.energy,
        toBaseMultiplier: 3.6e6,
      ),
      UnitDefinition(
        id: 'electronvolt',
        name: 'Electronvolt',
        symbol: 'eV',
        category: UnitCategory.energy,
        toBaseMultiplier: 1.602176634e-19,
      ),
    ],

    // 6. Force (Base: Newton)
    UnitCategory.force: const [
      UnitDefinition(
        id: 'newton',
        name: 'Newton',
        symbol: 'N',
        category: UnitCategory.force,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'kilonewton',
        name: 'Kilonewton',
        symbol: 'kN',
        category: UnitCategory.force,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'pound_force',
        name: 'Pound-force',
        symbol: 'lbf',
        category: UnitCategory.force,
        toBaseMultiplier: 4.4482216152605,
      ),
    ],

    // 7. Fuel Economy (Base: Kilometers per Liter, with reciprocal handling)
    UnitCategory.fuel: const [
      UnitDefinition(
        id: 'km_per_liter',
        name: 'Kilometers per Liter',
        symbol: 'km/L',
        category: UnitCategory.fuel,
        toBaseMultiplier: 1.0,
        conversionType: ConversionType.fuel,
        isBase: true,
      ),
      UnitDefinition(
        id: 'liters_per_100km',
        name: 'Liters per 100 Kilometers',
        symbol: 'L/100 km',
        category: UnitCategory.fuel,
        toBaseMultiplier: 1.0,
        conversionType: ConversionType.fuel,
      ),
      UnitDefinition(
        id: 'mpg_us',
        name: 'Miles per Gallon (US)',
        symbol: 'mpg (US)',
        category: UnitCategory.fuel,
        toBaseMultiplier: 0.4251437074976384, // 1.609344 / 3.785411784
        conversionType: ConversionType.fuel,
      ),
      UnitDefinition(
        id: 'mpg_imp',
        name: 'Miles per Gallon (Imperial)',
        symbol: 'mpg (Imp)',
        category: UnitCategory.fuel,
        toBaseMultiplier: 0.3540061899346471, // 1.609344 / 4.54609
        conversionType: ConversionType.fuel,
      ),
    ],

    // 8. Length (Base: Meter)
    UnitCategory.length: const [
      UnitDefinition(
        id: 'millimeter',
        name: 'Millimeter',
        symbol: 'mm',
        category: UnitCategory.length,
        toBaseMultiplier: 0.001,
      ),
      UnitDefinition(
        id: 'centimeter',
        name: 'Centimeter',
        symbol: 'cm',
        category: UnitCategory.length,
        toBaseMultiplier: 0.01,
      ),
      UnitDefinition(
        id: 'meter',
        name: 'Meter',
        symbol: 'm',
        category: UnitCategory.length,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'kilometer',
        name: 'Kilometer',
        symbol: 'km',
        category: UnitCategory.length,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'inch',
        name: 'Inch',
        symbol: 'in',
        category: UnitCategory.length,
        toBaseMultiplier: 0.0254,
      ),
      UnitDefinition(
        id: 'foot',
        name: 'Foot',
        symbol: 'ft',
        category: UnitCategory.length,
        toBaseMultiplier: 0.3048,
      ),
      UnitDefinition(
        id: 'yard',
        name: 'Yard',
        symbol: 'yd',
        category: UnitCategory.length,
        toBaseMultiplier: 0.9144,
      ),
      UnitDefinition(
        id: 'mile',
        name: 'Mile',
        symbol: 'mi',
        category: UnitCategory.length,
        toBaseMultiplier: 1609.344,
      ),
      UnitDefinition(
        id: 'nautical_mile',
        name: 'Nautical Mile',
        symbol: 'NM',
        category: UnitCategory.length,
        toBaseMultiplier: 1852.0,
      ),
    ],

    // 9. Power (Base: Watt)
    UnitCategory.power: const [
      UnitDefinition(
        id: 'watt',
        name: 'Watt',
        symbol: 'W',
        category: UnitCategory.power,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'kilowatt',
        name: 'Kilowatt',
        symbol: 'kW',
        category: UnitCategory.power,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'megawatt',
        name: 'Megawatt',
        symbol: 'MW',
        category: UnitCategory.power,
        toBaseMultiplier: 1e6,
      ),
      UnitDefinition(
        id: 'horsepower_metric',
        name: 'Metric Horsepower (PS)',
        symbol: 'hp (M)',
        category: UnitCategory.power,
        toBaseMultiplier: 735.49875,
      ),
      UnitDefinition(
        id: 'horsepower_mechanical',
        name: 'Mechanical Horsepower',
        symbol: 'hp (I)',
        category: UnitCategory.power,
        toBaseMultiplier: 745.69987158227022,
      ),
    ],

    // 10. Pressure (Base: Pascal)
    UnitCategory.pressure: const [
      UnitDefinition(
        id: 'pascal',
        name: 'Pascal',
        symbol: 'Pa',
        category: UnitCategory.pressure,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'kilopascal',
        name: 'Kilopascal',
        symbol: 'kPa',
        category: UnitCategory.pressure,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'bar',
        name: 'Bar',
        symbol: 'bar',
        category: UnitCategory.pressure,
        toBaseMultiplier: 100000.0,
      ),
      UnitDefinition(
        id: 'millibar',
        name: 'Millibar',
        symbol: 'mbar',
        category: UnitCategory.pressure,
        toBaseMultiplier: 100.0,
      ),
      UnitDefinition(
        id: 'atmosphere',
        name: 'Standard Atmosphere',
        symbol: 'atm',
        category: UnitCategory.pressure,
        toBaseMultiplier: 101325.0,
      ),
      UnitDefinition(
        id: 'psi',
        name: 'Pound per Square Inch',
        symbol: 'psi',
        category: UnitCategory.pressure,
        toBaseMultiplier: 6894.757293168,
      ),
      UnitDefinition(
        id: 'mm_hg',
        name: 'Millimeter of Mercury',
        symbol: 'mmHg',
        category: UnitCategory.pressure,
        toBaseMultiplier: 133.322387415,
      ),
    ],

    // 11. Speed (Base: Meter per second)
    UnitCategory.speed: const [
      UnitDefinition(
        id: 'meter_per_second',
        name: 'Meter per Second',
        symbol: 'm/s',
        category: UnitCategory.speed,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'kilometer_per_hour',
        name: 'Kilometer per Hour',
        symbol: 'km/h',
        category: UnitCategory.speed,
        toBaseMultiplier: 1.0 / 3.6,
      ),
      UnitDefinition(
        id: 'mile_per_hour',
        name: 'Mile per Hour',
        symbol: 'mph',
        category: UnitCategory.speed,
        toBaseMultiplier: 0.44704,
      ),
      UnitDefinition(
        id: 'knot',
        name: 'Knot',
        symbol: 'kn',
        category: UnitCategory.speed,
        toBaseMultiplier: 1852.0 / 3600.0,
      ),
      UnitDefinition(
        id: 'foot_per_second',
        name: 'Foot per Second',
        symbol: 'ft/s',
        category: UnitCategory.speed,
        toBaseMultiplier: 0.3048,
      ),
    ],

    // 12. Temperature (Non-linear offsets)
    UnitCategory.temperature: const [
      UnitDefinition(
        id: 'celsius',
        name: 'Celsius',
        symbol: '°C',
        category: UnitCategory.temperature,
        conversionType: ConversionType.temperature,
        isBase: true,
      ),
      UnitDefinition(
        id: 'fahrenheit',
        name: 'Fahrenheit',
        symbol: '°F',
        category: UnitCategory.temperature,
        conversionType: ConversionType.temperature,
      ),
      UnitDefinition(
        id: 'kelvin',
        name: 'Kelvin',
        symbol: 'K',
        category: UnitCategory.temperature,
        conversionType: ConversionType.temperature,
      ),
    ],

    // 13. Time (Base: Second)
    UnitCategory.time: const [
      UnitDefinition(
        id: 'millisecond',
        name: 'Millisecond',
        symbol: 'ms',
        category: UnitCategory.time,
        toBaseMultiplier: 0.001,
      ),
      UnitDefinition(
        id: 'second',
        name: 'Second',
        symbol: 's',
        category: UnitCategory.time,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'minute',
        name: 'Minute',
        symbol: 'min',
        category: UnitCategory.time,
        toBaseMultiplier: 60.0,
      ),
      UnitDefinition(
        id: 'hour',
        name: 'Hour',
        symbol: 'h',
        category: UnitCategory.time,
        toBaseMultiplier: 3600.0,
      ),
      UnitDefinition(
        id: 'day',
        name: 'Day',
        symbol: 'd',
        category: UnitCategory.time,
        toBaseMultiplier: 86400.0,
      ),
      UnitDefinition(
        id: 'week',
        name: 'Week',
        symbol: 'wk',
        category: UnitCategory.time,
        toBaseMultiplier: 604800.0,
      ),
    ],

    // 14. Volume (Base: Liter)
    UnitCategory.volume: const [
      UnitDefinition(
        id: 'milliliter',
        name: 'Milliliter',
        symbol: 'mL',
        category: UnitCategory.volume,
        toBaseMultiplier: 0.001,
      ),
      UnitDefinition(
        id: 'liter',
        name: 'Liter',
        symbol: 'L',
        category: UnitCategory.volume,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'cubic_meter',
        name: 'Cubic Meter',
        symbol: 'm³',
        category: UnitCategory.volume,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'gallon_us',
        name: 'Gallon (US liquid)',
        symbol: 'gal (US)',
        category: UnitCategory.volume,
        toBaseMultiplier: 3.785411784,
      ),
      UnitDefinition(
        id: 'gallon_imperial',
        name: 'Gallon (Imperial)',
        symbol: 'gal (Imp)',
        category: UnitCategory.volume,
        toBaseMultiplier: 4.54609,
      ),
      UnitDefinition(
        id: 'cup_us',
        name: 'Cup (US)',
        symbol: 'cup',
        category: UnitCategory.volume,
        toBaseMultiplier: 0.2365882365,
      ),
      UnitDefinition(
        id: 'tablespoon',
        name: 'Tablespoon (US)',
        symbol: 'tbsp',
        category: UnitCategory.volume,
        toBaseMultiplier: 0.01478676478125,
      ),
      UnitDefinition(
        id: 'teaspoon',
        name: 'Teaspoon (US)',
        symbol: 'tsp',
        category: UnitCategory.volume,
        toBaseMultiplier: 0.00492892159375,
      ),
    ],

    // 15. Weight / Mass (Base: Kilogram)
    UnitCategory.weight: const [
      UnitDefinition(
        id: 'milligram',
        name: 'Milligram',
        symbol: 'mg',
        category: UnitCategory.weight,
        toBaseMultiplier: 1e-6,
      ),
      UnitDefinition(
        id: 'gram',
        name: 'Gram',
        symbol: 'g',
        category: UnitCategory.weight,
        toBaseMultiplier: 1e-3,
      ),
      UnitDefinition(
        id: 'kilogram',
        name: 'Kilogram',
        symbol: 'kg',
        category: UnitCategory.weight,
        toBaseMultiplier: 1.0,
        isBase: true,
      ),
      UnitDefinition(
        id: 'metric_tonne',
        name: 'Metric Tonne',
        symbol: 't',
        category: UnitCategory.weight,
        toBaseMultiplier: 1000.0,
      ),
      UnitDefinition(
        id: 'ounce',
        name: 'Ounce',
        symbol: 'oz',
        category: UnitCategory.weight,
        toBaseMultiplier: 0.028349523125,
      ),
      UnitDefinition(
        id: 'pound',
        name: 'Pound',
        symbol: 'lb',
        category: UnitCategory.weight,
        toBaseMultiplier: 0.45359237,
      ),
      UnitDefinition(
        id: 'stone',
        name: 'Stone',
        symbol: 'st',
        category: UnitCategory.weight,
        toBaseMultiplier: 6.35029318,
      ),
    ],
  };

  /// Returns all units in a given category.
  static List<UnitDefinition> getUnits(UnitCategory category) {
    return _unitsByCategory[category] ?? const [];
  }

  /// Returns default source unit for a category.
  static UnitDefinition getDefaultSource(UnitCategory category) {
    final list = getUnits(category);
    if (list.isEmpty) {
      return UnitDefinition(
        id: 'empty',
        name: 'None',
        symbol: '',
        category: category,
      );
    }
    // Return base unit or first
    return list.firstWhere((u) => u.isBase, orElse: () => list.first);
  }

  /// Returns default target unit for a category.
  static UnitDefinition getDefaultTarget(UnitCategory category) {
    final list = getUnits(category);
    if (list.isEmpty) {
      return UnitDefinition(
        id: 'empty',
        name: 'None',
        symbol: '',
        category: category,
      );
    }
    // Pick standard secondary unit
    switch (category) {
      case UnitCategory.angle:
        return list.firstWhere(
          (u) => u.id == 'degree',
          orElse: () => list.last,
        );
      case UnitCategory.area:
        return list.firstWhere(
          (u) => u.id == 'square_foot',
          orElse: () => list.last,
        );
      case UnitCategory.data:
        return list.firstWhere(
          (u) => u.id == 'megabyte',
          orElse: () => list.last,
        );
      case UnitCategory.energy:
        return list.firstWhere(
          (u) => u.id == 'kilocalorie',
          orElse: () => list.last,
        );
      case UnitCategory.force:
        return list.firstWhere(
          (u) => u.id == 'pound_force',
          orElse: () => list.last,
        );
      case UnitCategory.fuel:
        return list.firstWhere(
          (u) => u.id == 'liters_per_100km',
          orElse: () => list.last,
        );
      case UnitCategory.length:
        return list.firstWhere((u) => u.id == 'foot', orElse: () => list.last);
      case UnitCategory.power:
        return list.firstWhere(
          (u) => u.id == 'horsepower_mechanical',
          orElse: () => list.last,
        );
      case UnitCategory.pressure:
        return list.firstWhere((u) => u.id == 'psi', orElse: () => list.last);
      case UnitCategory.speed:
        return list.firstWhere(
          (u) => u.id == 'kilometer_per_hour',
          orElse: () => list.last,
        );
      case UnitCategory.temperature:
        return list.firstWhere(
          (u) => u.id == 'fahrenheit',
          orElse: () => list.last,
        );
      case UnitCategory.time:
        return list.firstWhere(
          (u) => u.id == 'minute',
          orElse: () => list.last,
        );
      case UnitCategory.volume:
        return list.firstWhere(
          (u) => u.id == 'gallon_us',
          orElse: () => list.last,
        );
      case UnitCategory.weight:
        return list.firstWhere((u) => u.id == 'pound', orElse: () => list.last);
      case UnitCategory.currency:
        return list.first;
    }
  }

  /// Searches all units across categories by query text.
  static List<UnitDefinition> searchUnits(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];

    final results = <UnitDefinition>[];
    for (final list in _unitsByCategory.values) {
      for (final unit in list) {
        if (unit.name.toLowerCase().contains(clean) ||
            unit.symbol.toLowerCase().contains(clean) ||
            unit.category.displayName.toLowerCase().contains(clean)) {
          results.add(unit);
        }
      }
    }
    return results;
  }
}
