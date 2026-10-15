import 'package:flutter/material.dart';

/// The 15 supported unit conversion categories in Easy Calculator Phase 8.
enum UnitCategory {
  angle,
  area,
  currency,
  data,
  energy,
  force,
  fuel,
  length,
  power,
  pressure,
  speed,
  temperature,
  time,
  volume,
  weight;

  String get displayName {
    switch (this) {
      case UnitCategory.angle:
        return 'Angle';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.currency:
        return 'Currency';
      case UnitCategory.data:
        return 'Data';
      case UnitCategory.energy:
        return 'Energy';
      case UnitCategory.force:
        return 'Force';
      case UnitCategory.fuel:
        return 'Fuel';
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.power:
        return 'Power';
      case UnitCategory.pressure:
        return 'Pressure';
      case UnitCategory.speed:
        return 'Speed';
      case UnitCategory.temperature:
        return 'Temperature';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.weight:
        return 'Weight';
    }
  }

  IconData get icon {
    switch (this) {
      case UnitCategory.angle:
        return Icons.architecture_rounded;
      case UnitCategory.area:
        return Icons.crop_square_rounded;
      case UnitCategory.currency:
        return Icons.currency_exchange_rounded;
      case UnitCategory.data:
        return Icons.sd_storage_rounded;
      case UnitCategory.energy:
        return Icons.bolt_rounded;
      case UnitCategory.force:
        return Icons.fitness_center_rounded;
      case UnitCategory.fuel:
        return Icons.local_gas_station_rounded;
      case UnitCategory.length:
        return Icons.straighten_rounded;
      case UnitCategory.power:
        return Icons.power_rounded;
      case UnitCategory.pressure:
        return Icons.compress_rounded;
      case UnitCategory.speed:
        return Icons.speed_rounded;
      case UnitCategory.temperature:
        return Icons.thermostat_rounded;
      case UnitCategory.time:
        return Icons.schedule_rounded;
      case UnitCategory.volume:
        return Icons.opacity_rounded;
      case UnitCategory.weight:
        return Icons.scale_rounded;
    }
  }

  /// Whether this category supports negative inputs (e.g. Temperature).
  bool get supportsNegative {
    return this == UnitCategory.temperature;
  }
}
