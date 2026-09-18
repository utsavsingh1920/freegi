import 'package:flutter_test/flutter_test.dart';
import 'package:freegi/main.dart';

void main() {
  testWidgets('Freegi app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FreegiApp());

    expect(find.text('Freegi'), findsOneWidget);
  });
}