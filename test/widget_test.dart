import 'package:flutter_test/flutter_test.dart';
import 'package:tales_of_jcs/main.dart';

void main() {
  testWidgets('Splash Screen tests', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(TalesOfJCSApp());

    expect(find.text('Tales of JCS'), findsOneWidget);
  });
}
