import 'package:flutter/material.dart';

/// Centralized color palette for Easy Calculator.
/// Adheres strictly to the PRD specifications.
abstract final class AppColors {
  /// The approved brand primary blue used across both light and dark themes.
  static const Color primaryBlue = Color(0xFF64AFFA);

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);

  /// Slate 600 provides WCAG AAA contrast (>7.0:1) on white backgrounds.
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightOperatorButton = primaryBlue;
  static const Color lightOperatorText = Color(0xFF000000);
  static const Color lightNumberButton = Color(0xFFFFFFFF);

  /// Slate 300 provides clear, visible squircle boundary definition on pure white.
  static const Color lightNumberButtonBorder = Color(0xFFCBD5E1);
  static const Color lightNumberText = Color(0xFF000000);

  /// Scientific function buttons must remain white with black labels in light mode.
  static const Color lightFunctionButton = Color(0xFFFFFFFF);
  static const Color lightFunctionText = Color(0xFF000000);

  /// High-contrast primary accent for light mode text/icons where #64AFFA has poor contrast.
  static const Color lightAccentHighContrast = Color(0xFF0284C7);

  /// Distinguishable disabled icon/text state in light mode.
  static const Color lightDisabled = Color(0xFF94A3B8);

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
  static const Color darkAccentHighContrast = primaryBlue;
  static const Color darkDisabled = Color(0xFF555050);

  // --- General UI ---
  static const Color errorRed = Color(0xFFEF4444);
}
