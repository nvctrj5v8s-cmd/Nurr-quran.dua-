import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A reading journey through the canonical 604 Quran pages.
///
/// Pages are confirmed explicitly by the reader; merely opening a page never
/// counts it as read. All collections are immutable snapshots.
@immutable
class ReadingPlan {
  ReadingPlan({
    this.dailyGoal = 1,
    this.startPage = 1,
    int? nextPage,
    this.paused = false,
    Map<String, List<int>> pagesByDay = const {},
  }) : nextPage = nextPage ?? startPage,
       pagesByDay = Map.unmodifiable({
         for (final entry in pagesByDay.entries)
           entry.key: List<int>.unmodifiable(entry.value),
       }) {
    _validate();
  }

  static const int pageCount = 604;

  final int dailyGoal;
  final int startPage;

  /// 605 is the end sentinel and must never be opened in the reader.
  final int nextPage;
  final bool paused;
  final Map<String, List<int>> pagesByDay;

  int get completedPages => nextPage - startPage;
  int get totalPages => pageCount + 1 - startPage;
  int get remainingPages => pageCount + 1 - nextPage;
  bool get isComplete => nextPage == pageCount + 1;
  double get progress => completedPages / totalPages;

  static String dateKey(DateTime date) {
    final local = date.toLocal();
    return _calendarKey(local);
  }

  static String _calendarKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  int pagesReadOn(DateTime date) => pagesByDay[dateKey(date)]?.length ?? 0;

  bool goalMetOn(DateTime date) => pagesReadOn(date) >= dailyGoal;

  /// Consecutive local calendar days with reading, independent of goal changes.
  /// Today's still unfinished day does not break yesterday's streak.
  int streakOn(DateTime date) {
    final local = date.toLocal();
    // UTC is used only for calendar arithmetic, avoiding 23/25-hour DST days.
    var day = DateTime.utc(local.year, local.month, local.day);
    bool hasReading(DateTime value) =>
        pagesByDay[_calendarKey(value)]?.isNotEmpty ?? false;

    if (!hasReading(day)) day = day.subtract(const Duration(days: 1));
    var result = 0;
    while (hasReading(day)) {
      result++;
      day = day.subtract(const Duration(days: 1));
    }
    return result;
  }

  ReadingPlan _copyWith({
    int? dailyGoal,
    int? nextPage,
    bool? paused,
    Map<String, List<int>>? pagesByDay,
  }) => ReadingPlan(
    dailyGoal: dailyGoal ?? this.dailyGoal,
    startPage: startPage,
    nextPage: nextPage ?? this.nextPage,
    paused: paused ?? this.paused,
    pagesByDay: pagesByDay ?? this.pagesByDay,
  );

  void _validate() {
    if (dailyGoal < 1 || dailyGoal > pageCount) {
      throw ArgumentError.value(dailyGoal, 'dailyGoal');
    }
    if (startPage < 1 || startPage > pageCount) {
      throw ArgumentError.value(startPage, 'startPage');
    }
    if (nextPage < startPage || nextPage > pageCount + 1) {
      throw ArgumentError.value(nextPage, 'nextPage');
    }
    final allPages = <int>[];
    for (final entry in pagesByDay.entries) {
      final parsed = DateTime.tryParse(entry.key);
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(entry.key) ||
          parsed == null ||
          parsed.year < 1 ||
          _calendarKey(parsed) != entry.key ||
          entry.value.isEmpty) {
        throw ArgumentError('Invalid reading day: ${entry.key}');
      }
      var previous = startPage - 1;
      for (final page in entry.value) {
        if (page <= previous || page >= nextPage) {
          throw ArgumentError('Invalid page history');
        }
        previous = page;
        allPages.add(page);
      }
    }
    allPages.sort();
    if (allPages.length != completedPages) {
      throw ArgumentError('Incomplete page history');
    }
    for (var i = 0; i < allPages.length; i++) {
      if (allPages[i] != startPage + i) {
        throw ArgumentError('Duplicate or skipped page');
      }
    }
  }

  Map<String, Object> _toJson() => {
    'version': 1,
    'dailyGoal': dailyGoal,
    'startPage': startPage,
    'nextPage': nextPage,
    'paused': paused,
    'pagesByDay': pagesByDay,
  };

  static ReadingPlan? _decode(Object? raw) {
    if (raw is! String) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic> ||
          data['version'] != 1 ||
          data['dailyGoal'] is! int ||
          data['startPage'] is! int ||
          data['nextPage'] is! int ||
          data['paused'] is! bool ||
          data['pagesByDay'] is! Map<String, dynamic>) {
        return null;
      }
      final history = <String, List<int>>{};
      for (final entry
          in (data['pagesByDay'] as Map<String, dynamic>).entries) {
        if (entry.value is! List ||
            !(entry.value as List).every((page) => page is int)) {
          return null;
        }
        history[entry.key] = List<int>.from(entry.value as List);
      }
      return ReadingPlan(
        dailyGoal: data['dailyGoal'] as int,
        startPage: data['startPage'] as int,
        nextPage: data['nextPage'] as int,
        paused: data['paused'] as bool,
        pagesByDay: history,
      );
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}

