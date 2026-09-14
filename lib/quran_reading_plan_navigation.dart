import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nurr_design.dart';
import 'quran_reading_plan/reading_plan_store.dart';
import 'quran_text_reader_page.dart';
import 'quran_text_repository.dart';

Future<void> openQuranReadingPlanSession(
  BuildContext context, {
  required String languageCode,
  required int page,
  ReadingPlanStore? store,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) =>
        QuranReadingPlanSession(languageCode: languageCode, page: page, store: store),
  ),
);

/// A reading session counts a canonical Quran page only after confirmation.
/// Merely opening the reader or swiping never changes the plan's progress.
class QuranReadingPlanSession extends StatefulWidget {
  final String languageCode;
  final int page;
  final ReadingPlanStore? store;

  const QuranReadingPlanSession({
    super.key,
    required this.languageCode,
    required this.page,
    this.store,
  });

  @override
  State<QuranReadingPlanSession> createState() =>
      _QuranReadingPlanSessionState();
}

class _QuranReadingPlanSessionState extends State<QuranReadingPlanSession> {
  late final ReadingPlanStore _store;
  late Future<_ReaderConfiguration> _configuration;
  late int _page;
  bool _busy = false;
  bool _confirmed = false;
  String? _error;

  String _t(String de, String en, String ar) => switch (widget.languageCode) {
    'ar' => ar,
    'en' => en,
    _ => de,
  };

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? ReadingPlanStore.instance;
    _page = widget.page.clamp(1, 604);
    _configuration = _load();
  }

  Future<_ReaderConfiguration> _load() async {
    await _store.load();
    final data = await QuranTextRepository.instance.load();
    final prefs = await SharedPreferences.getInstance();
    final language = widget.languageCode;
    final highlights = <String, String>{};
    final raw = prefs.getString('quran_text_highlight_colors');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.key is String && entry.value is String) {
              highlights[entry.key as String] = entry.value as String;
            }
          }
        }
      } on FormatException {
        // An invalid optional annotation cannot hide the Quran text.
      }
    } else {
      for (final key
          in prefs.getStringList('quran_text_highlights') ?? <String>[]) {
        highlights[key] = 'gold';
      }
    }
    return _ReaderConfiguration(
      data: data,
      prefs: prefs,
      translationLanguage:
          prefs.getString('quran_translation_language_$language') ??
          (language == 'en' ? 'en' : 'de'),
      preferences: QuranReaderPreferences(
        mode: prefs.getString('quran_text_reading_mode') == 'pairedPages'
            ? QuranReadingMode.pairedPages
            : QuranReadingMode.interleaved,
        showArabic: prefs.getBool('quran_show_arabic_$language') ?? true,
        showTranslation:
            prefs.getBool('quran_show_translation_$language') ??
            language != 'ar',
        arabicFontSize: prefs.getDouble('quran_arabic_font_size') ?? 30,
        translationFontSize:
            prefs.getDouble('quran_translation_font_size') ?? 18,
        verseSpacing: prefs.getDouble('quran_verse_spacing') ?? 18,
        darkMode:
            prefs.getBool('quran_reader_dark_mode') ??
            NurrDesign.darkMode.value,
        showSideBySide: prefs.getBool('quran_show_side_by_side') ?? true,
      ),
      bookmarks: (prefs.getStringList('quran_text_bookmarks') ?? <String>[])
          .toSet(),
      highlights: highlights,
    );
  }

  String get _saveError => _t(
    'Das Speichern hat nicht geklappt. Bitte versuche es erneut.',
    'Could not save. Please try again.',
    'تعذر الحفظ. يرجى المحاولة مرة أخرى.',
  );

  Future<void> _saveAnnotation(Future<bool> operation) async {
    try {
      if (!await operation) throw StateError('Local write failed');
    } catch (_) {
      if (mounted) setState(() => _error = _saveError);
    }
  }

  Future<void> _confirm() async {
    if (_busy || _confirmed) return;
    final plan = _store.plan;
    if (plan == null || plan.paused || plan.nextPage != _page) {
      setState(
        () => _error = _t(
          'Dein Plan hat sich geändert. Öffne die Lesestelle bitte erneut im Plan.',
          'Your plan changed. Please reopen your reading position from the plan.',
          'تغيرت خطتك. افتح موضع القراءة من الخطة مجددًا.',
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _store.completePage(_page);
      if (mounted && _store.plan?.nextPage == _page + 1) {
        setState(() => _confirmed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _error = _saveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_ReaderConfiguration>(
    future: _configuration,
    builder: (context, snapshot) {
      final config = snapshot.data;
      if (config == null) {
        final dark = NurrDesign.darkMode.value;
        return Scaffold(
          backgroundColor: NurrDesign.background(dark),
          appBar: AppBar(
            title: Text(
              _t('Deine Lesezeit', 'Your reading time', 'وقت قراءتك'),
            ),
            backgroundColor: NurrDesign.surface(dark),
            foregroundColor: NurrDesign.text(dark),
          ),
          body: Center(
            child: snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _t(
                            'Der Quran konnte nicht geladen werden.',
                            'The Quran could not be loaded.',
                            'تعذر تحميل القرآن.',
                          ),
                          style: TextStyle(color: NurrDesign.text(dark)),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              setState(() => _configuration = _load()),
                          child: Text(
                            _t('Erneut versuchen', 'Try again', 'حاول مجددًا'),
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: NurrDesign.gold),
          ),
        );
      }
      final dark = config.preferences.darkMode;
      final firstVerse = config.data.verses.firstWhere(
        (verse) => verse.page == _page,
      );
      return Directionality(
        textDirection: widget.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: dark
                ? const ColorScheme.dark(
                    primary: NurrDesign.gold,
                    surface: NurrDesign.darkSurface,
                  )
                : const ColorScheme.light(
                    primary: NurrDesign.goldDark,
                    surface: NurrDesign.paper,
                  ),
          ),
          child: Scaffold(
            backgroundColor: NurrDesign.background(dark),
            body: QuranSurahReaderPage(
              key: ValueKey('plan-reader-$_page'),
              data: config.data,
              surah: config.data.surahs.firstWhere(
                (s) => s.number == firstVerse.surah,
              ),
              initialAyah: firstVerse.ayah,
              readingPlanPage: _page,
              themeColor: NurrDesign.gold,
              uiLanguageCode: widget.languageCode,
              translationLanguage: config.translationLanguage,
              preferences: config.preferences,
              bookmarks: config.bookmarks,
              onBookmarksChanged: (updated) {
                config.bookmarks = updated;
                _saveAnnotation(
                  config.prefs.setStringList(
                    'quran_text_bookmarks',
                    updated.toList(),
                  ),
                );
              },
              highlights: config.highlights,
              onHighlightsChanged: (updated) {
                config.highlights = updated;
                _saveAnnotation(
                  config.prefs.setString(
                    'quran_text_highlight_colors',
                    jsonEncode(updated),
                  ),
                );
              },
            ),
            bottomNavigationBar: _buildFooter(dark),
          ),
        ),
      );
    },
  );

  Widget _buildFooter(bool dark) {
    final plan = _store.plan;
    final todayRead = plan?.pagesReadOn(DateTime.now()) ?? 0;
    final goal = plan?.dailyGoal ?? 1;
    final goalMet = plan?.goalMetOn(DateTime.now()) ?? false;
    final complete = plan?.isComplete ?? false;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Container(
      decoration: BoxDecoration(
        color: NurrDesign.surface(dark),
        border: Border(
          top: BorderSide(color: NurrDesign.gold.withValues(alpha: .22)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: AnimatedSize(
            duration: Duration(milliseconds: reducedMotion ? 0 : 350),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(color: NurrDesign.text(dark)),
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _confirmed
                          ? _t(
                              'Seite $_page geschafft',
                              'Page $_page completed',
                              'أتممت الصفحة $_page',
                            )
                          : _t(
                              'Deine Lesezeit',
                              'Your reading time',
                              'وقت قراءتك',
                            ),
                      style: TextStyle(
                        color: NurrDesign.text(dark),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _t(
                        'Heute $todayRead / $goal',
                        'Today $todayRead / $goal',
                        'اليوم $todayRead / $goal',
                      ),
                      style: TextStyle(color: NurrDesign.secondaryText(dark)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!_confirmed)
                  FilledButton.icon(
                    key: const ValueKey('confirm-plan-page'),
                    onPressed: _busy ? null : _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: NurrDesign.gold,
                      foregroundColor: NurrDesign.ink,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.done_rounded),
                    label: Text(
                      _t(
                        'Seite $_page gelesen',
                        'I have read page $_page',
                        'قرأت الصفحة $_page',
                      ),
                    ),
                  )
                else ...[
                  Text(
                    complete
                        ? _t(
                            'Du hast deinen Leseplan abgeschlossen.',
                            'You have completed your reading plan.',
                            'لقد أكملت خطة القراءة.',
                          )
                        : goalMet
                        ? _t(
                            'Dein Tagesziel ist erreicht. Schön, dass du dir Zeit genommen hast.',
                            'Your daily goal is complete. Thank you for taking this time.',
                            'أتممت هدف اليوم. جميل أنك خصصت وقتًا للقراءة.',
                          )
                        : _t(
                            'Dein Fortschritt ist gespeichert. Weiter mit der nächsten Seite?',
                            'Your progress is saved. Ready for the next page?',
                            'حُفظ تقدمك. هل تتابع إلى الصفحة التالية؟',
                          ),
                    style: TextStyle(
                      color: NurrDesign.secondaryText(dark),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          _t(
                            'Zurück zum Plan',
                            'Back to plan',
                            'العودة إلى الخطة',
                          ),
                        ),
                      ),
                      if (!complete && plan != null)
                        FilledButton.icon(
                          key: const ValueKey('next-plan-page'),
                          style: FilledButton.styleFrom(
                            backgroundColor: NurrDesign.emerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => setState(() {
                            _page = plan.nextPage;
                            _confirmed = false;
                            _error = null;
                          }),
                          icon: const Icon(Icons.menu_book_rounded, size: 20),
                          label: Text(
                            _t('Weiterlesen', 'Keep reading', 'متابعة القراءة'),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderConfiguration {
  final QuranTextData data;
  final SharedPreferences prefs;
  final QuranReaderPreferences preferences;
  final String translationLanguage;
  Set<String> bookmarks;
  Map<String, String> highlights;

  _ReaderConfiguration({
    required this.data,
    required this.prefs,
    required this.preferences,
    required this.translationLanguage,
    required this.bookmarks,
    required this.highlights,
  });
}
