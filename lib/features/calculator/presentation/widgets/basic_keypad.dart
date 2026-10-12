import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

/// Keypad providing standard arithmetic operations and squircle buttons.
class BasicKeypad extends StatelessWidget {
  const BasicKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<CalculatorCubit>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) =>
          prev.expression != curr.expression ||
          prev.isResultComputed != curr.isResultComputed,
      builder: (context, state) {
        final clearLabel = (state.expression.isEmpty || state.isResultComputed)
            ? 'AC'
            : 'C';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow([
                _buildButton(
                  text: clearLabel,
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  onTap: () => cubit.clear(),
                  semanticLabel: 'Clear',
                ),
                _buildButton(
                  text: '±',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  onTap: () => cubit.toggleSign(),
                  semanticLabel: 'Toggle positive negative',
                ),
                _buildButton(
                  text: '%',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  onTap: () => cubit.appendPercent(),
                  semanticLabel: 'Percentage',
                ),
                _buildButton(
                  text: '÷',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  onTap: () => cubit.appendOperator('÷'),
                  semanticLabel: 'Divide',
                ),
              ]),
              const SizedBox(height: 12),
              _buildRow([
                _buildNumberButton('7', cubit, colors),
                _buildNumberButton('8', cubit, colors),
                _buildNumberButton('9', cubit, colors),
                _buildButton(
                  text: '×',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  onTap: () => cubit.appendOperator('×'),
                  semanticLabel: 'Multiply',
                ),
              ]),
              const SizedBox(height: 12),
              _buildRow([
                _buildNumberButton('4', cubit, colors),
                _buildNumberButton('5', cubit, colors),
                _buildNumberButton('6', cubit, colors),
                _buildButton(
                  text: '−',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  onTap: () => cubit.appendOperator('−'),
                  semanticLabel: 'Subtract',
                ),
              ]),
              const SizedBox(height: 12),
              _buildRow([
                _buildNumberButton('1', cubit, colors),
                _buildNumberButton('2', cubit, colors),
                _buildNumberButton('3', cubit, colors),
                _buildButton(
                  text: '+',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  onTap: () => cubit.appendOperator('+'),
                  semanticLabel: 'Add',
                ),
              ]),
              const SizedBox(height: 12),
              _buildRow([
                _buildNumberButton('0', cubit, colors),
                _buildButton(
                  text: '.',
                  backgroundColor: colors.numberButton,
                  foregroundColor: colors.numberText,
                  borderColor: colors.numberButtonBorder,
                  onTap: () => cubit.appendDecimal(),
                  semanticLabel: 'Decimal point',
                ),
                _buildButton(
                  icon: Icons.backspace_outlined,
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  onTap: () => cubit.backspace(),
                  fontSize: 22.0,
                  semanticLabel: 'Backspace',
                ),
                _buildButton(
                  text: '=',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
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

  Widget _buildRow(List<Widget> children) {
    return SizedBox(
      height: 72,
      child: Row(
        children: children.map((btn) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: btn,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberButton(
    String digit,
    CalculatorCubit cubit,
    CalculatorColors colors,
  ) {
    return _buildButton(
      text: digit,
      backgroundColor: colors.numberButton,
      foregroundColor: colors.numberText,
      borderColor: colors.numberButtonBorder,
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
    double fontSize = 28.0,
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
