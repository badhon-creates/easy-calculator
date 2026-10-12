import 'package:easy_calculator/features/calculator/domain/models/calculator_session.dart';

/// Contract for persisting and restoring the in-progress calculator session state.
abstract class SessionRepository {
  /// Loads the most recently saved calculator session, or null if no valid session exists.
  Future<CalculatorSession?> loadSession();

  /// Saves the active calculator session state.
  Future<void> saveSession(CalculatorSession session);

  /// Clears persisted session state.
  Future<void> clearSession();
}
