import 'package:flutter/foundation.dart';

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

  CalculatorState copyWith({
    String? expression,
    String? result,
    bool? isResultComputed,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    CalculatorMode? mode,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: clearResult ? null : (result ?? this.result),
      isResultComputed: isResultComputed ?? this.isResultComputed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mode: mode ?? this.mode,
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
        other.mode == mode;
  }

  @override
  int get hashCode =>
      Object.hash(expression, result, isResultComputed, errorMessage, mode);
}
