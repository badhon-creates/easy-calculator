import 'package:flutter/foundation.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';

enum CalculatorMode { basic, scientific, mathNotes, convert }

/// State representation for the calculator.
@immutable
class CalculatorState {
  const CalculatorState({
    this.expression = '',
    this.result,
    this.isResultComputed = false,
    this.errorMessage,
    this.mode = CalculatorMode.basic,
    this.angleMode = AngleMode.degrees,
    this.isSecondary = false,
    this.memoryValue = 0.0,
    this.hasMemory = false,
  });

  /// The active expression input by the user (e.g., '12 + 5').
  final String expression;

  /// The computed result string (e.g., '17').
  final String? result;

  /// Whether the user has pressed equals and the result is in finalized state.
  final bool isResultComputed;

  /// Any active mathematical or syntax error message.
  final String? errorMessage;

  /// Current active mode of the application.
  final CalculatorMode mode;

  /// Angle mode (degrees vs radians) for trigonometric functions.
  final AngleMode angleMode;

  /// Whether secondary functions (2nd) are active.
  final bool isSecondary;

  /// Value currently stored in the memory register.
  final double memoryValue;

  /// Whether memory holds an active non-zero stored value.
  final bool hasMemory;

  CalculatorState copyWith({
    String? expression,
    String? result,
    bool? isResultComputed,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    CalculatorMode? mode,
    AngleMode? angleMode,
    bool? isSecondary,
    double? memoryValue,
    bool? hasMemory,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: clearResult ? null : (result ?? this.result),
      isResultComputed: isResultComputed ?? this.isResultComputed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mode: mode ?? this.mode,
      angleMode: angleMode ?? this.angleMode,
      isSecondary: isSecondary ?? this.isSecondary,
      memoryValue: memoryValue ?? this.memoryValue,
      hasMemory: hasMemory ?? this.hasMemory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculatorState &&
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
