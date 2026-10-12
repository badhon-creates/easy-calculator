import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';
import 'package:easy_calculator/features/history/domain/repositories/history_repository.dart';

/// Implementation of [HistoryRepository] using atomic JSON file storage in app-private storage.
///
/// Implements strict 7-calendar-day retention:
/// Retains calculations created on the current calendar day plus the preceding six calendar days
/// in the device's local calendar context (total 7 calendar days).
/// Any entries older than this window (diffDays >= 7) are automatically purged.
class LocalHistoryRepository implements HistoryRepository {
  LocalHistoryRepository({
    Future<Directory> Function()? getDirectory,
    DateTime Function()? clock,
    this.fileName = 'easy_calc_history.json',
  }) : _getDirectory = getDirectory ?? getApplicationSupportDirectory,
       _clock = clock ?? DateTime.now;

  final Future<Directory> Function() _getDirectory;
  final DateTime Function() _clock;
  final String fileName;

  /// Checks if an entry's timestamp is expired under the 7-calendar-day retention rule.
  ///
  /// Retention policy covers the current calendar day (diffDays == 0) plus the preceding 6
  /// calendar days (diffDays == 1..6). Any entry with diffDays >= 7 is expired.
  /// Entries from future timestamps (e.g. clock adjustments) are retained.
  static bool isEntryExpired(DateTime entryTimestamp, DateTime now) {
    final localNow = now.toLocal();
    final localEntry = entryTimestamp.toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final entryDate = DateTime(
      localEntry.year,
      localEntry.month,
      localEntry.day,
    );
    final diffDays = today.difference(entryDate).inDays;
    return diffDays >= 7;
  }

  Future<File> _getFile() async {
    final dir = await _getDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(dir.path, fileName));
  }

  @override
  Future<List<HistoryItem>> getHistory() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }

      final rawContent = await file.readAsString();
      if (rawContent.trim().isEmpty) {
        return [];
      }

      final List<dynamic> rawItems;
      try {
        final decoded = jsonDecode(rawContent);
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          rawItems = decoded['items'] as List<dynamic>;
        } else if (decoded is List) {
          rawItems = decoded;
        } else {
          return [];
        }
      } catch (e) {
        debugPrint(
          'LocalHistoryRepository: Malformed JSON, recovering gracefully: $e',
        );
        return [];
      }

      final now = _clock();
      final validItems = <HistoryItem>[];
      var expiredCount = 0;

      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          try {
            final item = HistoryItem.fromJson(raw);
            if (isEntryExpired(item.timestamp, now)) {
              expiredCount++;
            } else {
              validItems.add(item);
            }
          } catch (e) {
            debugPrint('LocalHistoryRepository: Skipping corrupted entry: $e');
          }
        }
      }

      // If expired items were filtered out during retrieval, sync cleaned list back to storage
      if (expiredCount > 0) {
        await _saveItems(validItems);
      }

      // Sort newest to oldest
      validItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return validItems;
    } catch (e) {
      debugPrint(
        'LocalHistoryRepository: Storage read error, failing gracefully: $e',
      );
      return [];
    }
  }

  Future<List<HistoryItem>> _loadRawItems() async {
    final file = await _getFile();
    if (!await file.exists()) {
      return [];
    }

    final rawContent = await file.readAsString();
    if (rawContent.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawContent);
      final List<dynamic> rawItems;
      if (decoded is Map<String, dynamic> && decoded['items'] is List) {
        rawItems = decoded['items'] as List<dynamic>;
      } else if (decoded is List) {
        rawItems = decoded;
      } else {
        return [];
      }

      final items = <HistoryItem>[];
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          try {
            items.add(HistoryItem.fromJson(raw));
          } catch (_) {}
        }
      }
      return items;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addEntry(HistoryItem item) async {
    try {
      final currentList = await _loadRawItems();

      // Prevent duplicate entry with same ID
      final filtered = currentList
          .where((existing) => existing.id != item.id)
          .toList();
      filtered.insert(0, item);

      await _saveItems(filtered);
    } catch (e) {
      debugPrint('LocalHistoryRepository: Failed to add entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      final currentList = await _loadRawItems();
      final updated = currentList.where((item) => item.id != id).toList();
      await _saveItems(updated);
    } catch (e) {
      debugPrint('LocalHistoryRepository: Failed to delete entry: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('LocalHistoryRepository: Failed to clear history: $e');
    }
  }

  @override
  Future<int> purgeExpiredEntries() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return 0;
      }

      final rawContent = await file.readAsString();
      if (rawContent.trim().isEmpty) {
        return 0;
      }

      final decoded = jsonDecode(rawContent);
      final List<dynamic> rawItems;
      if (decoded is Map<String, dynamic> && decoded['items'] is List) {
        rawItems = decoded['items'] as List<dynamic>;
      } else if (decoded is List) {
        rawItems = decoded;
      } else {
        return 0;
      }

      final now = _clock();
      final retainedItems = <HistoryItem>[];
      var purgedCount = 0;

      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          try {
            final item = HistoryItem.fromJson(raw);
            if (isEntryExpired(item.timestamp, now)) {
              purgedCount++;
            } else {
              retainedItems.add(item);
            }
          } catch (_) {
            purgedCount++;
          }
        }
      }

      if (purgedCount > 0) {
        await _saveItems(retainedItems);
      }

      return purgedCount;
    } catch (e) {
      debugPrint('LocalHistoryRepository: Failed to purge expired entries: $e');
      return 0;
    }
  }

  /// Atomically writes items to disk by writing to a temporary file first and renaming.
  Future<void> _saveItems(List<HistoryItem> items) async {
    final file = await _getFile();
    final tempFile = File('${file.path}.tmp');

    final payload = {
      'version': 1,
      'items': items.map((e) => e.toJson()).toList(),
    };

    final jsonStr = jsonEncode(payload);
    await tempFile.writeAsString(jsonStr, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await tempFile.rename(file.path);
  }
}
