import 'dart:typed_data';

import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';

/// Abstract service for sharing a generated PDF via system channels.
abstract class NoteShareService {
  /// Shares [pdfBytes] representing [note] with external applications.
  Future<void> shareNotePdf(MathNote note, Uint8List pdfBytes);
}
