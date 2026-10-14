import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_canvas_view.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_color_picker_dialog.dart';

void main() {
  group('Drawing Color & Opacity Unit Tests', () {
    test('colorToHex converts fully opaque colors to #RRGGBB', () {
      expect(colorToHex(const Color(0xFF64AFFA)), '#64AFFA');
      expect(colorToHex(const Color(0xFF000000)), '#000000');
      expect(colorToHex(const Color(0xFFFFFFFF)), '#FFFFFF');
      expect(colorToHex(const Color(0xFFEF4444)), '#EF4444');
    });

    test('colorToHex converts translucent colors to #AARRGGBB', () {
      // 50% opacity blue
      const translucentBlue = Color(0x8064AFFA);
      final hex = colorToHex(translucentBlue);
      expect(hex, '#8064AFFA');
      expect(hex.length, 9); // # + 8 hex chars
    });

    test('parseHexColor safely parses both 6-char and 8-char hex colors', () {
      // 6-character hex
      final opaqueColor = parseHexColor('#64AFFA');
      expect(opaqueColor.a, 1.0);
      expect(opaqueColor.r, closeTo(0x64 / 255.0, 0.01));
      expect(opaqueColor.g, closeTo(0xAF / 255.0, 0.01));
      expect(opaqueColor.b, closeTo(0xFA / 255.0, 0.01));

      // 8-character hex with alpha
      final alphaColor = parseHexColor('#8064AFFA');
      expect(alphaColor.a, closeTo(0x80 / 255.0, 0.01));
      expect(alphaColor.r, closeTo(0x64 / 255.0, 0.01));
      expect(alphaColor.g, closeTo(0xAF / 255.0, 0.01));
      expect(alphaColor.b, closeTo(0xFA / 255.0, 0.01));

      // Malformed string falls back safely
      final fallbackColor = parseHexColor('invalid_hex');
      expect(fallbackColor, const Color(0xFF64AFFA));
    });

    test(
      'DrawingStroke model preserves 8-character hex with alpha in JSON',
      () {
        const stroke = DrawingStroke(
          colorHex: '#8064AFFA',
          strokeWidth: 4.0,
          points: [
            StrokePoint(x: 10.0, y: 15.0),
            StrokePoint(x: 20.0, y: 25.0),
          ],
        );

        final json = stroke.toJson();
        expect(json['colorHex'], '#8064AFFA');
        expect(json['strokeWidth'], 4.0);

        final restored = DrawingStroke.fromJson(json);
        expect(restored.colorHex, '#8064AFFA');
        expect(restored.strokeWidth, 4.0);
        expect(restored.points.length, 2);
        expect(restored.points[0].x, 10.0);
        expect(restored.points[1].y, 25.0);
      },
    );

    test(
      'Backward compatibility: existing 6-character hex strokes parse cleanly',
      () {
        final legacyJson = {
          'colorHex': '#EF4444',
          'strokeWidth': 2.0,
          'points': [
            {'x': 5.0, 'y': 5.0},
          ],
        };

        final restored = DrawingStroke.fromJson(legacyJson);
        expect(restored.colorHex, '#EF4444');
        final color = parseHexColor(restored.colorHex);
        expect(color.a, 1.0);
      },
    );
  });
}
