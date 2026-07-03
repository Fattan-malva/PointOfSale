import 'package:flutter_test/flutter_test.dart';
import 'package:backoffice/app.dart';

void main() {
  testWidgets('Backoffice app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BackofficeApp());
    // Verify the app loads without error
    // Just checking no crash during build
  });
}
