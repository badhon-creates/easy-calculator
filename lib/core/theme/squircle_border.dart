import 'package:flutter/material.dart';

/// A custom squircle/superellipse shape border for calculator buttons.
/// Produces continuous curvature with straight horizontal/vertical edges
/// and large, smooth corners matching the reference image.
class SquircleBorder extends OutlinedBorder {
  const SquircleBorder({
    super.side = BorderSide.none,
    this.radius,
    this.smoothness = 0.85,
    this.cornerRatio = 0.332,
    this.curvature = 0.55,
  });

  /// The nominal corner radius. If null or <= 0, automatically derived from [cornerRatio].
  final double? radius;

  /// Smoothness factor preserved for backward compatibility.
  final double smoothness;

  /// Corner ratio relative to min(width, height). Defaults to 0.332 (~33%) matching reference image.
  final double cornerRatio;

  /// Bezier control point curvature ratio. Defaults to 0.55 matching reference image.
  final double curvature;

  @override
  ShapeBorder scale(double t) => SquircleBorder(
    side: side.scale(t),
    radius: radius != null ? radius! * t : null,
    smoothness: smoothness,
    cornerRatio: cornerRatio,
    curvature: curvature,
  );

  @override
  OutlinedBorder copyWith({
    BorderSide? side,
    double? radius,
    double? smoothness,
    double? cornerRatio,
    double? curvature,
  }) {
    return SquircleBorder(
      side: side ?? this.side,
      radius: radius ?? this.radius,
      smoothness: smoothness ?? this.smoothness,
      cornerRatio: cornerRatio ?? this.cornerRatio,
      curvature: curvature ?? this.curvature,
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
    if (width <= 0 || height <= 0) {
      return Path();
    }

    final shortestSide = width < height ? width : height;
    final maxCorner = shortestSide * 0.45;

    // Determine corner span c
    final double c;
    if (radius != null && radius! > 0) {
      c = radius!.clamp(0.0, maxCorner);
    } else {
      c = (shortestSide * cornerRatio).clamp(0.0, maxCorner);
    }

    if (c <= 0) {
      return Path()..addRect(rect);
    }

    final k = curvature.clamp(0.1, 0.9);
    final l = rect.left;
    final t = rect.top;
    final r = rect.right;
    final b = rect.bottom;

    final path = Path();

    // Top edge: from (l + c, t) to (r - c, t)
    path.moveTo(l + c, t);
    path.lineTo(r - c, t);

    // Top-right corner: from (r - c, t) to (r, t + c)
    path.cubicTo(r - k * c, t, r, t + k * c, r, t + c);

    // Right edge: from (r, t + c) to (r, b - c)
    path.lineTo(r, b - c);

    // Bottom-right corner: from (r, b - c) to (r - c, b)
    path.cubicTo(r, b - k * c, r - k * c, b, r - c, b);

    // Bottom edge: from (r - c, b) to (l + c, b)
    path.lineTo(l + c, b);

    // Bottom-left corner: from (l + c, b) to (l, b - c)
    path.cubicTo(l + k * c, b, l, b - k * c, l, b - c);

    // Left edge: from (l, b - c) to (l, t + c)
    path.lineTo(l, t + c);

    // Top-left corner: from (l, t + c) to (l + c, t)
    path.cubicTo(l, t + k * c, l + k * c, t, l + c, t);

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none || side.width == 0.0) return;
    final paint = side.toPaint();
    final path = _buildSquirclePath(rect.deflate(side.width / 2.0));
    canvas.drawPath(path, paint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SquircleBorder &&
        other.side == side &&
        other.radius == radius &&
        other.smoothness == smoothness &&
        other.cornerRatio == cornerRatio &&
        other.curvature == curvature;
  }

  @override
  int get hashCode =>
      Object.hash(side, radius, smoothness, cornerRatio, curvature);
}
