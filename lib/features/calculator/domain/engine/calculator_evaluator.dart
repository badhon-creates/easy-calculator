import 'dart:math' as math;

import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_token.dart';

/// Evaluates a Reverse Polish Notation (RPN) token stream.
/// Supports both basic arithmetic and advanced scientific mathematical operations.
class CalculatorEvaluator {
  const CalculatorEvaluator();

  /// Evaluates the given RPN token stream with the specified [angleMode].
  double evaluateRpn(
    List<CalculatorToken> rpnTokens, {
    AngleMode angleMode = AngleMode.degrees,
  }) {
    if (rpnTokens.isEmpty) {
      throw const CalculationException('Expression is empty');
    }

    final stack = <double>[];

    for (final token in rpnTokens) {
      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          if (token.numberValue == null) {
            throw const CalculationException('Invalid operand value');
          }
          stack.add(token.numberValue!);
          break;

        case TokenType.operator:
          final op = token.operatorType;
          if (op == null) {
            throw const CalculationException('Unknown operator');
          }

          if (op == OperatorType.unaryMinus) {
            if (stack.isEmpty) {
              throw const CalculationException('Missing operand for negation');
            }
            final val = stack.removeLast();
            stack.add(-val);
          } else if (op == OperatorType.percent) {
            if (stack.isEmpty) {
              throw const CalculationException(
                'Missing operand for percentage',
              );
            }
            final val = stack.removeLast();
            stack.add(val / 100.0);
          } else if (op == OperatorType.factorial) {
            if (stack.isEmpty) {
              throw const CalculationException('Missing operand for factorial');
            }
            final val = stack.removeLast();
            stack.add(_evaluateFactorial(val));
          } else {
            // Binary operators
            if (stack.length < 2) {
              throw const CalculationException(
                'Malformed expression: missing operand',
              );
            }
            final right = stack.removeLast();
            final left = stack.removeLast();

            switch (op) {
              case OperatorType.add:
                stack.add(left + right);
                break;
              case OperatorType.subtract:
                stack.add(left - right);
                break;
              case OperatorType.multiply:
                stack.add(left * right);
                break;
              case OperatorType.divide:
                if (right == 0 || right == -0.0) {
                  throw const CalculationException('Cannot divide by zero');
                }
                stack.add(left / right);
                break;
              case OperatorType.power:
                stack.add(_evaluatePower(left, right));
                break;
              case OperatorType.nthRoot:
                stack.add(_evaluateNthRoot(left, right));
                break;
              case OperatorType.scientificNotation:
                stack.add(left * math.pow(10, right));
                break;
              case OperatorType.unaryMinus:
              case OperatorType.percent:
              case OperatorType.factorial:
                // Handled above
                break;
            }
          }
          break;

        case TokenType.function:
          if (stack.isEmpty) {
            throw CalculationException(
              'Missing argument for function ${token.stringValue}',
            );
          }
          final arg = stack.removeLast();
          stack.add(_evaluateFunction(token.stringValue ?? '', arg, angleMode));
          break;

        case TokenType.openParen:
        case TokenType.closeParen:
          throw const CalculationException(
            'Unexpected parenthesis in RPN evaluation',
          );
      }
    }

    if (stack.isEmpty) {
      throw const CalculationException('Incomplete calculation');
    }
    if (stack.length > 1) {
      throw const CalculationException(
        'Malformed expression: unresolved operands',
      );
    }

    final finalResult = stack.single;
    if (finalResult.isNaN) {
      throw const CalculationException('Result is undefined');
    }
    if (finalResult.isInfinite) {
      throw const CalculationException('Calculation overflow');
    }

