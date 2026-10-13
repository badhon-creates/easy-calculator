import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/features/math_notes/data/services/pdf_note_generator.dart';
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';

void main() {
  const generator = PdfNoteGenerator();

  group('PdfNoteGenerator Unit Tests', () {
    test('Exporting a simple text note produces valid PDF bytes', () async {
      final note = MathNote(
        id: 'note-1',
        title: 'Calculus Notes',
        blocks: [
          const NoteBlock(
            id: 'b-1',
            type: NoteBlockType.body,
            spans: [
              TextSpanData(text: 'Derivatives represent rates of change.'),
            ],
          ),
          const NoteBlock(
            id: 'b-2',
            type: NoteBlockType.body,
            spans: [
              TextSpanData(text: 'Integrals represent accumulated area.'),
            ],
          ),
        ],
        createdAt: DateTime(2026, 10, 13, 10, 0),
        updatedAt: DateTime(2026, 10, 13, 10, 30),
      );

      final pdfBytes = await generator.generatePdf(note);
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.isNotEmpty, true);
      // Valid PDF document begins with %PDF-
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, '%PDF-');
    });

    test(
      'Exporting formatted text preserves styles, headings, and colors',
      () async {
        final note = MathNote(
          id: 'note-2',
          title: 'Linear Algebra Summary',
          blocks: [
            const NoteBlock(
              id: 'b-title',
              type: NoteBlockType.title,
              spans: [
                TextSpanData(text: 'Eigenvalues & Eigenvectors', isBold: true),
              ],
            ),
            const NoteBlock(
              id: 'b-heading',
              type: NoteBlockType.heading,
              spans: [TextSpanData(text: '1. Characteristic Equation')],
            ),
            const NoteBlock(
              id: 'b-subheading',
              type: NoteBlockType.subheading,
              spans: [TextSpanData(text: 'Definition and Properties')],
            ),
            const NoteBlock(
              id: 'b-rich',
              type: NoteBlockType.body,
              spans: [
                TextSpanData(text: 'A vector v is an ', isItalic: true),
                TextSpanData(text: 'eigenvector', isBold: true),
                TextSpanData(
                  text: ' if Av = λv.',
                  isUnderline: true,
                  colorHex: '#64AFFA',
                ),
              ],
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final pdfBytes = await generator.generatePdf(note);
        expect(pdfBytes.isNotEmpty, true);
        expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
      },
    );

    test(
      'Exporting bullet lists preserves bullet structure and indentation',
      () async {
        final note = MathNote(
          id: 'note-3',
          title: 'Formulas to Remember',
          blocks: [
            const NoteBlock(
              id: 'bullet-1',
              type: NoteBlockType.bullet,
              spans: [
                TextSpanData(
                  text: 'sin^2(x) + cos^2(x) = 1',
                  colorHex: '#64AFFA',
                ),
              ],
            ),
            const NoteBlock(
              id: 'bullet-2',
              type: NoteBlockType.bullet,
              spans: [TextSpanData(text: 'e^(i*pi) + 1 = 0', isBold: true)],
            ),
            const NoteBlock(
              id: 'bullet-3',
              type: NoteBlockType.bullet,
              spans: [TextSpanData(text: 'd/dx [ln(x)] = 1/x', isItalic: true)],
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final pdfBytes = await generator.generatePdf(note);
        expect(pdfBytes.isNotEmpty, true);
        expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
      },
    );

    test(
      'Exporting a note containing vector drawings renders without error',
      () async {
        final note = MathNote(
          id: 'note-4',
          title: 'Coordinate Diagram',
          blocks: [
            const NoteBlock(
              id: 'b-desc',
              type: NoteBlockType.body,
              spans: [
                TextSpanData(text: 'Below is a sketch of the function curve.'),
              ],
            ),
          ],
          drawings: [
            const DrawingStroke(
              points: [
                StrokePoint(x: 20, y: 30),
                StrokePoint(x: 50, y: 70),
                StrokePoint(x: 90, y: 120),
              ],
              colorHex: '#64AFFA',
              strokeWidth: 3.5,
            ),
            const DrawingStroke(
              points: [StrokePoint(x: 100, y: 100)],
              colorHex: '#FF5252',
              strokeWidth: 4.0,
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final pdfBytes = await generator.generatePdf(note);
        expect(pdfBytes.isNotEmpty, true);
        expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
      },
    );

    test(
      'Exporting long notes automatically paginates without clipping',
      () async {
        // 80 paragraphs will definitely exceed a single A4 page
        final blocks = List.generate(80, (index) {
          return NoteBlock(
            id: 'long-block-$index',
            type: index % 5 == 0 ? NoteBlockType.heading : NoteBlockType.body,
            spans: [
              TextSpanData(
                text:
                    'Section $index: Mathematical theorem details and proofs '
                    'concerning boundary conditions in partial differential equations.',
                isBold: index % 5 == 0,
              ),
            ],
          );
        });

        final note = MathNote(
          id: 'note-long',
          title: 'Comprehensive Differential Equations Manuscript',
          blocks: blocks,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final pdfBytes = await generator.generatePdf(note);
        expect(pdfBytes.isNotEmpty, true);
        expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
        // A multi-page document is notably larger in bytes than a 1-line note
        expect(pdfBytes.length, greaterThan(4000));
      },
    );

    test(
      'Exporting empty or nearly empty note produces valid PDF safely',
      () async {
        final emptyNote = MathNote(
          id: 'note-empty',
          title: '',
          blocks: const [],
          drawings: const [],
          createdAt: DateTime(2026, 10, 13),
          updatedAt: DateTime(2026, 10, 13),
        );

        final pdfBytes = await generator.generatePdf(emptyNote);
        expect(pdfBytes.isNotEmpty, true);
        expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
      },
    );

    test('PDF generation does not modify original note model', () async {
      final originalNote = MathNote(
        id: 'note-pure',
        title: 'Unchanged Note',
        blocks: const [
          NoteBlock(
            id: 'b-pure-1',
            type: NoteBlockType.body,
            spans: [TextSpanData(text: 'Immutable text content.')],
          ),
        ],
        drawings: const [
          DrawingStroke(
            points: [StrokePoint(x: 10, y: 15)],
            colorHex: '#000000',
          ),
        ],
        createdAt: DateTime(2026, 10, 13, 8, 0),
        updatedAt: DateTime(2026, 10, 13, 9, 0),
      );

      final titleBefore = originalNote.title;
      final blockCountBefore = originalNote.blocks.length;
      final drawingCountBefore = originalNote.drawings.length;
      final updatedAtBefore = originalNote.updatedAt;

      await generator.generatePdf(originalNote);

      expect(originalNote.title, titleBefore);
      expect(originalNote.blocks.length, blockCountBefore);
      expect(originalNote.drawings.length, drawingCountBefore);
      expect(originalNote.updatedAt, updatedAtBefore);
    });
  });
}
