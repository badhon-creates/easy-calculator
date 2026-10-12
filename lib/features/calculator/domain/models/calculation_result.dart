/// Represents the outcome of an expression evaluation.
class CalculationResult {
  const CalculationResult.success({
    required this.value,
    required this.formattedResult,
  }) : isSuccess = true,
       errorMessage = null;

  const CalculationResult.failure(this.errorMessage)
    : isSuccess = false,
      value = null,
      formattedResult = null;

  final bool isSuccess;
  final double? value;
  final String? formattedResult;
  final String? errorMessage;

  @override
  String toString() => isSuccess
      ? 'CalculationResult.success($formattedResult)'
      : 'CalculationResult.failure($errorMessage)';
}
