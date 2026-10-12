import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';
import 'package:easy_calculator/features/history/domain/repositories/history_repository.dart';
import 'package:easy_calculator/features/history/presentation/cubit/history_cubit.dart';
import 'package:easy_calculator/features/history/presentation/cubit/history_state.dart';
import 'package:easy_calculator/features/history/presentation/widgets/history_item_tile.dart';

/// Screen displaying completed calculation history with 7-calendar-day retention and entry reuse.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.repository});

  final HistoryRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryCubit>(
      create: (context) => HistoryCubit(repository: repository)..loadHistory(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  void _confirmClearAll(BuildContext context) {
    final colors = context.calcColors;
    final cubit = context.read<HistoryCubit>();

    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Clear History?',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all saved calculation history? This action cannot be undone.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.operatorButton,
              foregroundColor: colors.operatorText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx, true);
              cubit.clearAll();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _onSelectEntry(BuildContext context, HistoryItem item) {
    // Restore entry expression and result to active calculator
    context.read<CalculatorCubit>().reuseHistoryItem(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'History',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.delete_sweep_rounded,
                  color: colors.textPrimary,
                ),
                tooltip: 'Clear history',
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.operatorButton.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          size: 56,
                          color: colors.operatorButton,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Calculation History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed calculations from Basic and Scientific modes will be saved here for 7 calendar days.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 7-day retention informative badge
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Retained for 7 calendar days on device',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // History list
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    padding: const EdgeInsets.only(bottom: 16.0),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return HistoryItemTile(
                        item: item,
                        onTap: (selected) => _onSelectEntry(context, selected),
                        onDelete: () =>
                            context.read<HistoryCubit>().deleteItem(item.id),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
