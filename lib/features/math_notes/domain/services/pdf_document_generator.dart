import 'dart:typed_data';

import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

/// Abstract service for generating a PDF document representing a [MathNote].
abstract class PdfDocumentGenerator {
  /// Generates a binary PDF representation of [note].
  Future<Uint8List> generatePdf(MathNote note);
}
