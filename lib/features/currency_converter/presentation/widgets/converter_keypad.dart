import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/currency_converter/presentation/cubit/currency_converter_cubit.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

/// Responsive keypad component for currency amount entry with squircle buttons.
class ConverterKeypad extends StatelessWidget {
  const ConverterKeypad({super.key});

  Widget _buildRow(double height, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: height,
        child: Row(
          children: children
              .map(
                (child) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: child,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<CurrencyConverterCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt row height dynamically to available vertical space
        final availableHeight = constraints.maxHeight;
        final rowHeight = (availableHeight > 0 && availableHeight < 320)
            ? (availableHeight / 5.4).clamp(42.0, 60.0)
            : 58.0;
        final fontSize = rowHeight < 50 ? 20.0 : 24.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Actions (Clear, Backspace, Swap)
            _buildRow(rowHeight, [
              SquircleButton(
                text: 'C',
                backgroundColor: colors.functionButton,
                foregroundColor: colors.functionText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                semanticLabel: 'Clear amount',
                onTap: cubit.clear,
              ),
              SquircleButton(
                icon: Icons.backspace_outlined,
                backgroundColor: colors.functionButton,
                foregroundColor: colors.functionText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: 'Backspace',
                onTap: cubit.deleteDigit,
              ),
              SquircleButton(
                icon: Icons.swap_vert_rounded,
                backgroundColor: colors.operatorButton,
                foregroundColor: colors.operatorText,
                fontSize: fontSize,
                semanticLabel: 'Swap currencies',
                onTap: cubit.swapCurrencies,
              ),
            ]),

            // Row 2: 7, 8, 9
            _buildRow(rowHeight, [
              SquircleButton(
                text: '7',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '7',
                onTap: () => cubit.appendDigit('7'),
              ),
              SquircleButton(
                text: '8',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '8',
                onTap: () => cubit.appendDigit('8'),
              ),
              SquircleButton(
                text: '9',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '9',
                onTap: () => cubit.appendDigit('9'),
              ),
            ]),

            // Row 3: 4, 5, 6
            _buildRow(rowHeight, [
              SquircleButton(
                text: '4',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '4',
                onTap: () => cubit.appendDigit('4'),
              ),
              SquircleButton(
                text: '5',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '5',
                onTap: () => cubit.appendDigit('5'),
              ),
              SquircleButton(
                text: '6',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '6',
                onTap: () => cubit.appendDigit('6'),
              ),
            ]),

            // Row 4: 1, 2, 3
            _buildRow(rowHeight, [
              SquircleButton(
                text: '1',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '1',
                onTap: () => cubit.appendDigit('1'),
              ),
              SquircleButton(
                text: '2',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '2',
                onTap: () => cubit.appendDigit('2'),
              ),
              SquircleButton(
                text: '3',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '3',
                onTap: () => cubit.appendDigit('3'),
              ),
            ]),

            // Row 5: 00, 0, .
            _buildRow(rowHeight, [
              SquircleButton(
                text: '00',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: 'Double zero',
                onTap: () {
                  cubit.appendDigit('0');
                  cubit.appendDigit('0');
                },
              ),
              SquircleButton(
                text: '0',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: '0',
                onTap: () => cubit.appendDigit('0'),
              ),
              SquircleButton(
                text: '.',
                backgroundColor: colors.numberButton,
                foregroundColor: colors.numberText,
                borderColor: colors.numberButtonBorder,
                fontSize: fontSize,
                semanticLabel: 'Decimal point',
                onTap: cubit.appendDecimal,
              ),
            ]),
          ],
        );
      },
    );
  }
}
