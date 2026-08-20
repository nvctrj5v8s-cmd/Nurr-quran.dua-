import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quran_text_repository.dart';
import 'nurr_design.dart';

enum QuranReadingMode { interleaved, pairedPages }

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
  QuranReaderPreferences _preferences = const QuranReaderPreferences();
  Set<String> _bookmarks = {};
  String _translationLanguage = 'de';
  bool _showFirstChoice = false;

  bool get _isArabicUi => widget.uiLanguageCode == 'ar';
  bool get _isEnglishUi => widget.uiLanguageCode == 'en';

  @override
  void initState() {
    super.initState();
    _translationLanguage = _isEnglishUi ? 'en' : 'de';
    _dataFuture = QuranTextRepository.instance.load();
    _loadPreferences();
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
      _loadPreferences();
    }
    if (oldWidget.resumeRequest != widget.resumeRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resumeLastRead());
    }
  }

  Future<void> _resumeLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surahNumber = prefs.getInt('quran_last_surah') ?? 1;
    final ayah = prefs.getInt('quran_last_ayah') ?? 1;
    final data = await _dataFuture;
    if (!mounted) return;
    final surah = data.surahs.firstWhere(
      (item) => item.number == surahNumber,
      orElse: () => data.surahs.first,
    );
    _openSurah(surah, initialAyah: ayah.clamp(1, surah.ayahCount));
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
          backgroundColor: const Color(0xFF151515),
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
      backgroundColor: const Color(0xFF151515),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void update(QuranReaderPreferences value) {
            setSheetState(() => draft = value);
          }

          return SafeArea(
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
                    title: Text(_t('Übersetzung', 'Translation', 'الترجمة')),
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
                    title: Text(_t('Dunkelmodus', 'Dark mode', 'الوضع الداكن')),
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
          );
        },
      ),
    );
  }

  void _openSurah(QuranSurah surah, {int? initialAyah}) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('quran_last_surah', surah.number);
      prefs.setInt('quran_last_ayah', initialAyah ?? 1);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahReaderPage(
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
        ),
      ),
    );
  }

  Future<void> _showSearch(QuranTextData data) async {
    final controller = TextEditingController();
    List<QuranVerse> results = [];
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF151515),
          title: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: _t(
                'Im Quran suchen',
                'Search Quran',
                'البحث في القرآن',
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (query) {
              final normalized = query.trim().toLowerCase();
              setDialogState(() {
                results = normalized.length < 2
                    ? []
                    : data.verses
                          .where((verse) {
                            return verse.arabic.contains(query.trim()) ||
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
            child: results.isEmpty
                ? Center(
                    child: Text(
                      _t(
                        'Mindestens zwei Zeichen eingeben',
                        'Enter at least two characters',
                        'أدخل حرفين على الأقل',
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final verse = results[index];
                      return ListTile(
                        title: Text(
                          verse.arabic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: 'AmiriQuran'),
                        ),
                        subtitle: Text(
                          '${verse.key} · ${verse.translationFor(_translationLanguage)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _openSurah(
                            data.surahs[verse.surah - 1],
                            initialAyah: verse.ayah,
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _showBookmarks(QuranTextData data) async {
    final sorted = _bookmarks.toList()..sort(_compareVerseKeys);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151515),
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
                          title: Text('[${verse.key}]'),
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
                          onTap: () => _openSurah(surah),
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
  final QuranSurah surah;
  final int? initialAyah;
  final Color themeColor;
  final String uiLanguageCode;
  final String translationLanguage;
  final QuranReaderPreferences preferences;
  final Set<String> bookmarks;
  final ValueChanged<Set<String>> onBookmarksChanged;

  const QuranSurahReaderPage({
    super.key,
    required this.surah,
    this.initialAyah,
    required this.themeColor,
    required this.uiLanguageCode,
    required this.translationLanguage,
    required this.preferences,
    required this.bookmarks,
    required this.onBookmarksChanged,
  });

  @override
  State<QuranSurahReaderPage> createState() => _QuranSurahReaderPageState();
}

class _QuranSurahReaderPageState extends State<QuranSurahReaderPage> {
  late Set<String> _bookmarks;
  late List<int> _pages;
  late int _pageIndex;
  bool _showArabicPage = true;

  bool get _isArabicUi => widget.uiLanguageCode == 'ar';
  bool get _isEnglishUi => widget.uiLanguageCode == 'en';
  bool get _isDark => widget.preferences.darkMode;
  bool get _hasBasmala => widget.surah.number != 1 && widget.surah.number != 9;
  Color get _pageColor =>
      _isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F3E8);
  Color get _cardColor => _isDark ? const Color(0xFF171717) : Colors.white;
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF171717);

  @override
  void initState() {
    super.initState();
    _bookmarks = {...widget.bookmarks};
    _showArabicPage = widget.preferences.showArabic;
    _pages = widget.surah.verses.map((v) => v.page).toSet().toList()..sort();
    final initialVerse = widget.initialAyah == null
        ? null
        : widget.surah.verses[widget.initialAyah! - 1];
    _pageIndex = initialVerse == null
        ? 0
        : _pages.indexOf(initialVerse.page).clamp(0, _pages.length - 1);
    _saveLastRead();
  }

  Future<void> _saveLastRead() async {
    final currentPage = _pages[_pageIndex];
    final firstVerse = widget.surah.verses.firstWhere(
      (verse) => verse.page == currentPage,
      orElse: () => widget.surah.verses.first,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_last_surah', widget.surah.number);
    await prefs.setInt('quran_last_ayah', firstVerse.ayah);
  }

  void _changePage(int delta) {
    final next = (_pageIndex + delta).clamp(0, _pages.length - 1);
    if (next == _pageIndex) return;
    setState(() => _pageIndex = next);
    _saveLastRead();
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
      backgroundColor: const Color(0xFF151515),
      builder: (context) => SafeArea(
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
            Text(widget.surah.transliteratedName),
            Text(
              widget.surah.arabicName,
              textDirection: TextDirection.rtl,
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
      body: widget.preferences.mode == QuranReadingMode.interleaved
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
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            14,
            horizontalPadding,
            14,
          ),
          itemCount: widget.surah.verses.length + (_hasBasmala ? 1 : 0),
          itemBuilder: (context, index) {
            if (_hasBasmala && index == 0) {
              return _buildBasmalaHeader();
            }
            final verse = widget.surah.verses[index - (_hasBasmala ? 1 : 0)];
            return Card(
              key: ValueKey(verse.key),
              color: _cardColor,
              margin: EdgeInsets.only(bottom: widget.preferences.verseSpacing),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: widget.initialAyah == verse.ayah
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
                        ],
                      ),
                      if (widget.preferences.showArabic) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          verse.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          textWidthBasis: TextWidthBasis.parent,
                          style: TextStyle(
                            color: _textColor,
                            fontFamily: 'AmiriQuran',
                            fontSize: widget.preferences.arabicFontSize,
                            height: 2,
                          ),
                        ),
                      ],
                      if (widget.preferences.showArabic &&
                          widget.preferences.showTranslation)
                        Divider(
                          height: 26,
                          color: _isDark ? Colors.white24 : Colors.black12,
                        ),
                      if (widget.preferences.showTranslation)
                        SelectableText(
                          _translation(verse),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: _textColor.withValues(alpha: 0.88),
                            fontSize: widget.preferences.translationFontSize,
                            height: 1.55,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
    final verses = widget.surah.verses.where((v) => v.page == page).toList();
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
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -250 && _pageIndex < _pages.length - 1) {
              _changePage(1);
            } else if (velocity > 250 && _pageIndex > 0) {
              _changePage(-1);
            }
          },
          child: Column(
            children: [
              Container(
                color: _isDark ? Colors.black54 : Colors.white70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pageIndex > 0 ? () => _changePage(-1) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        '${_t('Seite', 'Page', 'الصفحة')} $page · ${_pageIndex + 1}/${_pages.length}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _pageIndex < _pages.length - 1
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
                          Expanded(child: _buildTextPage(verses, true)),
                          const VerticalDivider(width: 1),
                          Expanded(child: _buildTextPage(verses, false)),
                        ],
                      )
                    : _buildTextPage(
                        verses,
                        widget.preferences.showArabic &&
                            (!widget.preferences.showTranslation ||
                                _showArabicPage),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextPage(List<QuranVerse> verses, bool arabic) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF171717) : const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.themeColor, width: 2),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_hasBasmala && verses.any((verse) => verse.ayah == 1))
              _buildBasmalaHeader(arabicOnly: arabic, translationOnly: !arabic),
            ...verses.map((verse) {
              return InkWell(
                onTap: () => _showVerseActions(verse),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: widget.preferences.verseSpacing,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: arabic ? verse.arabic : _translation(verse),
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
                    textAlign: arabic ? TextAlign.center : TextAlign.start,
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
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
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
          const Text(
            'Übersetzungen geben die Bedeutung des Quran wieder und ersetzen nicht den arabischen Qurantext.',
            style: TextStyle(color: Colors.white70, height: 1.5),
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
    return Card(
      color: const Color(0xFF191919),
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
              style: const TextStyle(color: Colors.white70, height: 1.5),
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
