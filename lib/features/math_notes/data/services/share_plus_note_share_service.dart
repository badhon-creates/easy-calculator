import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/services/note_share_service.dart';

/// Sanitizes note title for safe use in file systems.
/// Replaces whitespace with underscores, removes disallowed characters,
/// and limits length.
String sanitizeNoteFilename(String rawTitle) {
  final trimmed = rawTitle.trim();
  if (trimmed.isEmpty) return 'Math_Note';

  // Replace whitespace with underscores
  var sanitized = trimmed.replaceAll(RegExp(r'\s+'), '_');

  // Strip characters that are not alphanumeric, underscore, or hyphen
  sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');

  if (sanitized.isEmpty) return 'Math_Note';

  // Prevent overly long filenames
  if (sanitized.length > 40) {
    sanitized = sanitized.substring(0, 40);
  }

  return sanitized;
}

/// Concrete implementation of [NoteShareService] using `share_plus`
/// and Android FileProvider content URIs.
class SharePlusNoteShareService implements NoteShareService {
  SharePlusNoteShareService({
    Future<Directory> Function()? getTempDirectory,
    this.shareLauncher,
  }) : _getTempDirectory = getTempDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _getTempDirectory;
  final Future<void> Function(List<XFile>, {String? subject})? shareLauncher;

  @override
  Future<void> shareNotePdf(MathNote note, Uint8List pdfBytes) async {
    final tempDir = await _getTempDirectory();
    final exportsDir = Directory(p.join(tempDir.path, 'math_notes_exports'));

    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    // Safely prune stale temporary export files (> 30 minutes old)
    try {
      final now = DateTime.now();
      final entities = exportsDir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.pdf')) {
          final stat = entity.statSync();
          if (now.difference(stat.modified) > const Duration(minutes: 30)) {
            entity.deleteSync();
          }
        }
      }
    } catch (_) {
      // Non-critical temporary cleanup failure should not prevent sharing
    }

    final sanitizedTitle = sanitizeNoteFilename(note.title);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${sanitizedTitle}_$timestamp.pdf';
    final targetFile = File(p.join(exportsDir.path, filename));

    await targetFile.writeAsBytes(pdfBytes, flush: true);

    final subject = note.title.trim().isNotEmpty
        ? note.title.trim()
        : 'Math Note';

    final xFile = XFile(
      targetFile.path,
      mimeType: 'application/pdf',
      name: filename,
    );

    if (shareLauncher != null) {
      await shareLauncher!([xFile], subject: subject);
    } else {
      await SharePlus.instance.share(
        ShareParams(files: [xFile], subject: subject),
      );
    }
  }
}
