import 'dart:math' as math;

import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_token.dart';

/// Lexer that transforms a mathematical expression string into a sequence of tokens.
class CalculatorLexer {
  const CalculatorLexer();

  /// Tokenizes the given [expression] string.
  List<CalculatorToken> tokenize(String expression) {
    final tokens = <CalculatorToken>[];
    final cleanExpr = expression.replaceAll(' ', '');
    if (cleanExpr.isEmpty) {
      throw const CalculationException('Expression is empty');
    }

    int i = 0;
    while (i < cleanExpr.length) {
      final ch = cleanExpr[i];

      // 1. Number parsing (digits or decimal point)
      if (_isDigit(ch) || ch == '.') {
        final start = i;
        bool hasDecimal = ch == '.';
        i++;
        while (i < cleanExpr.length &&
            (_isDigit(cleanExpr[i]) || cleanExpr[i] == '.')) {
          if (cleanExpr[i] == '.') {
            if (hasDecimal) {
              throw const CalculationException(
                'Invalid number with multiple decimal points',
              );
            }
            hasDecimal = true;
          }
          i++;
        }
        final numStr = cleanExpr.substring(start, i);
        final numVal = double.tryParse(numStr);
        if (numVal == null) {
          throw CalculationException('Invalid number format: $numStr');
        }

        // Implicit multiplication check (e.g., ) before number is handled below,
        // here if previous token was closeParen or constant, insert multiply
        if (tokens.isNotEmpty &&
            (tokens.last.type == TokenType.closeParen ||
                tokens.last.type == TokenType.constant ||
                tokens.last.isPostfix)) {
          tokens.add(
            const CalculatorToken(
              type: TokenType.operator,
              operatorType: OperatorType.multiply,
            ),
          );
        }

        tokens.add(
          CalculatorToken(
            type: TokenType.number,
            numberValue: numVal,
            stringValue: numStr,
          ),
        );
        continue;
      }

      // 2. Parentheses
      if (ch == '(') {
        // Implicit multiplication: e.g. 5(3) or )( -> insert *
        if (tokens.isNotEmpty &&
            (tokens.last.type == TokenType.number ||
                tokens.last.type == TokenType.closeParen ||
                tokens.last.type == TokenType.constant ||
                tokens.last.isPostfix)) {
          tokens.add(
            const CalculatorToken(
              type: TokenType.operator,
              operatorType: OperatorType.multiply,
            ),
          );
        }
        tokens.add(const CalculatorToken(type: TokenType.openParen));
        i++;
        continue;
      }

      if (ch == ')') {
        tokens.add(const CalculatorToken(type: TokenType.closeParen));
        i++;
        continue;
      }

      // 3. Operators
      if (ch == '+' ||
          ch == '-' ||
          ch == '−' ||
          ch == '×' ||
          ch == '*' ||
          ch == '÷' ||
          ch == '/' ||
          ch == '^') {
        final isMinus = ch == '-' || ch == '−';
        final isPlus = ch == '+';

        // Check for unary operator:
        // Occurs if at start of expression, or preceded by an operator, or preceded by open parenthesis
        final isUnary =
            tokens.isEmpty ||
            tokens.last.type == TokenType.openParen ||
            (tokens.last.type == TokenType.operator && !tokens.last.isPostfix);

        if (isMinus && isUnary) {
          tokens.add(
            const CalculatorToken(
              type: TokenType.operator,
              operatorType: OperatorType.unaryMinus,
            ),
          );
          i++;
          continue;
        }

        if (isPlus && isUnary) {
          // Unary plus is a no-op (e.g. +5), just skip
          i++;
          continue;
        }

        final OperatorType op;
        if (isMinus) {
          op = OperatorType.subtract;
        } else if (isPlus) {
          op = OperatorType.add;
        } else if (ch == '×' || ch == '*') {
          op = OperatorType.multiply;
        } else if (ch == '÷' || ch == '/') {
          op = OperatorType.divide;
        } else {
          op = OperatorType.power;
        }

        tokens.add(CalculatorToken(type: TokenType.operator, operatorType: op));
        i++;
        continue;
      }

      // 4. Percentage (postfix operator)
      if (ch == '%') {
        if (tokens.isEmpty ||
            (tokens.last.type != TokenType.number &&
                tokens.last.type != TokenType.closeParen &&
                tokens.last.type != TokenType.constant)) {
          throw const CalculationException('Invalid percentage placement');
        }
        tokens.add(
          const CalculatorToken(
            type: TokenType.operator,
            operatorType: OperatorType.percent,
          ),
        );
        i++;
        continue;
      }

      // 5. Constants (pi, e)
      if (ch == 'π') {
        if (tokens.isNotEmpty &&
            (tokens.last.type == TokenType.number ||
                tokens.last.type == TokenType.closeParen ||
                tokens.last.isPostfix)) {
          tokens.add(
            const CalculatorToken(
              type: TokenType.operator,
              operatorType: OperatorType.multiply,
            ),
          );
        }
        tokens.add(
          const CalculatorToken(
            type: TokenType.constant,
            numberValue: math.pi,
            stringValue: 'π',
          ),
        );
        i++;
        continue;
      }

      if (ch == 'e' &&
          (i + 1 == cleanExpr.length || !_isAlpha(cleanExpr[i + 1]))) {
        if (tokens.isNotEmpty &&
            (tokens.last.type == TokenType.number ||
                tokens.last.type == TokenType.closeParen ||
                tokens.last.isPostfix)) {
          tokens.add(
            const CalculatorToken(
              type: TokenType.operator,
              operatorType: OperatorType.multiply,
            ),
          );
        }
        tokens.add(
          const CalculatorToken(
            type: TokenType.constant,
            numberValue: math.e,
            stringValue: 'e',
          ),
        );
        i++;
        continue;
      }

      throw CalculationException('Unexpected character: $ch');
    }

    return tokens;
  }

  bool _isDigit(String s) {
    return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
  }

  bool _isAlpha(String s) {
    final code = s.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
