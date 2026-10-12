import 'dart:math' as math;

import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_token.dart';

/// Evaluates a Reverse Polish Notation (RPN) token stream.
class CalculatorEvaluator {
  const CalculatorEvaluator();

  double evaluateRpn(List<CalculatorToken> rpnTokens) {
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
                final result = math.pow(left, right);
                stack.add(result.toDouble());
                break;
              case OperatorType.unaryMinus:
              case OperatorType.percent:
                // Handled above
                break;
            }
          }
          break;

        case TokenType.function:
          // Ready for scientific calculator functions (sin, cos, sqrt, etc.)
          if (stack.isEmpty) {
            throw CalculationException(
              'Missing argument for function ${token.stringValue}',
            );
          }
          final arg = stack.removeLast();
          stack.add(_evaluateFunction(token.stringValue ?? '', arg));
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

  double _evaluateFunction(String name, double arg) {
    switch (name.toLowerCase()) {
      case 'sqrt':
      case '²√':
        if (arg < 0) {
          throw const CalculationException('Invalid domain for square root');
        }
        return math.sqrt(arg);
      case 'sin':
        return math.sin(arg);
      case 'cos':
        return math.cos(arg);
      case 'tan':
        return math.tan(arg);
      case 'ln':
        if (arg <= 0) {
          throw const CalculationException(
            'Invalid domain for natural logarithm',
          );
        }
        return math.log(arg);
      default:
        throw CalculationException('Unsupported function: $name');
    }
  }
}
