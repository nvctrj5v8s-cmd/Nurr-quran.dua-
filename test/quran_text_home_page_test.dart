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
      'quran_text_reading_mode': 'pairedPages',
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

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.gpp_bad_outlined), findsNothing);
    expect(find.byType(ListTile), findsWidgets);
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      tester
          .widget<QuranSurahReaderPage>(find.byType(QuranSurahReaderPage))
          .surah
          .number,
      1,
    );

    final readerSwipeArea = find.byWidgetPredicate(
      (widget) =>
          widget is GestureDetector && widget.onHorizontalDragEnd != null,
    );
    for (var swipe = 0; swipe < 5; swipe++) {
      await tester.fling(readerSwipeArea.first, const Offset(-500, 0), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final reader = tester.widget<QuranSurahReaderPage>(
        find.byType(QuranSurahReaderPage),
      );
      if (reader.surah.number == 2) break;
    }

    expect(
      tester
          .widget<QuranSurahReaderPage>(find.byType(QuranSurahReaderPage))
          .surah
          .number,
      2,
    );
  });
}
