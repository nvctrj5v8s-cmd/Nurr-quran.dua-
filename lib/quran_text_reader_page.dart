import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quran_text_repository.dart';
import 'nurr_design.dart';

enum QuranReadingMode { interleaved, pairedPages }

class _QuranHighlightOption {
  final String id;
  final Color color;
  final String germanName;
  final String englishName;

  const _QuranHighlightOption(
    this.id,
    this.color,
    this.germanName,
    this.englishName,
  );

  static const gold = _QuranHighlightOption(
    'gold',
    Color(0xFFE7B84B),
    'Gold',
    'Gold',
  );

  static const options = <_QuranHighlightOption>[
    gold,
    _QuranHighlightOption(
      'sage',
      Color(0xFF88A879),
      'Salbeigrün',
      'Sage green',
    ),
    _QuranHighlightOption('sky', Color(0xFF7BA7C9), 'Himmelblau', 'Sky blue'),
    _QuranHighlightOption('rose', Color(0xFFC9828D), 'Rosé', 'Rose'),
    _QuranHighlightOption(
      'lavender',
      Color(0xFF9A8BC1),
      'Lavendel',
      'Lavender',
    ),
  ];
}

class QuranReaderPreferences {
  final QuranReadingMode mode;
  final bool showArabic;
  final bool showTranslation;
  final double arabicFontSize;
  final double translationFontSize;
  final double verseSpacing;
  final bool darkMode;
  final bool showSideBySide;

  const QuranReaderPreferences({
    this.mode = QuranReadingMode.interleaved,
    this.showArabic = true,
    this.showTranslation = true,
    this.arabicFontSize = 30,
    this.translationFontSize = 18,
    this.verseSpacing = 18,
    this.darkMode = false,
    this.showSideBySide = true,
  });

  QuranReaderPreferences copyWith({
    QuranReadingMode? mode,
    bool? showArabic,
    bool? showTranslation,
    double? arabicFontSize,
    double? translationFontSize,
    double? verseSpacing,
    bool? darkMode,
    bool? showSideBySide,
  }) {
    return QuranReaderPreferences(
      mode: mode ?? this.mode,
      showArabic: showArabic ?? this.showArabic,
      showTranslation: showTranslation ?? this.showTranslation,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      verseSpacing: verseSpacing ?? this.verseSpacing,
      darkMode: darkMode ?? this.darkMode,
      showSideBySide: showSideBySide ?? this.showSideBySide,
    );
  }
}

class QuranTextHomePage extends StatefulWidget {
  final Color themeColor;
  final String uiLanguageCode;
  final int resumeRequest;

  const QuranTextHomePage({
    super.key,
    required this.themeColor,
    required this.uiLanguageCode,
    this.resumeRequest = 0,
  });

  @override
  State<QuranTextHomePage> createState() => _QuranTextHomePageState();
}

class _QuranTextHomePageState extends State<QuranTextHomePage> {
  late Future<QuranTextData> _dataFuture;
  late Future<void> _preferencesFuture;
  QuranReaderPreferences _preferences = const QuranReaderPreferences();
  Set<String> _bookmarks = {};
  Map<String, String> _highlights = {};
  String _translationLanguage = 'de';
  bool _showFirstChoice = false;
  int _handledResumeRequest = 0;

  bool get _isArabicUi => widget.uiLanguageCode == 'ar';
  bool get _isEnglishUi => widget.uiLanguageCode == 'en';

  @override
  void initState() {
    super.initState();
    _translationLanguage = _isEnglishUi ? 'en' : 'de';
    _dataFuture = QuranTextRepository.instance.load();
    _preferencesFuture = _loadPreferences();
  }

  void _retryLoading() {
    QuranTextRepository.instance.clearCache();
    setState(() {
      _dataFuture = QuranTextRepository.instance.load();
    });
  }

