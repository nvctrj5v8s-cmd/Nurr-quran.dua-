import 'package:flutter_test/flutter_test.dart';
import 'package:quran/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app opens the current main page', (tester) async {
    SharedPreferences.setMockInitialValues({
      'app_language': 'de',
      'nurr_onboarding_seen_v2': true,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MainPage), findsOneWidget);
  });
}
