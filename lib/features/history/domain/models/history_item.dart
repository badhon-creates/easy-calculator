import 'package:flutter/foundation.dart';

/// Represents a completed calculation stored in calculation history.
@immutable
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.mode = 'basic',
  });

  /// Unique identifier for this calculation entry.
  final String id;

  /// The original mathematical expression (e.g. '12 + 5' or 'sin(30)').
  final String expression;

  /// The calculated result string (e.g. '17' or '0.5').
  final String result;

  /// Reliable timestamp when the calculation was finalized.
  final DateTime timestamp;

  /// Calculator mode in which the calculation was performed ('basic' or 'scientific').
  final String mode;

  /// Creates a [HistoryItem] from a JSON map.
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String? ?? '',
      expression: json['expression'] as String? ?? '',
      result: json['result'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      mode: json['mode'] as String? ?? 'basic',
    );
  }

  /// Converts this [HistoryItem] to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'mode': mode,
    };
  }

  HistoryItem copyWith({
    String? id,
    String? expression,
    String? result,
    DateTime? timestamp,
    String? mode,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      mode: mode ?? this.mode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryItem &&
        other.id == id &&
        other.expression == expression &&
        other.result == result &&
        other.timestamp == timestamp &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(id, expression, result, timestamp, mode);

  @override
  String toString() =>
      'HistoryItem(id: $id, expr: $expression, res: $result, time: $timestamp, mode: $mode)';
}
