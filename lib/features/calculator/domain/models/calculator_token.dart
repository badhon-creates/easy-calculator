enum TokenType { number, operator, openParen, closeParen, function, constant }

enum OperatorType {
  add,
  subtract,
  multiply,
  divide,
  power,
  unaryMinus,
  percent, // Postfix percent operator: x% = x / 100
  factorial, // Postfix factorial operator: x!
  scientificNotation, // Infix scientific notation operator: aEb = a * 10^b
  nthRoot, // Infix y-th root of x: x ʸ√ y
}

/// A token produced during mathematical expression lexical analysis.
class CalculatorToken {
  const CalculatorToken({
    required this.type,
    this.numberValue,
    this.operatorType,
    this.stringValue,
  });

  final TokenType type;
  final double? numberValue;
  final OperatorType? operatorType;
  final String? stringValue;

  /// Returns the operator precedence for Shunting-yard algorithm.
  int get precedence {
    switch (operatorType) {
      case OperatorType.add:
      case OperatorType.subtract:
        return 1;
      case OperatorType.multiply:
      case OperatorType.divide:
        return 2;
      case OperatorType.unaryMinus:
        return 3;
      case OperatorType.power:
      case OperatorType.nthRoot:
        return 4;
      case OperatorType.scientificNotation:
        return 5;
      case OperatorType.percent:
      case OperatorType.factorial:
        return 6;
      case null:
        return 0;
    }
  }

  /// Whether the operator is right-associative (e.g. unary minus, power, nth root).
  bool get isRightAssociative {
    return operatorType == OperatorType.unaryMinus ||
        operatorType == OperatorType.power ||
        operatorType == OperatorType.nthRoot;
  }

  /// Whether this is a postfix operator (e.g. %, !).
  bool get isPostfix =>
      operatorType == OperatorType.percent ||
      operatorType == OperatorType.factorial;

  @override
  String toString() {
    switch (type) {
      case TokenType.number:
        return 'Num($numberValue)';
      case TokenType.operator:
        return 'Op($operatorType)';
      case TokenType.openParen:
        return '(';
      case TokenType.closeParen:
        return ')';
      case TokenType.function:
        return 'Fn($stringValue)';
      case TokenType.constant:
        return 'Const($stringValue)';
    }
  }
}
