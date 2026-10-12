import 'package:flutter_test/flutter_test.dart';
import 'package:easy_calculator/main.dart';

void main() {
  testWidgets('EasyCalculatorApp Phase 0 foundation smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EasyCalculatorApp());

    expect(find.text('Easy Calculator'), findsWidgets);
    expect(find.text('Phase 0 Foundation Verified'), findsOneWidget);
  });
}
