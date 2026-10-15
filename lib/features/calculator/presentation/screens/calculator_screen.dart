import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/basic_keypad.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/mode_menu_button.dart';
import 'package:easy_calculator/features/calculator/presentation/widgets/scientific_keypad.dart';
import 'package:easy_calculator/features/history/data/repositories/local_history_repository.dart';
import 'package:easy_calculator/features/history/presentation/screens/history_screen.dart';

import 'package:easy_calculator/features/calculator/presentation/widgets/scientific_landscape_keypad.dart';

/// The primary screen for Easy Calculator supporting Basic and Scientific modes,
/// calculation history access, and Android lifecycle session preservation.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // Flush active session immediately upon backgrounding, pause, or detachment
      if (mounted) {
        context.read<CalculatorCubit>().flushSession();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Purge any expired history entries when application resumes
      if (mounted) {
        context
            .read<CalculatorCubit>()
            .historyRepository
            ?.purgeExpiredEntries();
      }
    }
  }

  void _openHistory(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    final historyRepo = cubit.historyRepository ?? LocalHistoryRepository();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(repository: historyRepo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            final isScientific = state.mode == CalculatorMode.scientific;

            if (isLandscape) {
              if (isScientific) {
                // Landscape Scientific: Top bar + display, followed by 10-column keypad
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 2.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.history_rounded,
                              color: colors.textPrimary,
                              size: 24,
                            ),
                            tooltip: 'History',
                            onPressed: () => _openHistory(context),
                          ),
                          const ModeMenuButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CalculatorDisplay(
                        expression: state.expression,
                        result: state.result,
                        isResultComputed: state.isResultComputed,
                        errorMessage: state.errorMessage,
                        angleMode: state.angleMode,
                        isSecondary: state.isSecondary,
                        hasMemory: state.hasMemory,
                        isScientific: true,
                      ),
                    ),
                    const ScientificLandscapeKeypad(),
                    const SizedBox(height: 4),
                  ],
                );
              } else {
                // Landscape Basic: 2-column layout with display on left, keypad on right
                return Row(
                  children: [
                    Expanded(
                      flex: 42,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
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
                                  onPressed: () => _openHistory(context),
                                ),
                                const ModeMenuButton(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CalculatorDisplay(
                              expression: state.expression,
                              result: state.result,
                              isResultComputed: state.isResultComputed,
                              errorMessage: state.errorMessage,
                              angleMode: state.angleMode,
                              isSecondary: state.isSecondary,
                              hasMemory: state.hasMemory,
                              isScientific: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      color: colors.numberButtonBorder != Colors.transparent
                          ? colors.numberButtonBorder
                          : colors.textSecondary.withValues(alpha: 0.15),
                    ),
                    const Expanded(
                      flex: 58,
                      child: Center(
                        child: BasicKeypad(
                          isScientific: false,
                          isLandscape: true,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }

            // Portrait layout
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
                        onPressed: () => _openHistory(context),
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