/// Device-local storage. Writes are serialized, including rapid repeated taps,
/// and listeners see a changed plan only after its save succeeds.
class ReadingPlanStore extends ChangeNotifier {
  ReadingPlanStore({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static final ReadingPlanStore instance = ReadingPlanStore();
  static const String storageKey = 'nurr_quran_reading_plan_v1';

  final DateTime Function() _clock;
  ReadingPlan? _plan;
  bool _loaded = false;
  Future<void> _pending = Future<void>.value();

  ReadingPlan? get plan => _plan;
  bool get loaded => _loaded;

  Future<void> _enqueue(Future<void> Function() action) {
    final operation = _pending.then((_) => action());
    // Keep the queue usable after a failure while propagating that failure to
    // the caller of this operation.
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _plan = ReadingPlan._decode(prefs.get(storageKey));
    _loaded = true;
    notifyListeners();
  }

  Future<void> load() => _enqueue(_ensureLoaded);

  Future<void> _persist(ReadingPlan? value) async {
    final prefs = await SharedPreferences.getInstance();
    bool saved;
    try {
      saved = value == null
          ? await prefs.remove(storageKey)
          : await prefs.setString(storageKey, jsonEncode(value._toJson()));
    } catch (_) {
      // The legacy preferences API updates its in-memory cache before writing.
      // Refresh it if disk/platform persistence fails.
      await _refreshAfterFailure(prefs);
      rethrow;
    }
    if (!saved) {
      await _refreshAfterFailure(prefs);
      throw StateError('The reading plan could not be saved on this device.');
    }
    _plan = value;
    notifyListeners();
  }

  Future<void> _refreshAfterFailure(SharedPreferences prefs) async {
    try {
      await prefs.reload();
    } catch (_) {
      // Preserve the original write error. Our published state remains intact.
    }
  }

  Future<void> create({required int dailyGoal, required int startPage}) =>
      _enqueue(() async {
        await _ensureLoaded();
        await _persist(ReadingPlan(dailyGoal: dailyGoal, startPage: startPage));
      });

  Future<void> setDailyGoal(int dailyGoal) => _enqueue(() async {
    await _ensureLoaded();
    final current = _plan;
    if (current == null || current.dailyGoal == dailyGoal) return;
    await _persist(current._copyWith(dailyGoal: dailyGoal));
  });

  Future<void> setPaused(bool paused) => _enqueue(() async {
    await _ensureLoaded();
    final current = _plan;
    if (current == null || current.paused == paused) return;
    await _persist(current._copyWith(paused: paused));
  });

  Future<void> completePage(int expectedPage) => _enqueue(() async {
    await _ensureLoaded();
    final current = _plan;
    if (current == null ||
        current.paused ||
        current.isComplete ||
        current.nextPage != expectedPage) {
      return;
    }
    final key = ReadingPlan.dateKey(_clock());
    final history = <String, List<int>>{
      ...current.pagesByDay,
      key: [...?current.pagesByDay[key], expectedPage],
    };
    await _persist(
      current._copyWith(nextPage: expectedPage + 1, pagesByDay: history),
    );
  });

  Future<void> undoLastPage() => _enqueue(() async {
    await _ensureLoaded();
    final current = _plan;
    if (current == null || current.completedPages == 0) return;
    final key = ReadingPlan.dateKey(_clock());
    final today = current.pagesByDay[key];
    if (today == null || today.last != current.nextPage - 1) return;
    final history = <String, List<int>>{...current.pagesByDay};
    if (today.length == 1) {
      history.remove(key);
    } else {
      history[key] = today.sublist(0, today.length - 1);
    }
    await _persist(
      current._copyWith(nextPage: current.nextPage - 1, pagesByDay: history),
    );
  });

  Future<void> reset() => _enqueue(() async {
    await _ensureLoaded();
    await _persist(null);
  });
}
