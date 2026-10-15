import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

/// Keypad providing standard arithmetic operations with responsive sizing for basic and scientific modes.
class BasicKeypad extends StatelessWidget {
  const BasicKeypad({
    super.key,
    this.isScientific = false,
    this.isLandscape = false,
  });

  final bool isScientific;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<CalculatorCubit>();
    final rowHeight = isScientific ? 46.0 : (isLandscape ? 52.0 : 72.0);
    final numFontSize = isScientific ? 22.0 : (isLandscape ? 24.0 : 28.0);
    final opFontSize = isScientific ? 22.0 : (isLandscape ? 24.0 : 28.0);
    final rowSpacing = isScientific ? 5.0 : (isLandscape ? 6.0 : 12.0);

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) =>
          prev.expression != curr.expression ||
          prev.isResultComputed != curr.isResultComputed,
      builder: (context, state) {
        final clearLabel = (state.expression.isEmpty || state.isResultComputed)
            ? 'AC'
            : 'C';

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: isScientific ? 2.0 : (isLandscape ? 4.0 : 12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow(rowHeight, [
                _buildButton(
                  text: clearLabel,
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: opFontSize,
                  onTap: () => cubit.clear(),
                  semanticLabel: 'Clear',
                  colors: colors,
                ),
                _buildButton(
                  text: '±',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: opFontSize,
                  onTap: () => cubit.toggleSign(),
                  semanticLabel: 'Toggle positive negative',
                  colors: colors,
                ),
                _buildButton(
                  text: '%',
                  backgroundColor: colors.functionButton,
                  foregroundColor: colors.functionText,
                  borderColor: colors.numberButtonBorder,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendPercent(),
                  semanticLabel: 'Percentage',
                  colors: colors,
                ),
                _buildButton(
                  text: '÷',
                  backgroundColor: colors.operatorButton,
                  foregroundColor: colors.operatorText,
                  fontSize: opFontSize,
                  onTap: () => cubit.appendOperator('÷'),
                  semanticLabel: 'Divide',
                  colors: colors,
                ),
              ]),
              SizedBox(height: rowSpacing),
              _buildRow(rowHeight, [
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
              SizedBox(height: rowSpacing),
              _buildRow(rowHeight, [
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
              SizedBox(height: rowSpacing),
              _buildRow(rowHeight, [
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
              SizedBox(height: rowSpacing),
              _buildRow(rowHeight, [
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
                  fontSize: isScientific ? 19.0 : 22.0,
                  onTap: () => cubit.backspace(),
                  semanticLabel: 'Backspace',
                  colors: colors,
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
    double fontSize = 28.0,
    String? semanticLabel,
    CalculatorColors? colors,
  }) {
    final effectiveBorder =
        borderColor ??
        (colors != null && backgroundColor != colors.operatorButton
            ? colors.numberButtonBorder
            : null);

    return SquircleButton(
      text: text,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: effectiveBorder,
      fontSize: fontSize,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }
}
