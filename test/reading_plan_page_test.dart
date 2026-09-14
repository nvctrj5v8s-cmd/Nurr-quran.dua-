import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/nurr_design.dart';
import 'package:quran/quran_reading_plan/reading_plan_page.dart';
import 'package:quran/quran_reading_plan/reading_plan_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> showPage(
    WidgetTester tester, {
    required ReadingPlanStore store,
    String language = 'de',
    bool dark = false,
    bool reducedMotion = false,
    Widget? child,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reducedMotion,
            textScaler: const TextScaler.linear(1.2),
          ),
          child: child!,
        ),
        home:
            child ??
            QuranReadingPlanPage(
              languageCode: language,
              darkMode: dark,
              store: store,
            ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  }

  Future<void> closePage(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('small animated German setup saves the chosen goal', (
    tester,
  ) async {
    final store = ReadingPlanStore();
    addTearDown(store.dispose);
    await showPage(tester, store: store);
    expect(find.byKey(const ValueKey('reading-plan-setup')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapKey(tester, 'reading-plan-goal-2');
    await tapKey(tester, 'reading-plan-create');
    expect(store.plan!.dailyGoal, 2);
    expect(store.plan!.nextPage, 1);
    expect(store.plan!.completedPages, 0);
    expect(
      find.byKey(const ValueKey('reading-plan-dashboard')),
      findsOneWidget,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ReadingPlanStore.storageKey), isNotNull);

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1400),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
    await closePage(tester);
  });

  testWidgets('small Arabic dark dashboard keeps progress when changing pace', (
    tester,
  ) async {
    final store = ReadingPlanStore();
    addTearDown(store.dispose);
    await store.create(dailyGoal: 2, startPage: 3);
    await store.completePage(3);
    await showPage(
      tester,
      store: store,
      language: 'ar',
      dark: true,
      reducedMotion: true,
    );
    expect(tester.takeException(), isNull);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, NurrDesign.darkBackground);
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('reading-plan-dashboard'))),
      ),
      TextDirection.rtl,
    );

    await tapKey(tester, 'reading-plan-settings');
    await tapKey(tester, 'reading-plan-goal-5');
    expect(store.plan!.dailyGoal, 5);
    expect(store.plan!.nextPage, 4);
    expect(store.plan!.completedPages, 1);

    await tapKey(tester, 'reading-plan-settings');
    await tapKey(tester, 'reading-plan-pause');
    expect(store.plan!.paused, isTrue);
    expect(store.plan!.nextPage, 4);

    await tapKey(tester, 'reading-plan-undo');
    expect(store.plan!.nextPage, 3);
    expect(store.plan!.completedPages, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await closePage(tester);
  });

  testWidgets('completed plan never offers a page beyond 604', (tester) async {
    final store = ReadingPlanStore();
    addTearDown(store.dispose);
    await store.create(dailyGoal: 1, startPage: 604);
    await store.completePage(604);
    await showPage(tester, store: store, language: 'en', reducedMotion: true);
    expect(store.plan!.isComplete, isTrue);
    expect(find.text('Page by page, you made it.'), findsOneWidget);
    expect(find.byKey(const ValueKey('reading-plan-read')), findsNothing);
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await closePage(tester);
  });

  testWidgets('entry card opens plan and removal requires confirmation', (
    tester,
  ) async {
    final store = ReadingPlanStore();
    addTearDown(store.dispose);
    await store.create(dailyGoal: 1, startPage: 1);
    await showPage(
      tester,
      store: store,
      reducedMotion: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QuranReadingPlanCard(
              languageCode: 'de',
              darkMode: false,
              store: store,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tapKey(tester, 'quran-reading-plan-card');
    expect(find.byType(QuranReadingPlanPage), findsOneWidget);
    await tapKey(tester, 'reading-plan-settings');
    await tapKey(tester, 'reading-plan-remove');
    expect(store.plan, isNotNull);
    await tester.tap(find.text('Behalten'));
    await tester.pumpAndSettle();
    expect(store.plan, isNotNull);

    await tapKey(tester, 'reading-plan-settings');
    await tapKey(tester, 'reading-plan-remove');
    await tester.tap(find.text('Entfernen'));
    await tester.pumpAndSettle();
    expect(store.plan, isNull);
    expect(find.byKey(const ValueKey('reading-plan-setup')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closePage(tester);
  });
}
