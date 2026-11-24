import 'package:flutter_test/flutter_test.dart';
import 'package:koki_party/main.dart';

void main() {
  testWidgets('KOKI PARTY starts on the Arabic sign-in screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KokiPartyApp());

    expect(find.text('KOKI PARTY'), findsOneWidget);
    expect(find.text('دخول'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
  });
}
