import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/math_notes_home_screen.dart';
import 'package:easy_calculator/features/units_converter/presentation/screens/units_converter_screen.dart';

/// Top-right menu allowing mode selection across the four application modes.
class ModeMenuButton extends StatelessWidget {
  const ModeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<CalculatorCubit>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) => prev.mode != curr.mode,
      builder: (context, state) {
        return PopupMenuButton<CalculatorMode>(
          tooltip: 'Select mode',
          icon: Icon(
            Icons.calculate_outlined,
            color: colors.textPrimary,
            size: 26,
          ),
          color: colors.backgroundColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: colors.numberButtonBorder != Colors.transparent
                  ? colors.numberButtonBorder
                  : colors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          onSelected: (mode) {
            if (mode == CalculatorMode.basic ||
                mode == CalculatorMode.scientific) {
              cubit.setMode(mode);
            } else if (mode == CalculatorMode.mathNotes) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MathNotesHomeScreen(),
                ),
              );
            } else if (mode == CalculatorMode.convert) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => UnitsConverterScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_modeTitle(mode)} mode will be available in its upcoming phase.',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          itemBuilder: (context) => [
            _buildMenuItem(
              context,
              mode: CalculatorMode.basic,
              title: 'Basic',
              icon: Icons.calculate,
              isSelected: state.mode == CalculatorMode.basic,
            ),
            _buildMenuItem(
              context,
              mode: CalculatorMode.scientific,
              title: 'Scientific',
              icon: Icons.science_outlined,
              isSelected: state.mode == CalculatorMode.scientific,
            ),
            _buildMenuItem(
              context,
              mode: CalculatorMode.mathNotes,
              title: 'Math Notes',
              icon: Icons.edit_note_outlined,
              isSelected: state.mode == CalculatorMode.mathNotes,
            ),
            _buildMenuItem(
              context,
              mode: CalculatorMode.convert,
              title: 'Convert',
              icon: Icons.currency_exchange_outlined,
              isSelected: state.mode == CalculatorMode.convert,
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<CalculatorMode> _buildMenuItem(
    BuildContext context, {
    required CalculatorMode mode,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedAccent = isSelected
        ? (isDark ? colors.operatorButton : colors.accentHighContrast)
        : colors.textSecondary;

    return PopupMenuItem<CalculatorMode>(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20, color: selectedAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_rounded, size: 20, color: selectedAccent),
        ],
      ),
    );
  }

  String _modeTitle(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.basic:
        return 'Basic Calculator';
      case CalculatorMode.scientific:
        return 'Scientific Calculator';
      case CalculatorMode.mathNotes:
        return 'Math Notes';
      case CalculatorMode.convert:
        return 'Units Converter';
    }
  }
}
