import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/core/theme/squircle_border.dart';

void main() {
  group('SquircleBorder Geometry & Path Tests', () {
    test('Constructs with defaults matching the reference design', () {
      const border = SquircleBorder();
      expect(border.side, equals(BorderSide.none));
      expect(border.radius, isNull);
      expect(border.cornerRatio, equals(0.332));
      expect(border.curvature, equals(0.55));
    });

    test('Generates closed path matching Rect bounding box', () {
      const border = SquircleBorder();
      const rect = Rect.fromLTWH(0, 0, 100, 100);
      final path = border.getOuterPath(rect);

      expect(path.getBounds().width, closeTo(100.0, 0.01));
      expect(path.getBounds().height, closeTo(100.0, 0.01));
      expect(path.contains(const Offset(50, 50)), isTrue);
    });

    test(
      'Sharp outer corners are rounded/clipped, middle edges are intact',
      () {
        const border = SquircleBorder();
        const rect = Rect.fromLTWH(0, 0, 100, 100);
        final path = border.getOuterPath(rect);

        // Center is contained
        expect(path.contains(const Offset(50, 50)), isTrue);

        // Midpoints of edges are contained (straight middle sections)
        expect(path.contains(const Offset(50, 1)), isTrue);
        expect(path.contains(const Offset(50, 99)), isTrue);
        expect(path.contains(const Offset(1, 50)), isTrue);
        expect(path.contains(const Offset(99, 50)), isTrue);

        // Extreme sharp corner vertices (0,0), (100,0), (100,100), (0,100) are outside the squircle
        expect(path.contains(const Offset(1, 1)), isFalse);
        expect(path.contains(const Offset(99, 1)), isFalse);
        expect(path.contains(const Offset(99, 99)), isFalse);
        expect(path.contains(const Offset(1, 99)), isFalse);
      },
    );

    test(
      'Renders adaptively across different aspect ratios without distortion',
      () {
        const border = SquircleBorder();

        // 1. Basic button: near square (80 x 72)
        final basicPath = border.getOuterPath(
          const Rect.fromLTWH(0, 0, 80, 72),
        );
        expect(basicPath.contains(const Offset(40, 36)), isTrue);
        expect(basicPath.contains(const Offset(40, 1)), isTrue);
        expect(basicPath.contains(const Offset(1, 1)), isFalse);

        // 2. Scientific button: compact rectangle (55 x 38)
        final sciPath = border.getOuterPath(const Rect.fromLTWH(0, 0, 55, 38));
        expect(sciPath.contains(const Offset(27.5, 19)), isTrue);
        expect(sciPath.contains(const Offset(27.5, 1)), isTrue);
        expect(sciPath.contains(const Offset(1, 1)), isFalse);

        // 3. Currency converter button: wide rectangle (114 x 58)
        final convPath = border.getOuterPath(
          const Rect.fromLTWH(0, 0, 114, 58),
        );
        expect(convPath.contains(const Offset(57, 29)), isTrue);
        expect(convPath.contains(const Offset(57, 1)), isTrue);
        expect(convPath.contains(const Offset(1, 1)), isFalse);
      },
    );

    test(
      'Deflates inner path properly when border side has non-zero width',
      () {
        const border = SquircleBorder(
          side: BorderSide(color: Colors.blue, width: 2.0),
        );
        const rect = Rect.fromLTWH(0, 0, 80, 80);
        final outer = border.getOuterPath(rect);
        final inner = border.getInnerPath(rect);

        expect(outer.getBounds().width, equals(80.0));
        expect(inner.getBounds().width, closeTo(76.0, 0.01));
        expect(inner.getBounds().height, closeTo(76.0, 0.01));
      },
    );

    test('Handles zero or degenerate rectangles safely without crashing', () {
      const border = SquircleBorder();
      final zeroPath = border.getOuterPath(Rect.zero);
      expect(zeroPath.getBounds(), equals(Rect.zero));

      final negativePath = border.getOuterPath(
        const Rect.fromLTWH(0, 0, -10, -10),
      );
      expect(negativePath.getBounds(), equals(Rect.zero));
    });

    test('Scale, copyWith, equality, and hashCode support', () {
      const border1 = SquircleBorder(
        side: BorderSide(color: Colors.red, width: 1.0),
        cornerRatio: 0.33,
        curvature: 0.55,
      );
      const border2 = SquircleBorder(
        side: BorderSide(color: Colors.red, width: 1.0),
        cornerRatio: 0.33,
        curvature: 0.55,
      );
      final borderScaled = border1.scale(2.0) as SquircleBorder;

      expect(border1, equals(border2));
      expect(border1.hashCode, equals(border2.hashCode));
      expect(borderScaled.side.width, equals(2.0));

      final borderCopied = border1.copyWith(
        side: const BorderSide(color: Colors.green),
      );
      expect(borderCopied.side.color, equals(Colors.green));
    });
  });
}
