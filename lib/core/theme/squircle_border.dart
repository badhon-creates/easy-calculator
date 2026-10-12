import 'package:flutter/material.dart';

/// A custom squircle/superellipse shape border for calculator buttons.
/// Produces continuous curvature with straight horizontal/vertical edges
/// and large, smooth corners matching the approved PRD visual reference.
class SquircleBorder extends OutlinedBorder {
  const SquircleBorder({
    super.side = BorderSide.none,
    this.radius = 24.0,
    this.smoothness = 0.8,
  });

  /// The nominal corner radius.
  final double radius;

  /// Smoothness factor (0.0 = regular rounded rect, 1.0 = deep superellipse/squircle).
  final double smoothness;

  @override
  ShapeBorder scale(double t) => SquircleBorder(
    side: side.scale(t),
    radius: radius * t,
    smoothness: smoothness,
  );

  @override
  OutlinedBorder copyWith({
    BorderSide? side,
    double? radius,
    double? smoothness,
  }) {
    return SquircleBorder(
      side: side ?? this.side,
      radius: radius ?? this.radius,
      smoothness: smoothness ?? this.smoothness,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _buildSquirclePath(rect.deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _buildSquirclePath(rect);
  }

  Path _buildSquirclePath(Rect rect) {
    final width = rect.width;
    final height = rect.height;
    final maxRadius = (width < height ? width : height) / 2;
    final r = radius.clamp(0.0, maxRadius);

    if (r == 0) {
      return Path()..addRect(rect);
    }

    // Smoothness determines how far into the straight edges the curve extends.
    final p = (r * (1 + smoothness * 0.5)).clamp(r, maxRadius);
    final offset = (p - r) * 0.8;

    final path = Path();
    // Top-left corner start
    path.moveTo(rect.left + p, rect.top);

    // Top edge -> Top-right corner
    path.lineTo(rect.right - p, rect.top);
    path.cubicTo(
      rect.right - p + offset,
      rect.top,
      rect.right,
      rect.top + p - offset,
      rect.right,
      rect.top + p,
    );

    // Right edge -> Bottom-right corner
    path.lineTo(rect.right, rect.bottom - p);
    path.cubicTo(
      rect.right,
      rect.bottom - p + offset,
      rect.right - p + offset,
      rect.bottom,
      rect.right - p,
      rect.bottom,
    );

    // Bottom edge -> Bottom-left corner
    path.lineTo(rect.left + p, rect.bottom);
    path.cubicTo(
      rect.left + p - offset,
      rect.bottom,
      rect.left,
      rect.bottom - p + offset,
      rect.left,
      rect.bottom - p,
    );

    // Left edge -> Top-left corner
    path.lineTo(rect.left, rect.top + p);
    path.cubicTo(
      rect.left,
      rect.top + p - offset,
      rect.left + p - offset,
      rect.top,
      rect.left + p,
      rect.top,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none || side.width == 0.0) return;
    final paint = side.toPaint();
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SquircleBorder &&
        other.side == side &&
        other.radius == radius &&
        other.smoothness == smoothness;
  }

  @override
  int get hashCode => Object.hash(side, radius, smoothness);
}
