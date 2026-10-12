import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/main.dart';
import 'package:easy_calculator/shared/widgets/squircle_button.dart';

void main() {
  testWidgets('Scientific Calculator mode switching and calculation UI test', (
    WidgetTester tester,
  ) async {
    // Set a phone-like viewport matching Pixel 7 aspect ratio
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const EasyCalculatorApp());
    await tester.pumpAndSettle();

    // Verify initial Basic Calculator mode
    expect(find.widgetWithText(SquircleButton, '7'), findsOneWidget);
    expect(find.widgetWithText(SquircleButton, 'sin'), findsNothing);

    // Open mode menu at top-right
    final modeMenuBtn = find.byTooltip('Select mode');
    expect(modeMenuBtn, findsOneWidget);
    await tester.tap(modeMenuBtn);
    await tester.pumpAndSettle();

    // Select Scientific mode
    final scientificItem = find.text('Scientific');
    expect(scientificItem, findsOneWidget);
    await tester.tap(scientificItem);
    await tester.pumpAndSettle();

    // Verify scientific controls are revealed
    expect(find.widgetWithText(SquircleButton, 'sin'), findsOneWidget);
    expect(find.widgetWithText(SquircleButton, 'cos'), findsOneWidget);
    expect(find.widgetWithText(SquircleButton, 'tan'), findsOneWidget);
    expect(find.text('DEG'), findsWidgets);
    expect(find.widgetWithText(SquircleButton, '2nd'), findsOneWidget);
    expect(find.widgetWithText(SquircleButton, 'π'), findsOneWidget);

    // Toggle 2nd functions
    final secondBtn = find.widgetWithText(SquircleButton, '2nd');
    await tester.tap(secondBtn);
    await tester.pumpAndSettle();

    // Verify secondary labels are shown
    expect(find.widgetWithText(SquircleButton, 'sin⁻¹'), findsOneWidget);
    expect(find.widgetWithText(SquircleButton, 'cos⁻¹'), findsOneWidget);
    expect(find.widgetWithText(SquircleButton, 'tan⁻¹'), findsOneWidget);

    // Toggle 2nd back off
    await tester.tap(secondBtn);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SquircleButton, 'sin'), findsOneWidget);

    // Perform calculation: sin(30) = 0.5
    await tester.tap(find.widgetWithText(SquircleButton, 'sin'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, ')'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquircleButton, '='));
    await tester.pumpAndSettle();

    expect(find.text('0.5'), findsOneWidget);

    // Switch back to Basic mode and ensure result is preserved
    await tester.tap(find.byTooltip('Select mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Basic'));
    await tester.pumpAndSettle();

    // Verify scientific controls collapsed and result 0.5 is preserved
    expect(find.widgetWithText(SquircleButton, 'sin'), findsNothing);
    expect(find.text('0.5'), findsOneWidget);
  });
}
