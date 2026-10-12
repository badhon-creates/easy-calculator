import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/history/data/repositories/local_history_repository.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';

void main() {
  group('LocalHistoryRepository - Core Persistence & 7-Calendar-Day Expiry', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('calc_history_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'Saving and retrieving history entries returns newest first',
      () async {
        final repo = LocalHistoryRepository(
          getDirectory: () async => tempDir,
          clock: () => DateTime(2026, 10, 12, 12, 0),
        );

        final item1 = HistoryItem(
          id: '1',
          expression: '12 + 5',
          result: '17',
          timestamp: DateTime(2026, 10, 12, 10, 0),
          mode: 'basic',
        );
        final item2 = HistoryItem(
          id: '2',
          expression: 'sin(30)',
          result: '0.5',
          timestamp: DateTime(2026, 10, 12, 11, 0),
          mode: 'scientific',
        );

        await repo.addEntry(item1);
        await repo.addEntry(item2);

        final history = await repo.getHistory();
        expect(history.length, equals(2));
        // item2 is newer so should appear first
        expect(history[0].id, equals('2'));
        expect(history[0].expression, equals('sin(30)'));
        expect(history[0].result, equals('0.5'));
        expect(history[0].mode, equals('scientific'));

        expect(history[1].id, equals('1'));
        expect(history[1].expression, equals('12 + 5'));
        expect(history[1].result, equals('17'));
        expect(history[1].mode, equals('basic'));
      },
    );

    test('Retention across simulated application restarts', () async {
      DateTime fixedClock() => DateTime(2026, 10, 12, 12, 0);

      // App Instance 1
      final repo1 = LocalHistoryRepository(
        getDirectory: () async => tempDir,
        clock: fixedClock,
      );
      await repo1.addEntry(
        HistoryItem(
          id: 'item_1',
          expression: '10 × 20',
          result: '200',
          timestamp: DateTime(2026, 10, 12, 11, 0),
        ),
      );

      // App Instance 2 (simulating fresh launch)
      final repo2 = LocalHistoryRepository(
        getDirectory: () async => tempDir,
        clock: fixedClock,
      );
      final history = await repo2.getHistory();
      expect(history.length, equals(1));
      expect(history.first.expression, equals('10 × 20'));
      expect(history.first.result, equals('200'));
    });

    test('Strict 7-calendar-day retention: keeps today + preceding 6 calendar days', () async {
      // Deterministic reference time: Monday, October 12, 2026 at 15:00
      final referenceNow = DateTime(2026, 10, 12, 15, 0);
      final repo = LocalHistoryRepository(
        getDirectory: () async => tempDir,
        clock: () => referenceNow,
      );

      // Day 0: Today (Oct 12)
      final todayItem = HistoryItem(
        id: 'd0',
        expression: '1 + 1',
        result: '2',
        timestamp: DateTime(2026, 10, 12, 9, 0),
      );
      // Day 1: Yesterday (Oct 11)
      final day1Item = HistoryItem(
        id: 'd1',
        expression: '2 + 2',
        result: '4',
        timestamp: DateTime(2026, 10, 11, 23, 59),
      );
      // Day 6: Preceding 6th calendar day (Oct 6) -> within 7 calendar days!
      final day6Item = HistoryItem(
        id: 'd6',
        expression: '6 + 6',
        result: '12',
        timestamp: DateTime(2026, 10, 6, 0, 1),
      );
      // Day 7: Preceding 7th calendar day (Oct 5) -> EXPIRED (> 6 days prior)
      final day7Item = HistoryItem(
        id: 'd7',
        expression: '7 + 7',
        result: '14',
        timestamp: DateTime(2026, 10, 5, 23, 59),
      );
      // Day 30: 30 days ago (Sept 12) -> EXPIRED
      final oldItem = HistoryItem(
        id: 'd30',
        expression: '30 + 30',
        result: '60',
        timestamp: DateTime(2026, 9, 12, 12, 0),
      );

      await repo.addEntry(todayItem);
      await repo.addEntry(day1Item);
      await repo.addEntry(day6Item);
      await repo.addEntry(day7Item);
      await repo.addEntry(oldItem);

      // getHistory should filter out expired items and purge them
      final history = await repo.getHistory();
      final ids = history.map((e) => e.id).toSet();

      expect(
        ids.contains('d0'),
        isTrue,
        reason: 'Today entry must be retained',
      );
      expect(
        ids.contains('d1'),
        isTrue,
        reason: 'Yesterday entry must be retained',
      );
      expect(
        ids.contains('d6'),
        isTrue,
        reason: '6th preceding day must be retained',
      );
      expect(
        ids.contains('d7'),
        isFalse,
        reason: '7th preceding day must be expired',
      );
      expect(
        ids.contains('d30'),
        isFalse,
        reason: '30-day-old entry must be expired',
      );
      expect(history.length, equals(3));
    });

    test('Calendar-day expiry is not a rolling 168-hour rule', () {
      // Consider an entry created at 08:00 AM on Oct 6.
      // Reference now is Oct 12 at 20:00 PM (156 hours elapsed, but calendar date difference is 6 days).
      final entryTime = DateTime(2026, 10, 6, 8, 0);
      final refTime = DateTime(2026, 10, 12, 20, 0);

      expect(
        LocalHistoryRepository.isEntryExpired(entryTime, refTime),
        isFalse,
        reason: 'Oct 6 is the 6th preceding calendar day of Oct 12, so it is retained',
      );

      // An entry from Oct 5 at 23:59 (just 8 hours before Oct 6 08:00) is 7 calendar days prior:
      final oct5Time = DateTime(2026, 10, 5, 23, 59);
      expect(
        LocalHistoryRepository.isEntryExpired(oct5Time, refTime),
        isTrue,
        reason: 'Oct 5 is 7 calendar days prior to Oct 12, so it is expired',
      );
    });

    test(
      'purgeExpiredEntries deletes expired entries and returns count',
      () async {
        final repo = LocalHistoryRepository(
          getDirectory: () async => tempDir,
          clock: () => DateTime(2026, 10, 12, 12, 0),
        );

        await repo.addEntry(
          HistoryItem(
            id: 'fresh',
            expression: '5 + 5',
            result: '10',
            timestamp: DateTime(2026, 10, 12, 11, 0),
          ),
        );
        await repo.addEntry(
          HistoryItem(
            id: 'stale1',
            expression: '1 + 1',
            result: '2',
            timestamp: DateTime(2026, 9, 1, 10, 0),
          ),
        );
        await repo.addEntry(
          HistoryItem(
            id: 'stale2',
            expression: '2 + 2',
            result: '4',
            timestamp: DateTime(2026, 9, 2, 10, 0),
          ),
        );

        final purged = await repo.purgeExpiredEntries();
        expect(purged, equals(2));

        final remaining = await repo.getHistory();
        expect(remaining.length, equals(1));
        expect(remaining.first.id, equals('fresh'));
      },
    );

    test(
      'Does NOT delete all history when 7 days pass since app was last opened',
      () async {
        // User created a calculation on Oct 10
        // User doesn't open the app until Oct 14 (4 days later)
        final repo = LocalHistoryRepository(
          getDirectory: () async => tempDir,
          clock: () => DateTime(2026, 10, 14, 12, 0),
        );

        await repo.addEntry(
          HistoryItem(
            id: 'oct10',
            expression: '100 + 50',
            result: '150',
            timestamp: DateTime(2026, 10, 10, 14, 0),
          ),
        );

        final history = await repo.getHistory();
        expect(history.length, equals(1));
        expect(history.first.id, equals('oct10'));
      },
    );

    test('Handling empty history returns empty list', () async {
      final repo = LocalHistoryRepository(getDirectory: () async => tempDir);
      final history = await repo.getHistory();
      expect(history, isEmpty);
    });

    test('Deleting individual history entry', () async {
      final repo = LocalHistoryRepository(getDirectory: () async => tempDir);
      await repo.addEntry(
        HistoryItem(
          id: 'del_1',
          expression: '9 × 9',
          result: '81',
          timestamp: DateTime.now(),
        ),
      );
      await repo.addEntry(
        HistoryItem(
          id: 'keep_2',
          expression: '8 × 8',
          result: '64',
          timestamp: DateTime.now(),
        ),
      );

      await repo.deleteEntry('del_1');

      final history = await repo.getHistory();
      expect(history.length, equals(1));
      expect(history.first.id, equals('keep_2'));
    });

    test('Clearing all history', () async {
      final repo = LocalHistoryRepository(getDirectory: () async => tempDir);
      await repo.addEntry(
        HistoryItem(
          id: 'c1',
          expression: '1 + 1',
          result: '2',
          timestamp: DateTime.now(),
        ),
      );
      await repo.clearHistory();

      final history = await repo.getHistory();
      expect(history, isEmpty);
    });

    test('Handling malformed or corrupted file gracefully', () async {
      final file = File('${tempDir.path}/easy_calc_history.json');
      await file.writeAsString('{ corrupted json [!!@@##', flush: true);

      final repo = LocalHistoryRepository(getDirectory: () async => tempDir);
      final history = await repo.getHistory();
      expect(history, isEmpty);
    });

    test(
      'History expiry never deletes unrelated files in the same directory',
      () async {
        // Create a dummy note file simulating Math Notes or other data
        final noteFile = File('${tempDir.path}/math_notes_sample.json');
        await noteFile.writeAsString(
          '{"title": "Important Note"}',
          flush: true,
        );

        final repo = LocalHistoryRepository(
          getDirectory: () async => tempDir,
          clock: () => DateTime(2026, 10, 12, 12, 0),
        );

        await repo.addEntry(
          HistoryItem(
            id: 'expired',
            expression: '1 + 1',
            result: '2',
            timestamp: DateTime(2026, 8, 1, 10, 0),
          ),
        );

        await repo.purgeExpiredEntries();

        // Ensure noteFile still exists and is untouched
        expect(await noteFile.exists(), isTrue);
        final noteContent = await noteFile.readAsString();
        expect(noteContent, contains('Important Note'));
      },
    );
  });
}
