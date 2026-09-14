import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran_reading_plan/reading_plan_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime now;
  late ReadingPlanStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 9, 13, 14);
    store = ReadingPlanStore(clock: () => now);
  });

  tearDown(() => store.dispose());

  test('no journey is configured until the user creates one', () async {
    expect(store.loaded, isFalse);
    expect(store.plan, isNull);
    await store.load();
    expect(store.loaded, isTrue);
    expect(store.plan, isNull);

    await store.create(dailyGoal: 1, startPage: 1);
    expect(store.plan!.nextPage, 1);
    expect(store.plan!.completedPages, 0);
    expect(store.plan!.totalPages, 604);
    expect(store.plan!.remainingPages, 604);
    expect(store.plan!.progress, 0);
  });

  test('progress, goal, history and pause survive reopening', () async {
    await store.create(dailyGoal: 2, startPage: 42);
    await store.completePage(42);
    await store.completePage(43);
    await store.setPaused(true);

    final reopened = ReadingPlanStore(clock: () => now);
    addTearDown(reopened.dispose);
    await reopened.load();
    final plan = reopened.plan!;
    expect(plan.startPage, 42);
    expect(plan.nextPage, 44);
    expect(plan.dailyGoal, 2);
    expect(plan.paused, isTrue);
    expect(plan.pagesByDay, {
      '2026-09-13': [42, 43],
    });
    expect(plan.goalMetOn(now), isTrue);
    expect(plan.progress, closeTo(2 / 563, 0.000001));
  });

  test('rapid duplicate taps and skipped pages never earn credit', () async {
    await store.create(dailyGoal: 3, startPage: 1);
    await Future.wait([
      store.completePage(1),
      store.completePage(1),
      store.completePage(3),
      store.completePage(2),
      store.completePage(2),
    ]);
    expect(store.plan!.nextPage, 3);
    expect(store.plan!.pagesReadOn(now), 2);
    expect(store.plan!.pagesByDay, {
      '2026-09-13': [1, 2],
    });
  });

  test('the last canonical page completes the journey exactly once', () async {
    await store.create(dailyGoal: 1, startPage: 603);
    await store.completePage(603);
    expect(store.plan!.isComplete, isFalse);
    expect(store.plan!.progress, 0.5);
    await store.completePage(604);
    await store.completePage(604);
    await store.completePage(605);
    expect(store.plan!.nextPage, 605);
    expect(store.plan!.isComplete, isTrue);
    expect(store.plan!.progress, 1);
    expect(store.plan!.remainingPages, 0);
    expect(store.plan!.completedPages, 2);

    await store.undoLastPage();
    expect(store.plan!.nextPage, 604);
    expect(store.plan!.isComplete, isFalse);
  });

  test('pausing blocks page confirmation without losing progress', () async {
    await store.create(dailyGoal: 1, startPage: 20);
    await store.completePage(20);
    await store.setPaused(true);
    await store.completePage(21);
    expect(store.plan!.nextPage, 21);
    await store.setPaused(false);
    await store.completePage(21);
    expect(store.plan!.nextPage, 22);
    expect(store.plan!.pagesReadOn(now), 2);
  });

  test('each local day starts fresh without missed-day debt', () async {
    await store.create(dailyGoal: 2, startPage: 1);
    await store.completePage(1);
    expect(store.plan!.goalMetOn(now), isFalse);
    now = DateTime(2026, 9, 16, 0, 1);
    expect(store.plan!.pagesReadOn(now), 0);
    expect(store.plan!.nextPage, 2);
    expect(store.plan!.dailyGoal, 2);
    await store.completePage(2);
    await store.completePage(3);
    expect(store.plan!.goalMetOn(now), isTrue);
    expect(store.plan!.pagesByDay, {
      '2026-09-13': [1],
      '2026-09-16': [2, 3],
    });
  });

  test('reading streak allows today to start and breaks after a gap', () async {
    await store.create(dailyGoal: 2, startPage: 1);
    await store.completePage(1);
    expect(store.plan!.streakOn(now), 1);
    now = DateTime(2026, 9, 14, 8);
    expect(store.plan!.streakOn(now), 1);
    await store.completePage(2);
    expect(store.plan!.streakOn(now), 2);
    await store.setDailyGoal(5);
    expect(store.plan!.streakOn(now), 2);
    expect(store.plan!.goalMetOn(now), isFalse);
    now = DateTime(2026, 9, 16, 8);
    expect(store.plan!.streakOn(now), 0);
    await store.completePage(3);
    expect(store.plan!.streakOn(now), 1);
  });

  for (final boundary in [DateTime(2026, 3, 29), DateTime(2026, 10, 25)]) {
    test('calendar streak spans the DST boundary $boundary', () async {
      now = DateTime(boundary.year, boundary.month, boundary.day - 1, 23, 55);
      await store.create(dailyGoal: 1, startPage: 1);
      await store.completePage(1);
      now = DateTime(boundary.year, boundary.month, boundary.day, 23, 55);
      await store.completePage(2);
      now = DateTime(boundary.year, boundary.month, boundary.day + 1, 0, 1);
      await store.completePage(3);
      expect(store.plan!.streakOn(now), 3);
      expect(store.plan!.pagesReadOn(now), 1);
      expect(store.plan!.pagesByDay.length, 3);
    });
  }

  test(
    'undo only changes today and never removes a prior reading day',
    () async {
      await store.create(dailyGoal: 2, startPage: 1);
      await store.completePage(1);
      now = DateTime(2026, 9, 14, 8);
      await store.undoLastPage();
      expect(store.plan!.nextPage, 2);
      await store.completePage(2);
      await store.completePage(3);
      await store.undoLastPage();
      expect(store.plan!.pagesReadOn(now), 1);
      await store.undoLastPage();
      await store.undoLastPage();
      expect(store.plan!.nextPage, 2);
      expect(store.plan!.pagesByDay, {
        '2026-09-13': [1],
      });
    },
  );

  test('reset removes only the plan and persists its removal', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_reader_preference', 'keep me');
    await store.create(dailyGoal: 2, startPage: 1);
    await store.completePage(1);
    await store.reset();
    expect(store.loaded, isTrue);
    expect(store.plan, isNull);
    expect(prefs.containsKey(ReadingPlanStore.storageKey), isFalse);
    expect(prefs.getString('quran_reader_preference'), 'keep me');
    final reopened = ReadingPlanStore();
    addTearDown(reopened.dispose);
    await reopened.load();
    expect(reopened.plan, isNull);
  });

  test(
    'invalid edits keep the existing plan and leave the queue usable',
    () async {
      await store.create(dailyGoal: 1, startPage: 1);
      await expectLater(store.setDailyGoal(0), throwsArgumentError);
      expect(store.plan!.dailyGoal, 1);
      await expectLater(
        store.create(dailyGoal: 1, startPage: 605),
        throwsArgumentError,
      );
      expect(store.plan!.startPage, 1);
      await store.completePage(1);
      expect(store.plan!.nextPage, 2);
    },
  );

  test('snapshots cannot be mutated externally', () {
    final pages = [1];
    final history = {'2026-09-13': pages};
    final plan = ReadingPlan(nextPage: 2, pagesByDay: history);
    pages.add(2);
    history.clear();
    expect(plan.pagesByDay, {
      '2026-09-13': [1],
    });
    expect(() => plan.pagesByDay.clear(), throwsUnsupportedError);
    expect(() => plan.pagesByDay.values.first.add(2), throwsUnsupportedError);
  });

  test(
    'corrupt or inconsistent stored data loads safely as unconfigured',
    () async {
      final valid = <String, Object>{
        'version': 1,
        'dailyGoal': 1,
        'startPage': 1,
        'nextPage': 2,
        'paused': false,
        'pagesByDay': {
          '2026-09-13': [1],
        },
      };
      final invalidValues = <Object>[
        'not json',
        7,
        '[]',
        'null',
        '{}',
        jsonEncode({...valid, 'version': 2}),
        jsonEncode({...valid, 'dailyGoal': 0}),
        jsonEncode({...valid, 'dailyGoal': 605}),
        jsonEncode({...valid, 'startPage': 0}),
        jsonEncode({...valid, 'nextPage': 606}),
        jsonEncode({...valid, 'nextPage': 0}),
        jsonEncode({...valid, 'paused': 'false'}),
        jsonEncode({...valid, 'pagesByDay': <String, Object>{}}),
        jsonEncode({
          ...valid,
          'pagesByDay': {
            '2026-02-30': [1],
          },
        }),
        jsonEncode({
          ...valid,
          'pagesByDay': {'2026-09-13': <int>[]},
        }),
        jsonEncode({
          ...valid,
          'pagesByDay': {
            '2026-09-13': [2],
          },
        }),
        jsonEncode({
          ...valid,
          'pagesByDay': {
            '2026-09-13': ['1'],
          },
        }),
        jsonEncode({
          ...valid,
          'nextPage': 3,
          'pagesByDay': {
            '2026-09-13': [1, 1],
          },
        }),
        jsonEncode({
          ...valid,
          'nextPage': 3,
          'pagesByDay': {
            '2026-09-13': [1],
            '2026-09-14': [1],
          },
        }),
      ];
      for (final raw in invalidValues) {
        SharedPreferences.setMockInitialValues({
          ReadingPlanStore.storageKey: raw,
        });
        final reopened = ReadingPlanStore();
        try {
          await reopened.load();
          expect(reopened.loaded, isTrue, reason: '$raw');
          expect(reopened.plan, isNull, reason: '$raw');
        } finally {
          reopened.dispose();
        }
      }
    },
  );
}
