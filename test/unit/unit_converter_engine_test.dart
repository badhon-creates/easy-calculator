import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/units_converter/domain/models/unit_category.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_registry.dart';
import 'package:easy_calculator/features/units_converter/domain/services/unit_converter_engine.dart';

void main() {
  group('UnitRegistry Tests', () {
    test('Contains all 15 categories', () {
      expect(UnitCategory.values.length, 15);
      for (final cat in UnitCategory.values) {
        if (cat == UnitCategory.currency) continue;
        final units = UnitRegistry.getUnits(cat);
        expect(
          units.isNotEmpty,
          isTrue,
          reason: 'Category ${cat.displayName} has units',
        );
      }
    });

    test('Each category has default source and target units', () {
      for (final cat in UnitCategory.values) {
        if (cat == UnitCategory.currency) continue;
        final src = UnitRegistry.getDefaultSource(cat);
        final tgt = UnitRegistry.getDefaultTarget(cat);
        expect(src.id, isNotEmpty);
        expect(tgt.id, isNotEmpty);
        expect(src.id != tgt.id, isTrue);
      }
    });

    test('Search units across categories finds relevant units', () {
      final results = UnitRegistry.searchUnits('meter');
      expect(results.any((u) => u.id == 'meter'), isTrue);
      expect(results.any((u) => u.id == 'kilometer'), isTrue);

      final tempResults = UnitRegistry.searchUnits('celsius');
      expect(tempResults.any((u) => u.id == 'celsius'), isTrue);
    });
  });

  group('Linear Unit Conversions', () {
    test('Length: meters to feet, miles, inches', () {
      final m = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'meter');
      final ft = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'foot');
      final mi = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'mile');
      final inch = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'inch');

      // 1 meter = 3.28084 feet
      final rFt = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: m,
        to: ft,
      );
      expect(rFt.isValid, isTrue);
      expect(rFt.targetValue, closeTo(3.28084, 0.001));

      // 1609.344 meters = 1 mile
      final rMi = UnitConverterEngine.convert(
        sourceValue: 1609.344,
        from: m,
        to: mi,
      );
      expect(rMi.targetValue, closeTo(1.0, 0.0001));

      // 1 inch = 0.0254 meters
      final rIn = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: inch,
        to: m,
      );
      expect(rIn.targetValue, closeTo(0.0254, 0.0001));
    });

    test('Data: SI decimal and IEC binary conversions', () {
      final b = UnitRegistry.getUnits(UnitCategory.data)
          .firstWhere((u) => u.id == 'bit');
      final byte = UnitRegistry.getUnits(UnitCategory.data)
          .firstWhere((u) => u.id == 'byte');
      final kb = UnitRegistry.getUnits(UnitCategory.data)
          .firstWhere((u) => u.id == 'kilobyte');
      final kib = UnitRegistry.getUnits(UnitCategory.data)
          .firstWhere((u) => u.id == 'kibibyte');
      final mb = UnitRegistry.getUnits(UnitCategory.data)
          .firstWhere((u) => u.id == 'megabyte');

      // 8 bits = 1 byte
      final rByte = UnitConverterEngine.convert(
        sourceValue: 8.0,
        from: b,
        to: byte,
      );
      expect(rByte.targetValue, closeTo(1.0, 0.0001));

      // 1 kilobyte (SI) = 1000 bytes
      final rKb = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: kb,
        to: byte,
      );
      expect(rKb.targetValue, closeTo(1000.0, 0.0001));

      // 1 kibibyte (IEC) = 1024 bytes
      final rKib = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: kib,
        to: byte,
      );
      expect(rKib.targetValue, closeTo(1024.0, 0.0001));

      // 1 megabyte = 1,000,000 bytes
      final rMb = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: mb,
        to: byte,
      );
      expect(rMb.targetValue, closeTo(1000000.0, 0.0001));
    });

    test('Angle: degrees, radians, gradians', () {
      final deg = UnitRegistry.getUnits(UnitCategory.angle)
          .firstWhere((u) => u.id == 'degree');
      final rad = UnitRegistry.getUnits(UnitCategory.angle)
          .firstWhere((u) => u.id == 'radian');
      final grad = UnitRegistry.getUnits(UnitCategory.angle)
          .firstWhere((u) => u.id == 'gradian');

      // 180 degrees = pi radians
      final rRad = UnitConverterEngine.convert(
        sourceValue: 180.0,
        from: deg,
        to: rad,
      );
      expect(rRad.targetValue, closeTo(3.14159265, 0.0001));

      // 180 degrees = 200 gradians
      final rGrad = UnitConverterEngine.convert(
        sourceValue: 180.0,
        from: deg,
        to: grad,
      );
      expect(rGrad.targetValue, closeTo(200.0, 0.0001));
    });

    test('Area: square meters, acres, hectares', () {
      final m2 = UnitRegistry.getUnits(UnitCategory.area)
          .firstWhere((u) => u.id == 'square_meter');
      final ha = UnitRegistry.getUnits(UnitCategory.area)
          .firstWhere((u) => u.id == 'hectare');
      final ac = UnitRegistry.getUnits(UnitCategory.area)
          .firstWhere((u) => u.id == 'acre');

      // 10,000 m² = 1 hectare
      final rHa = UnitConverterEngine.convert(
        sourceValue: 10000.0,
        from: m2,
        to: ha,
      );
      expect(rHa.targetValue, closeTo(1.0, 0.0001));

      // 1 acre = 4046.856 m²
      final rAc = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: ac,
        to: m2,
      );
      expect(rAc.targetValue, closeTo(4046.856, 0.01));
    });

    test('Energy, Force, Power, Pressure, Speed, Time, Volume, Weight', () {
      // Energy: 1 kWh = 3.6e6 J
      final kwh = UnitRegistry.getUnits(UnitCategory.energy)
          .firstWhere((u) => u.id == 'kilowatt_hour');
      final j = UnitRegistry.getUnits(UnitCategory.energy)
          .firstWhere((u) => u.id == 'joule');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: kwh,
          to: j,
        ).targetValue,
        closeTo(3.6e6, 1.0),
      );

      // Force: 1 lbf ≈ 4.44822 N
      final lbf = UnitRegistry.getUnits(UnitCategory.force)
          .firstWhere((u) => u.id == 'pound_force');
      final n = UnitRegistry.getUnits(UnitCategory.force)
          .firstWhere((u) => u.id == 'newton');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: lbf,
          to: n,
        ).targetValue,
        closeTo(4.44822, 0.001),
      );

      // Power: 1 hp (I) ≈ 745.7 W
      final hp = UnitRegistry.getUnits(UnitCategory.power)
          .firstWhere((u) => u.id == 'horsepower_mechanical');
      final w = UnitRegistry.getUnits(UnitCategory.power)
          .firstWhere((u) => u.id == 'watt');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: hp,
          to: w,
        ).targetValue,
        closeTo(745.7, 0.1),
      );

      // Pressure: 1 atm = 101325 Pa
      final atm = UnitRegistry.getUnits(UnitCategory.pressure)
          .firstWhere((u) => u.id == 'atmosphere');
      final pa = UnitRegistry.getUnits(UnitCategory.pressure)
          .firstWhere((u) => u.id == 'pascal');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: atm,
          to: pa,
        ).targetValue,
        closeTo(101325.0, 0.1),
      );

      // Speed: 100 km/h ≈ 27.7778 m/s
      final kmh = UnitRegistry.getUnits(UnitCategory.speed)
          .firstWhere((u) => u.id == 'kilometer_per_hour');
      final ms = UnitRegistry.getUnits(UnitCategory.speed)
          .firstWhere((u) => u.id == 'meter_per_second');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 100.0,
          from: kmh,
          to: ms,
        ).targetValue,
        closeTo(27.7778, 0.001),
      );

      // Time: 1 hour = 3600 seconds
      final hr = UnitRegistry.getUnits(UnitCategory.time)
          .firstWhere((u) => u.id == 'hour');
      final sec = UnitRegistry.getUnits(UnitCategory.time)
          .firstWhere((u) => u.id == 'second');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: hr,
          to: sec,
        ).targetValue,
        closeTo(3600.0, 0.01),
      );

      // Volume: 1 gal (US) ≈ 3.78541 L
      final galUs = UnitRegistry.getUnits(UnitCategory.volume)
          .firstWhere((u) => u.id == 'gallon_us');
      final liter = UnitRegistry.getUnits(UnitCategory.volume)
          .firstWhere((u) => u.id == 'liter');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: galUs,
          to: liter,
        ).targetValue,
        closeTo(3.78541, 0.001),
      );

      // Weight: 1 lb = 0.453592 kg
      final lb = UnitRegistry.getUnits(UnitCategory.weight)
          .firstWhere((u) => u.id == 'pound');
      final kg = UnitRegistry.getUnits(UnitCategory.weight)
          .firstWhere((u) => u.id == 'kilogram');
      expect(
        UnitConverterEngine.convert(
          sourceValue: 1.0,
          from: lb,
          to: kg,
        ).targetValue,
        closeTo(0.453592, 0.0001),
      );
    });
  });

  group('Temperature Conversions (Offset and Negative Cases)', () {
    final c = UnitRegistry.getUnits(UnitCategory.temperature)
        .firstWhere((u) => u.id == 'celsius');
    final f = UnitRegistry.getUnits(UnitCategory.temperature)
        .firstWhere((u) => u.id == 'fahrenheit');
    final k = UnitRegistry.getUnits(UnitCategory.temperature)
        .firstWhere((u) => u.id == 'kelvin');

    test('0 °C = 32 °F and 273.15 K', () {
      final toF = UnitConverterEngine.convert(sourceValue: 0.0, from: c, to: f);
      expect(toF.targetValue, closeTo(32.0, 0.0001));

      final toK = UnitConverterEngine.convert(sourceValue: 0.0, from: c, to: k);
      expect(toK.targetValue, closeTo(273.15, 0.0001));
    });

    test('100 °C = 212 °F and 373.15 K', () {
      final toF = UnitConverterEngine.convert(
        sourceValue: 100.0,
        from: c,
        to: f,
      );
      expect(toF.targetValue, closeTo(212.0, 0.0001));

      final toK = UnitConverterEngine.convert(
        sourceValue: 100.0,
        from: c,
        to: k,
      );
      expect(toK.targetValue, closeTo(373.15, 0.0001));
    });

    test('-40 °C = -40 °F', () {
      final toF = UnitConverterEngine.convert(
        sourceValue: -40.0,
        from: c,
        to: f,
      );
      expect(toF.targetValue, closeTo(-40.0, 0.0001));

      final toC = UnitConverterEngine.convert(
        sourceValue: -40.0,
        from: f,
        to: c,
      );
      expect(toC.targetValue, closeTo(-40.0, 0.0001));
    });

    test('0 K = -273.15 °C = -459.67 °F (Absolute Zero)', () {
      final toC = UnitConverterEngine.convert(sourceValue: 0.0, from: k, to: c);
      expect(toC.targetValue, closeTo(-273.15, 0.01));

      final toF = UnitConverterEngine.convert(sourceValue: 0.0, from: k, to: f);
      expect(toF.targetValue, closeTo(-459.67, 0.01));
    });
  });

  group('Fuel Economy (Reciprocal & Gallon Distinctions)', () {
    final kml = UnitRegistry.getUnits(UnitCategory.fuel)
        .firstWhere((u) => u.id == 'km_per_liter');
    final l100 = UnitRegistry.getUnits(UnitCategory.fuel)
        .firstWhere((u) => u.id == 'liters_per_100km');
    final mpgUs = UnitRegistry.getUnits(UnitCategory.fuel)
        .firstWhere((u) => u.id == 'mpg_us');
    final mpgImp = UnitRegistry.getUnits(UnitCategory.fuel)
        .firstWhere((u) => u.id == 'mpg_imp');

    test('10 km/L = 10 L/100 km', () {
      final r = UnitConverterEngine.convert(
        sourceValue: 10.0,
        from: kml,
        to: l100,
      );
      expect(r.isValid, isTrue);
      expect(r.targetValue, closeTo(10.0, 0.001));
    });

    test('8 L/100 km = 12.5 km/L', () {
      final r = UnitConverterEngine.convert(
        sourceValue: 8.0,
        from: l100,
        to: kml,
      );
      expect(r.targetValue, closeTo(12.5, 0.001));
    });

    test('Distinguishes US mpg vs Imperial mpg', () {
      // 1 mpg US ≈ 0.42514 km/L
      final rUs = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: mpgUs,
        to: kml,
      );
      expect(rUs.targetValue, closeTo(0.42514, 0.001));

      // 1 mpg Imp ≈ 0.35401 km/L
      final rImp = UnitConverterEngine.convert(
        sourceValue: 1.0,
        from: mpgImp,
        to: kml,
      );
      expect(rImp.targetValue, closeTo(0.35401, 0.001));

      // Imperial mpg gives higher mpg number for same km/L (since Imp gallon is larger)
      final usToImp = UnitConverterEngine.convert(
        sourceValue: 30.0,
        from: mpgUs,
        to: mpgImp,
      );
      expect(usToImp.targetValue, closeTo(36.03, 0.1));
    });

    test('Rejects zero and negative fuel values safely', () {
      final rZero = UnitConverterEngine.convert(
        sourceValue: 0.0,
        from: kml,
        to: l100,
      );
      expect(rZero.isValid, isFalse);

      final rNeg = UnitConverterEngine.convert(
        sourceValue: -5.0,
        from: kml,
        to: l100,
      );
      expect(rNeg.isValid, isFalse);
    });
  });

  group('Safety and Formatting Tests', () {
    test('Non-finite inputs are rejected gracefully', () {
      final m = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'meter');
      final ft = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'foot');

      final rNan = UnitConverterEngine.convert(
        sourceValue: double.nan,
        from: m,
        to: ft,
      );
      expect(rNan.isValid, isFalse);

      final rInf = UnitConverterEngine.convert(
        sourceValue: double.infinity,
        from: m,
        to: ft,
      );
      expect(rInf.isValid, isFalse);
    });

    test('Negative lengths are rejected', () {
      final m = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'meter');
      final ft = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'foot');

      final rNeg = UnitConverterEngine.convert(
        sourceValue: -10.0,
        from: m,
        to: ft,
      );
      expect(rNeg.isValid, isFalse);
      expect(rNeg.errorMessage, contains('Negative'));
    });

    test('Round-trip conversion preserves value', () {
      final m = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'meter');
      final yd = UnitRegistry.getUnits(UnitCategory.length)
          .firstWhere((u) => u.id == 'yard');

      final toYd = UnitConverterEngine.convert(
        sourceValue: 42.5,
        from: m,
        to: yd,
      );
      final backToM = UnitConverterEngine.convert(
        sourceValue: toYd.targetValue,
        from: yd,
        to: m,
      );
      expect(backToM.targetValue, closeTo(42.5, 0.000001));
    });
  });
}
