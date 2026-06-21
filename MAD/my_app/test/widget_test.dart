import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/preference_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Test Student',
      'user_email': 'test@student.com',
    });
    await PreferenceService.init();
  });

  testWidgets('Splash and Login screen render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that Splash elements are displayed
    expect(find.text('EduHub'), findsOneWidget);
    expect(find.text('Online Learning Platform'), findsOneWidget);

    // Let the splash finish its timer
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we are on the login screen
    expect(find.text('Welcome Back to EduHub'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
