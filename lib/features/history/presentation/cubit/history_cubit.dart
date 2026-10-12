import 'package:bloc/bloc.dart';
import 'package:easy_calculator/features/history/domain/repositories/history_repository.dart';
import 'package:easy_calculator/features/history/presentation/cubit/history_state.dart';

/// Cubit managing calculation history retrieval, deletion, and expiry maintenance.
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required this.repository}) : super(const HistoryState());

  final HistoryRepository repository;

  /// Loads history items, automatically purging any entries older than 7 calendar days.
  Future<void> loadHistory() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      // Purge any expired items on access
      await repository.purgeExpiredEntries();
      final items = await repository.getHistory();
      emit(state.copyWith(items: items, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load calculation history.',
        ),
      );
    }
  }

  /// Deletes a specific history item by [id].
  Future<void> deleteItem(String id) async {
    try {
      await repository.deleteEntry(id);
      final updated = state.items.where((item) => item.id != id).toList();
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete history item.'));
    }
  }

  /// Clears all history entries.
  Future<void> clearAll() async {
    try {
      await repository.clearHistory();
      emit(state.copyWith(items: const []));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to clear history.'));
    }
  }
}
