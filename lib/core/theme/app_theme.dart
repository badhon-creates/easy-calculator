import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_colors.dart';

/// Semantic color tokens for calculator components across themes.
@immutable
class CalculatorColors extends ThemeExtension<CalculatorColors> {
  const CalculatorColors({
    required this.backgroundColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.operatorButton,
    required this.operatorText,
    required this.numberButton,
    required this.numberButtonBorder,
    required this.numberText,
    required this.functionButton,
    required this.functionText,
    required this.errorColor,
    required this.accentHighContrast,
    required this.disabledColor,
  });

  final Color backgroundColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color operatorButton;
  final Color operatorText;
  final Color numberButton;
  final Color numberButtonBorder;
  final Color numberText;
  final Color functionButton;
  final Color functionText;
  final Color errorColor;
  final Color accentHighContrast;
  final Color disabledColor;

  static const CalculatorColors light = CalculatorColors(
    backgroundColor: AppColors.lightBackground,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    operatorButton: AppColors.lightOperatorButton,
    operatorText: AppColors.lightOperatorText,
    numberButton: AppColors.lightNumberButton,
    numberButtonBorder: AppColors.lightNumberButtonBorder,
    numberText: AppColors.lightNumberText,
    functionButton: AppColors.lightFunctionButton,
    functionText: AppColors.lightFunctionText,
    errorColor: AppColors.errorRed,
    accentHighContrast: AppColors.lightAccentHighContrast,
    disabledColor: AppColors.lightDisabled,
  );

  static const CalculatorColors dark = CalculatorColors(
    backgroundColor: AppColors.darkBackground,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    operatorButton: AppColors.darkOperatorButton,
    operatorText: AppColors.darkOperatorText,
    numberButton: AppColors.darkNumberButton,
    numberButtonBorder: AppColors.darkNumberButtonBorder,
    numberText: AppColors.darkNumberText,
    functionButton: AppColors.darkFunctionButton,
    functionText: AppColors.darkFunctionText,
    errorColor: AppColors.errorRed,
    accentHighContrast: AppColors.darkAccentHighContrast,
    disabledColor: AppColors.darkDisabled,
  );

  @override
  CalculatorColors copyWith({
    Color? backgroundColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? operatorButton,
    Color? operatorText,
    Color? numberButton,
    Color? numberButtonBorder,
    Color? numberText,
    Color? functionButton,
    Color? functionText,
    Color? errorColor,
    Color? accentHighContrast,
    Color? disabledColor,
  }) {
    return CalculatorColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      operatorButton: operatorButton ?? this.operatorButton,
      operatorText: operatorText ?? this.operatorText,
      numberButton: numberButton ?? this.numberButton,
      numberButtonBorder: numberButtonBorder ?? this.numberButtonBorder,
      numberText: numberText ?? this.numberText,
      functionButton: functionButton ?? this.functionButton,
      functionText: functionText ?? this.functionText,
      errorColor: errorColor ?? this.errorColor,
      accentHighContrast: accentHighContrast ?? this.accentHighContrast,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  CalculatorColors lerp(ThemeExtension<CalculatorColors>? other, double t) {
    if (other is! CalculatorColors) return this;
    return CalculatorColors(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      operatorButton: Color.lerp(operatorButton, other.operatorButton, t)!,
      operatorText: Color.lerp(operatorText, other.operatorText, t)!,
      numberButton: Color.lerp(numberButton, other.numberButton, t)!,
      numberButtonBorder: Color.lerp(
        numberButtonBorder,
        other.numberButtonBorder,
        t,
      )!,
      numberText: Color.lerp(numberText, other.numberText, t)!,
      functionButton: Color.lerp(functionButton, other.functionButton, t)!,
      functionText: Color.lerp(functionText, other.functionText, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      accentHighContrast: Color.lerp(
        accentHighContrast,
        other.accentHighContrast,
        t,
      )!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
    );
  }
}

/// Convenience extension to access [CalculatorColors] from [BuildContext].
extension CalculatorThemeX on BuildContext {
  CalculatorColors get calcColors =>
      Theme.of(this).extension<CalculatorColors>() ?? CalculatorColors.dark;
}

/// AppTheme configuration for Easy Calculator.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        surface: AppColors.lightBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extensions: const [CalculatorColors.light],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
        surface: AppColors.darkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extensions: const [CalculatorColors.dark],
    );
  }
}
