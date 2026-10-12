import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easy_calculator/features/calculator/domain/models/calculator_session.dart';
import 'package:easy_calculator/features/calculator/domain/repositories/session_repository.dart';

/// Implementation of [SessionRepository] using atomic JSON file storage in app-private storage.
class LocalSessionRepository implements SessionRepository {
  LocalSessionRepository({
    Future<Directory> Function()? getDirectory,
    this.fileName = 'easy_calc_session.json',
  }) : _getDirectory = getDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _getDirectory;
  final String fileName;

  Future<File> _getFile() async {
    final dir = await _getDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(dir.path, fileName));
  }

  @override
  Future<CalculatorSession?> loadSession() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return null;
      }

      final rawContent = await file.readAsString();
      if (rawContent.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawContent);
      if (decoded is Map<String, dynamic>) {
        return CalculatorSession.fromJson(decoded);
      }
      return null;
    } catch (e) {
      debugPrint(
        'LocalSessionRepository: Failed to load session, recovering safely: $e',
      );
      return null;
    }
  }

  @override
  Future<void> saveSession(CalculatorSession session) async {
    try {
      final file = await _getFile();
      final tempFile = File('${file.path}.tmp');

      final jsonStr = jsonEncode(session.toJson());
      await tempFile.writeAsString(jsonStr, flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);
    } catch (e) {
      debugPrint('LocalSessionRepository: Failed to save session: $e');
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
      debugPrint('LocalSessionRepository: Failed to clear session: $e');
    }
  }
}