    return finalResult;
  }

  double _evaluatePower(double base, double exponent) {
    if (base < 0) {
      // Check if exponent is an integer
      if (exponent == exponent.roundToDouble()) {
        final expInt = exponent.round();
        if (expInt.isOdd) {
          return -math.pow(-base, exponent).toDouble();
        } else {
          return math.pow(-base, exponent).toDouble();
        }
      }
      throw const CalculationException('Invalid domain for power');
    }
    return math.pow(base, exponent).toDouble();
  }

  double _evaluateNthRoot(double radicand, double rootIndex) {
    if (rootIndex == 0) {
      throw const CalculationException('Root index cannot be zero');
    }
    if (radicand < 0) {
      // Negative radicand valid only for odd integer roots (e.g. ³√(-8) = -2)
      if (rootIndex == rootIndex.roundToDouble() && rootIndex.round().isOdd) {
        return -math.pow(-radicand, 1.0 / rootIndex).toDouble();
      }
      throw const CalculationException('Invalid domain for root');
    }
    return math.pow(radicand, 1.0 / rootIndex).toDouble();
  }

  double _evaluateFactorial(double val) {
    if (val < 0) {
      throw const CalculationException(
        'Factorial undefined for negative numbers',
      );
    }
    if (val != val.roundToDouble()) {
      throw const CalculationException(
        'Factorial requires a non-negative integer',
      );
    }
    final n = val.round();
    if (n > 170) {
      throw const CalculationException('Calculation overflow');
    }
    double result = 1.0;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  double _evaluateFunction(String name, double arg, AngleMode angleMode) {
    switch (name.toLowerCase()) {
      case 'sqrt':
        if (arg < 0) {
          throw const CalculationException('Invalid domain for square root');
        }
        return math.sqrt(arg);

      case 'cbrt':
        if (arg < 0) {
          return -math.pow(-arg, 1.0 / 3.0).toDouble();
        }
        return math.pow(arg, 1.0 / 3.0).toDouble();

      case 'sin':
        if (angleMode == AngleMode.degrees) {
          // Prevent floating point artifacts for known zero crossings
          final normalized = arg % 360;
          if (normalized == 0 || normalized == 180 || normalized == -180) {
            return 0.0;
          }
          return math.sin(_degToRad(arg));
        }
        return math.sin(arg);

      case 'cos':
        if (angleMode == AngleMode.degrees) {
          final normalized = arg % 360;
          if (normalized == 90 ||
              normalized == 270 ||
              normalized == -90 ||
              normalized == -270) {
            return 0.0;
          }
          if (normalized == 0) return 1.0;
          if (normalized == 180 || normalized == -180) return -1.0;
          return math.cos(_degToRad(arg));
        }
        return math.cos(arg);

      case 'tan':
        if (angleMode == AngleMode.degrees) {
          final normalized = arg % 180;
          if (normalized == 90 || normalized == -90) {
            throw CalculationException('Tangent undefined at ${arg.toInt()}°');
          }
          if (normalized == 0) return 0.0;
          return math.tan(_degToRad(arg));
        }
        final c = math.cos(arg);
        if (c.abs() < 1e-15) {
          throw const CalculationException('Tangent is undefined');
        }
        return math.tan(arg);

      case 'asin':
        if (arg < -1.0 || arg > 1.0) {
          throw const CalculationException(
            'Invalid domain for sin⁻¹ (must be between -1 and 1)',
          );
        }
        final rad = math.asin(arg);
        return angleMode == AngleMode.degrees ? _radToDeg(rad) : rad;

      case 'acos':
        if (arg < -1.0 || arg > 1.0) {
          throw const CalculationException(
            'Invalid domain for cos⁻¹ (must be between -1 and 1)',
          );
        }
        final rad = math.acos(arg);
        return angleMode == AngleMode.degrees ? _radToDeg(rad) : rad;

      case 'atan':
        final rad = math.atan(arg);
        return angleMode == AngleMode.degrees ? _radToDeg(rad) : rad;

      case 'sinh':
        return (math.exp(arg) - math.exp(-arg)) / 2.0;

      case 'cosh':
        return (math.exp(arg) + math.exp(-arg)) / 2.0;

      case 'tanh':
        final ep = math.exp(arg);
        final em = math.exp(-arg);
        return (ep - em) / (ep + em);

      case 'asinh':
        return math.log(arg + math.sqrt(arg * arg + 1.0));

      case 'acosh':
        if (arg < 1.0) {
          throw const CalculationException(
            'Invalid domain for cosh⁻¹ (must be ≥ 1)',
          );
        }
        return math.log(arg + math.sqrt(arg * arg - 1.0));

      case 'atanh':
        if (arg <= -1.0 || arg >= 1.0) {
          throw const CalculationException(
            'Invalid domain for tanh⁻¹ (must be between -1 and 1)',
          );
        }
        return 0.5 * math.log((1.0 + arg) / (1.0 - arg));

      case 'ln':
        if (arg <= 0) {
          throw const CalculationException(
            'Invalid domain for natural logarithm',
          );
        }
        return math.log(arg);

      case 'log10':
        if (arg <= 0) {
          throw const CalculationException('Invalid domain for log₁₀');
        }
        return math.log(arg) / math.ln10;

      case 'log2':
        if (arg <= 0) {
          throw const CalculationException('Invalid domain for log₂');
        }
        return math.log(arg) / math.ln2;

      case 'exp':
        return math.exp(arg);

      case 'tenpow':
        return math.pow(10, arg).toDouble();

      case 'twopow':
        return math.pow(2, arg).toDouble();

      default:
        throw CalculationException('Unsupported function: $name');
    }
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
