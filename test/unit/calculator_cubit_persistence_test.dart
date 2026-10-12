import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/calculator/data/repositories/local_session_repository.dart';
import 'package:easy_calculator/features/calculator/domain/models/angle_mode.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_session.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:easy_calculator/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:easy_calculator/features/history/data/repositories/local_history_repository.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';

void main() {
  group('CalculatorCubit - History and Session Persistence Integration', () {
    late Directory tempDir;
    late LocalHistoryRepository historyRepo;
    late LocalSessionRepository sessionRepo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'cubit_persistence_test_',
      );
      historyRepo = LocalHistoryRepository(getDirectory: () async => tempDir);
      sessionRepo = LocalSessionRepository(getDirectory: () async => tempDir);
    });

    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test(
      'Records calculation history ONLY upon successful equals (=)',
      () async {
        final cubit = CalculatorCubit(
          historyRepository: historyRepo,
          sessionRepository: sessionRepo,
        );

        // Typing unfinished expression: '12 + 5'
        cubit.appendDigit('1');
        cubit.appendDigit('2');
        cubit.appendOperator('+');
        cubit.appendDigit('5');

        // Check history before equals: must be empty
        expect(await historyRepo.getHistory(), isEmpty);

        // Press equals
        await cubit.calculateEquals();

        final history = await historyRepo.getHistory();
        expect(history.length, equals(1));
        expect(history.first.expression, equals('12 + 5'));
        expect(history.first.result, equals('17'));
        expect(history.first.mode, equals('basic'));

        await cubit.close();
      },
    );

    test(
      'Does NOT record history if calculation has syntax or math error',
      () async {
        final cubit = CalculatorCubit(
          historyRepository: historyRepo,
          sessionRepository: sessionRepo,
        );

        cubit.appendDigit('5');
        cubit.appendOperator('÷');
        cubit.appendDigit('0');
        await cubit.calculateEquals();

        expect(cubit.state.errorMessage, isNotNull);
        expect(await historyRepo.getHistory(), isEmpty);

        await cubit.close();
      },
    );

    test('Prevents duplicate history entry on repeated equals without input change', () async {
      final cubit = CalculatorCubit(
        historyRepository: historyRepo,
        sessionRepository: sessionRepo,
      );

      cubit.appendDigit('3');
      cubit.appendOperator('×');
      cubit.appendDigit('4');

      await cubit.calculateEquals();
      await cubit.calculateEquals();
      await cubit.calculateEquals();

      final history = await historyRepo.getHistory();
      expect(
        history.length,
        equals(1),
        reason: 'Repeated equals should not duplicate history',
      );

      await cubit.close();
    });

    test(
      'Session restoration does NOT record duplicate history entries',
      () async {
        // Pre-seed a saved session with an unfinished expression
        await sessionRepo.saveSession(
          CalculatorSession(
            expression: '99 + 1',
            result: '100',
            isResultComputed: false,
            mode: CalculatorMode.basic,
            lastUpdated: DateTime.now(),
          ),
        );

        final cubit = CalculatorCubit(
          historyRepository: historyRepo,
          sessionRepository: sessionRepo,
        );

        await cubit.restoreSession();

        expect(cubit.state.expression, equals('99 + 1'));
        expect(cubit.state.result, equals('100'));
        expect(cubit.state.isResultComputed, isFalse);

        // Verify no history was recorded
        expect(await historyRepo.getHistory(), isEmpty);

        await cubit.close();
      },
    );

    test(
      'Restores Scientific mode, Radian angle mode, 2nd state, and memory',
      () async {
        await sessionRepo.saveSession(
          CalculatorSession(
            expression: 'cos(0)',
            result: '1',
            isResultComputed: true,
            mode: CalculatorMode.scientific,
            angleMode: AngleMode.radians,
            isSecondary: true,
            memoryValue: 123.45,
            hasMemory: true,
            lastUpdated: DateTime.now(),
          ),
        );

        final cubit = CalculatorCubit(
          historyRepository: historyRepo,
          sessionRepository: sessionRepo,
        );

        await cubit.restoreSession();

        expect(cubit.state.mode, equals(CalculatorMode.scientific));
        expect(cubit.state.angleMode, equals(AngleMode.radians));
        expect(cubit.state.isSecondary, isTrue);
        expect(cubit.state.memoryValue, equals(123.45));
        expect(cubit.state.hasMemory, isTrue);

        await cubit.close();
      },
    );

    test('Post-result rules apply correctly after session restoration', () async {
      // Save session with a finalized calculation
      await sessionRepo.saveSession(
        CalculatorSession(
          expression: '8 × 5',
          result: '40',
          isResultComputed: true,
          lastUpdated: DateTime.now(),
        ),
      );

      final cubit = CalculatorCubit(
        historyRepository: historyRepo,
        sessionRepository: sessionRepo,
      );
      await cubit.restoreSession();

      // Rule 1: Tapping an operator continues calculation from previous result
      cubit.appendOperator('+');
      expect(cubit.state.expression, equals('40 + '));
      expect(cubit.state.isResultComputed, isFalse);

      cubit.appendDigit('2');
      await cubit.calculateEquals();
      expect(cubit.state.result, equals('42'));

      // Rule 2: Tapping a digit after equals starts a fresh calculation
      cubit.appendDigit('7');
      expect(cubit.state.expression, equals('7'));
      expect(cubit.state.result, isNull);
      expect(cubit.state.isResultComputed, isFalse);

      await cubit.close();
    });

    test('Reusing history item restores calculation without duplicate history record', () async {
      final cubit = CalculatorCubit(
        historyRepository: historyRepo,
        sessionRepository: sessionRepo,
      );

      final historyItem = HistoryItem(
        id: 'hist_1',
        expression: '50 ÷ 2',
        result: '25',
        timestamp: DateTime.now(),
      );

      await cubit.reuseHistoryItem(historyItem);

      expect(cubit.state.expression, equals('50 ÷ 2'));
      expect(cubit.state.result, equals('25'));
      expect(cubit.state.isResultComputed, isTrue);

      // Verify no duplicate history item was added
      expect(await historyRepo.getHistory(), isEmpty);

      // Tapping operator continues calculation
      cubit.appendOperator('×');
      expect(cubit.state.expression, equals('25 × '));

      await cubit.close();
    });

    test('Mode switching flushes session state immediately', () async {
      final cubit = CalculatorCubit(
        historyRepository: historyRepo,
        sessionRepository: sessionRepo,
      );

      cubit.appendDigit('9');
      await cubit.setMode(CalculatorMode.scientific);

      // Since setMode flushes immediately, session is already saved
      final saved = await sessionRepo.loadSession();
      expect(saved, isNotNull);
      expect(saved!.mode, equals(CalculatorMode.scientific));
      expect(saved.expression, equals('9'));

      await cubit.close();
    });
  });
}
