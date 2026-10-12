import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/calculator/domain/engine/calculator_engine.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';

void main() {
  const engine = CalculatorEngine();

  group(
    'Scientific Calculator Engine - Trigonometric Functions & Angle Modes',
    () {
      test('Degrees mode: sin(30) = 0.5, sin(90) = 1, sin(180) = 0', () {
        final res30 = engine.evaluate('sin(30)', angleMode: AngleMode.degrees);
        expect(res30.isSuccess, isTrue);
        expect(res30.formattedResult, '0.5');

        final res90 = engine.evaluate('sin(90)', angleMode: AngleMode.degrees);
        expect(res90.isSuccess, isTrue);
        expect(res90.formattedResult, '1');

        final res180 = engine.evaluate(
          'sin(180)',
          angleMode: AngleMode.degrees,
        );
        expect(res180.isSuccess, isTrue);
        expect(res180.formattedResult, '0');
      });

      test('Degrees mode: cos(60) = 0.5, cos(90) = 0, cos(0) = 1', () {
        final res60 = engine.evaluate('cos(60)', angleMode: AngleMode.degrees);
        expect(res60.isSuccess, isTrue);
        expect(res60.formattedResult, '0.5');

        final res90 = engine.evaluate('cos(90)', angleMode: AngleMode.degrees);
        expect(res90.isSuccess, isTrue);
        expect(res90.formattedResult, '0');

        final res0 = engine.evaluate('cos(0)', angleMode: AngleMode.degrees);
        expect(res0.isSuccess, isTrue);
        expect(res0.formattedResult, '1');
      });

      test('Degrees mode: tan(45) = 1, tan(90) throws domain error', () {
        final res45 = engine.evaluate('tan(45)', angleMode: AngleMode.degrees);
        expect(res45.isSuccess, isTrue);
        expect(res45.formattedResult, '1');

        final res90 = engine.evaluate('tan(90)', angleMode: AngleMode.degrees);
        expect(res90.isSuccess, isFalse);
        expect(res90.errorMessage, contains('undefined'));
      });

      test('Radians mode: sin(π/2) = 1, cos(π) = -1', () {
        final resSin = engine.evaluate(
          'sin(π / 2)',
          angleMode: AngleMode.radians,
        );
        expect(resSin.isSuccess, isTrue);
        expect(resSin.formattedResult, '1');

        final resCos = engine.evaluate('cos(π)', angleMode: AngleMode.radians);
        expect(resCos.isSuccess, isTrue);
        expect(resCos.formattedResult, '-1');
      });

      test(
        'Inverse trigonometric: sin⁻¹(0.5) = 30° in degrees, cos⁻¹(0.5) = 60°',
        () {
          final asinRes = engine.evaluate(
            'sin⁻¹(0.5)',
            angleMode: AngleMode.degrees,
          );
          expect(asinRes.isSuccess, isTrue);
          expect(asinRes.formattedResult, '30');

          final acosRes = engine.evaluate(
            'cos⁻¹(0.5)',
            angleMode: AngleMode.degrees,
          );
          expect(acosRes.isSuccess, isTrue);
          expect(acosRes.formattedResult, '60');

          final atanRes = engine.evaluate(
            'tan⁻¹(1)',
            angleMode: AngleMode.degrees,
          );
          expect(atanRes.isSuccess, isTrue);
          expect(atanRes.formattedResult, '45');
        },
      );

      test('Inverse trig domain validation: sin⁻¹(2) returns domain error', () {
        final res = engine.evaluate('sin⁻¹(2)');
        expect(res.isSuccess, isFalse);
        expect(res.errorMessage, contains('Invalid domain'));
      });
    },
  );

  group('Scientific Calculator Engine - Hyperbolic Functions', () {
    test('sinh(0) = 0, cosh(0) = 1, tanh(0) = 0', () {
      final resSinh = engine.evaluate('sinh(0)');
      expect(resSinh.isSuccess, isTrue);
      expect(resSinh.formattedResult, '0');

      final resCosh = engine.evaluate('cosh(0)');
      expect(resCosh.isSuccess, isTrue);
      expect(resCosh.formattedResult, '1');

      final resTanh = engine.evaluate('tanh(0)');
      expect(resTanh.isSuccess, isTrue);
      expect(resTanh.formattedResult, '0');
    });

    test('Inverse hyperbolic: asinh(0) = 0, acosh(1) = 0', () {
      final resAsinh = engine.evaluate('asinh(0)');
      expect(resAsinh.isSuccess, isTrue);
      expect(resAsinh.formattedResult, '0');

      final resAcosh = engine.evaluate('acosh(1)');
      expect(resAcosh.isSuccess, isTrue);
      expect(resAcosh.formattedResult, '0');
    });

    test('acosh domain check: acosh(0.5) returns error', () {
      final res = engine.evaluate('acosh(0.5)');
      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, contains('Invalid domain'));
    });
  });

  group('Scientific Calculator Engine - Powers, Roots & Reciprocals', () {
    test('Squares and cubes: 5^2 = 25, 2^3 = 8', () {
      final sq = engine.evaluate('5^2');
      expect(sq.formattedResult, '25');

      final cube = engine.evaluate('2^3');
      expect(cube.formattedResult, '8');
    });

    test('Negative base with integer power: (-2)^3 = -8, (-2)^2 = 4', () {
      final cubeNeg = engine.evaluate('(-2)^3');
      expect(cubeNeg.formattedResult, '-8');

      final sqNeg = engine.evaluate('(-2)^2');
      expect(sqNeg.formattedResult, '4');
    });

    test('Non-integer power on negative base returns domain error', () {
      final res = engine.evaluate('(-4)^0.5');
      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, contains('Invalid domain'));
    });

    test('Square root: ²√(16) = 4, ²√(-4) returns domain error', () {
      final sqrtRes = engine.evaluate('²√(16)');
      expect(sqrtRes.formattedResult, '4');

      final sqrtNeg = engine.evaluate('²√(-4)');
      expect(sqrtNeg.isSuccess, isFalse);
      expect(sqrtNeg.errorMessage, contains('Invalid domain'));
    });

    test('Cube root handles negative numbers: ³√(-8) = -2, ³√(27) = 3', () {
      final cbrtNeg = engine.evaluate('³√(-8)');
      expect(cbrtNeg.isSuccess, isTrue);
      expect(cbrtNeg.formattedResult, '-2');

      final cbrtPos = engine.evaluate('³√(27)');
      expect(cbrtPos.formattedResult, '3');
    });

    test('Nth root: 8 ʸ√ 3 = 2 (cube root of 8)', () {
      final res = engine.evaluate('8 ʸ√ 3');
      expect(res.isSuccess, isTrue);
      expect(res.formattedResult, '2');
    });

    test('Exponentials: e^(0) = 1, e^(1) = 2.718281828459', () {
      final res0 = engine.evaluate('e^(0)');
      expect(res0.formattedResult, '1');

      final res1 = engine.evaluate('e^(1)');
      expect(res1.isSuccess, isTrue);
      expect(double.parse(res1.formattedResult!).toStringAsFixed(4), '2.7183');
    });

    test('Powers of 10 and 2: 10^(3) = 1000, 2^(5) = 32', () {
      final res10 = engine.evaluate('10^(3)');
      expect(res10.formattedResult, '1000');

      final res2 = engine.evaluate('2^(5)');
      expect(res2.formattedResult, '32');
    });

    test('Reciprocal: 1/(4) = 0.25, 1/(0) throws division by zero', () {
      final res = engine.evaluate('1 / (4)');
      expect(res.formattedResult, '0.25');

      final divZero = engine.evaluate('1 / (0)');
      expect(divZero.isSuccess, isFalse);
      expect(divZero.errorMessage, contains('divide by zero'));
    });
  });

  group('Scientific Calculator Engine - Logarithms', () {
    test('Natural log: ln(e) = 1, ln(1) = 0', () {
      final resE = engine.evaluate('ln(e)');
      expect(resE.formattedResult, '1');

      final res1 = engine.evaluate('ln(1)');
      expect(res1.formattedResult, '0');
    });

    test('Log base 10: log₁₀(1000) = 3, log₁₀(1) = 0', () {
      final res1000 = engine.evaluate('log₁₀(1000)');
      expect(res1000.formattedResult, '3');

      final res1 = engine.evaluate('log₁₀(1)');
      expect(res1.formattedResult, '0');
    });

    test('Log base 2: log2(8) = 3', () {
      final res8 = engine.evaluate('log2(8)');
      expect(res8.formattedResult, '3');
    });

    test('Logarithm domain check: ln(0) and ln(-5) return error', () {
      final resZero = engine.evaluate('ln(0)');
      expect(resZero.isSuccess, isFalse);
      expect(resZero.errorMessage, contains('Invalid domain'));

      final resNeg = engine.evaluate('ln(-5)');
      expect(resNeg.isSuccess, isFalse);
      expect(resNeg.errorMessage, contains('Invalid domain'));
    });
  });

  group('Scientific Calculator Engine - Factorials', () {
    test('Basic factorials: 0! = 1, 1! = 1, 5! = 120, 6! = 720', () {
      expect(engine.evaluate('0!').formattedResult, '1');
      expect(engine.evaluate('1!').formattedResult, '1');
      expect(engine.evaluate('5!').formattedResult, '120');
      expect(engine.evaluate('6!').formattedResult, '720');
    });

    test(
      'Factorial validation: negative numbers and non-integers return error',
      () {
        final negFact = engine.evaluate('(-3)!');
        expect(negFact.isSuccess, isFalse);

        final decFact = engine.evaluate('3.5!');
        expect(decFact.isSuccess, isFalse);
        expect(decFact.errorMessage, contains('non-negative integer'));
      },
    );

    test('Factorial overflow: 200! returns overflow error', () {
      final overflow = engine.evaluate('200!');
      expect(overflow.isSuccess, isFalse);
      expect(overflow.errorMessage, contains('overflow'));
    });
  });

  group('Scientific Calculator Engine - Scientific Notation (EE)', () {
    test('EE operator: 5E3 = 5000, 2.5E2 = 250, 4E-2 = 0.04', () {
      expect(engine.evaluate('5E3').formattedResult, '5000');
      expect(engine.evaluate('2.5E2').formattedResult, '250');
      expect(engine.evaluate('4E-2').formattedResult, '0.04');
    });

    test('Embedded scientific notation in number: 1.2e4 = 12000', () {
      expect(engine.evaluate('1.2e4').formattedResult, '12000');
    });
  });

  group(
    'Scientific Calculator Engine - Constants & Implicit Multiplication',
    () {
      test('Constants π and e values', () {
        final piRes = engine.evaluate('π');
        expect(
          double.parse(piRes.formattedResult!).toStringAsFixed(4),
          '3.1416',
        );

        final eRes = engine.evaluate('e');
        expect(
          double.parse(eRes.formattedResult!).toStringAsFixed(4),
          '2.7183',
        );
      });

      test('Implicit multiplication with constants: 2π = 2 * π', () {
        final res = engine.evaluate('2π');
        expect(
          double.parse(res.formattedResult!).toStringAsFixed(4),
          (2 * math.pi).toStringAsFixed(4),
        );
      });

      test(
        'Implicit multiplication with functions: 2sin(30) = 1 in degrees',
        () {
          final res = engine.evaluate('2sin(30)', angleMode: AngleMode.degrees);
          expect(res.formattedResult, '1');
        },
      );
    },
  );
}
