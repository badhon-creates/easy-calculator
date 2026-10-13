import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';

/// Local file-backed implementation of [NoteRepository].
///
/// Stores notes as structured JSON in app-private storage.
/// Employs atomic temp-file writes to ensure crash resilience.
/// Saved notes persist indefinitely until explicitly deleted by the user.
class LocalNoteRepository implements NoteRepository {
  LocalNoteRepository({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryProvider;
  static const String _fileName = 'easy_calc_notes.json';
  static const String _tmpFileName = 'easy_calc_notes.json.tmp';
  static const int _schemaVersion = 1;

  Future<File> _getFile() async {
    final dir = await _directoryProvider();
    return File(p.join(dir.path, _fileName));
  }

  Future<File> _getTmpFile() async {
    final dir = await _directoryProvider();
    return File(p.join(dir.path, _tmpFileName));
  }

  @override
  Future<List<MathNote>> getAllNotes({bool newestFirst = true}) async {
    final file = await _getFile();
    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawNotes = decoded['notes'] as List<dynamic>? ?? [];

      final notes = rawNotes
          .map((item) {
            try {
              return MathNote.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint('LocalNoteRepository: Skipping malformed note: $e');
              return null;
            }
          })
          .whereType<MathNote>()
          .toList();

      _sortNotes(notes, newestFirst: newestFirst);
      return notes;
    } catch (e) {
      debugPrint(
        'LocalNoteRepository: Failed to parse notes, recovering safely: $e',
      );
      return [];
    }
  }

  @override
  Future<MathNote?> getNoteById(String id) async {
    final notes = await getAllNotes();
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveNote(MathNote note) async {
    final currentNotes = await getAllNotes(newestFirst: true);
    final index = currentNotes.indexWhere((n) => n.id == note.id);

    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    if (index >= 0) {
      currentNotes[index] = updatedNote;
    } else {
      currentNotes.insert(0, updatedNote);
    }

    await _writeNotes(currentNotes);
  }

  @override
  Future<void> deleteNotes(List<String> ids) async {
    if (ids.isEmpty) return;
    final idSet = ids.toSet();
    final currentNotes = await getAllNotes();
    final remaining = currentNotes.where((n) => !idSet.contains(n.id)).toList();
    await _writeNotes(remaining);
  }

  @override
  Future<List<MathNote>> searchNotes(
    String query, {
    bool newestFirst = true,
  }) async {
    final allNotes = await getAllNotes(newestFirst: newestFirst);
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return allNotes;
    }

    return allNotes.where((note) {
      final titleMatches = note.title.toLowerCase().contains(cleanQuery);
      final contentMatches = note.plainTextPreview.toLowerCase().contains(
        cleanQuery,
      );
      return titleMatches || contentMatches;
    }).toList();
  }

  Future<void> _writeNotes(List<MathNote> notes) async {
    final payload = {
      'version': _schemaVersion,
      'notes': notes.map((n) => n.toJson()).toList(),
    };

    final jsonString = jsonEncode(payload);
    final tmpFile = await _getTmpFile();
    final targetFile = await _getFile();

    await tmpFile.parent.create(recursive: true);
    await tmpFile.writeAsString(jsonString, flush: true);

    if (await targetFile.exists()) {
      await targetFile.delete();
    }
    await tmpFile.rename(targetFile.path);
  }

  void _sortNotes(List<MathNote> notes, {required bool newestFirst}) {
    notes.sort((a, b) {
      return newestFirst
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.updatedAt.compareTo(b.updatedAt);
    });
  }
}
