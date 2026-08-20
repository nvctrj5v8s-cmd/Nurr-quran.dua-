import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran_text_reader_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Quran page loads its bundled surah list', (tester) async {
    SharedPreferences.setMockInitialValues({
      'quran_text_reader_configured': true,
      'quran_reader_theme_configured': true,
      'quran_text_reading_mode': 'interleaved',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuranTextHomePage(
            themeColor: Color(0xFFC79435),
            uiLanguageCode: 'de',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.gpp_bad_outlined), findsNothing);
    expect(find.byType(ListTile), findsWidgets);
  });
}
