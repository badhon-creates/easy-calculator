import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/basic_keypad.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/mode_menu_button.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/scientific_keypad.dart';

/// The primary screen for Easy Calculator supporting Basic and Scientific modes.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            final isScientific = state.mode == CalculatorMode.scientific;

            return Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
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
                  child: CalculatorDisplay(
                    expression: state.expression,
                    result: state.result,
                    isResultComputed: state.isResultComputed,
                    errorMessage: state.errorMessage,
                    angleMode: state.angleMode,
                    isSecondary: state.isSecondary,
                    hasMemory: state.hasMemory,
                    isScientific: isScientific,
                  ),
                ),

                // Scientific Controls (Smoothly expand / collapse)
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  child: isScientific
                      ? const ScientificKeypad()
                      : const SizedBox.shrink(),
                ),

                // Arithmetic Keypad
                BasicKeypad(isScientific: isScientific),
                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ),
    );
  }
}
