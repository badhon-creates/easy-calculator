/// Coordinate point in a freehand drawing stroke.
class StrokePoint {
  const StrokePoint({required this.x, required this.y});

  final double x;
  final double y;

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory StrokePoint.fromJson(Map<String, dynamic> json) {
    return StrokePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrokePoint &&
          runtimeType == other.runtimeType &&
          (x - other.x).abs() < 0.001 &&
          (y - other.y).abs() < 0.001;

  @override
  int get hashCode => Object.hash(x.roundToDouble(), y.roundToDouble());
}

/// A continuous freehand drawing stroke with points, color, and stroke width.
class DrawingStroke {
  const DrawingStroke({
    required this.points,
    required this.colorHex,
    this.strokeWidth = 3.0,
  });

  final List<StrokePoint> points;
  final String colorHex;
  final double strokeWidth;

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
    'colorHex': colorHex,
    'strokeWidth': strokeWidth,
  };

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      points: (json['points'] as List<dynamic>? ?? [])
          .map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      colorHex: json['colorHex'] as String? ?? '#64AFFA',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3.0,
    );
  }

  DrawingStroke copyWith({
    List<StrokePoint>? points,
    String? colorHex,
    double? strokeWidth,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      colorHex: colorHex ?? this.colorHex,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
