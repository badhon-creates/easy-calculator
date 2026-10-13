/// Domain model representing a calculated currency conversion result.
class ConversionResult {
  const ConversionResult({
    required this.sourceAmount,
    required this.targetAmount,
    required this.sourceCode,
    required this.targetCode,
    required this.rate,
    required this.isSameCurrency,
    required this.date,
    required this.timestamp,
    required this.isCached,
    required this.formattedTarget,
  });

  final double sourceAmount;
  final double targetAmount;
  final String sourceCode;
  final String targetCode;
  final double rate;
  final bool isSameCurrency;
  final String date;
  final DateTime? timestamp;
  final bool isCached;
  final String formattedTarget;

  static const String disclaimer =
      'Reference exchange rates provided for informational purposes only. '
      'Not guaranteed for financial transactions or commercial remittances.';
}
