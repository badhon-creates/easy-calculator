import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:easy_calculator/features/math_notes/data/services/share_plus_note_share_service.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

void main() {
  group('sanitizeNoteFilename tests', () {
    test('sanitizes standard title with spaces', () {
      expect(sanitizeNoteFilename('Physics Homework 1'), 'Physics_Homework_1');
    });

    test('strips special symbols and unsafe path characters', () {
      expect(
        sanitizeNoteFilename('Math: Chapter 3 / Final & Tests?'),
        'Math_Chapter_3__Final__Tests',
      );
    });

    test('returns default Math_Note for empty or whitespace-only titles', () {
      expect(sanitizeNoteFilename(''), 'Math_Note');
      expect(sanitizeNoteFilename('   \t\n  '), 'Math_Note');
      expect(sanitizeNoteFilename('???///###'), 'Math_Note');
    });

    test('truncates titles exceeding maximum length safely', () {
      const longTitle =
          'This_Is_An_Extremely_Long_Title_That_Exceeds_The_Maximum_Allowed_Length_For_Files';
      final result = sanitizeNoteFilename(longTitle);
      expect(result.length, lessThanOrEqualTo(40));
    });
  });

  group('SharePlusNoteShareService tests', () {
    late Directory tempTestDir;

    setUp(() {
      tempTestDir = Directory.systemTemp.createTempSync('share_service_test_');
    });

    tearDown(() {
      if (tempTestDir.existsSync()) {
        tempTestDir.deleteSync(recursive: true);
      }
    });

    test('creates temporary PDF file and triggers shareLauncher', () async {
      List<XFile>? sharedFiles;
      String? sharedSubject;

      final service = SharePlusNoteShareService(
        getTempDirectory: () async => tempTestDir,
        shareLauncher: (files, {subject}) async {
          sharedFiles = files;
          sharedSubject = subject;
        },
      );

      final note = MathNote(
        id: 'test-note-share',
        title: 'Quantum Mechanics',
        blocks: const [],
        createdAt: DateTime(2026, 10, 13),
        updatedAt: DateTime(2026, 10, 13),
      );

      final dummyPdfBytes = Uint8List.fromList([
        37,
        80,
        68,
        70,
        45,
        49,
        46,
        52,
      ]); // %PDF-1.4

      await service.shareNotePdf(note, dummyPdfBytes);

      expect(sharedFiles, isNotNull);
      expect(sharedFiles!.length, 1);
      expect(sharedSubject, 'Quantum Mechanics');

      final exportedFile = File(sharedFiles!.first.path);
      expect(exportedFile.existsSync(), true);
      expect(exportedFile.path.contains('math_notes_exports'), true);
      expect(
        p.basename(exportedFile.path).startsWith('Quantum_Mechanics_'),
        true,
      );
      expect(exportedFile.path.endsWith('.pdf'), true);

      final writtenBytes = await exportedFile.readAsBytes();
      expect(writtenBytes, dummyPdfBytes);
    });

    test(
      'cleans up old export files (>30 min) while preserving fresh exports',
      () async {
        final exportsDir = Directory(
          p.join(tempTestDir.path, 'math_notes_exports'),
        );
        exportsDir.createSync(recursive: true);

        // Create an old simulated export file
        final oldFile = File(p.join(exportsDir.path, 'Old_Note_123.pdf'));
        oldFile.writeAsStringSync('old dummy');
        // Set modification time to 45 minutes ago
        final oldTime = DateTime.now().subtract(const Duration(minutes: 45));
        oldFile.setLastModifiedSync(oldTime);

        final service = SharePlusNoteShareService(
          getTempDirectory: () async => tempTestDir,
          shareLauncher: (files, {subject}) async {},
        );

        final note = MathNote(
          id: 'new-note-share',
          title: 'Fresh Note',
          blocks: const [],
          createdAt: DateTime(2026, 10, 13),
          updatedAt: DateTime(2026, 10, 13),
        );

        await service.shareNotePdf(note, Uint8List.fromList([1, 2, 3]));

        // Old file should be deleted
        expect(oldFile.existsSync(), false);

        // Newly generated file exists
        final currentFiles = exportsDir.listSync();
        expect(currentFiles.length, 1);
        expect(currentFiles.first.path.contains('Fresh_Note_'), true);
      },
    );
  });
}
