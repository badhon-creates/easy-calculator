import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';

/// Display widget showing the active expression, evaluated result, and scientific indicators.
/// Implements smooth upward animation when a calculation is finalized.
class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    required this.isResultComputed,
    this.errorMessage,
    this.angleMode = AngleMode.degrees,
    this.isSecondary = false,
    this.hasMemory = false,
    this.isScientific = false,
  });

  final String expression;
  final String? result;
  final bool isResultComputed;
  final String? errorMessage;
  final AngleMode angleMode;
  final bool isSecondary;
  final bool hasMemory;
  final bool isScientific;

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final hasError = errorMessage != null;
    final displayExpression = expression.isEmpty ? '0' : expression;
    final showResultRow =
        isResultComputed || hasError || (result != null && result!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicators Bar (Angle Mode, 2nd, Memory)
          if (isScientific)
            Row(
              children: [
                _buildIndicatorBadge(
                  label: angleMode == AngleMode.degrees ? 'DEG' : 'RAD',
                  colors: colors,
                  isActive: true,
                ),
                if (isSecondary) ...[
                  const SizedBox(width: 8),
                  _buildIndicatorBadge(
                    label: '2nd',
                    colors: colors,
                    isActive: true,
                    highlight: true,
                  ),
                ],
                if (hasMemory) ...[
                  const SizedBox(width: 8),
                  _buildIndicatorBadge(
                    label: 'M',
                    colors: colors,
                    isActive: true,
                  ),
                ],
              ],
            ),

          // Flexible Display Area
          Expanded(
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
                          fontSize: isResultComputed
                              ? 22.0
                              : (isScientific ? 36.0 : 44.0),
                          fontWeight: isResultComputed
                              ? FontWeight.w400
                              : FontWeight.w300,
                          color: isResultComputed
                              ? colors.textSecondary
                              : (hasError
                                    ? colors.errorColor
                                    : colors.textPrimary),
                          letterSpacing: -0.5,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            displayExpression,
                            textAlign: TextAlign.right,
                          ),
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
                                fontSize: isResultComputed
                                    ? (isScientific ? 40.0 : 48.0)
                                    : (isScientific ? 22.0 : 26.0),
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
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorBadge({
    required String label,
    required CalculatorColors colors,
    required bool isActive,
    bool highlight = false,
  }) {
    final hasLightBorder = colors.numberButtonBorder != Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? colors.operatorButton
            : (hasLightBorder
                  ? colors.numberButton
                  : colors.functionButton.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlight ? colors.operatorButton : colors.numberButtonBorder,
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ? colors.operatorText : colors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
