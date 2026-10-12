import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';

/// Display widget showing the active expression and evaluated result.
/// Implements smooth upward animation when a calculation is finalized.
class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    required this.isResultComputed,
    this.errorMessage,
  });

  final String expression;
  final String? result;
  final bool isResultComputed;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final hasError = errorMessage != null;
    final displayExpression = expression.isEmpty ? '0' : expression;
    final showResultRow =
        isResultComputed || hasError || (result != null && result!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Completed/Active expression
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: isResultComputed ? 24.0 : 44.0,
                    fontWeight: isResultComputed
                        ? FontWeight.w400
                        : FontWeight.w300,
                    color: isResultComputed
                        ? colors.textSecondary
                        : (hasError ? colors.errorColor : colors.textPrimary),
                    letterSpacing: -0.5,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(displayExpression, textAlign: TextAlign.right),
                  ),
                ),

                if (showResultRow) ...[
                  const SizedBox(height: 4),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    offset: isResultComputed
                        ? Offset.zero
                        : const Offset(0, 0.1),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        hasError ? errorMessage! : (result ?? ''),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: isResultComputed ? 48.0 : 26.0,
                          fontWeight: isResultComputed
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: hasError
                              ? colors.errorColor
                              : (isResultComputed
                                    ? colors.textPrimary
                                    : colors.textSecondary.withValues(
                                        alpha: 0.8,
                                      )),
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
