/// Exception thrown when a calculation cannot be evaluated safely or correctly.
class CalculationException implements Exception {
  const CalculationException(this.message);

  final String message;

  @override
  String toString() => message;
}