  @override
  void didUpdateWidget(covariant QuranTextHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uiLanguageCode != widget.uiLanguageCode) {
      _translationLanguage = _isEnglishUi ? 'en' : 'de';
      _preferencesFuture = _loadPreferences();
    }
    if (oldWidget.resumeRequest != widget.resumeRequest) {
      _handledResumeRequest = 0;
    }
  }

  Future<void> _resumeLastRead([QuranTextData? loadedData]) async {
    final prefs = await SharedPreferences.getInstance();
    final surahNumber = prefs.getInt('quran_last_surah') ?? 1;
    final ayah = prefs.getInt('quran_last_ayah') ?? 1;
    final data = loadedData ?? await _dataFuture;
    if (!mounted) return;
    final surah = data.surahs.firstWhere(
      (item) => item.number == surahNumber,
      orElse: () => data.surahs.first,
    );
    _openSurah(surah, data: data, initialAyah: ayah.clamp(1, surah.ayahCount));
  }

  String _t(String de, String en, String ar) {
    if (_isArabicUi) return ar;
    if (_isEnglishUi) return en;
    return de;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString('quran_text_reading_mode');
    final bookmarksRaw = prefs.getStringList('quran_text_bookmarks') ?? [];
    final savedHighlightColors = prefs.getString('quran_text_highlight_colors');
    final legacyHighlights = prefs.getStringList('quran_text_highlights') ?? [];
    final highlights = <String, String>{};
    if (savedHighlightColors != null) {
      try {
        final decoded = jsonDecode(savedHighlightColors);
        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (key is String && value is String) highlights[key] = value;
          });
        }
      } on FormatException {
        // A damaged local setting must never prevent the Quran from opening.
      }
    } else {
      for (final key in legacyHighlights) {
        highlights[key] = _QuranHighlightOption.gold.id;
      }
    }
    if (!mounted) return;
    setState(() {
      _translationLanguage =
          prefs.getString(
            'quran_translation_language_${widget.uiLanguageCode}',
          ) ??
          (_isEnglishUi ? 'en' : 'de');
      _preferences = QuranReaderPreferences(
        mode: modeName == QuranReadingMode.pairedPages.name
            ? QuranReadingMode.pairedPages
            : QuranReadingMode.interleaved,
        showArabic:
            prefs.getBool('quran_show_arabic_${widget.uiLanguageCode}') ?? true,
        showTranslation:
            prefs.getBool('quran_show_translation_${widget.uiLanguageCode}') ??
            !_isArabicUi,
        arabicFontSize: prefs.getDouble('quran_arabic_font_size') ?? 30,
        translationFontSize:
            prefs.getDouble('quran_translation_font_size') ?? 18,
        verseSpacing: prefs.getDouble('quran_verse_spacing') ?? 18,
        darkMode:
            prefs.getBool('quran_reader_dark_mode') ??
            NurrDesign.darkMode.value,
        showSideBySide: prefs.getBool('quran_show_side_by_side') ?? true,
      );
      _bookmarks = bookmarksRaw.toSet();
      _highlights = highlights;
      _showFirstChoice =
          !prefs.containsKey('quran_text_reader_configured') ||
          !prefs.containsKey('quran_reader_theme_configured');
    });
    if (_showFirstChoice) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showModeChooser(true),
      );
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_text_reading_mode', _preferences.mode.name);
    await prefs.setBool(
      'quran_show_arabic_${widget.uiLanguageCode}',
      _preferences.showArabic,
    );
    await prefs.setBool(
      'quran_show_translation_${widget.uiLanguageCode}',
      _preferences.showTranslation,
    );
    await prefs.setDouble(
      'quran_arabic_font_size',
      _preferences.arabicFontSize,
    );
    await prefs.setDouble(
      'quran_translation_font_size',
      _preferences.translationFontSize,
    );
    await prefs.setDouble('quran_verse_spacing', _preferences.verseSpacing);
    await prefs.setBool('quran_reader_dark_mode', _preferences.darkMode);
    await prefs.setBool('quran_show_side_by_side', _preferences.showSideBySide);
    await prefs.setBool('quran_reader_theme_configured', true);
    await prefs.setString(
      'quran_translation_language_${widget.uiLanguageCode}',
      _translationLanguage,
    );
    await prefs.setBool('quran_text_reader_configured', true);
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = _bookmarks.toList()..sort(_compareVerseKeys);
    await prefs.setStringList('quran_text_bookmarks', sorted);
  }

  Future<void> _saveHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'quran_text_highlight_colors',
      jsonEncode(_highlights),
    );
  }

  int _compareVerseKeys(String a, String b) {
    final ap = a.split(':').map(int.parse).toList();
    final bp = b.split(':').map(int.parse).toList();
    final surahCompare = ap[0].compareTo(bp[0]);
    return surahCompare != 0 ? surahCompare : ap[1].compareTo(bp[1]);
  }

  Future<void> _showModeChooser(bool firstTime) async {
    var selected = _preferences.mode;
    var darkMode = _preferences.darkMode;
    await showDialog<void>(
      context: context,
      barrierDismissible: !firstTime,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: NurrDesign.surface(darkMode),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: NurrDesign.text(darkMode),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: NurrDesign.text(darkMode)),
          title: Text(
            _t(
              'Wie möchtest du lesen?',
              'How would you like to read?',
              'كيف تريد أن تقرأ؟',
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<QuranReadingMode>(
                value: QuranReadingMode.interleaved,
                groupValue: selected,
                activeColor: widget.themeColor,
                title: Text(
                  _t(
                    'Arabisch mit Übersetzung',
                    'Arabic with translation',
                    'العربية مع الترجمة',
                  ),
                ),
                subtitle: Text(
                  _t(
                    'Übersetzung direkt unter jedem Vers',
                    'Translation directly below each verse',
                    'الترجمة تحت كل آية مباشرة',
                  ),
                ),
                onChanged: (value) => setDialogState(() => selected = value!),
              ),
              const Divider(),
              Text(
                _t('Darstellung', 'Appearance', 'المظهر'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(_t('Hell', 'Light', 'فاتح')),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(_t('Dunkel', 'Dark', 'داكن')),
                  ),
                ],
                selected: {darkMode},
                onSelectionChanged: (value) =>
                    setDialogState(() => darkMode = value.first),
              ),
              RadioListTile<QuranReadingMode>(
                value: QuranReadingMode.pairedPages,
                groupValue: selected,
                activeColor: widget.themeColor,
                title: Text(
                  _t('Getrennte Seiten', 'Separate pages', 'صفحات منفصلة'),
                ),
                subtitle: Text(
                  _t(
                    'Arabische und übersetzte Seite getrennt',
                    'Arabic and translated pages separately',
                    'صفحة عربية وصفحة ترجمة منفصلة',
                  ),
                ),
                onChanged: (value) => setDialogState(() => selected = value!),
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: widget.themeColor),
              onPressed: () {
                setState(
                  () => _preferences = _preferences.copyWith(
                    mode: selected,
                    darkMode: darkMode,
                  ),
                );
                _savePreferences();
                Navigator.pop(context);
              },
              child: Text(_t('Speichern', 'Save', 'حفظ')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDisplaySettings() async {
    var draft = _preferences;
    var language = _translationLanguage;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void update(QuranReaderPreferences value) {
            setSheetState(() => draft = value);
          }

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: draft.darkMode
                  ? const ColorScheme.dark(
                      primary: NurrDesign.gold,
                      surface: NurrDesign.darkSurface,
                    )
                  : const ColorScheme.light(
                      primary: NurrDesign.goldDark,
                      surface: NurrDesign.paper,
                    ),
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: NurrDesign.text(draft.darkMode),
                displayColor: NurrDesign.text(draft.darkMode),
              ),
            ),
            child: Material(
              color: NurrDesign.surface(draft.darkMode),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('Quran-Anzeige', 'Quran display', 'عرض القرآن'),
                        style: TextStyle(
                          color: widget.themeColor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<QuranReadingMode>(
                        segments: [
                          ButtonSegment(
                            value: QuranReadingMode.interleaved,
                            label: Text(_t('Versweise', 'Verses', 'الآيات')),
                          ),
                          ButtonSegment(
                            value: QuranReadingMode.pairedPages,
                            label: Text(_t('Seiten', 'Pages', 'الصفحات')),
                          ),
                        ],
                        selected: {draft.mode},
                        onSelectionChanged: (value) =>
                            update(draft.copyWith(mode: value.first)),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: widget.themeColor,
                        secondary: const Icon(Icons.view_week_outlined),
                        title: Text(
                          _t(
                            'Zwei Seiten nebeneinander',
                            'Two pages side by side',
                            'صفحتان جنبًا إلى جنب',
                          ),
                        ),
                        subtitle: Text(
                          _t(
                            'Für iPad, Tablet und PC',
                            'For iPad, tablet and PC',
                            'للآيباد والجهاز اللوحي والكمبيوتر',
                          ),
                        ),
                        value: draft.showSideBySide,
                        onChanged: draft.mode == QuranReadingMode.pairedPages
                            ? (value) =>
                                  update(draft.copyWith(showSideBySide: value))
                            : null,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: widget.themeColor,
                        title: Text(
                          _t('Arabischer Text', 'Arabic text', 'النص العربي'),
                        ),
                        value: draft.showArabic,
                        onChanged: (value) {
                          if (!value && !draft.showTranslation) return;
                          update(draft.copyWith(showArabic: value));
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: widget.themeColor,
                        title: Text(
                          _t('Übersetzung', 'Translation', 'الترجمة'),
                        ),
                        value: draft.showTranslation,
                        onChanged: (value) {
                          if (!value && !draft.showArabic) return;
                          update(draft.copyWith(showTranslation: value));
                        },
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: language,
                        decoration: InputDecoration(
                          labelText: _t(
                            'Übersetzungssprache',
                            'Translation language',
                            'لغة الترجمة',
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (value) =>
                            setSheetState(() => language = value!),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSlider(
                        label: _t(
                          'Arabische Schriftgröße',
                          'Arabic font size',
                          'حجم الخط العربي',
                        ),
                        value: draft.arabicFontSize,
                        min: 22,
                        max: 48,
                        onChanged: (value) =>
                            update(draft.copyWith(arabicFontSize: value)),
                      ),
                      _SettingsSlider(
                        label: _t(
                          'Übersetzungsgröße',
                          'Translation size',
                          'حجم خط الترجمة',
                        ),
                        value: draft.translationFontSize,
                        min: 14,
                        max: 30,
                        onChanged: (value) =>
                            update(draft.copyWith(translationFontSize: value)),
                      ),
                      _SettingsSlider(
                        label: _t(
                          'Versabstand',
                          'Verse spacing',
                          'المسافة بين الآيات',
                        ),
                        value: draft.verseSpacing,
                        min: 8,
                        max: 36,
                        onChanged: (value) =>
                            update(draft.copyWith(verseSpacing: value)),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: widget.themeColor,
                        secondary: Icon(
                          draft.darkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        title: Text(
                          _t('Dunkelmodus', 'Dark mode', 'الوضع الداكن'),
                        ),
                        value: draft.darkMode,
                        onChanged: (value) =>
                            update(draft.copyWith(darkMode: value)),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.themeColor,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _preferences = draft;
                              _translationLanguage = language;
                            });
                            _savePreferences();
                            Navigator.pop(context);
                          },
                          child: Text(_t('Speichern', 'Save', 'حفظ')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSurah(
    QuranSurah surah, {
    required QuranTextData data,
    int? initialAyah,
  }) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('quran_last_surah', surah.number);
      prefs.setInt('quran_last_ayah', initialAyah ?? 1);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahReaderPage(
          data: data,
          surah: surah,
          initialAyah: initialAyah,
          themeColor: widget.themeColor,
          uiLanguageCode: widget.uiLanguageCode,
          translationLanguage: _translationLanguage,
          preferences: _preferences,
          bookmarks: _bookmarks,
          onBookmarksChanged: (updated) {
            setState(() => _bookmarks = updated);
            _saveBookmarks();
          },
          highlights: _highlights,
          onHighlightsChanged: (updated) {
            setState(() => _highlights = updated);
            _saveHighlights();
          },
        ),
      ),
    );
  }

  Future<void> _showSearch(QuranTextData data) async {
    final controller = TextEditingController();
    List<QuranSurah> surahResults = [];
    List<QuranVerse> results = [];
    final dialogDark = _preferences.darkMode;
    await showDialog<void>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: dialogDark
              ? const ColorScheme.dark(
                  primary: NurrDesign.gold,
                  surface: NurrDesign.darkSurface,
                )
              : const ColorScheme.light(
                  primary: NurrDesign.goldDark,
                  surface: NurrDesign.paper,
                ),
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: NurrDesign.surface(dialogDark),
            surfaceTintColor: Colors.transparent,
            title: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: NurrDesign.text(dialogDark)),
              decoration: InputDecoration(
                hintText: _t(
                  'Sure, Nummer oder Vers suchen',
                  'Search surah, number, or verse',
                  'ابحث عن سورة أو رقم أو آية',
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (query) {
                final trimmed = query.trim();
                final normalized = _normalizeSearch(trimmed);
                setDialogState(() {
                  surahResults = normalized.isEmpty
                      ? []
                      : data.surahs
                            .where((surah) {
                              return _matchesSurahSearch(surah, normalized);
                            })
                            .take(12)
                            .toList();
                  results = normalized.length < 2 && !normalized.contains(':')
                      ? []
                      : data.verses
                            .where((verse) {
                              return verse.arabic.contains(trimmed) ||
                                  verse
                                      .translationFor(_translationLanguage)
                                      .toLowerCase()
                                      .contains(normalized) ||
                                  verse.key == normalized;
                            })
                            .take(100)
                            .toList();
                });
              },
            ),
            content: SizedBox(
              width: 600,
              height: 420,
              child: surahResults.isEmpty && results.isEmpty
                  ? Center(
                      child: Text(
                        _t(
                          'Suraname, Suranummer oder mindestens zwei Zeichen eingeben',
                          'Enter a surah name, surah number, or at least two characters',
                          'أدخل اسم السورة أو رقمها أو حرفين على الأقل',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NurrDesign.secondaryText(dialogDark),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        if (surahResults.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            child: Text(
                              _t('Suren', 'Surahs', 'السور'),
                              style: const TextStyle(
                                color: NurrDesign.goldDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          ...surahResults.map(
                            (surah) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: NurrDesign.gold.withValues(
                                  alpha: .16,
                                ),
                                foregroundColor: NurrDesign.goldDark,
                                child: Text('${surah.number}'),
                              ),
                              title: Text(
                                surah.transliteratedName,
                                style: TextStyle(
                                  color: NurrDesign.text(dialogDark),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                surah.englishName,
                                style: TextStyle(
                                  color: NurrDesign.secondaryText(dialogDark),
                                ),
                              ),
                              trailing: Text(
                                surah.arabicName,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  color: NurrDesign.goldDark,
                                  fontSize: 20,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _openSurah(surah, data: data);
                              },
                            ),
                          ),
                          if (results.isNotEmpty) const Divider(),
                        ],
                        if (results.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            child: Text(
                              _t('Verse', 'Verses', 'الآيات'),
                              style: const TextStyle(
                                color: NurrDesign.goldDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ...results.map(
                          (verse) => ListTile(
                            title: Text(
                              verse.arabic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'AmiriQuran',
                                color: NurrDesign.text(dialogDark),
                              ),
                            ),
                            subtitle: Text(
                              '${verse.key} · ${verse.translationFor(_translationLanguage)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: NurrDesign.secondaryText(dialogDark),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _openSurah(
                                data.surahs[verse.surah - 1],
                                data: data,
                                initialAyah: verse.ayah,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _normalizeSearch(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff:]'), '')
      .replaceFirst(RegExp(r'^(surah|sura|sure)'), '');

  bool _matchesSurahSearch(QuranSurah surah, String normalized) {
    if (surah.number.toString() == normalized) return true;
    final variants = <String>{normalized};
    if (normalized.endsWith('h') && normalized.length > 1) {
      variants.add(normalized.substring(0, normalized.length - 1));
    }
    final names = [
      surah.arabicName,
      surah.transliteratedName,
      surah.englishName,
    ].map(_normalizeSearch);
    return variants.any((query) => names.any((name) => name.contains(query)));
  }

  Future<void> _showBookmarks(QuranTextData data) async {
    final sorted = _bookmarks.toList()..sort(_compareVerseKeys);
    final dialogDark = _preferences.darkMode;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: NurrDesign.surface(dialogDark),
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                _t('Lesezeichen', 'Bookmarks', 'الإشارات المرجعية'),
                style: TextStyle(
                  color: widget.themeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: sorted.isEmpty
                  ? Center(
                      child: Text(
                        _t(
                          'Noch keine Lesezeichen',
                          'No bookmarks yet',
                          'لا توجد إشارات مرجعية بعد',
                        ),
                        style: TextStyle(
                          color: NurrDesign.secondaryText(dialogDark),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final verse = data.verse(sorted[index]);
                        return ListTile(
                          leading: Icon(
                            Icons.bookmark,
                            color: widget.themeColor,
                          ),
                          title: Text(
                            '[${verse.key}]',
                            style: TextStyle(
                              color: NurrDesign.text(dialogDark),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_preferences.showArabic)
                                Text(
                                  verse.arabic,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontFamily: 'AmiriQuran',
                                    fontSize: 19,
                                    height: 1.7,
                                  ),
                                ),
                              if (_preferences.showTranslation)
                                Text(
                                  verse.translationFor(_translationLanguage),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _openSurah(
                              data.surahs[verse.surah - 1],
                              data: data,
                              initialAyah: verse.ayah,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appDark = NurrDesign.darkMode.value;
    return ColoredBox(
      color: NurrDesign.background(appDark),
      child: SafeArea(
        child: FutureBuilder<QuranTextData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _IntegrityError(
                message: snapshot.error.toString(),
                themeColor: widget.themeColor,
                onRetry: _retryLoading,
                retryLabel: _t(
                  'Erneut versuchen',
                  'Try again',
                  'إعادة المحاولة',
                ),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: widget.themeColor),
              );
            }
            final data = snapshot.data!;
            if (widget.resumeRequest > 0 &&
                _handledResumeRequest != widget.resumeRequest) {
              _handledResumeRequest = widget.resumeRequest;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _preferencesFuture;
                if (mounted) _resumeLastRead(data);
              });
            }
            return Column(
              children: [
                Container(
                  color: NurrDesign.surface(appDark),
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: NurrDesign.goldDark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _t(
                            'Der edle Quran',
                            'The Noble Quran',
                            'القرآن الكريم',
                          ),
                          style: TextStyle(
                            color: NurrDesign.text(appDark),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _t('Suchen', 'Search', 'بحث'),
                        onPressed: () => _showSearch(data),
                        icon: const Icon(Icons.search),
                      ),
                      IconButton(
                        tooltip: _t(
                          'Lesezeichen',
                          'Bookmarks',
                          'الإشارات المرجعية',
                        ),
                        onPressed: () => _showBookmarks(data),
                        icon: const Icon(Icons.bookmarks_outlined),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'display') _showDisplaySettings();
                          if (value == 'sources') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuranSourcesPage(
                                  themeColor: widget.themeColor,
                                  uiLanguageCode: widget.uiLanguageCode,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'display',
                            child: Text(_t('Anzeige', 'Display', 'العرض')),
                          ),
                          PopupMenuItem(
                            value: 'sources',
                            child: Text(_t('Quellen', 'Sources', 'المصادر')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.surahs.length,
                    itemBuilder: (context, index) {
                      final surah = data.surahs[index];
                      return Card(
                        color: NurrDesign.surface(appDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: NurrDesign.gold.withValues(alpha: 0.22),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: NurrDesign.gold.withValues(
                              alpha: 0.16,
                            ),
                            foregroundColor: NurrDesign.goldDark,
                            child: Text('${surah.number}'),
                          ),
                          title: Text(
                            surah.transliteratedName,
                            style: TextStyle(
                              color: NurrDesign.text(appDark),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _t(
                              '${surah.ayahCount} Verse',
                              '${surah.ayahCount} verses',
                              '${surah.ayahCount} آيات',
                            ),
                            style: TextStyle(
                              color: NurrDesign.secondaryText(appDark),
                            ),
                          ),
                          trailing: Text(
                            surah.arabicName,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: NurrDesign.goldDark,
                              fontFamily: 'AmiriQuran',
                              fontSize: 23,
                            ),
                          ),
                          onTap: () => _openSurah(surah, data: data),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class QuranSurahReaderPage extends StatefulWidget {
  final QuranTextData data;
  final QuranSurah surah;
  final int? initialAyah;

  /// Scopes a reading-plan session to one complete Mushaf page, including
  /// every surah whose verses share that page.
  final int? readingPlanPage;
  final Color themeColor;
  final String uiLanguageCode;
  final String translationLanguage;
  final QuranReaderPreferences preferences;
  final Set<String> bookmarks;
  final ValueChanged<Set<String>> onBookmarksChanged;
  final Map<String, String> highlights;
  final ValueChanged<Map<String, String>> onHighlightsChanged;

  const QuranSurahReaderPage({
    super.key,
    required this.data,
    required this.surah,
    this.initialAyah,
    this.readingPlanPage,
    required this.themeColor,
    required this.uiLanguageCode,
    required this.translationLanguage,
    required this.preferences,
    required this.bookmarks,
    required this.onBookmarksChanged,
    required this.highlights,
    required this.onHighlightsChanged,
  });

  @override
  State<QuranSurahReaderPage> createState() => _QuranSurahReaderPageState();
}

class _QuranSurahReaderPageState extends State<QuranSurahReaderPage> {
  late Set<String> _bookmarks;
  late Map<String, String> _highlights;
  late List<int> _pages;
  late int _pageIndex;
  late final ScrollController _interleavedController;
  late final ScrollController _arabicPageController;
  late final ScrollController _translationPageController;
  final Key _interleavedCenterKey = UniqueKey();
  late final GlobalKey _arabicInitialVerseKey;
  late final GlobalKey _translationInitialVerseKey;
  late final List<QuranVerse> _readerVerses;
  late final int _initialVerseIndex;
  final Set<GlobalKey> _focusedPagePanes = {};
  bool _showArabicPage = true;

  bool get _isArabicUi => widget.uiLanguageCode == 'ar';
  bool get _isEnglishUi => widget.uiLanguageCode == 'en';
  bool get _isDark => widget.preferences.darkMode;
  bool get _isReadingPlan => widget.readingPlanPage != null;
  bool _isInitialVerse(QuranVerse verse) =>
      widget.initialAyah != null &&
      verse.surah == widget.surah.number &&
      verse.ayah == widget.initialAyah;
  bool _hasBasmala(QuranVerse verse) =>
      verse.ayah == 1 && verse.surah != 1 && verse.surah != 9;
  Color get _pageColor =>
      _isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F3E8);
  Color get _cardColor => _isDark ? const Color(0xFF171717) : Colors.white;
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF171717);

  @override
  void initState() {
    super.initState();
    _interleavedController = ScrollController();
    _arabicPageController = ScrollController();
    _translationPageController = ScrollController();
    _bookmarks = {...widget.bookmarks};
    _highlights = {...widget.highlights};
    _arabicInitialVerseKey = GlobalKey();
    _translationInitialVerseKey = GlobalKey();
    _readerVerses = _isReadingPlan
        ? widget.data.verses
              .where((verse) => verse.page == widget.readingPlanPage)
              .toList(growable: false)
        : widget.surah.verses;
    _initialVerseIndex = _readerVerses.indexWhere(_isInitialVerse);
    _showArabicPage = widget.preferences.showArabic;
    _pages = _readerVerses.map((v) => v.page).toSet().toList()..sort();
    final initialVerse = _initialVerseIndex < 0
        ? null
        : _readerVerses[_initialVerseIndex];
    _pageIndex = initialVerse == null
        ? 0
        : _pages.indexOf(initialVerse.page).clamp(0, _pages.length - 1);
    _saveLastRead();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusInitialVerse());
  }

  @override
  void dispose() {
    _interleavedController.dispose();
    _arabicPageController.dispose();
    _translationPageController.dispose();
    super.dispose();
  }

  Future<void> _saveLastRead() async {
    if (_readerVerses.isEmpty) return;
    final currentPage = _pages[_pageIndex];
    final firstVerse = _readerVerses.firstWhere(
      (verse) => verse.page == currentPage,
      orElse: () => _readerVerses.first,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_last_surah', firstVerse.surah);
    await prefs.setInt('quran_last_ayah', firstVerse.ayah);
    await prefs.setInt('quran_last_page', firstVerse.page);
  }

  void _changePage(int delta) {
    if (_isReadingPlan || !mounted) return;
    final requested = _pageIndex + delta;
    if (requested < 0) {
      _openAdjacentSurah(-1);
      return;
    }
    if (requested >= _pages.length) {
      _openAdjacentSurah(1);
      return;
    }
    final next = requested.clamp(0, _pages.length - 1);
    setState(() => _pageIndex = next);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetPageScroll());
    _saveLastRead();
  }

  void _resetPageScroll() {
    if (!mounted) return;
    for (final controller in [
      _arabicPageController,
      _translationPageController,
    ]) {
      if (controller.hasClients) controller.jumpTo(0);
    }
  }

  void _focusInitialVerse() {
    if (!mounted ||
        _isReadingPlan ||
        widget.initialAyah == null ||
        widget.initialAyah == 1 ||
        widget.preferences.mode == QuranReadingMode.interleaved) {
      return;
    }
    // Interleaved mode starts at its exact center sliver. Paired pages build
    // only one Mushaf page, so both target contexts are available after layout.
    // Remember panes separately, including a translation first shown later.
    for (final key in [_arabicInitialVerseKey, _translationInitialVerseKey]) {
      if (_focusedPagePanes.contains(key)) continue;
      final targetContext = key.currentContext;
      if (targetContext == null) continue;
      _focusedPagePanes.add(key);
      Scrollable.ensureVisible(targetContext, alignment: 0);
    }
  }

  void _openAdjacentSurah(int delta) {
    if (_isReadingPlan || !mounted) return;
    final targetNumber = widget.surah.number + delta;
    if (targetNumber < 1 || targetNumber > widget.data.surahs.length) return;
    final target = widget.data.surahs[targetNumber - 1];
    final initialAyah = delta < 0 ? target.ayahCount : 1;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahReaderPage(
          data: widget.data,
          surah: target,
          initialAyah: initialAyah,
          themeColor: widget.themeColor,
          uiLanguageCode: widget.uiLanguageCode,
          translationLanguage: widget.translationLanguage,
          preferences: widget.preferences,
          bookmarks: _bookmarks,
          onBookmarksChanged: widget.onBookmarksChanged,
          highlights: _highlights,
          onHighlightsChanged: widget.onHighlightsChanged,
        ),
      ),
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (_isReadingPlan) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -250) {
      _changePage(1);
    } else if (velocity > 250) {
      _changePage(-1);
    }
  }

  void _handleInterleavedSwipe(DragEndDetails details) {
    if (_isReadingPlan) return;
    final velocity = details.primaryVelocity ?? 0;
    if (!_interleavedController.hasClients) return;
    final position = _interleavedController.position;
    const edgeTolerance = 24.0;
    final isAtStart =
        position.pixels <= position.minScrollExtent + edgeTolerance;
    final isAtEnd = position.pixels >= position.maxScrollExtent - edgeTolerance;
    if (velocity < -250 && isAtEnd) {
      _openAdjacentSurah(1);
    } else if (velocity > 250 && isAtStart) {
      _openAdjacentSurah(-1);
    }
  }

  String _t(String de, String en, String ar) {
    if (_isArabicUi) return ar;
    if (_isEnglishUi) return en;
    return de;
  }

  String _translation(QuranVerse verse) =>
      verse.translationFor(widget.translationLanguage);

  Future<void> _toggleBookmark(QuranVerse verse) async {
    setState(() {
      if (!_bookmarks.add(verse.key)) _bookmarks.remove(verse.key);
    });
    widget.onBookmarksChanged({..._bookmarks});
  }

  _QuranHighlightOption? _highlightFor(QuranVerse verse) {
    final id = _highlights[verse.key];
    if (id == null) return null;
    for (final option in _QuranHighlightOption.options) {
      if (option.id == id) return option;
    }
    return _QuranHighlightOption.gold;
  }

  void _setHighlight(QuranVerse verse, _QuranHighlightOption option) {
    setState(() => _highlights[verse.key] = option.id);
    widget.onHighlightsChanged({..._highlights});
  }

  void _removeHighlight(QuranVerse verse) {
    setState(() => _highlights.remove(verse.key));
    widget.onHighlightsChanged({..._highlights});
  }

  void _showHighlightPicker(QuranVerse verse) {
    final selected = _highlightFor(verse);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cardColor,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  'Markierungsfarbe auswählen',
                  'Choose highlight color',
                  'اختر لون التظليل',
                ),
                style: TextStyle(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _QuranHighlightOption.options.map((option) {
                  final isSelected = selected?.id == option.id;
                  return Semantics(
                    button: true,
                    label: _isEnglishUi
                        ? option.englishName
                        : option.germanName,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        _setHighlight(verse, option);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 82,
                        height: 76,
                        decoration: BoxDecoration(
                          color: option.color.withValues(
                            alpha: _isDark ? .28 : .20,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? option.color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isEnglishUi
                                  ? option.englishName
                                  : option.germanName,
                              style: TextStyle(color: _textColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyVerse(QuranVerse verse, String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t('Vers kopiert', 'Verse copied', 'تم نسخ الآية')),
      ),
    );
  }

  Future<void> _shareVerse(QuranVerse verse) async {
    final parts = <String>[];
    if (widget.preferences.showArabic) parts.add(verse.arabic);
    if (widget.preferences.showTranslation) parts.add(_translation(verse));
    parts.add('[${verse.key}]');
    await Share.share(parts.join('\n\n'));
  }

  void _showVerseActions(QuranVerse verse) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cardColor,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(bodyColor: _textColor, displayColor: _textColor),
          listTileTheme: ListTileThemeData(
            textColor: _textColor,
            iconColor: widget.themeColor,
          ),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  _bookmarks.contains(verse.key)
                      ? Icons.bookmark_remove
                      : Icons.bookmark_add_outlined,
                  color: widget.themeColor,
                ),
                title: Text(
                  _bookmarks.contains(verse.key)
                      ? _t(
                          'Lesezeichen entfernen',
                          'Remove bookmark',
                          'إزالة الإشارة',
                        )
                      : _t(
                          'Lesezeichen speichern',
                          'Save bookmark',
                          'حفظ الإشارة',
                        ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleBookmark(verse);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.highlight_rounded,
                  color: _highlightFor(verse)?.color ?? widget.themeColor,
                ),
                title: Text(
                  _highlights.containsKey(verse.key)
                      ? _t(
                          'Markierung ändern',
                          'Change highlight',
                          'تغيير التظليل',
                        )
                      : _t('Vers markieren', 'Highlight verse', 'تظليل الآية'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _showHighlightPicker(verse),
                  );
                },
              ),
              if (_highlights.containsKey(verse.key))
                ListTile(
                  leading: Icon(
                    Icons.highlight_off_rounded,
                    color: _highlightFor(verse)?.color ?? widget.themeColor,
                  ),
                  title: Text(
                    _t(
                      'Markierung entfernen',
                      'Remove highlight',
                      'إزالة التظليل',
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeHighlight(verse);
                  },
                ),
              ListTile(
                leading: Icon(Icons.copy, color: widget.themeColor),
                title: Text(
                  _t('Arabisch kopieren', 'Copy Arabic', 'نسخ العربية'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _copyVerse(verse, '${verse.arabic}\n[${verse.key}]');
                },
              ),
              ListTile(
                leading: Icon(Icons.translate, color: widget.themeColor),
                title: Text(
                  _t('Übersetzung kopieren', 'Copy translation', 'نسخ الترجمة'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _copyVerse(verse, '${_translation(verse)}\n[${verse.key}]');
                },
              ),
              ListTile(
                leading: Icon(Icons.share_outlined, color: widget.themeColor),
                title: Text(_t('Vers teilen', 'Share verse', 'مشاركة الآية')),
                onTap: () {
                  Navigator.pop(context);
                  _shareVerse(verse);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.menu_book_outlined,
                  color: Colors.white38,
                ),
                title: Text(
                  _t(
                    'Tafsir – später verfügbar',
                    'Tafsir – coming later',
                    'التفسير – لاحقًا',
                  ),
                ),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(
                  Icons.volume_up_outlined,
                  color: Colors.white38,
                ),
                title: Text(
                  _t(
                    'Audio – später verfügbar',
                    'Audio – coming later',
                    'الصوت – لاحقًا',
                  ),
                ),
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageColor,
      appBar: AppBar(
        backgroundColor: _isDark ? Colors.black : Colors.white,
        foregroundColor: _textColor,
        title: Column(
          children: [
            Text(
              _isReadingPlan
                  ? _t(
                      'Leseplan · Seite ${widget.readingPlanPage}',
                      'Reading plan · Page ${widget.readingPlanPage}',
                      'خطة القراءة · الصفحة ${widget.readingPlanPage}',
                    )
                  : widget.surah.transliteratedName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _isReadingPlan
                  ? widget.data.surahs
                        .where(
                          (surah) => _readerVerses.any(
                            (verse) => verse.surah == surah.number,
                          ),
                        )
                        .map(
                          (surah) => _isArabicUi
                              ? surah.arabicName
                              : surah.transliteratedName,
                        )
                        .join(' · ')
                  : widget.surah.arabicName,
              textDirection: _isReadingPlan && !_isArabicUi
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.themeColor,
                fontFamily: 'AmiriQuran',
                fontSize: 17,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _readerVerses.isEmpty
          ? Center(
              child: Text(
                _t(
                  'Diese Seite ist nicht verfügbar.',
                  'This page is unavailable.',
                  'هذه الصفحة غير متاحة.',
                ),
              ),
            )
          : widget.preferences.mode == QuranReadingMode.interleaved
          ? _buildInterleaved()
          : _buildPairedPages(),
    );
  }

  Widget _buildInterleaved() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 928
            ? (constraints.maxWidth - 900) / 2
            : 14.0;
        final centerIndex = !_isReadingPlan && _initialVerseIndex > 0
            ? _initialVerseIndex
            : 0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: _isReadingPlan ? null : _handleInterleavedSwipe,
          // The requested verse is the scroll origin. Earlier verses grow
          // upwards and later verses downwards, without guessing card heights
          // or laying out a complete long surah just to reach one verse.
          child: CustomScrollView(
            controller: _interleavedController,
            center: _interleavedCenterKey,
            slivers: [
              if (centerIndex > 0)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildInterleavedVerse(
                        _readerVerses[centerIndex - index - 1],
                      ),
                      childCount: centerIndex,
                    ),
                  ),
                ),
              SliverPadding(
                key: _interleavedCenterKey,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  14,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildInterleavedVerse(
                      _readerVerses[centerIndex + index],
                    ),
                    childCount: _readerVerses.length - centerIndex,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInterleavedVerse(QuranVerse verse) {
    final highlight = _highlightFor(verse);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isReadingPlan && (verse == _readerVerses.first || verse.ayah == 1))
          _buildSurahSectionHeader(verse),
        if (_hasBasmala(verse)) _buildBasmalaHeader(),
        Card(
          key: ValueKey(verse.key),
          color: _cardColor,
          margin: EdgeInsets.only(bottom: widget.preferences.verseSpacing),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: _isInitialVerse(verse)
                  ? widget.themeColor
                  : (_isDark ? Colors.white12 : Colors.black12),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showVerseActions(verse),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _VerseNumber(
                        number: verse.ayah,
                        color: widget.themeColor,
                      ),
                      const Spacer(),
                      if (_bookmarks.contains(verse.key))
                        Icon(
                          Icons.bookmark,
                          color: widget.themeColor,
                          size: 20,
                        ),
                      if (highlight != null)
                        Icon(
                          Icons.highlight_rounded,
                          color: highlight.color,
                          size: 20,
                        ),
                    ],
                  ),
                  if (widget.preferences.showArabic) ...[
                    const SizedBox(height: 12),
                    SelectableText.rich(
                      TextSpan(
                        text: verse.arabic,
                        style: TextStyle(
                          color: _textColor,
                          fontFamily: 'AmiriQuran',
                          fontSize: widget.preferences.arabicFontSize,
                          height: 2,
                          backgroundColor: highlight?.color.withValues(
                            alpha: _isDark ? .34 : .28,
                          ),
                        ),
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                  ],
                  if (widget.preferences.showArabic &&
                      widget.preferences.showTranslation)
                    Divider(
                      height: 26,
                      color: _isDark ? Colors.white24 : Colors.black12,
                    ),
                  if (widget.preferences.showTranslation)
                    SelectableText.rich(
                      TextSpan(
                        text: _translation(verse),
                        style: TextStyle(
                          color: _textColor.withValues(alpha: 0.88),
                          fontSize: widget.preferences.translationFontSize,
                          height: 1.55,
                          backgroundColor: highlight?.color.withValues(
                            alpha: _isDark ? .34 : .28,
                          ),
                        ),
                      ),
                      textAlign: TextAlign.start,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahSectionHeader(QuranVerse verse) {
    final surah = widget.data.surahs.firstWhere(
      (surah) => surah.number == verse.surah,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      child: Column(
        children: [
          Text(
            surah.arabicName,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 26,
              color: widget.themeColor,
            ),
          ),
          if (!_isArabicUi)
            Text(
              surah.transliteratedName,
              textAlign: TextAlign.center,
              style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildBasmalaHeader({
    bool arabicOnly = false,
    bool translationOnly = false,
  }) {
    final showArabic =
        arabicOnly || (!translationOnly && widget.preferences.showArabic);
    final showTranslation =
        translationOnly || (!arabicOnly && widget.preferences.showTranslation);
    final translation = widget.translationLanguage == 'en'
        ? 'In the name of Allah, the Entirely Merciful, the Especially Merciful.'
        : 'Im Namen Allahs, des Allerbarmers, des Barmherzigen.';

    return Container(
      margin: EdgeInsets.only(bottom: widget.preferences.verseSpacing),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.themeColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          if (showArabic)
            SelectableText(
              QuranTextRepository.basmala,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontFamily: 'AmiriQuran',
                fontSize: widget.preferences.arabicFontSize,
                height: 1.8,
              ),
            ),
          if (showArabic && showTranslation) const SizedBox(height: 8),
          if (showTranslation)
            SelectableText(
              translation,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor.withValues(alpha: 0.88),
                fontSize: widget.preferences.translationFontSize,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPairedPages() {
    final page = _pages[_pageIndex];
    final verses = _readerVerses.where((v) => v.page == page).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusInitialVerse());
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final sideBySide =
            wide &&
            widget.preferences.showSideBySide &&
            widget.preferences.showArabic &&
            widget.preferences.showTranslation;
        final canChoosePage =
            widget.preferences.showArabic &&
            widget.preferences.showTranslation &&
            !sideBySide;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: _isReadingPlan ? null : _handleHorizontalSwipe,
          child: Column(
            children: [
              if (!_isReadingPlan)
                Container(
                  color: _isDark ? Colors.black54 : Colors.white70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.surah.number > 1 || _pageIndex > 0
                            ? () => _changePage(-1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          '${_t('Seite', 'Page', 'الصفحة')} $page · ${_pageIndex + 1}/${_pages.length}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            widget.surah.number < widget.data.surahs.length ||
                                _pageIndex < _pages.length - 1
                            ? () => _changePage(1)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              if (canChoosePage)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(_t('Arabisch', 'Arabic', 'العربية')),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(
                          _t('Übersetzung', 'Translation', 'الترجمة'),
                        ),
                      ),
                    ],
                    selected: {_showArabicPage},
                    onSelectionChanged: (value) =>
                        setState(() => _showArabicPage = value.first),
                  ),
                ),
              Expanded(
                child: sideBySide
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildTextPage(
                              verses,
                              true,
                              controller: _arabicPageController,
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: _buildTextPage(
                              verses,
                              false,
                              controller: _translationPageController,
                            ),
                          ),
                        ],
                      )
                    : _buildTextPage(
                        verses,
                        widget.preferences.showArabic &&
                            (!widget.preferences.showTranslation ||
                                _showArabicPage),
                        controller:
                            widget.preferences.showArabic &&
                                (!widget.preferences.showTranslation ||
                                    _showArabicPage)
                            ? _arabicPageController
                            : _translationPageController,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextPage(
    List<QuranVerse> verses,
    bool arabic, {
    required ScrollController controller,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF171717) : const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.themeColor, width: 2),
      ),
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...verses.map((verse) {
              final highlight = _highlightFor(verse);
              final focusKey = _isInitialVerse(verse)
                  ? (arabic
                        ? _arabicInitialVerseKey
                        : _translationInitialVerseKey)
                  : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isReadingPlan &&
                      (verse == verses.first || verse.ayah == 1))
                    _buildSurahSectionHeader(verse),
                  if (_hasBasmala(verse))
                    _buildBasmalaHeader(
                      arabicOnly: arabic,
                      translationOnly: !arabic,
                    ),
                  InkWell(
                    key: focusKey,
                    onTap: () => _showVerseActions(verse),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.preferences.verseSpacing,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: arabic
                                    ? verse.arabic
                                    : _translation(verse),
                                style: TextStyle(
                                  backgroundColor: highlight?.color.withValues(
                                    alpha: _isDark ? .34 : .28,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: arabic
                                    ? ' ﴿${verse.ayah}﴾'
                                    : '  [${verse.ayah}]',
                                style: TextStyle(
                                  color: widget.themeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textDirection: arabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign: arabic
                              ? TextAlign.center
                              : TextAlign.start,
                          textWidthBasis: TextWidthBasis.parent,
                          style: TextStyle(
                            color: _textColor,
                            fontFamily: arabic ? 'AmiriQuran' : null,
                            fontSize: arabic
                                ? widget.preferences.arabicFontSize
                                : widget.preferences.translationFontSize,
                            height: arabic ? 2 : 1.55,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class QuranSourcesPage extends StatelessWidget {
  final Color themeColor;
  final String uiLanguageCode;

  const QuranSourcesPage({
    super.key,
    required this.themeColor,
    required this.uiLanguageCode,
  });

  @override
  Widget build(BuildContext context) {
    final dark = NurrDesign.darkMode.value;
    return Scaffold(
      backgroundColor: NurrDesign.background(dark),
      appBar: AppBar(title: const Text('Quran – Quellen & Lizenzen')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _SourceCard(
            color: themeColor,
            title: 'Arabischer Qurantext',
            body:
                'Tanzil Quran Text – Uthmani, Version 1.1\n'
                'Copyright © 2007–2021 Tanzil Project\n'
                'Creative Commons Attribution 3.0\n'
                'Der Text wird in der App unverändert verwendet.\n'
                'Quelle: https://tanzil.net',
          ),
          _SourceCard(
            color: themeColor,
            title: 'Deutsche Übersetzung',
            body:
                'A. S. F. Bubenheim und N. Elyas\n'
                'Quelle: Tanzil Translations (de.bubenheim)\n'
                'Nutzung in dieser dauerhaft kostenlosen und werbefreien App.',
          ),
          _SourceCard(
            color: themeColor,
            title: 'English translation',
            body:
                'Saheeh International\n'
                'Source: Tanzil Translations (en.sahih)\n'
                'Used in this permanently free and ad-free application.',
          ),
          _SourceCard(
            color: themeColor,
            title: 'Quran-Schrift',
            body:
                'Amiri Quran\nSIL Open Font License 1.1\n'
                'Quelle: Google Fonts / Amiri Font Project',
          ),
          const SizedBox(height: 8),
          Text(
            'Übersetzungen geben die Bedeutung des Quran wieder und ersetzen nicht den arabischen Qurantext.',
            style: TextStyle(
              color: NurrDesign.secondaryText(dark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final Color color;
  final String title;
  final String body;

  const _SourceCard({
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final dark = NurrDesign.darkMode.value;
    return Card(
      color: NurrDesign.surface(dark),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                color: NurrDesign.secondaryText(dark),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SettingsSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _VerseNumber extends StatelessWidget {
  final int number;
  final Color color;

  const _VerseNumber({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: Text('$number', style: TextStyle(color: color)),
    );
  }
}

class _IntegrityError extends StatelessWidget {
  final String message;
  final Color themeColor;
  final VoidCallback onRetry;
  final String retryLabel;

  const _IntegrityError({
    required this.message,
    required this.themeColor,
    required this.onRetry,
    required this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.gpp_bad_outlined,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 14),
            Text(
              'Die Quran-Daten konnten die Integritätsprüfung nicht bestehen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
              style: FilledButton.styleFrom(backgroundColor: themeColor),
            ),
          ],
        ),
      ),
    );
  }
}
