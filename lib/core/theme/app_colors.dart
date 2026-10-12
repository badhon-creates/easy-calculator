import 'package:flutter/material.dart';

/// Centralized color palette for Easy Calculator.
/// Adheres strictly to the PRD specifications.
abstract final class AppColors {
  /// The approved brand primary blue used across both light and dark themes.
  static const Color primaryBlue = Color(0xFF64AFFA);

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightOperatorButton = primaryBlue;
  static const Color lightOperatorText = Color(0xFF000000);
  static const Color lightNumberButton = Color(0xFFFFFFFF);
  static const Color lightNumberButtonBorder = Color(0xFFE2E8F0);
  static const Color lightNumberText = Color(0xFF000000);
  static const Color lightFunctionButton = Color(0xFFF1F5F9);
  static const Color lightFunctionText = Color(0xFF000000);

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF1F1C1C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkOperatorButton = primaryBlue;
  static const Color darkOperatorText = Color(0xFFFFFFFF);

  /// Dark gray number buttons (distinct from background #1F1C1C and not pure black).
  static const Color darkNumberButton = Color(0xFF2E2B2B);
  static const Color darkNumberButtonBorder = Colors.transparent;
  static const Color darkNumberText = Color(0xFFFFFFFF);
  static const Color darkFunctionButton = Color(0xFF3D3A3A);
  static const Color darkFunctionText = Color(0xFFFFFFFF);

  // --- General UI ---
  static const Color errorRed = Color(0xFFEF4444);
}
