import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

/// Keypad providing comprehensive scientific functions using squircle geometry.
class ScientificKeypad extends StatelessWidget {
  const ScientificKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<CalculatorCubit>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) =>
          prev.isSecondary != curr.isSecondary ||
          prev.angleMode != curr.angleMode ||
          prev.hasMemory != curr.hasMemory,
      builder: (context, state) {
        final is2nd = state.isSecondary;
        final angleText = state.angleMode == AngleMode.degrees ? 'DEG' : 'RAD';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Controls, Parentheses & Memory
              _buildRow([
                _buildButton(
                  text: angleText,
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  onTap: () => cubit.toggleAngleMode(),
                  semanticLabel: 'Toggle degrees and radians',
                ),
                _buildButton(
                  text: '2nd',
                  backgroundColor: is2nd
                      ? colors.operatorButton
                      : colors.functionButton,
                  foregroundColor: is2nd
                      ? colors.operatorText
                      : colors.functionText,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  onTap: () => cubit.toggleSecondary(),
                  semanticLabel: 'Secondary functions toggle',
                ),
                _buildButton(
                  text: '(',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 17.0,
                  onTap: () => cubit.appendParenthesis('('),
                  semanticLabel: 'Open parenthesis',
                ),
                _buildButton(
                  text: ')',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 17.0,
                  onTap: () => cubit.appendParenthesis(')'),
                  semanticLabel: 'Close parenthesis',
                ),
                _buildButton(
                  text: 'mc',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 14.0,
                  onTap: () => cubit.memoryClear(),
                  semanticLabel: 'Memory clear',
                ),
                _buildButton(
                  text: 'mr',
                  backgroundColor: state.hasMemory
                      ? colors.operatorButton.withValues(alpha: 0.25)
                      : colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 14.0,
                  fontWeight: state.hasMemory
                      ? FontWeight.w700
                      : FontWeight.w500,
                  onTap: () => cubit.memoryRecall(),
                  semanticLabel: 'Memory recall',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 2: Memory arithmetic, Reciprocal, Powers, Factorial
              _buildRow([
                _buildButton(
                  text: 'm+',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 14.0,
                  onTap: () => cubit.memoryAdd(),
                  semanticLabel: 'Memory add',
                ),
                _buildButton(
                  text: 'm−',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  fontSize: 14.0,
                  onTap: () => cubit.memorySubtract(),
                  semanticLabel: 'Memory subtract',
                ),
                _buildButton(
                  text: '1/x',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendReciprocal(),
                  semanticLabel: 'Reciprocal',
                ),
                _buildButton(
                  text: is2nd ? 'x³' : 'x²',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 16.0,
                  onTap: () => cubit.appendPower(is2nd ? '^3' : '^2'),
                  semanticLabel: is2nd ? 'Cube' : 'Square',
                ),
                _buildButton(
                  text: 'xʸ',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 16.0,
                  onTap: () => cubit.appendPower('^'),
                  semanticLabel: 'Power',
                ),
                _buildButton(
                  text: 'x!',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 16.0,
                  onTap: () => cubit.appendFactorial(),
                  semanticLabel: 'Factorial',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 3: Roots, Powers, Exponentials
              _buildRow([
                _buildButton(
                  text: is2nd ? '³√x' : '²√x',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendRoot(is2nd ? '³√' : '²√'),
                  semanticLabel: is2nd ? 'Cube root' : 'Square root',
                ),
                _buildButton(
                  text: 'ʸ√x',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendRoot('ʸ√'),
                  semanticLabel: 'Yth root',
                ),
                _buildButton(
                  text: is2nd ? 'sin⁻¹' : 'sin',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 13.0 : 15.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'sin⁻¹' : 'sin'),
                  semanticLabel: is2nd ? 'Inverse sine' : 'Sine',
                ),
                _buildButton(
                  text: is2nd ? 'cos⁻¹' : 'cos',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 13.0 : 15.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'cos⁻¹' : 'cos'),
                  semanticLabel: is2nd ? 'Inverse cosine' : 'Cosine',
                ),
                _buildButton(
                  text: is2nd ? 'tan⁻¹' : 'tan',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 13.0 : 15.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'tan⁻¹' : 'tan'),
                  semanticLabel: is2nd ? 'Inverse tangent' : 'Tangent',
                ),
                _buildButton(
                  text: 'eˣ',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 16.0,
                  onTap: () => cubit.appendFunction('e^'),
                  semanticLabel: 'Exponential e to x',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 4: Hyperbolic Functions & Powers
              _buildRow([
                _buildButton(
                  text: is2nd ? 'sinh⁻¹' : 'sinh',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 11.5 : 14.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'sinh⁻¹' : 'sinh'),
                  semanticLabel: is2nd
                      ? 'Inverse hyperbolic sine'
                      : 'Hyperbolic sine',
                ),
                _buildButton(
                  text: is2nd ? 'cosh⁻¹' : 'cosh',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 11.5 : 14.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'cosh⁻¹' : 'cosh'),
                  semanticLabel: is2nd
                      ? 'Inverse hyperbolic cosine'
                      : 'Hyperbolic cosine',
                ),
                _buildButton(
                  text: is2nd ? 'tanh⁻¹' : 'tanh',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 11.5 : 14.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'tanh⁻¹' : 'tanh'),
                  semanticLabel: is2nd
                      ? 'Inverse hyperbolic tangent'
                      : 'Hyperbolic tangent',
                ),
                _buildButton(
                  text: is2nd ? 'log₂' : 'ln',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendFunction(is2nd ? 'log2' : 'ln'),
                  semanticLabel: is2nd ? 'Log base 2' : 'Natural log',
                ),
                _buildButton(
                  text: is2nd ? '2ˣ' : 'log₁₀',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: is2nd ? 16.0 : 14.0,
                  onTap: () => is2nd
                      ? cubit.appendFunction('2^')
                      : cubit.appendFunction('log₁₀'),
                  semanticLabel: is2nd ? '2 to the power x' : 'Log base 10',
                ),
                _buildButton(
                  text: '10ˣ',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendFunction('10^'),
                  semanticLabel: '10 to the power x',
                ),
              ]),
              const SizedBox(height: 4),

              // Row 5: Constants, Scientific Notation & Random
              _buildRow([
                _buildButton(
                  text: 'π',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 17.0,
                  onTap: () => cubit.appendConstant('π'),
                  semanticLabel: 'Pi constant',
                ),
                _buildButton(
                  text: 'e',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 17.0,
                  fontStyle: FontStyle.italic,
                  onTap: () => cubit.appendConstant('e'),
                  semanticLabel: 'Euler constant e',
                ),
                _buildButton(
                  text: 'EE',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendScientificNotation(),
                  semanticLabel: 'Scientific notation exponent',
                ),
                _buildButton(
                  text: 'Rand',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 13.5,
                  onTap: () => cubit.appendRandom(),
                  semanticLabel: 'Random number',
                ),
                _buildButton(
                  text: 'x³',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 16.0,
                  onTap: () => cubit.appendPower('^3'),
                  semanticLabel: 'Cube',
                ),
                _buildButton(
                  text: '³√x',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: 15.0,
                  onTap: () => cubit.appendRoot('³√'),
                  semanticLabel: 'Cube root',
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(List<Widget> children) {
    return SizedBox(
      height: 38,
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

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
    required VoidCallback onTap,
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle? fontStyle,
    String? semanticLabel,
  }) {
    return SquircleButton(
      text: text,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }
}
