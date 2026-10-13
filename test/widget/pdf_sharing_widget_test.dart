import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/services/note_share_service.dart';
import 'package:easy_calculator/features/math_notes/domain/services/pdf_document_generator.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/note_editor_screen.dart';

class _FakeNoteRepo implements NoteRepository {
  @override
  Future<List<MathNote>> getAllNotes({bool newestFirst = true}) async => [];
  @override
  Future<MathNote?> getNoteById(String id) async => null;
  @override
  Future<void> saveNote(MathNote note) async {}
  @override
  Future<void> deleteNotes(List<String> ids) async {}
  @override
  Future<List<MathNote>> searchNotes(
    String query, {
    bool newestFirst = true,
  }) async => [];
}

class _FakeSessionRepo implements NoteSessionRepository {
  @override
  Future<void> clearSession() async {}
  @override
  Future<NoteEditingSession?> loadSession() async => null;
  @override
  Future<void> saveSession(NoteEditingSession session) async {}
}

class _MockPdfGenerator implements PdfDocumentGenerator {
  _MockPdfGenerator({this.shouldFail = false, this.delay});

  final bool shouldFail;
  final Duration? delay;
  MathNote? lastGeneratedNote;

  @override
  Future<Uint8List> generatePdf(MathNote note) async {
    lastGeneratedNote = note;
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    if (shouldFail) {
      throw Exception('PDF engine storage failure');
    }
    return Uint8List.fromList([37, 80, 68, 70]); // %PDF
  }
}

class _MockShareService implements NoteShareService {
  MathNote? sharedNote;
  Uint8List? sharedBytes;

  @override
  Future<void> shareNotePdf(MathNote note, Uint8List pdfBytes) async {
    sharedNote = note;
    sharedBytes = pdfBytes;
  }
}

void main() {
  testWidgets('Share button generates PDF and triggers share service', (
    tester,
  ) async {
    final noteRepo = _FakeNoteRepo();
    final sessionRepo = _FakeSessionRepo();
    final pdfGenerator = _MockPdfGenerator();
    final shareService = _MockShareService();

    final testNote = MathNote(
      id: 'n-share-test',
      title: 'Topology Basics',
      blocks: const [
        NoteBlock(
          id: 'b-1',
          type: NoteBlockType.body,
          spans: [TextSpanData(text: 'Open and closed sets.')],
        ),
      ],
      createdAt: DateTime(2026, 10, 13),
      updatedAt: DateTime(2026, 10, 13),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: NoteEditorScreen(
          note: testNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
          pdfGenerator: pdfGenerator,
          shareService: shareService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shareButton = find.byTooltip('Share note as PDF');
    expect(shareButton, findsOneWidget);

    await tester.tap(shareButton);
    await tester.pumpAndSettle();

    expect(pdfGenerator.lastGeneratedNote, isNotNull);
    expect(pdfGenerator.lastGeneratedNote!.title, 'Topology Basics');
    expect(shareService.sharedNote, isNotNull);
    expect(shareService.sharedNote!.title, 'Topology Basics');
    expect(shareService.sharedBytes, isNotNull);
  });

  testWidgets('Failed PDF generation displays error SnackBar', (tester) async {
    final noteRepo = _FakeNoteRepo();
    final sessionRepo = _FakeSessionRepo();
    final pdfGenerator = _MockPdfGenerator(shouldFail: true);
    final shareService = _MockShareService();

    final testNote = MathNote(
      id: 'n-fail',
      title: 'Fault Note',
      blocks: const [],
      createdAt: DateTime(2026, 10, 13),
      updatedAt: DateTime(2026, 10, 13),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: NoteEditorScreen(
          note: testNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
          pdfGenerator: pdfGenerator,
          shareService: shareService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Share note as PDF'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.textContaining(
        'Failed to share PDF: Exception: PDF engine storage failure',
      ),
      findsOneWidget,
    );
    expect(shareService.sharedNote, isNull);
  });

  testWidgets('Displays loading indicator and disables taps while sharing', (
    tester,
  ) async {
    final noteRepo = _FakeNoteRepo();
    final sessionRepo = _FakeSessionRepo();
    final pdfGenerator = _MockPdfGenerator(
      delay: const Duration(milliseconds: 300),
    );
    final shareService = _MockShareService();

    final testNote = MathNote(
      id: 'n-loading',
      title: 'Loading Test',
      blocks: const [],
      createdAt: DateTime(2026, 10, 13),
      updatedAt: DateTime(2026, 10, 13),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: NoteEditorScreen(
          note: testNote,
          noteRepository: noteRepo,
          sessionRepository: sessionRepo,
          pdfGenerator: pdfGenerator,
          shareService: shareService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shareButton = find.byTooltip('Share note as PDF');
    expect(shareButton, findsOneWidget);

    await tester.tap(shareButton);
    // Pump a single frame without settling to observe in-flight loading state
    await tester.pump();

    // CircularProgressIndicator should be visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Preparing PDF tooltip should be shown
    expect(find.byTooltip('Generating PDF...'), findsOneWidget);

    // Let operation complete
    await tester.pumpAndSettle();

    // Loading indicator disappears and original icon returns
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byTooltip('Share note as PDF'), findsOneWidget);
  });
}
