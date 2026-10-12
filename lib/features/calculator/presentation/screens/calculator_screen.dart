import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/basic_keypad.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/mode_menu_button.dart';

/// The primary screen for the Basic Calculator.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.history_rounded,
                      color: colors.textPrimary,
                      size: 26,
                    ),
                    tooltip: 'History',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Calculation history will be available in Phase 3.',
                          ),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const ModeMenuButton(),
                ],
              ),
            ),

            // Expression & Result Display Area
            Expanded(
              child: BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (prev, curr) =>
                    prev.expression != curr.expression ||
                    prev.result != curr.result ||
                    prev.isResultComputed != curr.isResultComputed ||
                    prev.errorMessage != curr.errorMessage,
                builder: (context, state) {
                  return CalculatorDisplay(
                    expression: state.expression,
                    result: state.result,
                    isResultComputed: state.isResultComputed,
                    errorMessage: state.errorMessage,
                  );
                },
              ),
            ),

            // Arithmetic Keypad
            const BasicKeypad(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
