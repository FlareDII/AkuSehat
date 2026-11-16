import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Render halaman login AkuSehat', (WidgetTester tester) async {
    await tester.pumpWidget(const AkuSehatApp());
    expect(find.text('AkuSehat'), findsOneWidget);
  });
}
