import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

/// Unified 10-column keypad for the Scientific Calculator in landscape orientation.
/// Combines 6 scientific function columns on the left with 4 arithmetic/number columns on the right.
class ScientificLandscapeKeypad extends StatelessWidget {
  const ScientificLandscapeKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<CalculatorCubit>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final is2nd = state.isSecondary;
        final angleText = state.angleMode == AngleMode.degrees ? 'DEG' : 'RAD';
        final clearLabel = (state.expression.isEmpty || state.isResultComputed)
            ? 'AC'
            : 'C';

        const rowHeight = 42.0;
        const numFontSize = 20.0;
        const opFontSize = 20.0;
        const sciFontSize = 13.5;
        const sciSmallFontSize = 11.5;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Controls & Parentheses & Clear/Arithmetic
              _buildRow(rowHeight, [
                // Scientific keys (6 cols)
                _buildSciButton(
                  text: angleText,
                  colors: colors,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  onTap: () => cubit.toggleAngleMode(),
                  semanticLabel: 'Toggle degrees and radians',
                ),
                _buildSciButton(
                  text: '2nd',
                  colors: colors,
                  backgroundColor: is2nd
                      ? colors.operatorButton
                      : colors.functionButton,
                  foregroundColor: is2nd
                      ? colors.operatorText
                      : colors.functionText,
                  borderColor: is2nd ? null : colors.numberButtonBorder,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  onTap: () => cubit.toggleSecondary(),
                  semanticLabel: 'Secondary functions toggle',
                ),
                _buildSciButton(
                  text: '(',
                  colors: colors,
                  fontSize: 15.0,
                  onTap: () => cubit.appendParenthesis('('),
                  semanticLabel: 'Open parenthesis',
                ),
                _buildSciButton(
                  text: ')',
                  colors: colors,
                  fontSize: 15.0,
                  onTap: () => cubit.appendParenthesis(')'),
                  semanticLabel: 'Close parenthesis',
                ),
                _buildSciButton(
                  text: 'mc',
                  colors: colors,
                  fontSize: 13.0,
                  onTap: () => cubit.memoryClear(),
                  semanticLabel: 'Memory clear',
                ),
                _buildSciButton(
                  text: 'mr',
                  colors: colors,
                  backgroundColor: state.hasMemory
                      ? colors.operatorButton.withValues(alpha: 0.25)
                      : colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 13.0,
                  fontWeight: state.hasMemory
                      ? FontWeight.w700
                      : FontWeight.w500,
                  onTap: () => cubit.memoryRecall(),
                  semanticLabel: 'Memory recall',
                ),
                // Basic keys (4 cols)
                _buildButton(
                  text: clearLabel,
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: opFontSize,
                  onTap: () => cubit.clear(),
                  semanticLabel: 'Clear',
                ),
                _buildButton(
                  text: '±',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: opFontSize,
                  onTap: () => cubit.toggleSign(),
                  semanticLabel: 'Toggle positive negative',
                ),
                _buildButton(
                  text: '%',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendPercent(),
                  semanticLabel: 'Percentage',
                ),
                _buildButton(
                  text: '÷',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendOperator('÷'),
                  semanticLabel: 'Divide',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 2: Memory arithmetic & 7, 8, 9, ×
              _buildRow(rowHeight, [
                _buildSciButton(
                  text: 'm+',
                  colors: colors,
                  fontSize: 13.0,
                  onTap: () => cubit.memoryAdd(),
                  semanticLabel: 'Memory add',
                ),
                _buildSciButton(
                  text: 'm−',
                  colors: colors,
                  fontSize: 13.0,
                  onTap: () => cubit.memorySubtract(),
                  semanticLabel: 'Memory subtract',
                ),
                _buildSciButton(
                  text: '1/x',
                  colors: colors,
                  fontSize: 14.0,
                  onTap: () => cubit.appendReciprocal(),
                  semanticLabel: 'Reciprocal',
                ),
                _buildSciButton(
                  text: is2nd ? 'x³' : 'x²',
                  colors: colors,
                  fontSize: 14.5,
                  onTap: () => cubit.appendPower(is2nd ? '^3' : '^2'),
                  semanticLabel: is2nd ? 'Cube' : 'Square',
                ),
                _buildSciButton(
                  text: 'xʸ',
                  colors: colors,
                  fontSize: 14.5,
                  onTap: () => cubit.appendPower('^'),
                  semanticLabel: 'Power',
                ),
                _buildSciButton(
                  text: 'x!',
                  colors: colors,
                  fontSize: 14.5,
                  onTap: () => cubit.appendFactorial(),
                  semanticLabel: 'Factorial',
                ),
                // Basic keys (4 cols)
                _buildNumberButton('7', cubit, colors, numFontSize),
                _buildNumberButton('8', cubit, colors, numFontSize),
                _buildNumberButton('9', cubit, colors, numFontSize),
                _buildButton(
                  text: '×',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendOperator('×'),
                  semanticLabel: 'Multiply',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 3: Roots & Trig & 4, 5, 6, −
              _buildRow(rowHeight, [
                _buildSciButton(
                  text: is2nd ? '³√x' : '²√x',
                  colors: colors,
                  fontSize: 13.5,
                  onTap: () => cubit.appendRoot(is2nd ? '³√' : '²√'),
                  semanticLabel: is2nd ? 'Cube root' : 'Square root',
                ),
                _buildSciButton(
                  text: 'ʸ√x',
                  colors: colors,
                  fontSize: 13.5,
                  onTap: () => cubit.appendRoot('ʸ√'),
                  semanticLabel: 'Yth root',
                ),
                _buildSciButton(
                  text: is2nd ? 'sin⁻¹' : 'sin',
                  colors: colors,
                  fontSize: is2nd ? sciSmallFontSize : sciFontSize,
                  onTap: () => cubit.appendFunction(is2nd ? 'sin⁻¹' : 'sin'),
                  semanticLabel: is2nd ? 'Inverse sine' : 'Sine',
                ),
                _buildSciButton(
                  text: is2nd ? 'cos⁻¹' : 'cos',
                  colors: colors,
                  fontSize: is2nd ? sciSmallFontSize : sciFontSize,
                  onTap: () => cubit.appendFunction(is2nd ? 'cos⁻¹' : 'cos'),
                  semanticLabel: is2nd ? 'Inverse cosine' : 'Cosine',
                ),
                _buildSciButton(
                  text: is2nd ? 'tan⁻¹' : 'tan',
                  colors: colors,
                  fontSize: is2nd ? sciSmallFontSize : sciFontSize,
                  onTap: () => cubit.appendFunction(is2nd ? 'tan⁻¹' : 'tan'),
                  semanticLabel: is2nd ? 'Inverse tangent' : 'Tangent',
                ),
                _buildSciButton(
                  text: 'eˣ',
                  colors: colors,
                  fontSize: 14.5,
                  onTap: () => cubit.appendFunction('e^'),
                  semanticLabel: 'Exponential e to x',
                ),
                // Basic keys (4 cols)
                _buildNumberButton('4', cubit, colors, numFontSize),
                _buildNumberButton('5', cubit, colors, numFontSize),
                _buildNumberButton('6', cubit, colors, numFontSize),
                _buildButton(
                  text: '−',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendOperator('−'),
                  semanticLabel: 'Subtract',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 4: Hyperbolic & Logs & 1, 2, 3, +
              _buildRow(rowHeight, [
                _buildSciButton(
                  text: is2nd ? 'sinh⁻¹' : 'sinh',
                  colors: colors,
                  fontSize: is2nd ? 11.0 : 13.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'sinh⁻¹' : 'sinh'),
                  semanticLabel: is2nd
                      ? 'Inverse hyperbolic sine'
                      : 'Hyperbolic sine',
                ),
                _buildSciButton(
                  text: is2nd ? 'cosh⁻¹' : 'cosh',
                  colors: colors,
                  fontSize: is2nd ? 11.0 : 13.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'cosh⁻¹' : 'cosh'),
                  semanticLabel: is2nd
                      ? 'Inverse hyperbolic cosine'
                      : 'Hyperbolic cosine',
                ),
                _buildSciButton(
                  text: is2nd ? 'tanh⁻¹' : 'tanh',
                  colors: colors,
                  fontSize: is2nd ? 11.0 : 13.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'tanh⁻¹' : 'tanh'),
                  semanticLabel: is2nd
                      ? 'Inverse hyperbolic tangent'
                      : 'Hyperbolic tangent',
                ),
                _buildSciButton(
                  text: is2nd ? 'log₂' : 'ln',
                  colors: colors,
                  fontSize: 13.5,
                  onTap: () => cubit.appendFunction(is2nd ? 'log2' : 'ln'),
                  semanticLabel: is2nd ? 'Log base 2' : 'Natural log',
                ),
                _buildSciButton(
                  text: is2nd ? '2ˣ' : 'log₁₀',
                  colors: colors,
                  fontSize: is2nd ? 14.5 : 12.5,
                  onTap: () => is2nd
                      ? cubit.appendFunction('2^')
                      : cubit.appendFunction('log₁₀'),
                  semanticLabel: is2nd ? '2 to the power x' : 'Log base 10',
                ),
                _buildSciButton(
                  text: '10ˣ',
                  colors: colors,
                  fontSize: 13.5,
                  onTap: () => cubit.appendFunction('10^'),
                  semanticLabel: '10 to the power x',
                ),
                // Basic keys (4 cols)
                _buildNumberButton('1', cubit, colors, numFontSize),
                _buildNumberButton('2', cubit, colors, numFontSize),
                _buildNumberButton('3', cubit, colors, numFontSize),
                _buildButton(
                  text: '+',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendOperator('+'),
                  semanticLabel: 'Add',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 5: Constants & 0, ., ⌫, =
              _buildRow(rowHeight, [
                _buildSciButton(
                  text: 'π',
                  colors: colors,
                  fontSize: 15.0,
                  onTap: () => cubit.appendConstant('π'),
                  semanticLabel: 'Pi constant',
                ),
                _buildSciButton(
                  text: 'e',
                  colors: colors,
                  fontSize: 15.0,
                  onTap: () => cubit.appendConstant('e'),
                  semanticLabel: 'Euler constant e',
                ),
                _buildSciButton(
                  text: 'EE',
                  colors: colors,
                  fontSize: 13.5,
                  onTap: () => cubit.appendScientificNotation(),
                  semanticLabel: 'Scientific notation exponent',
                ),
                _buildSciButton(
                  text: 'Rand',
                  colors: colors,
                  fontSize: 12.5,
                  onTap: () => cubit.appendRandom(),
                  semanticLabel: 'Random number',
                ),
                _buildSciButton(
                  text: 'x³',
                  colors: colors,
                  fontSize: 14.5,
                  onTap: () => cubit.appendPower('^3'),
                  semanticLabel: 'Cube',
                ),
                _buildSciButton(
                  text: '³√x',
                  colors: colors,
                  fontSize: 13.5,
                  onTap: () => cubit.appendRoot('³√'),
                  semanticLabel: 'Cube root',
                ),
                // Basic keys (4 cols)
                _buildNumberButton('0', cubit, colors, numFontSize),
                _buildButton(
                  text: '.',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: numFontSize,
                  onTap: () => cubit.appendDecimal(),
                  semanticLabel: 'Decimal point',
                ),
                _buildButton(
                  icon: Icons.backspace_outlined,
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 18.0,
                  onTap: () => cubit.backspace(),
                  semanticLabel: 'Backspace',
                ),
                _buildButton(
                  text: '=',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  fontSize: opFontSize,
                  onTap: () => cubit.calculateEquals(),
                  semanticLabel: 'Equals',
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(double height, List<Widget> children) {
    return SizedBox(
      height: height,
      child: Row(
        children: children.map((btn) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: btn,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSciButton({
    required String text,
    required CalculatorColors colors,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    required VoidCallback onTap,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w500,
    String? semanticLabel,
  }) {
    return SquircleButton(
      text: text,
      backgroundColor: backgroundColor ?? colors.numberButton,
      foregroundColor: foregroundColor ?? colors.numberText,
      borderColor: borderColor ?? colors.numberButtonBorder,
      fontSize: fontSize,
      fontWeight: fontWeight,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  Widget _buildNumberButton(
    String digit,
    CalculatorCubit cubit,
    CalculatorColors colors,
    double fontSize,
  ) {
    return _buildButton(
      text: digit,
      backgroundColor: colors.numberButton,
      foregroundColor: colors.numberText,
      borderColor: colors.numberButtonBorder,
      fontSize: fontSize,
      onTap: () => cubit.appendDigit(digit),
      semanticLabel: digit,
    );
  }

  Widget _buildButton({
    String? text,
    IconData? icon,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
    required VoidCallback onTap,
    double fontSize = 20.0,
    String? semanticLabel,
  }) {
    return SquircleButton(
      text: text,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      fontSize: fontSize,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }
}
