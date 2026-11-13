import 'package:flutter_test/flutter_test.dart';
import 'package:shopmate/main.dart';

void main() {
  testWidgets('ShopMate app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopMateApp());

    expect(find.text('ShopMate'), findsOneWidget);
  });
}
