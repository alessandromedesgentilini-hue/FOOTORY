import 'package:flutter_test/flutter_test.dart';
import 'package:footory26/main.dart';

void main() {
  testWidgets('Footory app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const FootoryApp());
    await tester.pump();
    expect(find.text('Footory 26'), findsOneWidget);
  });
}
