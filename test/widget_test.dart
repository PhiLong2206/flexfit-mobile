import 'package:flutter_test/flutter_test.dart';
import 'package:flexfit_mobile/app.dart';

void main() {
  testWidgets('Explore screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlexFitApp());

    // Verify that our Explore screen is rendered.
    expect(find.text('FLEXFIT'), findsOneWidget);
  });
}
