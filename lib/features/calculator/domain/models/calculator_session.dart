import 'package:flutter/foundation.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';

/// Represents the persistent in-progress session of the calculator.
@immutable
class CalculatorSession {
  const CalculatorSession({
    this.expression = '',
    this.result,
    this.isResultComputed = false,
    this.errorMessage,
    this.mode = CalculatorMode.basic,
    this.angleMode = AngleMode.degrees,
    this.isSecondary = false,
    this.memoryValue = 0.0,
    this.hasMemory = false,
    required this.lastUpdated,
  });

  final String expression;
  final String? result;
  final bool isResultComputed;
  final String? errorMessage;
  final CalculatorMode mode;
  final AngleMode angleMode;
  final bool isSecondary;
  final double memoryValue;
  final bool hasMemory;
  final DateTime lastUpdated;

  /// Creates a [CalculatorSession] from a [CalculatorState].
  factory CalculatorSession.fromState(
    CalculatorState state, {
    DateTime? timestamp,
  }) {
    return CalculatorSession(
      expression: state.expression,
      result: state.result,
      isResultComputed: state.isResultComputed,
      errorMessage: state.errorMessage,
      mode: state.mode,
      angleMode: state.angleMode,
      isSecondary: state.isSecondary,
      memoryValue: state.memoryValue,
      hasMemory: state.hasMemory,
      lastUpdated: timestamp ?? DateTime.now(),
    );
  }

  /// Converts this session into a [CalculatorState].
  CalculatorState toState() {
    return CalculatorState(
      expression: expression,
      result: result,
      isResultComputed: isResultComputed,
      errorMessage: errorMessage,
      mode: mode,
      angleMode: angleMode,
      isSecondary: isSecondary,
      memoryValue: memoryValue,
      hasMemory: hasMemory,
    );
  }

  factory CalculatorSession.fromJson(Map<String, dynamic> json) {
    CalculatorMode parseMode(String? val) {
      if (val == 'scientific') return CalculatorMode.scientific;
      if (val == 'mathNotes') return CalculatorMode.mathNotes;
      if (val == 'convert') return CalculatorMode.convert;
      return CalculatorMode.basic;
    }

    AngleMode parseAngle(String? val) {
      if (val == 'radians') return AngleMode.radians;
      return AngleMode.degrees;
    }

    return CalculatorSession(
      expression: json['expression'] as String? ?? '',
      result: json['result'] as String?,
      isResultComputed: json['isResultComputed'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      mode: parseMode(json['mode'] as String?),
      angleMode: parseAngle(json['angleMode'] as String?),
      isSecondary: json['isSecondary'] as bool? ?? false,
      memoryValue: (json['memoryValue'] as num?)?.toDouble() ?? 0.0,
      hasMemory: json['hasMemory'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'expression': expression,
      'result': result,
      'isResultComputed': isResultComputed,
      'errorMessage': errorMessage,
      'mode': mode.name,
      'angleMode': angleMode == AngleMode.radians ? 'radians' : 'degrees',
      'isSecondary': isSecondary,
      'memoryValue': memoryValue,
      'hasMemory': hasMemory,
      'lastUpdated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculatorSession &&
        other.expression == expression &&
        other.result == result &&
        other.isResultComputed == isResultComputed &&
        other.errorMessage == errorMessage &&
        other.mode == mode &&
        other.angleMode == angleMode &&
        other.isSecondary == isSecondary &&
        other.memoryValue == memoryValue &&
        other.hasMemory == hasMemory;
  }

  @override
  int get hashCode => Object.hash(
    expression,
    result,
    isResultComputed,
    errorMessage,
    mode,
    angleMode,
    isSecondary,
    memoryValue,
    hasMemory,
  );
}
