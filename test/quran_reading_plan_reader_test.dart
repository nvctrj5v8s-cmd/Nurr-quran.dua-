import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran_text_reader_page.dart';
import 'package:quran/quran_text_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Test-only placeholders: Quran source text is neither modified nor generated.
QuranSurah fixtureSurah(int number, int count, int Function(int) page) {
  return QuranSurah(
    number: number,
    ayahCount: count,
    arabicName: 'Surah $number Arabic title',
    transliteratedName: 'Surah $number',
    englishName: 'Surah $number',
    revelationType: 'Meccan',
    verses: List.generate(count, (index) {
      final ayah = index + 1;
      final filler = List.filled(
        ayah % 7 + 3,
        'test text of varying length',
      ).join(' ');
      return QuranVerse(
        surah: number,
        ayah: ayah,
        page: page(ayah),
        arabic: 'Arabic $number:$ayah $filler',
        german: 'German $number:$ayah $filler',
        english: 'English $number:$ayah $filler',
      );
    }),
  );
}

Widget reader({
  required QuranTextData data,
  required QuranSurah surah,
  required QuranReadingMode mode,
  int? planPage,
  int? initialAyah,
  bool showArabic = false,
  ValueChanged<Set<String>>? onBookmarksChanged,
}) {
  return MaterialApp(
    home: QuranSurahReaderPage(
      data: data,
      surah: surah,
      initialAyah: initialAyah,
      readingPlanPage: planPage,
      themeColor: const Color(0xFFC79435),
      uiLanguageCode: 'en',
      translationLanguage: 'en',
      preferences: QuranReaderPreferences(mode: mode, showArabic: showArabic),
      bookmarks: const {},
      onBookmarksChanged: onBookmarksChanged ?? (_) {},
      highlights: const {},
      onHighlightsChanged: (_) {},
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final endingSurahs = [
    fixtureSurah(111, 5, (_) => 603),
    fixtureSurah(112, 4, (_) => 604),
    fixtureSurah(113, 5, (_) => 604),
    fixtureSurah(114, 6, (_) => 604),
  ];
  final endingData = QuranTextData(
    surahs: endingSurahs,
    verses: endingSurahs.expand((surah) => surah.verses).toList(),
  );

  testWidgets('plan page includes all three final surahs in paired mode', (
    tester,
  ) async {
    Set<String> bookmarks = {};
    await tester.pumpWidget(
      reader(
        data: endingData,
        surah: endingSurahs[1],
        mode: QuranReadingMode.pairedPages,
        planPage: 604,
        initialAyah: 1,
        onBookmarksChanged: (value) => bookmarks = value,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reading plan · Page 604'), findsOneWidget);
    expect(find.byType(CustomScrollView), findsNothing);
    expect(
      find.textContaining('English 111:', findRichText: true),
      findsNothing,
    );
    for (final surah in endingSurahs.skip(1)) {
      for (final verse in surah.verses) {
        expect(
          find.textContaining('English ${verse.key} ', findRichText: true),
          findsOneWidget,
        );
      }
    }
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(
      find.text(
        'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      ),
      findsNWidgets(3),
    );

    final lastVerse = find.textContaining('English 114:6 ', findRichText: true);
    await tester.ensureVisible(lastVerse);
    await tester.pumpAndSettle();
    await tester.tap(lastVerse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save bookmark'));
    await tester.pumpAndSettle();
    expect(bookmarks, {'114:6'});
    final saved = await SharedPreferences.getInstance();
    expect(saved.getInt('quran_last_surah'), 112);
    expect(saved.getInt('quran_last_ayah'), 1);
    expect(saved.getInt('quran_last_page'), 604);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plan respects interleaved mode across surah boundaries', (
    tester,
  ) async {
    await tester.pumpWidget(
      reader(
        data: endingData,
        surah: endingSurahs[1],
        mode: QuranReadingMode.interleaved,
        planPage: 604,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byKey(const ValueKey('112:1')), findsOneWidget);

    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('113:1')),
      350,
      scrollable: scrollable,
    );
    expect(find.byKey(const ValueKey('113:1')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('114:6')),
      350,
      scrollable: scrollable,
    );
    expect(find.byKey(const ValueKey('114:6')), findsOneWidget);
    expect(find.byKey(const ValueKey('111:5')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long surah opens exact requested verse and earlier verses remain readable',
    (tester) async {
      final surah = fixtureSurah(2, 286, (ayah) => 2 + (ayah - 1) ~/ 8);
      final data = QuranTextData(surahs: [surah], verses: surah.verses);
      await tester.pumpWidget(
        reader(
          data: data,
          surah: surah,
          mode: QuranReadingMode.interleaved,
          initialAyah: 200,
        ),
      );
      await tester.pumpAndSettle();

      final target = find.byKey(const ValueKey('2:200'));
      expect(target, findsOneWidget);
      final targetTop = tester.getTopLeft(target).dy;
      final toolbarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
      expect(targetTop, inInclusiveRange(toolbarBottom, toolbarBottom + 30));
      expect(find.byKey(const ValueKey('2:1')), findsNothing);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 450));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('2:199')).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'paired reader positions both languages at exact requested verse',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final surah = fixtureSurah(2, 24, (ayah) => 2 + (ayah - 1) ~/ 8);
      final data = QuranTextData(surahs: [surah], verses: surah.verses);
      await tester.pumpWidget(
        reader(
          data: data,
          surah: surah,
          mode: QuranReadingMode.pairedPages,
          initialAyah: 13,
          showArabic: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsNothing);
      for (final language in ['Arabic', 'English']) {
        final target = find.textContaining(
          '$language 2:13 ',
          findRichText: true,
        );
        expect(target, findsOneWidget);
        expect(tester.getTopLeft(target).dy, inInclusiveRange(100, 250));
      }
      expect(tester.takeException(), isNull);
    },
  );
}
