import 'package:easy_calculator/features/history/domain/models/history_item.dart';

/// Contract for managing persistent calculation history.
abstract class HistoryRepository {
  /// Retrieves all valid, unexpired calculation history entries ordered from newest to oldest.
  Future<List<HistoryItem>> getHistory();

  /// Adds a completed calculation entry to history.
  Future<void> addEntry(HistoryItem item);

  /// Deletes a specific history entry by [id].
  Future<void> deleteEntry(String id);

  /// Clears all history entries.
  Future<void> clearHistory();

  /// Automatically purges entries older than seven calendar days based on device local calendar date.
  /// Returns the number of entries removed.
  Future<int> purgeExpiredEntries();
}
