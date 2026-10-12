import 'package:easy_calculator/core/errors/calculation_exception.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_token.dart';

/// Implements Dijkstra's Shunting-yard algorithm to convert an infix token stream
/// into Reverse Polish Notation (RPN / Postfix).
class CalculatorParser {
  const CalculatorParser();

  List<CalculatorToken> parseToRpn(List<CalculatorToken> tokens) {
    if (tokens.isEmpty) {
      throw const CalculationException('Expression is empty');
    }

    final output = <CalculatorToken>[];
    final operatorStack = <CalculatorToken>[];

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          output.add(token);
          break;

        case TokenType.function:
          operatorStack.add(token);
          break;

        case TokenType.openParen:
          operatorStack.add(token);
          break;

        case TokenType.closeParen:
          bool foundOpenParen = false;
          while (operatorStack.isNotEmpty) {
            final top = operatorStack.removeLast();
            if (top.type == TokenType.openParen) {
              foundOpenParen = true;
              break;
            }
            output.add(top);
          }
          if (!foundOpenParen) {
            throw const CalculationException(
              'Mismatched parentheses: unexpected closing parenthesis',
            );
          }
          // If top of stack is a function, pop it to output
          if (operatorStack.isNotEmpty &&
              operatorStack.last.type == TokenType.function) {
            output.add(operatorStack.removeLast());
          }
          break;

        case TokenType.operator:
          if (token.isPostfix) {
            // Postfix operators like % are applied directly to the preceding operand
            output.add(token);
          } else {
            while (operatorStack.isNotEmpty) {
              final top = operatorStack.last;
              if (top.type == TokenType.operator) {
                final topPrec = top.precedence;
                final currPrec = token.precedence;
                if ((!token.isRightAssociative && currPrec <= topPrec) ||
                    (token.isRightAssociative && currPrec < topPrec)) {
                  output.add(operatorStack.removeLast());
                  continue;
                }
              }
              break;
            }
            operatorStack.add(token);
          }
          break;
      }
    }

    // Drain remaining operators
    while (operatorStack.isNotEmpty) {
      final top = operatorStack.removeLast();
      if (top.type == TokenType.openParen) {
        throw const CalculationException(
          'Mismatched parentheses: missing closing parenthesis',
        );
      }
      output.add(top);
    }

    return output;
  }
}
