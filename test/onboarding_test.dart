import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/nurr_design.dart';
import 'package:quran/nurr_onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding fits a small screen and stores completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    NurrDesign.darkMode.value = false;
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: NurrOnboardingPage(
          languageCode: 'de',
          nextPage: Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(PageView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.text('Überspringen'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 700));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboardingCompleted'), isTrue);
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('replay never changes completion status', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingCompleted': false});
    await tester.pumpWidget(
      const MaterialApp(
        home: NurrOnboardingPage(languageCode: 'de', replay: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.text('Überspringen'));
    await tester.pump(const Duration(milliseconds: 700));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboardingCompleted'), isFalse);
  });
}
