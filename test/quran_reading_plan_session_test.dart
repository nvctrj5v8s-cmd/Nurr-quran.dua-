import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran_reading_plan/reading_plan_store.dart';
import 'package:quran/quran_reading_plan_navigation.dart';
import 'package:quran/quran_text_reader_page.dart';
import 'package:quran/quran_text_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load the real, hash-verified files outside any widget test's fake clock.
  // A Future created by another widget test must not remain cached here.
  setUpAll(() async {
    QuranTextRepository.instance.clearCache();
    await QuranTextRepository.instance.load();
  });

  for (final mode in QuranReadingMode.values) {
    testWidgets('plan preserves ${mode.name} and counts only confirmed pages', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'quran_text_reading_mode': mode.name,
        'quran_translation_language_en': 'en',
        'quran_show_arabic_en': true,
        'quran_show_translation_en': true,
        'quran_reader_dark_mode': false,
      });
      final store = ReadingPlanStore();
      await store.create(dailyGoal: 2, startPage: 2);
      addTearDown(store.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: QuranReadingPlanSession(
            languageCode: 'en',
            page: 2,
            store: store,
          ),
        ),
      );
      // Allow continuations on the real asset-loading future to run before
      // settling Flutter's fake animation clock.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      final reader = tester.widget<QuranSurahReaderPage>(
        find.byType(QuranSurahReaderPage),
      );
      expect(reader.preferences.mode, mode);
      expect(reader.translationLanguage, 'en');
      expect(reader.readingPlanPage, 2);
      expect(store.plan!.completedPages, 0);

      await tester.tap(find.byKey(const ValueKey('confirm-plan-page')));
      await tester.pumpAndSettle();
      expect(store.plan!.completedPages, 1);
      expect(store.plan!.nextPage, 3);
      expect(find.byKey(const ValueKey('confirm-plan-page')), findsNothing);
      expect(find.text('Page 2 completed'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('next-plan-page')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<QuranSurahReaderPage>(find.byType(QuranSurahReaderPage))
            .readingPlanPage,
        3,
      );
      expect(store.plan!.completedPages, 1);

      await tester.tap(find.byKey(const ValueKey('confirm-plan-page')));
      await tester.pumpAndSettle();
      expect(store.plan!.completedPages, 2);
      expect(store.plan!.goalMetOn(DateTime.now()), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('quran_text_reading_mode'), mode.name);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('small Arabic dark reader completes at page 604', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'quran_text_reading_mode': 'pairedPages',
      'quran_reader_dark_mode': true,
    });
    final store = ReadingPlanStore();
    await store.create(dailyGoal: 1, startPage: 604);
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(1.2),
          ),
          child: QuranReadingPlanSession(
            languageCode: 'ar',
            page: 604,
            store: store,
          ),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final reader = tester.widget<QuranSurahReaderPage>(
      find.byType(QuranSurahReaderPage),
    );
    expect(reader.preferences.darkMode, isTrue);
    expect(reader.preferences.showTranslation, isFalse);
    expect(store.plan!.isComplete, isFalse);
    await tester.tap(find.byKey(const ValueKey('confirm-plan-page')));
    await tester.pumpAndSettle();
    expect(store.plan!.isComplete, isTrue);
    expect(find.byKey(const ValueKey('next-plan-page')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
