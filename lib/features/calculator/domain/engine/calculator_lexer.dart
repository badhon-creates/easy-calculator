import 'dart:math' as math;

import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_token.dart';

/// Lexer that transforms a mathematical expression string into a sequence of tokens.
/// Supports basic arithmetic and scientific calculator functions, operators, and constants.
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

        // Check for scientific notation exponent (e.g., 1e5, 2.5E-3)
        if (i < cleanExpr.length &&
            (cleanExpr[i] == 'e' || cleanExpr[i] == 'E') &&
            i + 1 < cleanExpr.length) {
          final nextChar = cleanExpr[i + 1];
          if (_isDigit(nextChar) ||
              ((nextChar == '+' || nextChar == '-' || nextChar == '−') &&
                  i + 2 < cleanExpr.length &&
                  _isDigit(cleanExpr[i + 2]))) {
            i++; // skip e/E
            if (cleanExpr[i] == '+' ||
                cleanExpr[i] == '-' ||
                cleanExpr[i] == '−') {
              i++;
            }
            while (i < cleanExpr.length && _isDigit(cleanExpr[i])) {
              i++;
            }
          }
        }

        var numStr = cleanExpr.substring(start, i);
        // Replace unicode minus if present in exponent
        numStr = numStr.replaceAll('−', '-');
        final numVal = double.tryParse(numStr);
        if (numVal == null) {
          throw CalculationException('Invalid number format: $numStr');
        }

        // Implicit multiplication check before number (e.g., )5, e2, π3, 5!2)
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
        // Implicit multiplication before open paren: e.g. 5(3), )(, π(, e(
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

      // 3. Postfix Factorial (!)
      if (ch == '!') {
        if (tokens.isEmpty ||
            (tokens.last.type != TokenType.number &&
                tokens.last.type != TokenType.closeParen &&
                tokens.last.type != TokenType.constant)) {
          throw const CalculationException('Invalid factorial placement');
        }
        tokens.add(
          const CalculatorToken(
            type: TokenType.operator,
            operatorType: OperatorType.factorial,
            stringValue: '!',
          ),
        );
        i++;
        continue;
      }

      // 4. Percentage (%)
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
            stringValue: '%',
          ),
        );
        i++;
        continue;
      }

      // 5. Scientific Notation Operator (EE or E)
      if (cleanExpr.startsWith('EE', i)) {
        tokens.add(
          const CalculatorToken(
            type: TokenType.operator,
            operatorType: OperatorType.scientificNotation,
            stringValue: 'EE',
          ),
        );
        i += 2;
        continue;
      }
      if (ch == 'E' &&
          (i + 1 == cleanExpr.length ||
              _isDigit(cleanExpr[i + 1]) ||
              cleanExpr[i + 1] == '+' ||
              cleanExpr[i + 1] == '-' ||
              cleanExpr[i + 1] == '−' ||
              cleanExpr[i + 1] == '(')) {
        tokens.add(
          const CalculatorToken(
            type: TokenType.operator,
            operatorType: OperatorType.scientificNotation,
            stringValue: 'E',
          ),
        );
        i++;
        continue;
      }

      // 6. Nth Root Operator (ʸ√ or yroot)
      if (cleanExpr.startsWith('ʸ√', i)) {
        tokens.add(
          const CalculatorToken(
            type: TokenType.operator,
            operatorType: OperatorType.nthRoot,
            stringValue: 'ʸ√',
          ),
        );
        i += 2;
        continue;
      }
      if (cleanExpr.startsWith('yroot', i)) {
        tokens.add(
          const CalculatorToken(
            type: TokenType.operator,
            operatorType: OperatorType.nthRoot,
            stringValue: 'yroot',
          ),
        );
        i += 5;
        continue;
      }

      // 7. Operators (+, -, −, ×, *, ÷, /, ^)
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

      // 8. Constants (π, pi, e)
      if (ch == 'π' || cleanExpr.startsWith('pi', i)) {
        _insertImplicitMultiplicationIfNeeded(tokens);
        tokens.add(
          const CalculatorToken(
            type: TokenType.constant,
            numberValue: math.pi,
            stringValue: 'π',
          ),
        );
        i += (ch == 'π') ? 1 : 2;
        continue;
      }

      // Constant 'e' (standalone, not followed by alpha like 'exp')
      if (ch == 'e' &&
          (i + 1 == cleanExpr.length ||
              (!_isAlpha(cleanExpr[i + 1]) && cleanExpr[i + 1] != 'ˣ'))) {
        _insertImplicitMultiplicationIfNeeded(tokens);
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

      // 9. Multi-character scientific functions
      final matchedFn = _matchFunction(cleanExpr, i);
      if (matchedFn != null) {
        _insertImplicitMultiplicationIfNeeded(tokens);
        tokens.add(
          CalculatorToken(
            type: TokenType.function,
            stringValue: matchedFn.name,
          ),
        );
        i += matchedFn.length;
        continue;
      }

      throw CalculationException('Unexpected character: $ch');
    }

    return tokens;
  }

  void _insertImplicitMultiplicationIfNeeded(List<CalculatorToken> tokens) {
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
  }

  _FunctionMatch? _matchFunction(String expr, int index) {
    // List of supported scientific function prefixes in priority order (longest first)
    const functionPrefixes = [
      // Inverse Hyperbolic
      ('sinh⁻¹', 'asinh'),
      ('cosh⁻¹', 'acosh'),
      ('tanh⁻¹', 'atanh'),
      ('asinh', 'asinh'),
      ('acosh', 'acosh'),
      ('atanh', 'atanh'),
      // Hyperbolic
      ('sinh', 'sinh'),
      ('cosh', 'cosh'),
      ('tanh', 'tanh'),
      // Inverse Trigonometric
      ('sin⁻¹', 'asin'),
      ('cos⁻¹', 'acos'),
      ('tan⁻¹', 'atan'),
      ('asin', 'asin'),
      ('acos', 'acos'),
      ('atan', 'atan'),
      // Trigonometric
      ('sin', 'sin'),
      ('cos', 'cos'),
      ('tan', 'tan'),
      // Logarithms
      ('log₁₀', 'log10'),
      ('log10', 'log10'),
      ('log2', 'log2'),
      ('log', 'log10'),
      ('ln', 'ln'),
      // Roots & Powers
      ('²√', 'sqrt'),
      ('³√', 'cbrt'),
      ('sqrt', 'sqrt'),
      ('cbrt', 'cbrt'),
      ('√', 'sqrt'),
      ('∛', 'cbrt'),
      ('eˣ', 'exp'),
      ('exp', 'exp'),
      ('10ˣ', 'tenPow'),
      ('2ˣ', 'twoPow'),
    ];

    for (final (prefix, canonicalName) in functionPrefixes) {
      if (expr.startsWith(prefix, index)) {
        return _FunctionMatch(name: canonicalName, length: prefix.length);
      }
    }
    return null;
  }

  bool _isDigit(String s) {
    return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
  }

  bool _isAlpha(String s) {
    final code = s.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}

class _FunctionMatch {
  const _FunctionMatch({required this.name, required this.length});
  final String name;
  final int length;
}
