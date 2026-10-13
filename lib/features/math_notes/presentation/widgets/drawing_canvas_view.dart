import 'package:flutter/material.dart';
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';

/// Helper to parse hex strings (e.g. '#64AFFA' or '#FF64AFFA') into [Color].
Color parseHexColor(String hex, {Color fallback = const Color(0xFF64AFFA)}) {
  try {
    String cleanHex = hex.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return fallback;
  } catch (_) {
    return fallback;
  }
}

/// Interactive or read-only canvas widget rendering freehand drawing strokes.
class DrawingCanvasView extends StatelessWidget {
  const DrawingCanvasView({
    super.key,
    required this.strokes,
    this.currentPoints = const [],
    this.activeColorHex = '#64AFFA',
    this.activeStrokeWidth = 3.0,
    this.isInteractive = false,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.height = 240,
    this.backgroundColor,
  });

  final List<DrawingStroke> strokes;
  final List<StrokePoint> currentPoints;
  final String activeColorHex;
  final double activeStrokeWidth;
  final bool isInteractive;
  final void Function(Offset localPosition)? onPanStart;
  final void Function(Offset localPosition)? onPanUpdate;
  final VoidCallback? onPanEnd;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final canvasWidget = ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        height: height,
        width: double.infinity,
        color: backgroundColor ?? Colors.transparent,
        child: CustomPaint(
          painter: _DrawingPainter(
            strokes: strokes,
            currentPoints: currentPoints,
            currentColor: parseHexColor(activeColorHex),
            currentWidth: activeStrokeWidth,
          ),
        ),
      ),
    );

    if (!isInteractive) {
      return canvasWidget;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => onPanStart?.call(details.localPosition),
      onPanUpdate: (details) => onPanUpdate?.call(details.localPosition),
      onPanEnd: (_) => onPanEnd?.call(),
      child: canvasWidget,
    );
  }
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
  });

  final List<DrawingStroke> strokes;
  final List<StrokePoint> currentPoints;
  final Color currentColor;
  final double currentWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = parseHexColor(stroke.colorHex)
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          Offset(stroke.points.first.x, stroke.points.first.y),
          stroke.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.x, stroke.points.first.y);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].x, stroke.points[i].y);
        }
        canvas.drawPath(path, paint);
      }
    }

    // 2. Draw active in-progress stroke
    if (currentPoints.isNotEmpty) {
      final activePaint = Paint()
        ..color = currentColor
        ..strokeWidth = currentWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (currentPoints.length == 1) {
        canvas.drawCircle(
          Offset(currentPoints.first.x, currentPoints.first.y),
          currentWidth / 2,
          activePaint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path();
        path.moveTo(currentPoints.first.x, currentPoints.first.y);
        for (int i = 1; i < currentPoints.length; i++) {
          path.lineTo(currentPoints[i].x, currentPoints[i].y);
        }
        canvas.drawPath(path, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
