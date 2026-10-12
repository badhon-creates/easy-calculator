import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/main.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

void main() {
  testWidgets('Easy Calculator basic arithmetic UI smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EasyCalculatorApp());
    await tester.pumpAndSettle();

    // Verify initial display is '0'
    expect(find.text('0'), findsWidgets);

    // Verify presence of squircle buttons
    expect(find.byType(SquircleButton), findsWidgets);

    // Perform calculation: 43 + 43 = 86
    await tester.tap(find.widgetWithText(SquircleButton, '4'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '4'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '3'));
    await tester.pumpAndSettle();

    // Tap equals '='
    await tester.tap(find.widgetWithText(SquircleButton, '='));
    await tester.pumpAndSettle();

    // Verify result is '86'
    expect(find.text('86'), findsOneWidget);
    expect(find.text('43 + 43'), findsOneWidget);

    // Post-result rule: Tapping operator '+' continues with '86 +'
    await tester.tap(find.widgetWithText(SquircleButton, '+'));
    await tester.pumpAndSettle();
    expect(find.text('86 + '), findsOneWidget);

    // Tap Clear 'AC' or 'C'
    await tester.tap(find.widgetWithText(SquircleButton, 'C'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('Theme changes dynamically between Light and Dark mode', (
    WidgetTester tester,
  ) async {
    // Test light theme
    await tester.pumpWidget(
      const MaterialApp(themeMode: ThemeMode.light, home: EasyCalculatorApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EasyCalculatorApp), findsOneWidget);

    // Test dark theme
    await tester.pumpWidget(
      const MaterialApp(themeMode: ThemeMode.dark, home: EasyCalculatorApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EasyCalculatorApp), findsOneWidget);
  });
}
