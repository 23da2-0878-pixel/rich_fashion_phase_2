import 'package:flutter_test/flutter_test.dart';

import 'package:rich_fashion_phase1/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RichFashionApp());
    expect(find.byType(RichFashionApp), findsOneWidget);
  });
}
