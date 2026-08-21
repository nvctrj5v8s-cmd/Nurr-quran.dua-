import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/spiritual_home_features.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('prayer journey opens and stores a prayer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: PrayerJourneyPage(languageCode: 'de', darkMode: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Mein Gebetsweg'), findsWidgets);
    await tester.tap(find.text('Fajr').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('gebet_0'), isTrue);
  });

  testWidgets('Sunnah page shows sourced daily habits', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SunnahHabitsPage(languageCode: 'de', darkMode: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sunnahs im Alltag'), findsWidgets);
    expect(find.text('Sahih al-Bukhari 5376'), findsOneWidget);
    expect(find.text('Heute umgesetzt'), findsWidgets);
  });
}
