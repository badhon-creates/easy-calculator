import 'package:intl/intl.dart';

/// Formatter for displaying human-readable timestamps in calculation history.
class HistoryDateFormatter {
  const HistoryDateFormatter._();

  /// Formats [timestamp] into a friendly relative date string (e.g. "Today, 3:30 PM", "Yesterday, 10:15 AM", "Oct 10, 4:20 PM").
  static String format(DateTime timestamp, {DateTime? referenceNow}) {
    final now = referenceNow ?? DateTime.now();
    final localNow = now.toLocal();
    final localTime = timestamp.toLocal();

    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final entryDate = DateTime(localTime.year, localTime.month, localTime.day);
    final diffDays = today.difference(entryDate).inDays;

    final timeStr = DateFormat.jm().format(localTime);

    if (diffDays == 0) {
      return 'Today, $timeStr';
    } else if (diffDays == 1) {
      return 'Yesterday, $timeStr';
    } else {
      final dateStr = DateFormat('MMM d').format(localTime);
      return '$dateStr, $timeStr';
    }
  }
}
