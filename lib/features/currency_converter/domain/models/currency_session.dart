/// Domain model representing the user's active currency converter session.
class CurrencySession {
  const CurrencySession({
    this.sourceCode = 'USD',
    this.targetCode = 'BDT',
    this.amountInput = '1',
  });

  final String sourceCode;
  final String targetCode;
  final String amountInput;

  CurrencySession copyWith({
    String? sourceCode,
    String? targetCode,
    String? amountInput,
  }) {
    return CurrencySession(
      sourceCode: sourceCode ?? this.sourceCode,
      targetCode: targetCode ?? this.targetCode,
      amountInput: amountInput ?? this.amountInput,
    );
  }

  factory CurrencySession.fromJson(Map<String, dynamic> json) {
    return CurrencySession(
      sourceCode: (json['sourceCode'] ?? 'USD').toString(),
      targetCode: (json['targetCode'] ?? 'BDT').toString(),
      amountInput: (json['amountInput'] ?? '1').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sourceCode': sourceCode,
    'targetCode': targetCode,
    'amountInput': amountInput,
  };
}
