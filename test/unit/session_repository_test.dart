import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/calculator/data/repositories/local_session_repository.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_session.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';

void main() {
  group('LocalSessionRepository - In-Progress State Persistence', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('calc_session_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Saving and restoring an unfinished expression', () async {
      final repo = LocalSessionRepository(getDirectory: () async => tempDir);

      final session = CalculatorSession(
        expression: '12 + 5',
        result: '17',
        isResultComputed: false,
        mode: CalculatorMode.basic,
        angleMode: AngleMode.degrees,
        lastUpdated: DateTime(2026, 10, 12, 10, 0),
      );

      await repo.saveSession(session);

      final loaded = await repo.loadSession();
      expect(loaded, isNotNull);
      expect(loaded!.expression, equals('12 + 5'));
      expect(loaded.result, equals('17'));
      expect(loaded.isResultComputed, isFalse);
      expect(loaded.mode, equals(CalculatorMode.basic));
      expect(loaded.angleMode, equals(AngleMode.degrees));
    });

    test('Saving and restoring completed calculation state', () async {
      final repo = LocalSessionRepository(getDirectory: () async => tempDir);

      final session = CalculatorSession(
        expression: '45 × 2',
        result: '90',
        isResultComputed: true,
        mode: CalculatorMode.basic,
        lastUpdated: DateTime(2026, 10, 12, 10, 0),
      );

      await repo.saveSession(session);

      final loaded = await repo.loadSession();
      expect(loaded, isNotNull);
      expect(loaded!.expression, equals('45 × 2'));
      expect(loaded.result, equals('90'));
      expect(loaded.isResultComputed, isTrue);
    });

    test('Saving and restoring Scientific mode, radians, 2nd, and memory registers', () async {
      final repo = LocalSessionRepository(getDirectory: () async => tempDir);

      final session = CalculatorSession(
        expression: 'sin(π/2)',
        result: '1',
        isResultComputed: true,
        mode: CalculatorMode.scientific,
        angleMode: AngleMode.radians,
        isSecondary: true,
        memoryValue: 42.5,
        hasMemory: true,
        lastUpdated: DateTime(2026, 10, 12, 10, 0),
      );

      await repo.saveSession(session);

      final loaded = await repo.loadSession();
      expect(loaded, isNotNull);
      expect(loaded!.mode, equals(CalculatorMode.scientific));
      expect(loaded.angleMode, equals(AngleMode.radians));
      expect(loaded.isSecondary, isTrue);
      expect(loaded.memoryValue, equals(42.5));
      expect(loaded.hasMemory, isTrue);

      final restoredState = loaded.toState();
      expect(restoredState.mode, equals(CalculatorMode.scientific));
      expect(restoredState.angleMode, equals(AngleMode.radians));
      expect(restoredState.isSecondary, isTrue);
      expect(restoredState.memoryValue, equals(42.5));
      expect(restoredState.hasMemory, isTrue);
    });

    test('Loading non-existent session returns null without error', () async {
      final repo = LocalSessionRepository(getDirectory: () async => tempDir);
      final loaded = await repo.loadSession();
      expect(loaded, isNull);
    });

    test(
      'Handling malformed or corrupted session file gracefully returns null',
      () async {
        final file = File('${tempDir.path}/easy_calc_session.json');
        await file.writeAsString('{ corrupted payload !!@#', flush: true);

        final repo = LocalSessionRepository(getDirectory: () async => tempDir);
        final loaded = await repo.loadSession();
        expect(loaded, isNull);
      },
    );

    test('Clearing session removes persisted file', () async {
      final repo = LocalSessionRepository(getDirectory: () async => tempDir);
      await repo.saveSession(
        CalculatorSession(expression: '123', lastUpdated: DateTime.now()),
      );
      expect(await repo.loadSession(), isNotNull);

      await repo.clearSession();
      expect(await repo.loadSession(), isNull);
    });
  });
}
