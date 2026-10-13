import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:easy_calculator/features/math_notes/domain/models/drawing_stroke.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_block.dart';
import 'package:easy_calculator/features/math_notes/domain/services/pdf_document_generator.dart';

/// Concrete implementation of [PdfDocumentGenerator] using the `pdf` package.
///
/// Builds a multi-page, vector-sharp PDF document faithfully preserving
/// titles, rich-text blocks (Title, Heading, Subheading, Body, Bullets),
/// inline styling (bold, italic, underline, colors), and freehand drawings.
class PdfNoteGenerator implements PdfDocumentGenerator {
  const PdfNoteGenerator();

  @override
  Future<Uint8List> generatePdf(MathNote note) async {
    final pdf = pw.Document(
      title: note.title.isNotEmpty ? note.title : 'Math Note',
      author: 'Easy Calculator',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36.0),
        header: (pw.Context context) {
          if (context.pageNumber <= 1) {
            return pw.SizedBox();
          }
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              note.title.isNotEmpty ? note.title : 'Math Note',
              style: const pw.TextStyle(
                color: PdfColors.grey600,
                fontSize: 9,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Easy Calculator',
                  style: const pw.TextStyle(
                    color: PdfColors.grey500,
                    fontSize: 9,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          // 1. Note Header: Title, Modification Date, and Divider
          final titleText = note.title.trim().isNotEmpty
              ? note.title.trim()
              : 'Untitled Note';

          widgets.add(
            pw.Text(
              titleText,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1F1C1C'),
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 4));

          final dateStr = DateFormat('MMMM d, yyyy | h:mm a')
              .format(note.updatedAt);
          widgets.add(
            pw.Text(
              'Last modified: $dateStr',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          );
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Divider(thickness: 0.8, color: PdfColors.grey300));
          widgets.add(pw.SizedBox(height: 12));

          // 2. Note Blocks
          if (note.blocks.isEmpty && note.drawings.isEmpty) {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 24),
                child: pw.Text(
                  'This note is empty.',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            );
          } else {
            for (final block in note.blocks) {
              widgets.add(_buildBlockWidget(block));
            }
          }

          // 3. Freehand Drawings
          if (note.drawings.isNotEmpty) {
            final drawingWidget = _buildDrawingsWidget(note.drawings);
            if (drawingWidget != null) {
              widgets.add(pw.SizedBox(height: 16));
              widgets.add(
                pw.Text(
                  'Drawings',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              );
              widgets.add(pw.SizedBox(height: 6));
              widgets.add(drawingWidget);
            }
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildBlockWidget(NoteBlock block) {
    if (block.plainText.trim().isEmpty && block.type != NoteBlockType.bullet) {
      return pw.SizedBox(height: 8);
    }

    double fontSize = 11.0;
    pw.FontWeight defaultWeight = pw.FontWeight.normal;
    double bottomMargin = 4.0;
    double topMargin = 0.0;

    switch (block.type) {
      case NoteBlockType.title:
        fontSize = 18.0;
        defaultWeight = pw.FontWeight.bold;
        bottomMargin = 6.0;
        topMargin = 4.0;
      case NoteBlockType.heading:
        fontSize = 15.0;
        defaultWeight = pw.FontWeight.bold;
        bottomMargin = 5.0;
        topMargin = 4.0;
      case NoteBlockType.subheading:
        fontSize = 13.0;
        defaultWeight = pw.FontWeight.bold;
        bottomMargin = 4.0;
        topMargin = 2.0;
      case NoteBlockType.body:
        fontSize = 11.0;
        defaultWeight = pw.FontWeight.normal;
        bottomMargin = 4.0;
      case NoteBlockType.bullet:
        fontSize = 11.0;
        defaultWeight = pw.FontWeight.normal;
        bottomMargin = 3.0;
    }

    final defaultTextColor = PdfColor.fromHex('#1F1C1C');

    pw.Widget contentWidget;
    if (block.spans.isNotEmpty) {
      contentWidget = pw.RichText(
        text: pw.TextSpan(
          children: block.spans.map((span) {
            final spanWeight = span.isBold ? pw.FontWeight.bold : defaultWeight;
            final spanStyle = span.isItalic
                ? pw.FontStyle.italic
                : pw.FontStyle.normal;
            final isUnderline = span.isUnderline;
            final color = _parsePdfColor(span.colorHex, defaultTextColor);

            return pw.TextSpan(
              text: span.text,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: spanWeight,
                fontStyle: spanStyle,
                decoration: isUnderline ? pw.TextDecoration.underline : null,
                color: color,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      contentWidget = pw.Text(
        block.plainText,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: defaultWeight,
          color: defaultTextColor,
        ),
      );
    }

    if (block.type == NoteBlockType.bullet) {
      final bulletColor = block.spans.isNotEmpty
          ? _parsePdfColor(block.spans.first.colorHex, defaultTextColor)
          : defaultTextColor;

      return pw.Padding(
        padding: pw.EdgeInsets.only(
          top: topMargin,
          bottom: bottomMargin,
          left: 10,
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 4.5,
              height: 4.5,
              margin: const pw.EdgeInsets.only(top: 4.5, right: 8),
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: bulletColor,
              ),
            ),
            pw.Expanded(child: contentWidget),
          ],
        ),
      );
    }

    if (topMargin > 0 || bottomMargin > 0) {
      return pw.Padding(
        padding: pw.EdgeInsets.only(top: topMargin, bottom: bottomMargin),
        child: contentWidget,
      );
    }

    return contentWidget;
  }

  pw.Widget? _buildDrawingsWidget(List<DrawingStroke> drawings) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    int pointCount = 0;

    for (final stroke in drawings) {
      for (final p in stroke.points) {
        pointCount++;
        if (p.x < minX) minX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.x > maxX) maxX = p.x;
        if (p.y > maxY) maxY = p.y;
      }
    }

    if (pointCount == 0 || minX == double.infinity) {
      return null;
    }

    // Add padding around bounding box
    const padding = 12.0;
    minX -= padding;
    minY -= padding;
    maxX += padding;
    maxY += padding;

    final boxWidth = maxX - minX;
    final boxHeight = maxY - minY;

    if (boxWidth <= 0 || boxHeight <= 0) return null;

    // Available printable width on A4 with 36pt margins: 595.28 - 72 = 523.28 pt
    const maxAllowedWidth = 500.0;
    const maxAllowedHeight = 650.0;

    double scale = 1.0;
    if (boxWidth > maxAllowedWidth) {
      scale = maxAllowedWidth / boxWidth;
    }
    if (boxHeight * scale > maxAllowedHeight) {
      scale = maxAllowedHeight / boxHeight;
    }

    final renderWidth = boxWidth * scale;
    final renderHeight = boxHeight * scale;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: PdfColors.white,
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.CustomPaint(
        size: PdfPoint(renderWidth, renderHeight),
        painter: (PdfGraphics canvas, PdfPoint size) {
          for (final stroke in drawings) {
            if (stroke.points.isEmpty) continue;
            final color = _parsePdfColor(stroke.colorHex, PdfColors.blue);
            canvas.setColor(color);
            canvas.setLineWidth(stroke.strokeWidth * scale);
            canvas.setLineCap(PdfLineCap.round);
            canvas.setLineJoin(PdfLineJoin.round);

            if (stroke.points.length == 1) {
              final p = stroke.points.first;
              final px = (p.x - minX) * scale;
              final py = size.y - ((p.y - minY) * scale);
              canvas.drawEllipse(
                px,
                py,
                (stroke.strokeWidth * scale) / 2,
                (stroke.strokeWidth * scale) / 2,
              );
              canvas.fillPath();
              continue;
            }

            bool isFirst = true;
            for (final p in stroke.points) {
              final px = (p.x - minX) * scale;
              final py = size.y - ((p.y - minY) * scale);
              if (isFirst) {
                canvas.moveTo(px, py);
                isFirst = false;
              } else {
                canvas.lineTo(px, py);
              }
            }
            canvas.strokePath();
          }
        },
      ),
    );
  }

  PdfColor _parsePdfColor(
    String? hex, [
    PdfColor fallback = const PdfColor(0.12, 0.11, 0.11),
  ]) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return PdfColor.fromHex('#$clean');
      } else if (clean.length == 8) {
        final val = int.parse(clean, radix: 16);
        return PdfColor.fromInt(val);
      }
      return PdfColor.fromHex(hex.startsWith('#') ? hex : '#$hex');
    } catch (_) {
      return fallback;
    }
  }
}
