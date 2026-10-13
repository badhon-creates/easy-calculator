import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easy_calculator/features/math_notes/domain/models/note_editing_session.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';

/// Local file-backed implementation of [NoteSessionRepository].
///
/// Persists the active in-progress note draft in app-private storage.
/// Used to restore unsaved edits if the application process is backgrounded or killed.
class LocalNoteSessionRepository implements NoteSessionRepository {
  LocalNoteSessionRepository({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryProvider;
  static const String _fileName = 'easy_calc_note_session.json';
  static const String _tmpFileName = 'easy_calc_note_session.json.tmp';

  Future<File> _getFile() async {
    final dir = await _directoryProvider();
    return File(p.join(dir.path, _fileName));
  }

  Future<File> _getTmpFile() async {
    final dir = await _directoryProvider();
    return File(p.join(dir.path, _tmpFileName));
  }

  @override
  Future<void> saveSession(NoteEditingSession session) async {
    try {
      final jsonString = jsonEncode(session.toJson());
      final tmpFile = await _getTmpFile();
      final targetFile = await _getFile();

      await tmpFile.parent.create(recursive: true);
      await tmpFile.writeAsString(jsonString, flush: true);

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tmpFile.rename(targetFile.path);
    } catch (e) {
      debugPrint('LocalNoteSessionRepository: Error saving draft session: $e');
    }
  }

  @override
  Future<NoteEditingSession?> loadSession() async {
    final file = await _getFile();
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      return NoteEditingSession.fromJson(decoded);
    } catch (e) {
      debugPrint(
        'LocalNoteSessionRepository: Failed to load session, recovering safely: $e',
      );
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('LocalNoteSessionRepository: Error clearing session: $e');
    }
  }
}
