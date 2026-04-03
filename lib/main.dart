import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'mushaf_reader_page.dart';
import 'german_reader_page.dart';

// ==================== SPRACH-MODELL ====================
enum QuranLanguage {
  arabic('Arabisch', 'quran-uthmani', '🇸🇦'),
  german('Deutsch', 'de.bubenheim', '🇩🇪'),
  english('English', 'en.sahih', '🇬🇧');

  final String displayName;
  final String apiEdition;
  final String flag;
  const QuranLanguage(this.displayName, this.apiEdition, this.flag);
}

// ==================== APP-SPRACHE ====================
enum AppLanguage {
  german('Deutsch', '🇩🇪', 'de'),
  english('English', '🇬🇧', 'en'),
  arabic('العربية', '🇸🇦', 'ar');

  final String displayName;
  final String flag;
  final String code;
  const AppLanguage(this.displayName, this.flag, this.code);
}

// ==================== APP-THEME ====================
enum AppTheme {
  classic(Colors.amber, 'Klassisch (Gold)'),
  green(Colors.green, 'Grün'),
  blue(Colors.blue, 'Blau'),
  pink(Colors.pink, 'Rosa'),
  graphite(Color(0xFF424242), 'Grau/Schwarz'),
  purple(Colors.purple, 'Lila'),
  teal(Colors.teal, 'Türkis');

  final Color color;
  final String name;
  const AppTheme(this.color, this.name);

  static AppTheme fromIndex(int index) {
    if (index >= 0 && index < AppTheme.values.length) {
      return AppTheme.values[index];
    }
    return AppTheme.classic;
  }
}

enum AppBackground {
  defaultImage('assets/images/hintergrund.jpg', 'Hintergrund 1'),
  altImage('assets/images/hintergrund2.jpg', 'Hintergrund 2'),
  bg3('assets/images/863ad44b341008c996f680d61ff457bc.jpg', 'Hintergrund 3'),
  bg4('assets/images/978ffb16be030a299ad164e390480d92.jpg', 'Hintergrund 4'),
  bg5('assets/images/9620bb06bbfd9c9cbbca520b5b7f6c10.jpg', 'Hintergrund 5'),
  bg6('assets/images/c9bd77df1796b47bd0345867734dccda.jpg', 'Hintergrund 6'),
  bg7('assets/images/c69be9ea90230e3d4fc366b353738728.jpg', 'Hintergrund 7'),
  bg8('assets/images/d0d20b27b7272e5f95ee8c3a13d62ed2.jpg', 'Hintergrund 8'),
  bg9('assets/images/e398611a35f42d3e50bc4ebd19960c6a.jpg', 'Hintergrund 9'),
  bg10('assets/images/ff2686056f5ff73715363eeb3e9ec772.jpg', 'Hintergrund 10');

  final String assetPath;
  final String label;
  const AppBackground(this.assetPath, this.label);

  static AppBackground fromAssetPath(String? assetPath) {
    return AppBackground.values.firstWhere(
      (background) => background.assetPath == assetPath,
      orElse: () => AppBackground.defaultImage,
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static AppTheme currentTheme = AppTheme.classic;
  static AppBackground currentBackground = AppBackground.defaultImage;
  static final ValueNotifier<AppBackground> backgroundNotifier =
      ValueNotifier<AppBackground>(AppBackground.defaultImage);

  @override
  void initState() {
    super.initState();
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('app_theme') ?? 0;
    final backgroundAsset = prefs.getString('app_background');
    setState(() {
      currentTheme = AppTheme.fromIndex(themeIndex);
      currentBackground = AppBackground.fromAssetPath(backgroundAsset);
    });
    backgroundNotifier.value = currentBackground;
  }

  static void updateTheme(BuildContext context, AppTheme newTheme) {
    currentTheme = newTheme;
    context.findAncestorStateOfType<_MyAppState>()?.setState(() {
      currentTheme = newTheme;
    });
  }

  static void updateBackground(BuildContext context, AppBackground newBackground) {
    currentBackground = newBackground;
    backgroundNotifier.value = newBackground;
    context.findAncestorStateOfType<_MyAppState>()?.setState(() {
      currentBackground = newBackground;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: currentTheme.color,
        colorScheme: ColorScheme.dark(
          primary: currentTheme.color,
          secondary: currentTheme.color,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: currentTheme.color),
              ),
            );
          }
          if (snapshot.data == true) {
            return const LanguageSelectionScreen(isFirstTime: true);
          }
          return const MainPage();
        },
      ),
    );
  }

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('app_language');
  }
}

// ==================== LANGUAGE SELECTION SCREEN ====================
class LanguageSelectionScreen extends StatefulWidget {
  final bool isFirstTime;
  const LanguageSelectionScreen({super.key, this.isFirstTime = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage? selectedLanguage;

  Future<void> _saveLanguage() async {
    if (selectedLanguage == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', selectedLanguage!.code);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  String _getQuestionText() {
    if (selectedLanguage == null) {
      return 'Welche Sprache möchtest du nutzen?';
    }
    switch (selectedLanguage!) {
      case AppLanguage.german:
        return 'Welche Sprache möchtest du nutzen?';
      case AppLanguage.english:
        return 'Which language would you like to use?';
      case AppLanguage.arabic:
        return 'ما هي اللغة التي تريد استخدامها؟';
    }
  }

  String _getContinueText() {
    if (selectedLanguage == null) return 'WEITER';
    switch (selectedLanguage!) {
      case AppLanguage.german:
        return 'WEITER';
      case AppLanguage.english:
        return 'CONTINUE';
      case AppLanguage.arabic:
        return 'متابعة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  _getQuestionText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                ...AppLanguage.values.map((lang) {
                  final isSelected = selectedLanguage == lang;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = lang;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [_MyAppState.currentTheme.color, Colors.orange.shade700]
                              : [Colors.grey.shade800, Colors.grey.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _MyAppState.currentTheme.color : Colors.grey.shade700,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _MyAppState.currentTheme.color.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Text(
                            lang.flag,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              lang.displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _MyAppState.currentTheme.color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/quran_app_logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: selectedLanguage != null ? _saveLanguage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedLanguage != null ? _MyAppState.currentTheme.color : Colors.grey,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: selectedLanguage != null ? 8 : 0,
                  ),
                  child: Text(
                    _getContinueText(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN PAGE ====================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tab = 0;
  AppLanguage _appLanguage = AppLanguage.german;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmupMushafPages();
    });
    _loadAppLanguage();
  }

  Future<void> _loadAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language') ?? 'de';
    if (mounted) {
      setState(() {
        _appLanguage = AppLanguage.values.firstWhere(
          (l) => l.code == langCode,
          orElse: () => AppLanguage.german,
        );
      });
    }
  }

  String _navLabel(String de, String en, String ar) {
    switch (_appLanguage) {
      case AppLanguage.english:
        return en;
      case AppLanguage.arabic:
        return ar;
      case AppLanguage.german:
        return de;
    }
  }

  Future<void> _warmupMushafPages() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    final numberingVersion = prefs.getInt('mushaf_page_numbering_version') ?? 1;
    final rawSavedPage = prefs.getInt('mushaf_last_page');
    final visiblePage = rawSavedPage == null
        ? 1
        : numberingVersion >= 2
            ? rawSavedPage.clamp(1, 602)
            : (rawSavedPage - 1).clamp(1, 602);
    final startPage = (visiblePage - 1).clamp(1, 602);
    final endPage = (visiblePage + 3).clamp(1, 602);
    final mediaQuery = MediaQuery.of(context);
    final targetWidth =
        (mediaQuery.size.width * mediaQuery.devicePixelRatio)
            .clamp(900.0, 1800.0)
            .round();

    for (int page = startPage; page <= endPage; page++) {
      final pageNum = (page + 2).toString().padLeft(3, '0');
      precacheImage(
        ResizeImage(
          AssetImage('assets/mushaf_pages/$pageNum.png'),
          width: targetWidth,
        ),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppBackground>(
      valueListenable: _MyAppState.backgroundNotifier,
      builder: (context, background, child) {
        return Scaffold(
          body: Stack(
            children: [
              Image.asset(
                background.assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              [
                HomePage(appLanguage: _appLanguage),
                _appLanguage == AppLanguage.german
                    ? GermanReaderPage(themeColor: _MyAppState.currentTheme.color)
                    : _appLanguage == AppLanguage.english
                        ? MushafReaderPage(
                            themeColor: _MyAppState.currentTheme.color,
                            uiLanguageCode: _appLanguage.code,
                          )
                        : MushafReaderPage(
                            themeColor: _MyAppState.currentTheme.color,
                            uiLanguageCode: _appLanguage.code,
                          ),
                PrayerTimesPage(appLanguage: _appLanguage),
                const NamesOfAllahPage(),
                const SettingsPage()
              ][tab],
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tab,
            onTap: (i) => setState(() => tab = i),
            backgroundColor: Colors.black87,
            selectedItemColor: _MyAppState.currentTheme.color,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: _navLabel('Home', 'Home', 'الرئيسية')),
              BottomNavigationBarItem(icon: const Icon(Icons.book), label: _navLabel('Quran', 'Quran', 'القرآن')),
              BottomNavigationBarItem(icon: const Icon(Icons.access_time_filled), label: _navLabel('Gebetszeiten', 'Prayer Times', 'أوقات الصلاة')),
              BottomNavigationBarItem(
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      '99',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                label: _navLabel('99 Namen', '99 Names', '99 اسما'),
              ),
              BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: _navLabel('Mehr', 'More', 'المزيد')),
            ],
          ),
        );
      },
    );
  }
}

// ==================== HOME PAGE ====================
class HomePage extends StatefulWidget {
  final AppLanguage appLanguage;

  const HomePage({super.key, required this.appLanguage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int hadithIndex = 0;
  AppLanguage appLanguage = AppLanguage.german;
  List<bool> gebete = [false, false, false, false, false];
  static const String _prayerHistoryKey = 'gebet_history_v1';
  final gebetNamen = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  final Map<AppLanguage, List<String>> hadithsByLanguage = {
    AppLanguage.german: [
      'Prophet ﷺ: Die besten unter euch sind diejenigen, die den Quran lernen und lehren. (Bukhari)',
      'Prophet ﷺ: Wer an Allah und den Jüngsten Tag glaubt, soll Gutes sprechen oder schweigen. (Bukhari)',
      'Prophet ﷺ: Das Gebet ist Licht. (Muslim)',
      'Prophet ﷺ: Lächle deinen Bruder an, das ist Sadaqah. (Tirmidhi)',
      'Prophet ﷺ: Allah ist gütig und liebt Güte. (Bukhari)',
      'Prophet ﷺ: Der Starke ist nicht derjenige, der andere im Kampf besiegt, sondern derjenige, der sich im Zorn beherrscht. (Bukhari)',
      'Prophet ﷺ: Ein gutes Wort ist Sadaqah. (Bukhari)',
      'Prophet ﷺ: Der Barmherzige wird vom Allerbarmer mit Barmherzigkeit behandelt. (Tirmidhi)',
      'Prophet ﷺ: Erleichtert und erschwert nicht; verkündet frohe Botschaft und schreckt nicht ab. (Bukhari)',
      'Prophet ﷺ: Allah schaut nicht auf eure Gestalt, sondern auf eure Herzen und Taten. (Muslim)',
    ],
    AppLanguage.english: [
      'Prophet ﷺ: The best among you are those who learn the Quran and teach it. (Bukhari)',
      'Prophet ﷺ: Whoever believes in Allah and the Last Day should speak good or remain silent. (Bukhari)',
      'Prophet ﷺ: Prayer is light. (Muslim)',
      'Prophet ﷺ: Smiling at your brother is charity. (Tirmidhi)',
      'Prophet ﷺ: Allah is kind and loves kindness. (Bukhari)',
      'Prophet ﷺ: The strong person is not the one who overcomes others, but the one who controls himself when angry. (Bukhari)',
      'Prophet ﷺ: A good word is charity. (Bukhari)',
      'Prophet ﷺ: The merciful are shown mercy by the Most Merciful. (Tirmidhi)',
      'Prophet ﷺ: Make things easy and do not make them difficult; give glad tidings and do not drive people away. (Bukhari)',
      'Prophet ﷺ: Allah does not look at your appearance, but at your hearts and deeds. (Muslim)',
    ],
    AppLanguage.arabic: [
      'قال النبي ﷺ: خيركم من تعلم القرآن وعلمه. (البخاري)',
      'قال النبي ﷺ: من كان يؤمن بالله واليوم الآخر فليقل خيرًا أو ليصمت. (البخاري)',
      'قال النبي ﷺ: الصلاة نور. (مسلم)',
      'قال النبي ﷺ: تبسمك في وجه أخيك صدقة. (الترمذي)',
      'قال النبي ﷺ: إن الله رفيق يحب الرفق. (البخاري)',
      'قال النبي ﷺ: ليس الشديد بالصرعة، إنما الشديد الذي يملك نفسه عند الغضب. (البخاري)',
      'قال النبي ﷺ: الكلمة الطيبة صدقة. (البخاري)',
      'قال النبي ﷺ: الراحمون يرحمهم الرحمن. (الترمذي)',
      'قال النبي ﷺ: يسروا ولا تعسروا، وبشروا ولا تنفروا. (البخاري)',
      'قال النبي ﷺ: إن الله لا ينظر إلى صوركم، ولكن ينظر إلى قلوبكم وأعمالكم. (مسلم)',
    ],
  };

  List<String> get _currentHadiths => hadithsByLanguage[appLanguage] ?? hadithsByLanguage[AppLanguage.german]!;

  String get _hadithOfDayTitle {
    switch (appLanguage) {
      case AppLanguage.german:
        return '⭐ HADITH DES TAGES';
      case AppLanguage.english:
        return '⭐ HADITH OF THE DAY';
      case AppLanguage.arabic:
        return '⭐ حديث اليوم';
    }
  }

  String get _dailySwitchText {
    switch (appLanguage) {
      case AppLanguage.german:
        return '(Wechselt täglich automatisch)';
      case AppLanguage.english:
        return '(Changes automatically every day)';
      case AppLanguage.arabic:
        return '(يتغير تلقائيًا كل يوم)';
    }
  }

  String get _prayerTrackerTitle {
    switch (appLanguage) {
      case AppLanguage.german:
        return '🕌 GEBETE TRACKER';
      case AppLanguage.english:
        return '🕌 PRAYER TRACKER';
      case AppLanguage.arabic:
        return '🕌 متابعة الصلوات';
    }
  }

  String get _prayerTrackerHint {
    switch (appLanguage) {
      case AppLanguage.german:
        return 'Deine Statistik findest du in Mehr.';
      case AppLanguage.english:
        return 'You can view your prayer stats in More.';
      case AppLanguage.arabic:
        return 'يمكنك رؤية إحصائيات صلاتك في قسم المزيد.';
    }
  }

  String get _masbahaTitle {
    switch (appLanguage) {
      case AppLanguage.german:
        return 'Tasbih / Masbaha';
      case AppLanguage.english:
        return 'Tasbih / Masbaha';
      case AppLanguage.arabic:
        return 'السبحة / الذكر';
    }
  }

  String get _masbahaSubtitle {
    switch (appLanguage) {
      case AppLanguage.german:
        return 'Tippe, um deine Dhikr zu zählen';
      case AppLanguage.english:
        return 'Tap to count your Dhikr';
      case AppLanguage.arabic:
        return 'اضغط لعد الاذكار';
    }
  }

  @override
  void initState() {
    super.initState();
    appLanguage = widget.appLanguage;
    _initializeHome();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appLanguage != widget.appLanguage) {
      setState(() {
        appLanguage = widget.appLanguage;
      });
      _setDailyHadith();
    }
  }

  Future<void> _initializeHome() async {
    await _checkAndResetDaily();
    await _loadGebete();
    _setDailyHadith();
  }

  void _setDailyHadith() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    setState(() {
      hadithIndex = dayOfYear % _currentHadiths.length;
    });
  }

  Future<void> _checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final trackingDate = DateTime(now.year, now.month, now.day);
    final heuteString =
      '${trackingDate.year}-${trackingDate.month.toString().padLeft(2, '0')}-${trackingDate.day.toString().padLeft(2, '0')}';
    final gespeichertesDatum = prefs.getString('gebet_datum') ?? '';

    if (gespeichertesDatum != heuteString) {
      if (gespeichertesDatum.isNotEmpty) {
        final historyJson = prefs.getString(_prayerHistoryKey);
        final historyRaw = historyJson == null
            ? <String, dynamic>{}
            : (json.decode(historyJson) as Map<String, dynamic>);

        final previousPrayers = List<bool>.generate(
          5,
          (i) => prefs.getBool('gebet_$i') ?? false,
        );
        final completed =
            previousPrayers.where((isChecked) => isChecked).length;

        historyRaw[gespeichertesDatum] = {
          'completed': completed,
          'total': previousPrayers.length,
          'prayers': previousPrayers,
        };

        final keys = historyRaw.keys.toList()
          ..sort((a, b) => DateTime.tryParse(a)?.compareTo(DateTime.tryParse(b) ?? DateTime(1900)) ?? -1);
        while (keys.length > 120) {
          historyRaw.remove(keys.removeAt(0));
        }

        await prefs.setString(_prayerHistoryKey, json.encode(historyRaw));
      }

      for (int i = 0; i < 5; i++) {
        await prefs.setBool('gebet_$i', false);
      }
      await prefs.setString('gebet_datum', heuteString);
    }
  }

  Future<void> _loadGebete() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < 5; i++) {
        gebete[i] = prefs.getBool('gebet_$i') ?? false;
      }
    });
  }

  Future<void> _saveGebet(int index, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gebet_$index', value);
    final updated = List<bool>.from(gebete);
    updated[index] = value;
    setState(() {
      gebete = updated;
    });
  }

  String _openPrayerStatsLabel() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Open prayer statistics';
      case AppLanguage.arabic:
        return 'فتح إحصائيات الصلاة';
      case AppLanguage.german:
        return 'Gebetsstatistik öffnen';
    }
  }

  Future<List<MapEntry<String, Map<String, dynamic>>>> _loadPrayerHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_prayerHistoryKey);
    final historyRaw = historyJson == null
        ? <String, dynamic>{}
        : (json.decode(historyJson) as Map<String, dynamic>);

    final parsedHistory = <MapEntry<String, Map<String, dynamic>>>[];
    for (final entry in historyRaw.entries) {
      if (entry.value is Map<String, dynamic>) {
        parsedHistory.add(MapEntry(entry.key, entry.value as Map<String, dynamic>));
      } else if (entry.value is Map) {
        parsedHistory.add(MapEntry(entry.key, Map<String, dynamic>.from(entry.value as Map)));
      }
    }
    parsedHistory.sort((a, b) {
      final aDate = DateTime.tryParse(a.key) ?? DateTime(1900);
      final bDate = DateTime.tryParse(b.key) ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });
    return parsedHistory;
  }

  Future<void> _openPrayerStatisticsPage() async {
    final history = await _loadPrayerHistory();
    if (!mounted) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrayerStatisticsPage(
          appLanguage: appLanguage,
          prayerHistory: history,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _MyAppState.currentTheme.color, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    _prayerTrackerTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _prayerTrackerHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            gebetNamen[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _saveGebet(i, !gebete[i]),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: gebete[i]
                                    ? Colors.green
                                    : Colors.grey.shade700,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                gebete[i] ? Icons.check : Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: appLanguage == AppLanguage.arabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _openPrayerStatisticsPage,
                      icon: Icon(
                        Icons.calendar_month,
                        color: _MyAppState.currentTheme.color,
                        size: 18,
                      ),
                      label: Text(
                        _openPrayerStatsLabel(),
                        style: TextStyle(
                          color: _MyAppState.currentTheme.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _MyAppState.currentTheme.color, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    _hadithOfDayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _currentHadiths[hadithIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _dailySwitchText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MasbahaPage(language: appLanguage),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _MyAppState.currentTheme.color, width: 4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: _MyAppState.currentTheme.color,
                      size: 34,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _masbahaTitle,
                            style: TextStyle(
                              color: _MyAppState.currentTheme.color,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _masbahaSubtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _MyAppState.currentTheme.color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnglishQuranPage extends StatefulWidget {
  const EnglishQuranPage({super.key});

  @override
  State<EnglishQuranPage> createState() => _EnglishQuranPageState();
}

class _EnglishQuranPageState extends State<EnglishQuranPage> {
  List<dynamic> surahs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load surahs (${response.statusCode})');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final payload = data['data'];
      if (payload is! List) {
        throw Exception('Invalid response payload');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        surahs = payload;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        errorMessage = 'Could not load Quran list. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '📖 AL-QURAN (ENGLISH)',
                  style: TextStyle(
                    color: _MyAppState.currentTheme.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sahih International Translation',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: _MyAppState.currentTheme.color,
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white70, size: 44),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: _loadSurahs,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _MyAppState.currentTheme.color,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: surahs.length,
                        itemBuilder: (context, i) {
                          final surah = surahs[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SurahDetailPage(
                                    surahNumber: surah['number'],
                                    language: QuranLanguage.english,
                                    appLanguage: AppLanguage.english,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _MyAppState.currentTheme.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${surah['number']}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          surah['englishName'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${surah['numberOfAyahs']} Ayahs • ${surah['revelationType']}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    surah['name'],
                                    style: TextStyle(
                                      color: _MyAppState.currentTheme.color,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ==================== QURAN PAGE ====================
class QuranPage extends StatefulWidget {
  final AppLanguage appLanguage;

  const QuranPage({super.key, required this.appLanguage});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<dynamic> surahs = [];
  bool isLoading = true;
  QuranLanguage selectedLanguage = QuranLanguage.arabic;

  @override
  void initState() {
    super.initState();
    if (widget.appLanguage == AppLanguage.english) {
      selectedLanguage = QuranLanguage.english;
    } else if (widget.appLanguage == AppLanguage.german) {
      selectedLanguage = QuranLanguage.german;
    }
    loadLanguagePreference();
    loadSurahs();
  }

  Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('quran_language') ?? 'arabic';
    final fallback = widget.appLanguage == AppLanguage.english
        ? QuranLanguage.english
        : widget.appLanguage == AppLanguage.german
            ? QuranLanguage.german
            : QuranLanguage.arabic;
    setState(() {
      selectedLanguage = QuranLanguage.values.firstWhere(
        (lang) => lang.name == savedLang,
        orElse: () => fallback,
      );
    });
  }

  Future<void> saveLanguagePreference(QuranLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_language', language.name);
    setState(() {
      selectedLanguage = language;
    });
  }

  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _MyAppState.currentTheme.color, width: 2),
          ),
          title: Text(
            '🌍 Sprache wählen',
            style: TextStyle(
              color: _MyAppState.currentTheme.color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: QuranLanguage.values.map((language) {
              final isSelected = language == selectedLanguage;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : _MyAppState.currentTheme.color.withOpacity(0.3),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  tileColor: isSelected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  leading: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    language.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white,
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                      : null,
                  onTap: () {
                    saveLanguagePreference(language);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> loadSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          surahs = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildGermanPdfSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, color: _MyAppState.currentTheme.color, size: 90),
            const SizedBox(height: 24),
            Text(
              'Übersetzung des Heiligen Qurans',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Deutsche Übersetzung',
              style: TextStyle(color: Colors.white60, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GermanReaderPage(themeColor: _MyAppState.currentTheme.color),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text(
                'Quran auf Deutsch lesen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _MyAppState.currentTheme.color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '📖 AL-QURAN AL-KAREEM',
                  style: TextStyle(
                    color: _MyAppState.currentTheme.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: showLanguageDialog,
                  icon: Text(
                    selectedLanguage.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  label: Text(
                    selectedLanguage.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _MyAppState.currentTheme.color,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (selectedLanguage == QuranLanguage.german || widget.appLanguage == AppLanguage.german)
                ? _buildGermanPdfSection()
                : isLoading
                ? Center(
                    child: CircularProgressIndicator(color: _MyAppState.currentTheme.color),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: surahs.length,
                    itemBuilder: (context, i) {
                      final surah = surahs[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetailPage(
                                surahNumber: surah['number'],
                                language: selectedLanguage,
                                appLanguage: widget.appLanguage,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _MyAppState.currentTheme.color,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${surah['number']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah['englishName'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${surah['numberOfAyahs']} Ayahs • ${surah['revelationType']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                surah['name'],
                                style: TextStyle(
                                  color: _MyAppState.currentTheme.color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== GERMAN QURAN PDF PAGE ====================
// ==================== SURAH DETAIL PAGE ====================
class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final QuranLanguage language;
  final AppLanguage appLanguage;
  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.language,
    required this.appLanguage,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<dynamic> ayahs = [];
  bool isLoading = true;
  int currentPage = 0;
  String surahName = '';
  String surahNameArabic = '';
  AppLanguage _appLanguage = AppLanguage.german;

  final int ayahsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _appLanguage = widget.appLanguage;
    loadSurah();
  }

  bool get _isArabicUi => _appLanguage == AppLanguage.arabic;

  String _pageIndicatorLabel() {
    switch (_appLanguage) {
      case AppLanguage.english:
        return 'Page ${currentPage + 1} of $totalPages';
      case AppLanguage.arabic:
        return 'الصفحة ${currentPage + 1} من $totalPages';
      case AppLanguage.german:
        return 'Seite ${currentPage + 1} von $totalPages';
    }
  }

  String _nextButtonLabel() {
    switch (_appLanguage) {
      case AppLanguage.english:
        return 'Next';
      case AppLanguage.arabic:
        return 'التالي';
      case AppLanguage.german:
        return 'Weiter';
    }
  }

  String _previousButtonLabel() {
    switch (_appLanguage) {
      case AppLanguage.english:
        return 'Previous';
      case AppLanguage.arabic:
        return 'السابق';
      case AppLanguage.german:
        return 'Zurück';
    }
  }

  Future<void> loadSurah() async {
    try {
      final url = 'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/${widget.language.apiEdition}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final surahData = data['data'];

        setState(() {
          ayahs = (surahData['ayahs'] as List).map((ayah) {
            String text = ayah['text'];
            final verseNumber = ayah['numberInSurah'];

            if (verseNumber == 1 &&
                widget.surahNumber != 1 &&
                widget.surahNumber != 9) {
              if (text.length > 40 && text.startsWith('بِ')) {
                final runes = text.runes.toList();
                if (runes.length >= 39) {
                  text = String.fromCharCodes(runes.skip(39)).trim();
                }
              }
            }

            return {
              'verse_key': verseNumber.toString(),
              'text_uthmani': text,
            };
          }).toList();

          surahName = surahData['englishName'];
          surahNameArabic = surahData['name'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  int get totalPages => (ayahs.length / ayahsPerPage).ceil();

  List<dynamic> getCurrentPageAyahs() {
    int start = currentPage * ayahsPerPage;
    int end = (start + ayahsPerPage > ayahs.length)
        ? ayahs.length
        : start + ayahsPerPage;
    return ayahs.sublist(start, end);
  }

  void goToNextPage() {
    if (currentPage < totalPages - 1) {
      setState(() => currentPage++);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  List<InlineSpan> _buildPageContent() {
    List<InlineSpan> spans = [];
    final pageAyahs = getCurrentPageAyahs();

    if (pageAyahs.isEmpty) {
      return spans;
    }

    for (int i = 0; i < pageAyahs.length; i++) {
      final ayah = pageAyahs[i];
      final verseKey = ayah['verse_key'];
      final text = ayah['text_uthmani'];

      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.language == QuranLanguage.arabic ? 28 : 19,
          height: widget.language == QuranLanguage.arabic ? 2.2 : 1.9,
          fontFamily: widget.language == QuranLanguage.arabic
              ? GoogleFonts.amiriQuran().fontFamily
              : null,
          fontWeight: FontWeight.w400,
          letterSpacing: widget.language == QuranLanguage.arabic ? 0.5 : 0.3,
        ),
      ));

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              verseKey,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));

      if (i < pageAyahs.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Column(
          children: [
            Text(
              surahName,
              style: GoogleFonts.amiriQuran(
                color: const Color(0xFFD4AF37),
                fontSize: 20,
              ),
            ),
            Text(
              surahNameArabic,
              style: GoogleFonts.amiriQuran(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: _MyAppState.currentTheme.color),
            )
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        const Color(0xFF1a1a1a),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _pageIndicatorLabel(),
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.language == QuranLanguage.arabic
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: widget.language == QuranLanguage.arabic
                                    ? Colors.green
                                    : Colors.blue,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  widget.language.flag,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.language.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (widget.language == QuranLanguage.arabic) {
                            if (details.primaryVelocity! < 0) {
                              goToPreviousPage();
                            } else if (details.primaryVelocity! > 0) {
                              goToNextPage();
                            }
                          } else {
                            if (details.primaryVelocity! < 0) {
                              goToNextPage();
                            } else if (details.primaryVelocity! > 0) {
                              goToPreviousPage();
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF0D1117),
                                const Color(0xFF1a1f2e),
                                const Color(0xFF0D1117),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (currentPage == 0 &&
                                    widget.surahNumber != 1 &&
                                    widget.surahNumber != 9)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Text(
                                      widget.language == QuranLanguage.arabic
                                          ? 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'
                                          : widget.language == QuranLanguage.german
                                              ? 'Im Namen Allahs, des Allerbarmers, des Barmherzigen'
                                              : 'In the name of Allah, the Most Gracious, the Most Merciful',
                                      style: widget.language == QuranLanguage.arabic
                                          ? GoogleFonts.amiriQuran(
                                              color: const Color(0xFFD4AF37),
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            )
                                          : TextStyle(
                                              color: const Color(0xFFD4AF37),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                SelectableText.rich(
                                  TextSpan(
                                    children: _buildPageContent(),
                                  ),
                                  textAlign: widget.language == QuranLanguage.arabic
                                      ? TextAlign.right
                                      : TextAlign.justify,
                                  textDirection: widget.language == QuranLanguage.arabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _isArabicUi
                            ? [
                                ElevatedButton.icon(
                                  onPressed: currentPage < totalPages - 1
                                      ? goToNextPage
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(_nextButtonLabel()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor:
                                        Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: currentPage > 0
                                      ? goToPreviousPage
                                      : null,
                                  icon: const Icon(Icons.arrow_back),
                                  label: Text(_previousButtonLabel()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor:
                                        Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                ElevatedButton.icon(
                                  onPressed: currentPage > 0
                                      ? goToPreviousPage
                                      : null,
                                  icon: const Icon(Icons.arrow_back),
                                  label: Text(_previousButtonLabel()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor:
                                        Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: currentPage < totalPages - 1
                                      ? goToNextPage
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(_nextButtonLabel()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor:
                                        Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ==================== HADITH LANGUAGE MODEL ====================
enum HadithLanguage {
  arabic('العربية', 'ara-bukhari', '🇸🇦'),
  english('English', 'eng-bukhari', '🇬🇧');

  final String displayName;
  final String apiEdition;
  final String flag;
  const HadithLanguage(this.displayName, this.apiEdition, this.flag);
}

// ==================== SUNNAH PAGE ====================
class SunnahPage extends StatefulWidget {
  const SunnahPage({super.key});

  @override
  State<SunnahPage> createState() => _SunnahPageState();
}

class _SunnahPageState extends State<SunnahPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> hadiths = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;
  HadithLanguage selectedLanguage = HadithLanguage.english;

  @override
  void initState() {
    super.initState();
    loadHadiths();
  }

  Future<void> loadHadiths() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${selectedLanguage.apiEdition}.json');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loadedHadiths =
            List<Map<String, dynamic>>.from(data['hadiths']);

        setState(() {
          hadiths = loadedHadiths;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void changeLanguage(HadithLanguage language) {
    setState(() {
      selectedLanguage = language;
      hadiths = [];
    });
    loadHadiths();
  }

  Future<void> searchHadith(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isSearching = true;
      searchResults = [];
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final keywords = query.toLowerCase().split(' ');
    final filtered = hadiths.where((h) {
      final text = (h['text'] ?? '').toString();
      final searchText = selectedLanguage == HadithLanguage.arabic
          ? text
          : text.toLowerCase();
      return keywords
          .any((k) => k.length > 2 && searchText.contains(k));
    }).take(50).toList();

    setState(() {
      searchResults = filtered;
      isSearching = false;
    });
  }

  List<Map<String, dynamic>> getFilteredHadiths(String category) {
    final arabicKeywords = {
      'Faith': [
        'إيمان',
        'آمن',
        'مؤمن',
        'كفر',
        'شهادة',
        'توحيد',
        'قلب'
      ],
      'Ablution': [
        'وضوء',
        'توضأ',
        'غسل',
        'طهارة',
        'ماء',
        'يد',
        'رجل',
        'رأس'
      ],
      'Prayer': [
        'صلاة',
        'صلى',
        'يصلي',
        'ركع',
        'سجد',
        'قبلة',
        'مسجد',
        'إمام',
        'ركعة'
      ],
      'Zakat': ['زكاة', 'صدقة', 'أعطى', 'مال', 'فقير', 'مسكين'],
      'Fasting': ['صوم', 'صيام', 'صائم', 'رمضان', 'فطر', 'أفطر', 'سحور'],
      'Hajj': ['حج', 'عمرة', 'بيت', 'كعبة', 'مكة', 'طواف', 'سعى'],
      'Marriage': ['نكاح', 'زوج', 'امرأة', 'زواج', 'عرس', 'أهل'],
      'Divorce': ['طلاق', 'فراق', 'خلع'],
      'Business': ['بيع', 'شراء', 'تجارة', 'سوق', 'ثمن', 'دين', 'ربا'],
      'Jihad': ['جهاد', 'غزو', 'قتال', 'عدو', 'شهيد'],
      'Manners': ['أدب', 'خلق', 'حسن', 'برّ', 'صدق', 'سلام', 'جار'],
      'Dua': ['دعا', 'دعاء', 'استغفر', 'حمد', 'سبح', 'ذكر'],
      'Food': ['طعام', 'أكل', 'شرب', 'لحم', 'خبز', 'تمر', 'لبن'],
      'Knowledge': ['علم', 'عالم', 'فقه', 'حكمة', 'قرأ', 'كتاب', 'تعلم'],
      'Funerals': ['جنازة', 'ميت', 'موت', 'دفن', 'قبر'],
    };

    final englishKeywords = {
      'Faith': ['faith', 'belief', 'believe', 'muslim', 'testif', 'heart', 'deed'],
      'Ablution': [
        'ablution',
        'wudu',
        'wash',
        'water',
        'purif',
        'hand',
        'foot',
        'head'
      ],
      'Prayer': [
        'prayer',
        'pray',
        'salah',
        'salat',
        'bow',
        'prostrat',
        'mosque',
        'imam',
        'rakat'
      ],
      'Zakat': [
        'zakat',
        'charity',
        'sadaqah',
        'give',
        'gave',
        'wealth',
        'poor',
        'needy'
      ],
      'Fasting': [
        'fast',
        'fasting',
        'fasted',
        'ramadan',
        'iftar',
        'suhur',
        'hunger'
      ],
      'Hajj': [
        'hajj',
        'pilgrimage',
        'umrah',
        'kaaba',
        'mecca',
        'tawaf',
        'saee'
      ],
      'Marriage': [
        'marriage',
        'marry',
        'married',
        'wife',
        'husband',
        'wedding'
      ],
      'Divorce': ['divorce', 'divorced', 'separation'],
      'Business': [
        'business',
        'trade',
        'sell',
        'buy',
        'bought',
        'sold',
        'price',
        'debt',
        'riba'
      ],
      'Jihad': ['jihad', 'fight', 'fought', 'battle', 'enemy', 'martyr'],
      'Manners': [
        'manner',
        'character',
        'good',
        'kind',
        'honest',
        'truth',
        'neighbor',
        'greet'
      ],
      'Dua': [
        'supplication',
        'invoke',
        'pray',
        'forgive',
        'praise',
        'remember',
        'allah'
      ],
      'Food': [
        'food',
        'eat',
        'ate',
        'drink',
        'drank',
        'meat',
        'bread',
        'date',
        'milk'
      ],
      'Knowledge': [
        'knowledge',
        'know',
        'learn',
        'teach',
        'scholar',
        'wisdom',
        'book',
        'read'
      ],
      'Funerals': [
        'funeral',
        'dead',
        'death',
        'died',
        'bury',
        'burial',
        'grave'
      ],
    };

    final keywords = selectedLanguage == HadithLanguage.arabic
        ? arabicKeywords[category] ?? []
        : englishKeywords[category] ?? [];

    if (keywords.isEmpty) return [];

    final filtered = hadiths.where((h) {
      final text = (h['text'] ?? '').toString();
      if (selectedLanguage == HadithLanguage.arabic) {
        return keywords.any((k) => text.contains(k));
      } else {
        final lowerText = text.toLowerCase();
        return keywords.any((k) => lowerText.contains(k.toLowerCase()));
      }
    }).take(50).toList();

    return filtered;
  }

  List<Map<String, String>> getCategories() {
    switch (selectedLanguage) {
      case HadithLanguage.arabic:
        return [
          {'name': 'الإيمان', 'key': 'Faith'},
          {'name': 'الوضوء', 'key': 'Ablution'},
          {'name': 'الصلاة', 'key': 'Prayer'},
          {'name': 'الزكاة', 'key': 'Zakat'},
          {'name': 'الصوم', 'key': 'Fasting'},
          {'name': 'الحج', 'key': 'Hajj'},
          {'name': 'النكاح', 'key': 'Marriage'},
          {'name': 'الطلاق', 'key': 'Divorce'},
          {'name': 'البيوع', 'key': 'Business'},
          {'name': 'الجهاد', 'key': 'Jihad'},
          {'name': 'الأدب', 'key': 'Manners'},
          {'name': 'الدعاء', 'key': 'Dua'},
          {'name': 'الطعام', 'key': 'Food'},
          {'name': 'العلم', 'key': 'Knowledge'},
          {'name': 'الجنائز', 'key': 'Funerals'},
        ];
      case HadithLanguage.english:
        return [
          {'name': 'Faith (Iman)', 'key': 'Faith'},
          {'name': 'Ablution (Wudu)', 'key': 'Ablution'},
          {'name': 'Prayer (Salah)', 'key': 'Prayer'},
          {'name': 'Zakat (Charity)', 'key': 'Zakat'},
          {'name': 'Fasting (Ramadan)', 'key': 'Fasting'},
          {'name': 'Hajj (Pilgrimage)', 'key': 'Hajj'},
          {'name': 'Marriage & Family', 'key': 'Marriage'},
          {'name': 'Divorce', 'key': 'Divorce'},
          {'name': 'Business & Trade', 'key': 'Business'},
          {'name': 'Jihad', 'key': 'Jihad'},
          {'name': 'Manners (Adab)', 'key': 'Manners'},
          {'name': 'Supplication (Dua)', 'key': 'Dua'},
          {'name': 'Food & Drinks', 'key': 'Food'},
          {'name': 'Knowledge (Ilm)', 'key': 'Knowledge'},
          {'name': 'Funerals', 'key': 'Funerals'},
        ];
    }
  }

  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _MyAppState.currentTheme.color, width: 2),
        ),
        title: Text(
          '🌍 Sprache wählen',
          style: TextStyle(
              color: _MyAppState.currentTheme.color,
              fontSize: 22,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: HadithLanguage.values.map((lang) {
            final isSelected = lang == selectedLanguage;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        isSelected ? Colors.green : _MyAppState.currentTheme.color.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                tileColor: isSelected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                leading: Text(lang.flag, style: const TextStyle(fontSize: 32)),
                title: Text(
                  lang.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.green : Colors.white,
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                    : null,
                onTap: () {
                  changeLanguage(lang);
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              border: Border(
                  bottom: BorderSide(color: _MyAppState.currentTheme.color, width: 2)),
            ),
            child: Column(
              children: [
                Text(
                  '📖 Hadiths des Propheten ﷺ',
                  style: TextStyle(
                      color: _MyAppState.currentTheme.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: showLanguageDialog,
                  icon: Text(selectedLanguage.flag,
                      style: const TextStyle(fontSize: 20)),
                  label: Text(
                    selectedLanguage.displayName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _MyAppState.currentTheme.color,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Suche nach Thema (z.B. prayer, patience)...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: _MyAppState.currentTheme.color),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: _MyAppState.currentTheme.color),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchResults = []);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                  onSubmitted: searchHadith,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: _MyAppState.currentTheme.color))
                : isSearching
                    ? Center(
                        child: CircularProgressIndicator(
                            color: _MyAppState.currentTheme.color))
                    : searchResults.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final hadith = searchResults[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: _MyAppState.currentTheme.color, width: 2),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _MyAppState.currentTheme.color,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Sahih Bukhari - Hadith ${hadith['hadithnumber']}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      hadith['text'] ?? 'Kein Text verfügbar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: selectedLanguage ==
                                                HadithLanguage.arabic
                                            ? 20
                                            : 16,
                                        height: selectedLanguage ==
                                                HadithLanguage.arabic
                                            ? 2.0
                                            : 1.6,
                                        fontFamily: selectedLanguage ==
                                                HadithLanguage.arabic
                                            ? GoogleFonts.amiriQuran()
                                                .fontFamily
                                            : null,
                                      ),
                                      textAlign: selectedLanguage ==
                                              HadithLanguage.arabic
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      textDirection: selectedLanguage ==
                                              HadithLanguage.arabic
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: getCategories().length,
                            itemBuilder: (context, index) {
                              final category = getCategories()[index];
                              return GestureDetector(
                                onTap: () {
                                  final filtered =
                                      getFilteredHadiths(category['key']!);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HadithListPage(
                                            hadiths: filtered,
                                            categoryName: category['name']!,
                                            language: selectedLanguage,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.85),
                                    borderRadius:
                                        BorderRadius.circular(15),
                                    border: Border.all(
                                        color: _MyAppState.currentTheme.color, width: 2),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration:
                                            BoxDecoration(
                                          color: _MyAppState.currentTheme.color,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.auto_stories,
                                            color: Colors.black,
                                            size: 28),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          category['name']!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: selectedLanguage ==
                                                    HadithLanguage.arabic
                                                ? GoogleFonts.amiriQuran()
                                                    .fontFamily
                                                : null,
                                          ),
                                          textDirection: selectedLanguage ==
                                                  HadithLanguage.arabic
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                        ),
                                      ),
                                      const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                          size: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ==================== HADITH LIST PAGE ====================
class HadithListPage extends StatelessWidget {
  final List<Map<String, dynamic>> hadiths;
  final String categoryName;
  final HadithLanguage language;

  const HadithListPage({
    super.key,
    required this.hadiths,
    required this.categoryName,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.black,
        foregroundColor: _MyAppState.currentTheme.color,
      ),
      body: hadiths.isEmpty
          ? const Center(
              child: Text(
                'Keine Hadithe gefunden',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: hadiths.length,
              itemBuilder: (context, index) {
                final hadith = hadiths[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _MyAppState.currentTheme.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sahih Bukhari - Hadith ${hadith['hadithnumber']}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hadith['text'] ?? 'Kein Text verfügbar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              language == HadithLanguage.arabic ? 20 : 16,
                          height: language == HadithLanguage.arabic ? 2.0 : 1.6,
                          fontFamily: language == HadithLanguage.arabic
                              ? GoogleFonts.amiriQuran().fontFamily
                              : null,
                        ),
                        textAlign: language == HadithLanguage.arabic
                            ? TextAlign.right
                            : TextAlign.left,
                        textDirection: language == HadithLanguage.arabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ==================== SETTINGS PAGE ====================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppLanguage appLanguage = AppLanguage.german;
  AppBackground appBackground = AppBackground.defaultImage;
  int tasbihCount = 0;
  String selectedDhikr = 'SubhanAllah';
  List<MapEntry<String, Map<String, dynamic>>> _prayerHistory = [];

  static const String _prayerHistoryKey = 'gebet_history_v1';

  static const List<String> dhikrOptions = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'Astaghfirullah',
    'La ilaha illa Allah',
    'SubhanAllahi wa bihamdihi',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language') ?? 'de';
    final backgroundAsset = prefs.getString('app_background');
    final savedDhikr = prefs.getString('tasbih_dhikr') ?? dhikrOptions.first;
    final countsJson = prefs.getString('tasbih_counts_by_dhikr');
    final countsRaw = countsJson == null
      ? <String, dynamic>{}
      : (json.decode(countsJson) as Map<String, dynamic>);
    final legacyCount = prefs.getInt('tasbih_count') ?? 0;
    final historyJson = prefs.getString(_prayerHistoryKey);
    final historyRaw = historyJson == null
        ? <String, dynamic>{}
        : (json.decode(historyJson) as Map<String, dynamic>);
    final selected = dhikrOptions.contains(savedDhikr)
      ? savedDhikr
      : dhikrOptions.first;
    final savedCount = (countsRaw[selected] as num?)?.toInt() ?? legacyCount;
    final parsedHistory = <MapEntry<String, Map<String, dynamic>>>[];
    for (final entry in historyRaw.entries) {
      if (entry.value is Map<String, dynamic>) {
        parsedHistory.add(MapEntry(entry.key, entry.value as Map<String, dynamic>));
      } else if (entry.value is Map) {
        parsedHistory.add(MapEntry(entry.key, Map<String, dynamic>.from(entry.value as Map)));
      }
    }
    parsedHistory.sort((a, b) {
      final aDate = DateTime.tryParse(a.key) ?? DateTime(1900);
      final bDate = DateTime.tryParse(b.key) ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

    setState(() {
      appLanguage = AppLanguage.values.firstWhere(
        (l) => l.code == langCode,
        orElse: () => AppLanguage.german,
      );
      appBackground = AppBackground.fromAssetPath(backgroundAsset);
      selectedDhikr = selected;
      tasbihCount = savedCount;
      _prayerHistory = parsedHistory;
    });
  }

  String _prayerStatsTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Prayer Statistics';
      case AppLanguage.arabic:
        return 'إحصائيات الصلاة';
      case AppLanguage.german:
        return 'Gebetsstatistik';
    }
  }

  String _prayerStatsSubtitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Calendar view of your recent prayer days';
      case AppLanguage.arabic:
        return 'عرض تقويمي لأيام صلاتك الأخيرة';
      case AppLanguage.german:
        return 'Kalenderansicht deiner letzten Gebetstage';
    }
  }

  String _prayerStatsEmptyLabel() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'No prayer days saved yet. Your own entries will appear here.';
      case AppLanguage.arabic:
        return 'لا توجد أيام صلاة محفوظة بعد. ستظهر بياناتك أنت فقط هنا.';
      case AppLanguage.german:
        return 'Noch keine Gebetstage gespeichert. Hier erscheinen nur deine eigenen Daten.';
    }
  }

  String _prayerStatsOpenHint() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Tap to open calendar';
      case AppLanguage.arabic:
        return 'اضغط لفتح التقويم';
      case AppLanguage.german:
        return 'Tippe, um den Kalender zu öffnen';
    }
  }

  String _prayerStatsDoneLabel(int completed, int total) {
    switch (appLanguage) {
      case AppLanguage.english:
        return '$completed of $total prayers';
      case AppLanguage.arabic:
        return '$completed من $total صلوات';
      case AppLanguage.german:
        return '$completed von $total Gebeten';
    }
  }

  Future<void> _changeLanguage(AppLanguage newLang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLang.code);
    setState(() => appLanguage = newLang);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (route) => false,
      );
    }
  }

  Future<void> _changeTheme(AppTheme newTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', newTheme.index);
    setState(() {});
    _MyAppState.updateTheme(context, newTheme);
  }

  Future<void> _changeBackground(AppBackground newBackground) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_background', newBackground.assetPath);
    setState(() => appBackground = newBackground);
    _MyAppState.updateBackground(context, newBackground);
  }
  Map<String, int> _getHijriDateParts() {
    final now = DateTime.now();
    int day = now.day;
    int month = now.month;
    int year = now.year;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    final a = year ~/ 100;
    final b = 2 - a + (a ~/ 4);
    final jd = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;

    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = (((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719)) +
        ((l ~/ 5670) * ((43 * l) ~/ 15238));
    l = l - (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) -
        ((j ~/ 16) * ((15238 * j) ~/ 43)) +
        29;
    final hijriMonth = (24 * l) ~/ 709;
    final hijriDay = l - ((709 * hijriMonth) ~/ 24);
    final hijriYear = 30 * n + j - 30;

    return {
      'day': hijriDay,
      'month': hijriMonth,
      'year': hijriYear,
    };
  }

  List<String> _getHijriMonths() {
    switch (appLanguage) {
      case AppLanguage.english:
        return const [
          'Muharram',
          'Safar',
          'Rabi al-Awwal',
          'Rabi al-Thani',
          'Jumada al-Ula',
          'Jumada al-Akhirah',
          'Rajab',
          'Shaaban',
          'Ramadan',
          'Shawwal',
          'Dhul Qadah',
          'Dhul Hijjah',
        ];
      case AppLanguage.arabic:
        return const [
          'محرم',
          'صفر',
          'ربيع الأول',
          'ربيع الآخر',
          'جمادى الأولى',
          'جمادى الآخرة',
          'رجب',
          'شعبان',
          'رمضان',
          'شوال',
          'ذو القعدة',
          'ذو الحجة',
        ];
      case AppLanguage.german:
        return const [
          'Muharram',
          'Safar',
          'Rabi al-Awwal',
          'Rabi ath-Thani',
          'Dschumada al-Ula',
          'Dschumada al-Akhira',
          'Radschab',
          'Schaban',
          'Ramadan',
          'Schawwal',
          'Dhu al-Qada',
          'Dhu al-Hiddscha',
        ];
    }
  }

  String _calendarTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Islamic Calendar';
      case AppLanguage.arabic:
        return 'التقويم الإسلامي';
      case AppLanguage.german:
        return 'Islamischer Kalender';
    }
  }

  String _tasbihTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Masbaha';
      case AppLanguage.arabic:
        return 'مسبحة';
      case AppLanguage.german:
        return 'Masbaha';
    }
  }

  String _todayLabel() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Today';
      case AppLanguage.arabic:
        return 'اليوم';
      case AppLanguage.german:
        return 'Heute';
    }
  }

  String _settingsTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'More';
      case AppLanguage.arabic:
        return 'المزيد';
      case AppLanguage.german:
        return 'Mehr';
    }
  }

  String _backgroundTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Background';
      case AppLanguage.arabic:
        return 'الخلفية';
      case AppLanguage.german:
        return 'Hintergrund';
    }
  }

  String _languageTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Language';
      case AppLanguage.arabic:
        return 'اللغة';
      case AppLanguage.german:
        return 'Sprache';
    }
  }

  String _themeTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Color Theme';
      case AppLanguage.arabic:
        return 'نظام الألوان';
      case AppLanguage.german:
        return 'Farbthema';
    }
  }

  String _aboutTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'About the App';
      case AppLanguage.arabic:
        return 'حول التطبيق';
      case AppLanguage.german:
        return 'Über die App';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsHistory = _prayerHistory;
    final isPreview = _prayerHistory.isEmpty;
    final completedTotal = statsHistory.fold<int>(
      0,
      (sum, entry) => sum + ((entry.value['completed'] as num?)?.toInt() ?? 0),
    );
    final totalPrayers = statsHistory.fold<int>(
      0,
      (sum, entry) => sum + ((entry.value['total'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: _MyAppState.currentTheme.color, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    _settingsTitle(),
                    style: TextStyle(
                      color: _MyAppState.currentTheme.color,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image,
                                color: _MyAppState.currentTheme.color, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              _backgroundTitle(),
                              style: TextStyle(
                                color: _MyAppState.currentTheme.color,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: AppBackground.values.map((background) {
                            final isSelected = appBackground == background;
                            return GestureDetector(
                              onTap: () => _changeBackground(background),
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? _MyAppState.currentTheme.color
                                        : _MyAppState.currentTheme.color.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        background.assetPath,
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            background.label,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle,
                                              color: _MyAppState.currentTheme.color,
                                              size: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Builder(
                      builder: (context) {
                        final hijri = _getHijriDateParts();
                        final months = _getHijriMonths();
                        final monthName = months[hijri['month']! - 1];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month,
                                    color: _MyAppState.currentTheme.color, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  _calendarTitle(),
                                  style: TextStyle(
                                    color: _MyAppState.currentTheme.color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _MyAppState.currentTheme.color.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _todayLabel(),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${hijri['day']}. $monthName ${hijri['year']} AH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrayerStatisticsPage(
                            appLanguage: appLanguage,
                            prayerHistory: _prayerHistory,
                          ),
                        ),
                      );
                      _loadSettings();
                    },
                    child: _buildCard(
                      child: Row(
                        children: [
                          Icon(Icons.query_stats,
                              color: _MyAppState.currentTheme.color, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _prayerStatsTitle(),
                                  style: TextStyle(
                                    color: _MyAppState.currentTheme.color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _prayerStatsSubtitle(),
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _prayerStatsDoneLabel(completedTotal, totalPrayers),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                if (isPreview)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _prayerStatsEmptyLabel(),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  _prayerStatsOpenHint(),
                                  style: TextStyle(
                                    color: _MyAppState.currentTheme.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: _MyAppState.currentTheme.color, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MasbahaPage(language: appLanguage),
                        ),
                      );
                      _loadSettings();
                    },
                    child: _buildCard(
                      child: Row(
                        children: [
                          Icon(Icons.touch_app,
                              color: _MyAppState.currentTheme.color, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tasbihTitle(),
                                  style: TextStyle(
                                    color: _MyAppState.currentTheme.color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$selectedDhikr  •  $tasbihCount',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: _MyAppState.currentTheme.color, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.language,
                                color: _MyAppState.currentTheme.color, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              _languageTitle(),
                              style: TextStyle(
                                color: _MyAppState.currentTheme.color,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...AppLanguage.values
                            .map((lang) => GestureDetector(
                              onTap: () => _changeLanguage(lang),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: appLanguage == lang
                                      ? _MyAppState.currentTheme.color.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.3),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: appLanguage == lang
                                        ? _MyAppState.currentTheme.color
                                        : _MyAppState.currentTheme.color
                                            .withOpacity(0.3),
                                    width: appLanguage == lang ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      lang.flag,
                                      style: const TextStyle(
                                          fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      lang.displayName,
                                      style: TextStyle(
                                        color: appLanguage == lang
                                            ? _MyAppState.currentTheme.color
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: appLanguage == lang
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (appLanguage == lang)
                                      Icon(Icons.check_circle,
                                          color: _MyAppState.currentTheme.color,
                                          size: 20),
                                  ],
                                ),
                              ),
                            ))
                            ,
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.palette,
                                color: _MyAppState.currentTheme.color, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              _themeTitle(),
                              style: TextStyle(
                                color: _MyAppState.currentTheme.color,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              AppTheme.values
                                  .map((theme) => GestureDetector(
                                    onTap: () => _changeTheme(theme),
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: theme.color
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _MyAppState.currentTheme == theme
                                              ? theme.color
                                              : theme.color
                                                  .withOpacity(0.3),
                                          width: _MyAppState.currentTheme == theme ? 3 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: theme.color,
                                              shape: BoxShape.circle,
                                            ),
                                            child: _MyAppState.currentTheme == theme
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 24)
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            theme.name.split(' ')[0],
                                            style: TextStyle(
                                              color: theme.color,
                                              fontSize: 12,
                                              fontWeight: _MyAppState.currentTheme == theme
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: _MyAppState.currentTheme.color, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              _aboutTitle(),
                              style: TextStyle(
                                color: _MyAppState.currentTheme.color,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Version',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                            const Text(
                              '1.0.0',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Quran & Hadith App',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: _MyAppState.currentTheme.color.withOpacity(0.3), width: 1),
      ),
      child: child,
    );
  }
}

class PrayerStatisticsPage extends StatefulWidget {
  final AppLanguage appLanguage;
  final List<MapEntry<String, Map<String, dynamic>>> prayerHistory;

  const PrayerStatisticsPage({
    super.key,
    required this.appLanguage,
    required this.prayerHistory,
  });

  @override
  State<PrayerStatisticsPage> createState() => _PrayerStatisticsPageState();
}

class _PrayerStatisticsPageState extends State<PrayerStatisticsPage> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  String _title() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Prayer Statistics';
      case AppLanguage.arabic:
        return 'إحصائيات الصلاة';
      case AppLanguage.german:
        return 'Gebetsstatistik';
    }
  }

  String _subtitle() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Monthly prayer calendar';
      case AppLanguage.arabic:
        return 'تقويم الصلاة الشهري';
      case AppLanguage.german:
        return 'Monatlicher Gebetskalender';
    }
  }

  String _previewLabel() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'No prayer days saved yet. Your own entries will appear here.';
      case AppLanguage.arabic:
        return 'لا توجد أيام صلاة محفوظة بعد. ستظهر بياناتك أنت فقط هنا.';
      case AppLanguage.german:
        return 'Noch keine Gebetstage gespeichert. Hier erscheinen nur deine eigenen Daten.';
    }
  }

  String _monthLabel(DateTime date) {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return const [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ][date.month - 1];
      case AppLanguage.arabic:
        return const [
          'يناير',
          'فبراير',
          'مارس',
          'ابريل',
          'مايو',
          'يونيو',
          'يوليو',
          'اغسطس',
          'سبتمبر',
          'اكتوبر',
          'نوفمبر',
          'ديسمبر',
        ][date.month - 1];
      case AppLanguage.german:
        return const [
          'Januar',
          'Februar',
          'März',
          'April',
          'Mai',
          'Juni',
          'Juli',
          'August',
          'September',
          'Oktober',
          'November',
          'Dezember',
        ][date.month - 1];
    }
  }

  String _weekdayShortLabel(int weekday) {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];
      case AppLanguage.arabic:
        return const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'][weekday - 1];
      case AppLanguage.german:
        return const ['M', 'D', 'M', 'D', 'F', 'S', 'S'][weekday - 1];
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showDayDetailDialog(DateTime date, Map<String, dynamic> entry) {
    final completed = (entry['completed'] as num?)?.toInt() ?? 0;
    final total = (entry['total'] as num?)?.toInt() ?? 5;
    final rawPrayers = entry['prayers'];
    final prayerList = rawPrayers is List
        ? rawPrayers.map((e) => e == true).toList()
        : null;

    final prayerNames = switch (widget.appLanguage) {
      AppLanguage.german => [
          'Fajr – Morgengebet',
          'Dhuhr – Mittagsgebet',
          'Asr – Nachmittagsgebet',
          'Maghrib – Abendgebet',
          'Isha – Nachtgebet',
        ],
      AppLanguage.english => ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
      AppLanguage.arabic => ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'],
    };

    final title = '${date.day}. ${_monthLabel(date)} ${date.year}';
    final closeLabel = switch (widget.appLanguage) {
      AppLanguage.german => 'Schließen',
      AppLanguage.english => 'Close',
      AppLanguage.arabic => 'إغلاق',
    };

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _MyAppState.currentTheme.color, width: 2),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: _MyAppState.currentTheme.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: widget.appLanguage == AppLanguage.arabic
              ? TextAlign.right
              : TextAlign.left,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (i) {
              final done = prayerList != null && i < prayerList.length
                  ? prayerList[i]
                  : i < completed;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color:
                          done ? const Color(0xFF45B97C) : const Color(0xFFD95D39),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      prayerNames[i],
                      style: TextStyle(
                        color: done ? const Color(0xFF45B97C) : const Color(0xFFD95D39),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            const Divider(color: Colors.white24),
            Text(
              '$completed / $total',
              style: TextStyle(
                color: _MyAppState.currentTheme.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              closeLabel,
              style: TextStyle(color: _MyAppState.currentTheme.color),
            ),
          ),
        ],
      ),
    );
  }

  Color _prayerDayColor(int completed) {
    if (completed >= 5) {
      return const Color(0xFF45B97C);
    }
    if (completed >= 3) {
      return const Color(0xFFE3B341);
    }
    return const Color(0xFFD95D39);
  }

  IconData _prayerDayIcon(int completed) {
    if (completed >= 5) return Icons.star_rounded;
    if (completed >= 3) return Icons.star_half_rounded;
    return Icons.star_border_rounded;
  }

  List<DateTime?> _calendarCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final leading = firstDay.weekday - 1;
    final total = leading + lastDay.day;
    final trailing = (7 - (total % 7)) % 7;
    final cells = <DateTime?>[];

    for (int index = 0; index < leading; index++) {
      cells.add(null);
    }

    for (int day = 1; day <= lastDay.day; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }

    for (int index = 0; index < trailing; index++) {
      cells.add(null);
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = widget.prayerHistory.isEmpty;
    final effectiveHistory = widget.prayerHistory;
    final historyMap = {for (final entry in effectiveHistory) entry.key: entry.value};
    final cells = _calendarCells(_currentMonth);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title(),
                          style: TextStyle(
                            color: _MyAppState.currentTheme.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _subtitle(),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _MyAppState.currentTheme.color.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month - 1,
                                    1,
                                  );
                                });
                              },
                              icon: const Icon(Icons.chevron_left, color: Colors.white),
                            ),
                            Expanded(
                              child: Text(
                                '${_monthLabel(_currentMonth)} ${_currentMonth.year}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _MyAppState.currentTheme.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month + 1,
                                    1,
                                  );
                                });
                              },
                              icon: const Icon(Icons.chevron_right, color: Colors.white),
                            ),
                          ],
                        ),
                        if (isPreview)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _previewLabel(),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Row(
                          children: List.generate(7, (index) {
                            final weekday = index + 1;
                            return Expanded(
                              child: Center(
                                child: Text(
                                  _weekdayShortLabel(weekday),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cells.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final date = cells[index];
                            if (date == null) {
                              return const SizedBox.shrink();
                            }

                            final entry = historyMap[_dateKey(date)];
                            final completed = (entry?['completed'] as num?)?.toInt();
                            final total = (entry?['total'] as num?)?.toInt() ?? 5;
                            final hasData = completed != null;
                            final dayColor = hasData
                                ? _prayerDayColor(completed)
                                : Colors.white10;

                            return GestureDetector(
                              onTap: hasData
                                  ? () => _showDayDetailDialog(date, entry!)
                                  : null,
                              child: Container(
                              decoration: BoxDecoration(
                                color: dayColor.withOpacity(hasData ? 0.9 : 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasData ? dayColor : Colors.white12,
                                  width: 1.4,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          color: hasData ? Colors.black87 : Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      hasData ? _prayerDayIcon(completed) : Icons.circle,
                                      size: hasData ? 20 : 8,
                                      color: hasData ? Colors.black87 : Colors.white24,
                                    ),
                                    Text(
                                      hasData ? '$completed/$total' : '-',
                                      style: TextStyle(
                                        color: hasData ? Colors.black87 : Colors.white54,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),  // Container
                            );  // GestureDetector
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  final AppLanguage appLanguage;

  const PrayerTimesPage({super.key, required this.appLanguage});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  bool _isLoading = false;
  bool _awaitingUserTrigger = true;
  String? _errorMessage;
  String _locationLabel = '';
  DateTime? _lastUpdated;
  Map<String, String> _timings = {};
  String? _nextPrayerName;
  String? _nextPrayerTime;
  String? _remainingLabel;

  @override
  void initState() {
    super.initState();
    // On web (iOS Safari etc.) geolocation must be triggered by a user gesture.
    // Auto-load only for native apps.
    if (!kIsWeb) {
      _awaitingUserTrigger = false;
      _loadPrayerTimes();
    }
  }

  String _title() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Prayer Times';
      case AppLanguage.arabic:
        return 'أوقات الصلاة';
      case AppLanguage.german:
        return 'Gebetszeiten';
    }
  }

  String _subtitle() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Based on your current location';
      case AppLanguage.arabic:
        return 'بناءً على موقعك الحالي';
      case AppLanguage.german:
        return 'Basierend auf deinem aktuellen Standort';
    }
  }

  String _refreshLabel() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Refresh';
      case AppLanguage.arabic:
        return 'تحديث';
      case AppLanguage.german:
        return 'Aktualisieren';
    }
  }

  String _locationUnavailableLabel() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Location unavailable';
      case AppLanguage.arabic:
        return 'الموقع غير متاح';
      case AppLanguage.german:
        return 'Standort nicht verfügbar';
    }
  }

  String _nextPrayerLabel() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Next prayer';
      case AppLanguage.arabic:
        return 'الصلاة القادمة';
      case AppLanguage.german:
        return 'Nächstes Gebet';
    }
  }

  String _updatedLabel(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Updated at $hh:$mm';
      case AppLanguage.arabic:
        return 'آخر تحديث $hh:$mm';
      case AppLanguage.german:
        return 'Aktualisiert um $hh:$mm';
    }
  }

  String _inLabel(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'in ${hours}h ${minutes}m';
      case AppLanguage.arabic:
        return 'بعد $hoursس $minutesد';
      case AppLanguage.german:
        return 'in ${hours}h ${minutes}min';
    }
  }

  String _timeParseError() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Could not load prayer times right now.';
      case AppLanguage.arabic:
        return 'تعذر تحميل أوقات الصلاة الآن.';
      case AppLanguage.german:
        return 'Gebetszeiten konnten gerade nicht geladen werden.';
    }
  }

  String _localizedPrayerName(String key) {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return key;
      case AppLanguage.arabic:
        switch (key) {
          case 'Fajr':
            return 'الفجر';
          case 'Dhuhr':
            return 'الظهر';
          case 'Asr':
            return 'العصر';
          case 'Maghrib':
            return 'المغرب';
          case 'Isha':
            return 'العشاء';
          default:
            return key;
        }
      case AppLanguage.german:
        switch (key) {
          case 'Fajr':
            return 'Fajr';
          case 'Dhuhr':
            return 'Dhuhr';
          case 'Asr':
            return 'Asr';
          case 'Maghrib':
            return 'Maghrib';
          case 'Isha':
            return 'Isha';
          default:
            return key;
        }
    }
  }

  String _normalizeTime(String raw) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match == null) {
      return raw;
    }
    final hour = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  DateTime _toDateTimeToday(String hhmm) {
    final parts = hhmm.split(':');
    final now = DateTime.now();
    final h = int.tryParse(parts.first) ?? 0;
    final m = int.tryParse(parts.last) ?? 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  Future<Map<String, dynamic>> _resolveCoordinatesFromIp() async {
    final response = await http.get(Uri.parse('https://ipapi.co/json/'));
    if (response.statusCode != 200) {
      throw Exception(_locationUnavailableLabel());
    }

    final payload = json.decode(response.body) as Map<String, dynamic>;
    final latitude = (payload['latitude'] as num?)?.toDouble();
    final longitude = (payload['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      throw Exception(_locationUnavailableLabel());
    }

    final city = '${payload['city'] ?? ''}'.trim();
    final country = '${payload['country_name'] ?? ''}'.trim();
    final label = [city, country]
        .where((part) => part.isNotEmpty)
        .join(', ');

    return {
      'latitude': latitude,
      'longitude': longitude,
      'label': label.isEmpty
          ? '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}'
          : '$label (IP)',
    };
  }

  Future<Map<String, dynamic>> _resolveCoordinates() async {
    // Web fallback: if browser/plugin geolocation fails, use IP location.
    if (kIsWeb) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high),
        );
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'label':
              '${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}',
        };
      } catch (_) {
        return _resolveCoordinatesFromIp();
      }
    }

    final position = await _resolvePosition();
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'label':
          '${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}',
    };
  }

  Future<Position> _resolvePosition() async {
    // isLocationServiceEnabled / checkPermission are not implemented in
    // geolocator_web.  On web the browser shows its own permission prompt when
    // getCurrentPosition is called, so we can skip those checks entirely.
    if (!kIsWeb) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(_locationUnavailableLabel());
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(_locationUnavailableLabel());
      }
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  void _computeNextPrayer(Map<String, String> timings) {
    final order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final now = DateTime.now();

    for (final prayer in order) {
      final time = timings[prayer];
      if (time == null) {
        continue;
      }
      final dateTime = _toDateTimeToday(time);
      if (dateTime.isAfter(now)) {
        _nextPrayerName = _localizedPrayerName(prayer);
        _nextPrayerTime = time;
        _remainingLabel = _inLabel(dateTime.difference(now));
        return;
      }
    }

    final fajrTime = timings['Fajr'];
    if (fajrTime != null) {
      final tomorrow = _toDateTimeToday(fajrTime).add(const Duration(days: 1));
      _nextPrayerName = _localizedPrayerName('Fajr');
      _nextPrayerTime = fajrTime;
      _remainingLabel = _inLabel(tomorrow.difference(now));
    }
  }

  String _loadLocationLabel() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Determine location & load prayer times';
      case AppLanguage.arabic:
        return 'تحديد الموقع وتحميل أوقات الصلاة';
      case AppLanguage.german:
        return 'Standort bestimmen & Gebetszeiten laden';
    }
  }

  String _locationInfoLabel() {
    switch (widget.appLanguage) {
      case AppLanguage.english:
        return 'Your location is only used to calculate local prayer times and is never stored or transmitted.';
      case AppLanguage.arabic:
        return 'يُستخدم موقعك فقط لحساب أوقات الصلاة المحلية ولا يتم تخزينه أو إرساله.';
      case AppLanguage.german:
        return 'Dein Standort wird nur zur Berechnung der lokalen Gebetszeiten genutzt und nie gespeichert oder weitergegeben.';
    }
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _awaitingUserTrigger = false;
    });

    try {
      final coords = await _resolveCoordinates();
      final latitude = (coords['latitude'] as num).toDouble();
      final longitude = (coords['longitude'] as num).toDouble();
      final label = '${coords['label'] ?? ''}'.trim();
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=3',
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(_timeParseError());
      }

      final payload = json.decode(response.body) as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final rawTimings = data?['timings'] as Map<String, dynamic>?;
      if (rawTimings == null) {
        throw Exception(_timeParseError());
      }

      final parsed = <String, String>{
        'Fajr': _normalizeTime('${rawTimings['Fajr'] ?? ''}'),
        'Dhuhr': _normalizeTime('${rawTimings['Dhuhr'] ?? ''}'),
        'Asr': _normalizeTime('${rawTimings['Asr'] ?? ''}'),
        'Maghrib': _normalizeTime('${rawTimings['Maghrib'] ?? ''}'),
        'Isha': _normalizeTime('${rawTimings['Isha'] ?? ''}'),
      };

      _computeNextPrayer(parsed);

      if (!mounted) {
        return;
      }

      setState(() {
        _timings = parsed;
        _lastUpdated = DateTime.now();
        _locationLabel = label;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildTimingCard(String prayer, String time) {
    final color = _MyAppState.currentTheme.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.24), Colors.black.withOpacity(0.45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.access_time_filled, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _localizedPrayerName(prayer),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(),
                    style: TextStyle(
                      color: _MyAppState.currentTheme.color,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (_locationLabel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _locationLabel,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_awaitingUserTrigger)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
                      child: Column(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: _MyAppState.currentTheme.color, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _locationInfoLabel(),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadPrayerTimes,
                            icon: const Icon(Icons.my_location),
                            label: Text(_loadLocationLabel(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _MyAppState.currentTheme.color,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.45)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadPrayerTimes,
                            child: Text(_refreshLabel()),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (_nextPrayerName != null && _nextPrayerTime != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _MyAppState.currentTheme.color.withOpacity(0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active,
                                color: _MyAppState.currentTheme.color),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nextPrayerLabel(),
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  Text(
                                    '$_nextPrayerName • $_nextPrayerTime',
                                    style: TextStyle(
                                      color: _MyAppState.currentTheme.color,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_remainingLabel != null)
                                    Text(
                                      _remainingLabel!,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ..._timings.entries.map((entry) {
                      return _buildTimingCard(entry.key, entry.value);
                    }),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_lastUpdated != null)
                          Text(
                            _updatedLabel(_lastUpdated!),
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        TextButton.icon(
                          onPressed: _loadPrayerTimes,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(_refreshLabel()),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MASBAHA PAGE ====================
class MasbahaPage extends StatefulWidget {
  final AppLanguage language;
  const MasbahaPage({super.key, required this.language});

  @override
  State<MasbahaPage> createState() => _MasbahaPageState();
}

class _MasbahaPageState extends State<MasbahaPage> {
  int tasbihCount = 0;
  String selectedDhikr = 'SubhanAllah';
  Map<String, int> _countsByDhikr = {};
  bool _hasSeenIntro = false;
  static const String _introSeenKey = 'masbaha_intro_seen_v1';

  static const List<String> _dhikrOptions = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'Astaghfirullah',
    'La ilaha illa Allah',
    'SubhanAllahi wa bihamdihi',
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
    _showIntroIfFirstTime();
  }

  String _introTitle() {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Erinnerung an Allah (Dhikr)';
      case AppLanguage.english:
        return 'Remembrance of Allah (Dhikr)';
      case AppLanguage.arabic:
        return 'ذكر الله (الذِّكر)';
    }
  }

  String _introBody() {
    switch (widget.language) {
      case AppLanguage.german:
    return '''Das Gedenken an Allah (Dhikr) gehört zu den wichtigsten Taten im Islam. Durch Dhikr erinnert sich der Gläubige an seinen Schöpfer, stärkt seinen Glauben und erhält großen Lohn. Allah lobt diejenigen, die Ihn häufig gedenken:

  „O ihr, die ihr glaubt, gedenkt Allahs in häufigem Gedenken.“
  — Qur'an 33:41

  Der Gesandte Allahs Muhammad ﷺ lehrte viele kurze Worte des Dhikr, die leicht zu sprechen sind, aber einen großen Lohn bringen.

  Zu den bekanntesten gehören:

  Subhanallah (Gepriesen sei Allah)
  Alhamdulillah (Alles Lob gebührt Allah)
  Allahu Akbar (Allah ist der Größte)

  Der Prophet ﷺ sagte:

  „Wer nach jedem Pflichtgebet 33-mal Subhanallah, 33-mal Alhamdulillah und 34-mal Allahu Akbar sagt, dem werden seine Sünden vergeben, auch wenn sie so zahlreich sind wie der Schaum des Meeres.“
  — Überliefert in Sahih Muslim

  In einer anderen Überlieferung sagte der Prophet ﷺ:

  „Zwei Worte sind leicht auf der Zunge, schwer auf der Waage und geliebt beim Allerbarmer:
  Subhanallahi wa bihamdihi, Subhanallahil-‘Azim.“
  — Überliefert in Sahih al-Bukhari und Sahih Muslim

  Dhikr kann mit den Fingern oder mit einer Zählhilfe (Masbaha) gezählt werden. Diese Funktion in der App hilft dir dabei, deine Dhikr zu zählen und eine Übersicht darüber zu behalten, wie oft du bestimmte Worte des Gedenkens gesagt hast.

  Dhikr kann fast überall gemacht werden – zum Beispiel nach dem Gebet, vor dem Schlafen, auf dem Weg zur Arbeit oder Schule, beim Warten auf den Bus oder in ruhigen Momenten des Tages. So kannst du deinen Tag immer wieder mit der Erinnerung an Allah füllen.''';
      case AppLanguage.english:
    return '''The remembrance of Allah (Dhikr) is one of the greatest acts of worship in Islam. Through Dhikr, a believer remembers their Lord, strengthens their faith, and grows closer to Allah. Allah commands the believers in the Qur'an:

  “O you who believe, remember Allah with much remembrance.”
  — Surah Al-Ahzab (33:41)

  Allah also tells us that remembering Him brings peace to the heart:

  “Indeed, in the remembrance of Allah do hearts find rest.”
  — Surah Ar-Ra'd (13:28)

  The Prophet Muhammad ﷺ taught his followers simple words of remembrance that are easy to say but bring great reward.

  Among the most well-known are:

  Subhanallah (Glory be to Allah)
  Alhamdulillah (All praise is due to Allah)
  Allahu Akbar (Allah is the Greatest)

  The Prophet ﷺ said:

  “Whoever says Subhanallah 33 times, Alhamdulillah 33 times, and Allahu Akbar 34 times after every obligatory prayer will have his sins forgiven, even if they are like the foam of the sea.”
  — Narrated in Sahih Muslim

  The Prophet ﷺ also said:

  “Two words are light on the tongue, heavy on the scale, and beloved to the Most Merciful:
  Subhanallahi wa bihamdihi, Subhanallahil-‘Azim.”
  — Narrated in Sahih al-Bukhari and Sahih Muslim

  A Muslim can remember Allah at many moments throughout the day—after prayer, before sleep, while traveling to work or school, while waiting for the bus, or during quiet moments.

  Dhikr can be counted using the fingers or a prayer counter (Masbaha). This feature in the app helps you keep track of your Dhikr and see how many times you have remembered Allah.

  Remembering Allah regularly brings peace to the heart and strengthens the connection between the believer and their Lord.''';
      case AppLanguage.arabic:
    return '''يُعَدُّ ذكرُ الله تعالى من أعظم العبادات في الإسلام، فهو سببٌ لزيادة الإيمان وتقريبِ العبد من ربّه. وقد أمر الله تعالى المؤمنين بالإكثار من ذكره فقال:

  ﴿يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا﴾
  — سورة الأحزاب، الآية 41

  كما بيّن الله سبحانه أن ذكره سببٌ لطمأنينة القلوب وسكون النفوس، فقال:

  ﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾
  — سورة الرعد، الآية 28

  وقد علَّم النبي محمد ﷺ أمّتَه أذكارًا يسيرةً على اللسان، عظيمةً في الأجر عند الله، ومن أشهرها:

  سبحان الله
  الحمد لله
  الله أكبر

  قال رسول الله ﷺ:

  «مَن سبَّح اللهَ دبرَ كلِّ صلاةٍ ثلاثًا وثلاثين، وحمِد اللهَ ثلاثًا وثلاثين، وكبَّر اللهَ أربعًا وثلاثين، غُفِرَت له خطاياه وإن كانت مثل زبد البحر».

  — رواه صحيح مسلم

  وقال النبي ﷺ أيضًا:

  «كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ:
  سُبْحَانَ اللَّهِ وَبِحَمْدِهِ،
  سُبْحَانَ اللَّهِ الْعَظِيمِ».

  — رواه صحيح البخاري و صحيح مسلم

  ويستطيع المسلم أن يذكر الله في أوقاتٍ كثيرة من يومه، مثل بعد الصلاة، وقبل النوم، وأثناء الطريق إلى العمل أو الدراسة، أو عند انتظار الحافلة، أو في أوقات الفراغ.

  ويمكن عدّ الأذكار بالأصابع أو باستخدام السبحة. وتساعدك هذه الميزة في التطبيق على عدّ الأذكار وتسجيلها، حتى تتمكّن من معرفة عدد المرات التي ذكرت فيها الله ومتابعة ذكرك بشكلٍ منتظم.

  فالذكر عبادة عظيمة، يقرّب العبد من ربّه ويملأ القلب بالسكينة والطمأنينة.''';
    }
  }

  String _introContinueLabel() {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Verstanden';
      case AppLanguage.english:
        return 'Got it';
      case AppLanguage.arabic:
        return 'فهمت';
    }
  }

  Future<void> _showIntroDialog({required bool firstTime}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !firstTime,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _MyAppState.currentTheme.color, width: 2),
          ),
          title: Text(
            _introTitle(),
            style: TextStyle(
              color: _MyAppState.currentTheme.color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign:
                widget.language == AppLanguage.arabic ? TextAlign.right : TextAlign.left,
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Text(
                _introBody(),
                textDirection:
                    widget.language == AppLanguage.arabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign:
                    widget.language == AppLanguage.arabic ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _MyAppState.currentTheme.color,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                _introContinueLabel(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (firstTime) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_introSeenKey, true);
      if (mounted) {
        setState(() {
          _hasSeenIntro = true;
        });
      }
    }
  }

  Future<void> _showIntroIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeen = prefs.getBool(_introSeenKey) ?? false;
    if (!mounted) {
      return;
    }

    setState(() {
      _hasSeenIntro = alreadySeen;
    });

    if (alreadySeen) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      await _showIntroDialog(firstTime: true);
    });
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDhikr = prefs.getString('tasbih_dhikr') ?? _dhikrOptions.first;
    final countsJson = prefs.getString('tasbih_counts_by_dhikr');
    final countsRaw = countsJson == null
        ? <String, dynamic>{}
        : (json.decode(countsJson) as Map<String, dynamic>);
    final parsedCounts = <String, int>{
      for (final entry in countsRaw.entries)
        entry.key: (entry.value as num).toInt(),
    };
    final selected = _dhikrOptions.contains(savedDhikr)
        ? savedDhikr
        : _dhikrOptions.first;
    final savedCount = parsedCounts[selected] ?? 0;
    if (mounted) {
      setState(() {
        _countsByDhikr = parsedCounts;
        selectedDhikr = selected;
        tasbihCount = savedCount;
      });
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasbih_counts_by_dhikr', json.encode(_countsByDhikr));
    await prefs.setString('tasbih_dhikr', selectedDhikr);
  }

  Future<void> _increment() async {
    setState(() {
      tasbihCount = (_countsByDhikr[selectedDhikr] ?? 0) + 1;
      _countsByDhikr[selectedDhikr] = tasbihCount;
    });
    await _saveState();
  }

  Future<void> _reset() async {
    setState(() {
      tasbihCount = 0;
      _countsByDhikr[selectedDhikr] = 0;
    });
    await _saveState();
  }

  String _title() {
    switch (widget.language) {
      case AppLanguage.arabic:
        return 'مسبحة';
      case AppLanguage.german:
      case AppLanguage.english:
        return 'Masbaha';
    }
  }

  String _resetLabel() {
    switch (widget.language) {
      case AppLanguage.english:
        return 'Reset';
      case AppLanguage.arabic:
        return 'إعادة';
      case AppLanguage.german:
        return 'Zurücksetzen';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppBackground>(
      valueListenable: _MyAppState.backgroundNotifier,
      builder: (context, background, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Image.asset(
                background.assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(0.65),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _title(),
                            style: TextStyle(
                              color: _MyAppState.currentTheme.color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: _introTitle(),
                            onPressed: () => _showIntroDialog(firstTime: false),
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: _MyAppState.currentTheme.color,
                                  size: 24,
                                ),
                                if (!_hasSeenIntro)
                                  Positioned(
                                    top: -1,
                                    right: -1,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black, width: 0.8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _MyAppState.currentTheme.color
                                .withOpacity(0.5),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedDhikr,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1a1a1a),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                            items: _dhikrOptions.map((dhikr) {
                              return DropdownMenuItem<String>(
                                value: dhikr,
                                child: Text(dhikr),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedDhikr = value;
                                  tasbihCount = _countsByDhikr[value] ?? 0;
                                });
                                _saveState();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: _increment,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _MyAppState.currentTheme.color,
                                  _MyAppState.currentTheme.color
                                      .withOpacity(0.65),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _MyAppState.currentTheme.color
                                      .withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$tasbihCount',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    selectedDhikr,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: TextButton.icon(
                        onPressed: _reset,
                        icon: Icon(Icons.refresh,
                            color: _MyAppState.currentTheme.color,
                            size: 28),
                        label: Text(
                          _resetLabel(),
                          style: TextStyle(
                            color: _MyAppState.currentTheme.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AllahName {
  final int number;
  final String arabic;
  final String transliteration;
  final String meaningDe;
  final String meaningEn;
  final String meaningAr;

  const _AllahName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaningDe,
    required this.meaningEn,
    required this.meaningAr,
  });

  String meaning(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return meaningEn;
      case AppLanguage.arabic:
        return meaningAr;
      case AppLanguage.german:
        return meaningDe;
    }
  }
}

class NamesOfAllahPage extends StatefulWidget {
  const NamesOfAllahPage({super.key});

  @override
  State<NamesOfAllahPage> createState() => _NamesOfAllahPageState();
}

class _NamesOfAllahPageState extends State<NamesOfAllahPage> {
  AppLanguage appLanguage = AppLanguage.german;
  bool _hasSeenIntro = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const String _introSeenKey = 'names_of_allah_intro_seen_v1';

  static const String _detailsRawDe = '''
1. Ar-Rahman (الرَّحْمٰن) – Der Allerbarmer: Allah umfasst Seine Schöpfung mit unermesslicher, allumfassender Barmherzigkeit.
2. Ar-Rahim (الرَّحِيم) – Der Barmherzige: Allah schenkt Seinen Dienern fortwährende und besondere Barmherzigkeit.
3. Al-Malik (الْمَلِك) – Der König: Allah ist der wahre Herrscher über alles. Niemand besitzt Herrschaft wie Er.
4. Al-Quddus (الْقُدُّوس) – Der Allheilige / Der Reine: Allah ist vollkommen rein von jedem Mangel und jeder Unvollkommenheit.
5. As-Salam (السَّلَام) – Der Friede / Die Quelle des Friedens: Von Allah kommt wahrer Frieden, Sicherheit und Unversehrtheit.
6. Al-Mu’min (الْمُؤْمِن) – Der Sicherheit Gebende: Allah gibt Schutz, Sicherheit und bestätigt die Wahrheit.
7. Al-Muhaymin (الْمُهَيْمِن) – Der Wächter / Der Bewahrende: Allah wacht über alles, bewahrt alles und entgeht nichts.
8. Al-‘Aziz (الْعَزِيز) – Der Allmächtige: Allah ist unbesiegbar, mächtig und unübertrefflich in Stärke.
9. Al-Jabbar (الْجَبَّار) – Der Erhabene, Der Wiederherstellende: Allah setzt Seinen Willen durch und heilt, richtet und stellt wieder her.
10. Al-Mutakabbir (الْمُتَكَبِّر) – Der Majestätische / Der Überragend Große: Allah allein besitzt wahre Größe und Erhabenheit.
11. Al-Khaliq (الْخَالِق) – Der Schöpfer: Allah erschafft alles aus Seinem Willen heraus.
12. Al-Bari’ (الْبَارِئ) – Der Erschaffer / Der Hervorbringer: Allah bringt die Schöpfung passend und vollkommen hervor.
13. Al-Musawwir (الْمُصَوِّر) – Der Gestalter: Allah gibt jeder Schöpfung ihre Form, Gestalt und ihr Aussehen.
14. Al-Ghaffar (الْغَفَّار) – Der Vielvergebende: Allah vergibt immer wieder, selbst wenn der Mensch oft Fehler macht.
15. Al-Qahhar (الْقَهَّار) – Der Allbezwingende: Alles untersteht Allahs Macht; nichts kann sich Seiner Herrschaft entziehen.
16. Al-Wahhab (الْوَهَّاب) – Der Schenkende: Allah gibt großzügig, ohne Gegenleistung zu brauchen.
17. Ar-Razzaq (الرَّزَّاق) – Der Versorger: Allah versorgt alle Geschöpfe mit allem, was sie brauchen.
18. Al-Fattah (الْفَتَّاح) – Der Öffnende / Der Entscheider: Allah öffnet Wege, Türen der Barmherzigkeit und entscheidet gerecht.
19. Al-‘Alim (الْعَلِيم) – Der Allwissende: Allah weiß alles – das Sichtbare, das Verborgene, das Vergangene und das Zukünftige.
20. Al-Qabid (الْقَابِض) – Der Verengende / Zurückhaltende: Allah hält zurück oder verengt nach Seiner Weisheit.
21. Al-Basit (الْبَاسِط) – Der Ausweitende: Allah erweitert Versorgung, Erleichterung und Gnade, wie Er will.
22. Al-Khafid (الْخَافِض) – Der Erniedrigende: Allah erniedrigt, wen Er nach Seiner Gerechtigkeit und Weisheit will.
23. Ar-Rafi‘ (الرَّافِع) – Der Erhöhende: Allah erhöht Rang, Ehre und Stellung, wem Er will.
24. Al-Mu‘izz (الْمُعِزُّ) – Der Ehre Gebende: Allah verleiht wahre Würde und Ansehen.
25. Al-Mudhill / Al-Muzill (ٱلْمُذِلُّ) – Der Erniedrigende: Allah nimmt Ehre von wem Er will, in vollkommener Gerechtigkeit.
26. As-Sami‘ (السَّمِيع) – Der Allhörende: Allah hört jedes Wort, jeden Laut und jedes stille Bittgebet.
27. Al-Basir (الْبَصِير) – Der Allsehende: Allah sieht alles, offen und verborgen.
28. Al-Hakam (الْحَكَم) – Der Richter: Allah urteilt vollkommen gerecht und ohne Fehler.
29. Al-‘Adl (الْعَدْل) – Der Gerechteste: Allah ist in jeder Entscheidung vollkommen gerecht.
30. Al-Latif (اللَّطِيف) – Der Feine / Der Sanftgütige: Allah kennt die feinsten Dinge und ist in Seiner Güte sanft zu Seinen Dienern.
31. Al-Khabir (الْخَبِير) – Der Allkundige: Allah kennt die innersten Realitäten und Hintergründe aller Dinge.
32. Al-Halim (الْحَلِيم) – Der Nachsichtige: Allah straft nicht voreilig und zeigt große Geduld.
33. Al-‘Azim (الْعَظِيم) – Der Großartige: Allah ist unermesslich groß in Wesen, Macht und Majestät.
34. Al-Ghafur (الْغَفُور) – Der Allvergebende: Allah vergibt Sünden umfassend und bedeckt Fehler.
35. Ash-Shakur (الشَّكُور) – Der Dankbar Anerkennende: Allah würdigt selbst kleine gute Taten und belohnt sie vielfach.
36. Al-‘Aliyy (الْعَلِيُّ) – Der Allerhöchste: Allah ist hoch erhaben über alles Geschaffene.
37. Al-Kabir (الْكَبِير) – Der Allergrößte: Allah ist größer als alles, was man sich vorstellen kann.
38. Al-Hafiz / Al-Hafidh (الْحَفِيظ) – Der Bewahrer: Allah schützt und bewahrt Seine Schöpfung.
39. Al-Muqit (المُقيِت) – Der Erhalter / Ernährer: Allah gibt Kraft, Unterhalt und das, wodurch Geschöpfe bestehen.
40. Al-Hasib (اﻟْﺣَسِيب) – Der Abrechnende / Der Genügende: Allah genügt Seinen Dienern und rechnet alles genau ab.
41. Al-Jalil (الْجَلِيل) – Der Majestätische: Allah besitzt höchste Erhabenheit und Würde.
42. Al-Karim (الْكَرِيم) – Der Großzügige: Allah gibt edel, reichlich und aus Gnade.
43. Ar-Raqib (الرَّقِيب) – Der Wachende: Allah beobachtet alles und entgeht nichts.
44. Al-Mujib (ٱلْمُجِيب) – Der Erhörende: Allah antwortet auf Bittgebete und Anrufungen.
45. Al-Wasi‘ (الْوَاسِعُ) – Der Allumfassende: Allahs Wissen, Barmherzigkeit und Macht umfassen alles.
46. Al-Hakim (الْحَكِيم) – Der Allweise: Allah handelt immer mit vollkommener Weisheit.
47. Al-Wadud (الْوَدُود) – Der Liebevolle: Allah liebt Seine rechtschaffenen Diener und schenkt ihnen Liebe.
48. Al-Majid (الْمَجِيد) – Der Glorreiche: Allah ist vollkommen in Ehre, Ruhm und Größe.
49. Al-Ba‘ith (الْبَاعِث) – Der Erweckende: Allah wird die Toten auferwecken und ins Leben zurückbringen.
50. Ash-Shahid (الشَّهِيد) – Der Zeuge: Allah ist über alles Zeuge. Nichts geschieht außerhalb Seines Wissens.
51. Al-Haqq (الْحَقُّ) – Die Wahrheit: Allah ist die absolute Wahrheit; Sein Wort und Sein Versprechen sind wahr.
52. Al-Wakil (الْوَكِيل) – Der Sachwalter / Der Vertrauenswürdige Helfer: Auf Allah kann man sich vollkommen verlassen.
53. Al-Qawiyy (الْقَوِيُّ) – Der Allstarke: Allah besitzt vollkommene Stärke, ohne Schwäche.
54. Al-Matin (الْمَتِين) – Der Unerschütterliche / Der Feste: Allahs Kraft ist beständig und vollkommen fest.
55. Al-Waliyy (الْوَلِيُّ) – Der Schutzherr / Nahe Helfer: Allah ist der Beschützer und Unterstützer der Gläubigen.
56. Al-Hamid (الْحَمِيد) – Der Preiswürdige: Allah ist in Sich selbst aller Lobpreisung würdig.
57. Al-Muhsi (الْمُحْصِي) – Der Alles Zählende: Allah kennt und erfasst alles bis ins Kleinste.
58. Al-Mubdi’ (الْمُبْدِئ) – Der Anfänger / Ursprunggeber: Allah beginnt die Schöpfung aus dem Nichts.
59. Al-Mu‘id (ٱلْمُعِيد) – Der Wiederbringende: Allah bringt die Schöpfung nach ihrem Ende erneut zurück.
60. Al-Muhyi (الْمُحْيِي) – Der Leben Gebende: Allah schenkt Leben, wem und wann Er will.
61. Al-Mumit (اَلْمُمِيت) – Der den Tod Bestimmende: Allah bestimmt den Tod und lässt sterben.
62. Al-Hayy (الْحَيُّ) – Der Ewig Lebendige: Allah lebt ewig, vollkommen und ohne Ende.
63. Al-Qayyum (الْقَيُّوم) – Der Beständige / Der Erhaltende: Allah besteht aus Sich selbst und erhält alles andere.
64. Al-Wajid (الْوَاجِدُ) – Der Findende / Der, Dem nichts fehlt: Allah findet alles, weiß alles und fehlt an nichts.
65. Al-Majid (الْمَاجِدُ) – Der Ruhmvolle: Allah ist reich an Ehre, Adel und Vollkommenheit.
66. Al-Wahid (الْوَاحِدُ) – Der Eine: Allah ist einzig in Seinem Wesen, ohne Partner.
67. Al-Ahad (اَلاَحَدُ) – Der Einzig Eine: Allah ist absolut einzigartig und unvergleichbar.
68. As-Samad (الصَّمَدُ) – Der Unabhängige, Zu Dem alle sich wenden: Allah braucht niemanden, aber alle brauchen Ihn.
69. Al-Qadir (الْقَادِرُ) – Der Allmächtige: Allah hat vollkommene Macht über alles.
70. Al-Muqtadir (الْمُقْتَدِرُ) – Der Vollkommen Mächtige: Allahs Macht ist vollkommen wirksam und unbeschränkt.
71. Al-Muqaddim (الْمُقَدِّمُ) – Der Voranstellende: Allah bringt nach Seiner Weisheit voran, wen oder was Er will.
72. Al-Mu’akhkhir (الْمُؤَخِّرُ) – Der Zurückstellende: Allah hält nach Seiner Weisheit zurück oder verzögert.
73. Al-Awwal (الأوَّلُ) – Der Erste: Allah war vor allem; nichts ist vor Ihm.
74. Al-Akhir (الآخِرُ) – Der Letzte: Allah bleibt nach allem; nichts ist nach Ihm.
75. Az-Zahir (الظَّاهِرُ) – Der Offenkundige / Der Hocherhabene: Allah ist über allem erhaben und Seine Zeichen sind klar sichtbar.
76. Al-Batin (الْبَاطِنُ) – Der Verborgene: Allah ist dem innersten Verstehen verborgen, und nichts Verborgenes entgeht Ihm.
77. Al-Wali (الْوَالِي) – Der Herrscher / Verwalter: Allah lenkt und regiert alle Angelegenheiten.
78. Al-Muta‘ali (الْمُتَعَالِي) – Der Höchsterhabene: Allah ist weit über jede Unvollkommenheit und jedes Geschöpf erhaben.
79. Al-Barr (الْبَرُّ) – Der Gütige / Der Wohltätige: Allah ist vollkommen gut und handelt mit Güte gegenüber Seinen Dienern.
80. At-Tawwab (التَّوَابُ) – Der Reue-Annehmende: Allah nimmt Reue immer wieder an.
81. Al-Muntaqim (الْمُنْتَقِمُ) – Der Vergeltende: Allah übt gerechte Vergeltung gegen Unrecht, wenn Er will.
82. Al-‘Afuww (العَفُوُّ) – Der Verzeihende: Allah löscht Sünden aus und vergibt großzügig.
83. Ar-Ra’uf (الرَّؤُوف) – Der Allgütige / Der Mitleidsvolle: Allah ist äußerst mild und gütig zu Seinen Dienern.
84. Malik-ul-Mulk (مَالِكُ الْمُلْك) – Der Besitzer aller Herrschaft: Jede Macht und jedes Reich gehören in Wahrheit Allah allein.
85. Dhul-Jalali wal-Ikram (ذُوالْجَلاَلِ وَالإكْرَام) – Der Besitzer von Majestät und Ehre: Allah vereint vollkommene Erhabenheit, Würde und Großzügigkeit.
86. Al-Muqsit (الْمُقْسِط) – Der Gerechte: Allah stellt Gerechtigkeit vollkommen her.
87. Al-Jami‘ (الْجَامِعُ) – Der Versammelnde: Allah sammelt die Menschen am Tag des Gerichts und vereint, was Er will.
88. Al-Ghaniyy (ٱلْغَنيُّ) – Der Unabhängige / Reiche: Allah ist auf nichts angewiesen.
89. Al-Mughni (ٱلْمُغْنِيُّ) – Der Bereichernde: Allah macht reich, genügsam und unabhängig, wem Er will.
90. Al-Mani‘ (اَلْمَانِعُ) – Der Verwehrende: Allah hält nach Seiner Weisheit zurück, was Er will.
91. Ad-Darr (الضَّار) – Der, in Dessen Hand Schaden liegt: Nichts trifft jemanden außer mit Allahs Zulassung und Weisheit.
92. An-Nafi‘ (النَّافِع) – Der Nutzen Schenkende: Jeder wahre Nutzen kommt letztlich von Allah.
93. An-Nur (النُّور) – Das Licht: Allah ist das Licht der Himmel und der Erde und der Geber von Rechtleitung.
94. Al-Hadi (الْهَادِي) – Der Rechtleitende: Allah führt, wen Er will, zum rechten Weg.
95. Al-Badi‘ (الْبَدِيع) – Der Einzigartige Erschaffer: Allah erschafft auf unvergleichliche Weise ohne Vorbild.
96. Al-Baqi (اَلْبَاقِي) – Der Ewig Bleibende: Allah vergeht nie; Seine Existenz ist ohne Ende.
97. Al-Warith (الْوَارِث) – Der Erbe: Alles kehrt letztlich zu Allah zurück.
98. Ar-Rashid (الرَّشِيد) – Der Rechtleitende mit vollkommener Weisheit: Allah führt stets auf die vollkommen richtige Weise.
99. As-Sabur (الصَّبُور) – Der Geduldige / Der Langmütige: Allah straft nicht übereilt und gibt den Menschen Zeit.
''';

  static const String _detailsRawAr = '''
1. الرحمن: واسع الرحمة التي شملت جميع الخلق.
2. الرحيم: الرحيم بعباده رحمةً خاصة، يرحمهم ويهديهم ويغفر لهم.
3. الملك: المالك المتصرف في كل شيء، له السلطان الكامل.
4. القدوس: المنزَّه عن كل نقص وعيب.
5. السلام: السالم من كل نقص، ومنه الأمن والسلام.
6. المؤمن: الذي يمنح الأمان ويصدق وعده لعباده.
7. المهيمن: الرقيب الحافظ لكل شيء.
8. العزيز: القوي الغالب الذي لا يُغلب.
9. الجبار: العالي القاهر، ويجبر كسر عباده ويصلح أحوالهم.
10. المتكبر: المتفرد بالعظمة والكبرياء الحقة.
11. الخالق: الذي أوجد الخلق من العدم.
12. البارئ: الذي خلق الخلق وأبرزهم على ما أراد.
13. المصور: الذي أعطى كل مخلوق صورته وهيئته.
14. الغفار: كثير المغفرة لعباده.
15. القهار: الذي قهر كل شيء وخضع له كل شيء.
16. الوهاب: كثير العطاء بلا مقابل.
17. الرزاق: الذي يرزق جميع خلقه.
18. الفتاح: الذي يفتح أبواب الرحمة والرزق والحكم بين عباده بالحق.
19. العليم: الذي أحاط علمه بكل شيء.
20. القابض: الذي يقبض الرزق أو يضيقه بحكمته.
21. الباسط: الذي يوسع الرزق والرحمة لمن يشاء.
22. الخافض: الذي يخفض من يشاء بحكمته وعدله.
23. الرافع: الذي يرفع من يشاء مكانةً وقدرًا.
24. المعز: الذي يمنح العزة لمن يشاء.
25. المذل: الذي يذل من يشاء بعدله.
26. السميع: الذي يسمع كل شيء، السر والجهر.
27. البصير: الذي يرى كل شيء، الظاهر والخفي.
28. الحكم: الذي يحكم بين عباده بالعدل والحق.
29. العدل: الكامل في عدله، لا يظلم أحدًا.
30. اللطيف: الذي يلطف بعباده ويعلم دقائق الأمور.
31. الخبير: الذي يعلم بواطن الأمور وخفاياها.
32. الحليم: الذي لا يعجل بالعقوبة مع قدرته.
33. العظيم: العظيم في ذاته وصفاته وقدره.
34. الغفور: كثير المغفرة والستر للذنوب.
35. الشكور: الذي يقبل القليل من العمل ويعطي عليه الكثير من الثواب.
36. العلي: العالي فوق خلقه بقدره وقهره.
37. الكبير: العظيم الجليل الذي كل شيء دونه صغير.
38. الحفيظ: الحافظ لعباده وأعمالهم وكل شيء.
39. المقيت: الذي يوصل القوت والرزق ويحفظ به الأبدان.
40. الحسيب: الكافي لعباده، والذي يحاسب الخلق على أعمالهم.
41. الجليل: المتصف بالجلال والعظمة والكمال.
42. الكريم: كثير الخير والعطاء والإحسان.
43. الرقيب: المطلع على كل شيء، لا يغيب عنه شيء.
44. المجيب: الذي يجيب دعاء عباده.
45. الواسع: الواسع في رحمته وعلمه وقدرته.
46. الحكيم: الذي يضع الأشياء في مواضعها بحكمة تامة.
47. الودود: المحب لعباده المؤمنين، والمحبوب إليهم.
48. المجيد: العظيم في مجده وشرفه وكماله.
49. الباعث: الذي يبعث الخلق بعد الموت.
50. الشهيد: الذي لا يغيب عنه شيء، وهو شاهد على كل شيء.
51. الحق: الثابت الحق في ذاته ووعده وقوله.
52. الوكيل: الذي يُعتمد عليه في كل الأمور، وكفى به وكيلًا.
53. القوي: الكامل في القوة، لا يعجزه شيء.
54. المتين: الشديد القوي الذي لا يلحقه ضعف.
55. الولي: الناصر والمتولي لأمور عباده المؤمنين.
56. الحميد: المستحق للحمد كله.
57. المحصي: الذي أحصى كل شيء عددًا وعلمًا.
58. المبدئ: الذي بدأ الخلق أول مرة.
59. المعيد: الذي يعيد الخلق بعد الموت.
60. المحيي: الذي يهب الحياة لمن يشاء.
61. المميت: الذي يقدر الموت على من يشاء.
62. الحي: الكامل في حياته، حياته أزلية أبدية.
63. القيوم: القائم بنفسه، المقيم لغيره، الذي تقوم به السماوات والأرض.
64. الواجد: الغني الذي لا يفتقر إلى أحد، ولا يعجزه شيء.
65. الماجد: الكامل في الشرف والمجد والعظمة.
66. الواحد: المنفرد في ذاته وصفاته وأفعاله.
67. الأحد: المتفرد الذي لا نظير له ولا شبيه.
68. الصمد: الذي تصمد إليه الخلائق في حوائجها، وهو غني عن الجميع.
69. القادر: الذي له القدرة الكاملة على كل شيء.
70. المقتدر: البالغ كمال القدرة والنفوذ في كل أمر.
71. المقدم: الذي يقدم من يشاء ويقربه بحكمته.
72. المؤخر: الذي يؤخر من يشاء بحكمته.
73. الأول: الذي ليس قبله شيء.
74. الآخر: الذي ليس بعده شيء.
75. الظاهر: العالي فوق كل شيء، الظاهر بآياته.
76. الباطن: الذي لا تدركه الأبصار، وهو العالم بخفايا الأمور.
77. الوالي: المتولي لجميع الخلق بالتدبير والتصرف.
78. المتعالي: المتنزه عن صفات النقص، العالي جدًا فوق خلقه.
79. البر: كثير الإحسان واللطف بعباده.
80. التواب: الذي يوفق للتوبة ويقبلها من عباده.
81. المنتقم: الذي ينتقم من الظالمين بعدله.
82. العفو: الذي يمحو الذنوب ويتجاوز عنها.
83. الرؤوف: شديد الرحمة واللطف بعباده.
84. مالك الملك: الذي له الملك كله، يعطيه من يشاء وينزعه ممن يشاء.
85. ذو الجلال والإكرام: صاحب العظمة والكبرياء والكرم.
86. المقسط: العادل الذي يقيم القسط بين عباده.
87. الجامع: الذي يجمع الخلائق ليوم لا ريب فيه.
88. الغني: الذي لا يحتاج إلى أحد، وكل الخلق محتاجون إليه.
89. المغني: الذي يغني من يشاء بفضله.
90. المانع: الذي يمنع ما يشاء بحكمته.
91. الضار: الذي لا يقع ضر إلا بإذنه وحكمته.
92. النافع: الذي بيده النفع كله.
93. النور: نور السماوات والأرض، ومنوِّر القلوب بالهداية.
94. الهادي: الذي يهدي من يشاء إلى الصراط المستقيم.
95. البديع: الذي أبدع الخلق على غير مثال سابق.
96. الباقي: الذي لا يزول ولا يفنى.
97. الوارث: الذي يرث الأرض ومن عليها، وإليه يرجع كل شيء.
98. الرشيد: الذي يهدي إلى الصواب، وكل تدبيره رشد وحكمة.
99. الصبور: الذي لا يعجل بالعقوبة، مع كمال قدرته.
''';

  static const String _detailsRawEn = '''
1. Ar-Rahman — The Most Compassionate: His mercy is vast and encompasses all creation.
2. Ar-Rahim — The Most Merciful: He shows special mercy to His servants.
3. Al-Malik — The King: He is the true sovereign over everything.
4. Al-Quddus — The Most Holy / The Most Pure: He is completely free from every imperfection.
5. As-Salam — The Source of Peace: True peace, safety, and perfection come from Him.
6. Al-Mu’min — The Giver of Security: He grants safety, faith, and reassurance.
7. Al-Muhaymin — The Guardian / The Preserver: He watches over and protects all things.
8. Al-‘Aziz — The Almighty: He is mighty, honored, and never overcome.
9. Al-Jabbar — The Compeller / The Restorer: His will is irresistible, and He also restores what is broken.
10. Al-Mutakabbir — The Supreme / The Majestic: True greatness and majesty belong to Him alone.
11. Al-Khaliq — The Creator: He creates all things from nothing.
12. Al-Bari’ — The Originator: He brings creation into existence in perfect order.
13. Al-Musawwir — The Fashioner: He gives every created thing its form and appearance.
14. Al-Ghaffar — The Ever-Forgiving: He forgives again and again.
15. Al-Qahhar — The All-Subduer: Everything is under His complete power.
16. Al-Wahhab — The Bestower: He gives generously without needing anything in return.
17. Ar-Razzaq — The Provider: He provides sustenance for all creation.
18. Al-Fattah — The Opener / The Judge: He opens doors of mercy, victory, and provision, and judges with truth.
19. Al-‘Alim — The All-Knowing: He knows everything, seen and unseen.
20. Al-Qabid — The Withholder: He withholds or constricts by His wisdom.
21. Al-Basit — The Expander: He expands provision, mercy, and ease as He wills.
22. Al-Khafid — The Humbler: He lowers whom He wills in justice and wisdom.
23. Ar-Rafi‘ — The Exalter: He raises whom He wills in rank and honor.
24. Al-Mu‘izz — The Giver of Honor: He grants true dignity and strength.
25. Al-Mudhill — The Giver of Humiliation: He humbles whom He wills in justice.
26. As-Sami‘ — The All-Hearing: He hears every sound, word, and prayer.
27. Al-Basir — The All-Seeing: He sees everything, open and hidden.
28. Al-Hakam — The Judge: His judgment is perfect and final.
29. Al-‘Adl — The Utterly Just: He is perfectly fair and never unjust.
30. Al-Latif — The Most Subtle / The Most Gentle: He knows the finest details and is gentle with His servants.
31. Al-Khabir — The All-Aware: He knows the reality and inner details of everything.
32. Al-Halim — The Most Forbearing: He does not hasten to punish despite having full power.
33. Al-‘Azim — The Magnificent: He is immense in greatness and majesty.
34. Al-Ghafur — The Great Forgiver: He forgives sins fully and covers faults.
35. Ash-Shakur — The Most Appreciative: He rewards even small good deeds abundantly.
36. Al-‘Aliyy — The Most High: He is exalted above all creation.
37. Al-Kabir — The Most Great: He is greater than everything.
38. Al-Hafiz — The Preserver: He protects and preserves all things.
39. Al-Muqit — The Sustainer: He nourishes and maintains His creation.
40. Al-Hasib — The Reckoner / The Sufficient: He is enough for His servants and takes account of all things.
41. Al-Jalil — The Majestic: He possesses absolute grandeur and dignity.
42. Al-Karim — The Most Generous: He gives nobly, abundantly, and kindly.
43. Ar-Raqib — The Watchful: Nothing escapes His watch.
44. Al-Mujib — The Responsive: He answers prayers and calls upon Him.
45. Al-Wasi‘ — The All-Encompassing: His mercy, knowledge, and power are vast.
46. Al-Hakim — The All-Wise: Everything He does is with perfect wisdom.
47. Al-Wadud — The Most Loving: He loves His righteous servants and bestows love upon them.
48. Al-Majid — The Most Glorious: He is full of glory, honor, and nobility.
49. Al-Ba‘ith — The Resurrector: He will raise the dead.
50. Ash-Shahid — The Witness: He witnesses all things; nothing is hidden from Him.
51. Al-Haqq — The Truth: He is the absolute truth, and His promise is true.
52. Al-Wakil — The Trustee / The Disposer of Affairs: He is the One fully relied upon in all matters.
53. Al-Qawiyy — The Most Strong: His strength is perfect and complete.
54. Al-Matin — The Firm / The Steadfast: His power is unshakable and enduring.
55. Al-Waliyy — The Protecting Friend: He is the guardian and ally of the believers.
56. Al-Hamid — The Praiseworthy: He is worthy of all praise.
57. Al-Muhsi — The All-Enumerating: He counts and knows everything completely.
58. Al-Mubdi’ — The Originator: He begins creation.
59. Al-Mu‘id — The Restorer: He brings creation back after its end.
60. Al-Muhyi — The Giver of Life: He gives life to whom He wills.
61. Al-Mumit — The Bringer of Death: He decrees death for whom He wills.
62. Al-Hayy — The Ever-Living: His life is perfect, eternal, and without end.
63. Al-Qayyum — The Self-Subsisting / Sustainer of All: He exists by Himself and sustains everything else.
64. Al-Wajid — The Finder / The Self-Sufficient: Nothing is beyond Him, and He lacks nothing.
65. Al-Majid — The Noble / The Glorious: He is perfect in honor and splendor.
66. Al-Wahid — The One: He is one, without partner.
67. Al-Ahad — The Unique One: He is absolutely unique and incomparable.
68. As-Samad — The Eternal Refuge: All creation depends on Him, while He depends on none.
69. Al-Qadir — The All-Powerful: He has complete power over everything.
70. Al-Muqtadir — The Determiner / The Omnipotent: His power is fully effective and irresistible.
71. Al-Muqaddim — The Expediter: He brings forward whom or what He wills.
72. Al-Mu’akhkhir — The Delayer: He delays whom or what He wills by wisdom.
73. Al-Awwal — The First: Nothing was before Him.
74. Al-Akhir — The Last: Nothing will remain after Him except by His will.
75. Az-Zahir — The Manifest / The Most High: He is above all things, and His signs are clear.
76. Al-Batin — The Hidden: He is beyond full human grasp, and nothing hidden escapes Him.
77. Al-Wali — The Governor: He manages and governs all affairs.
78. Al-Muta‘ali — The Most Exalted: He is far above every imperfection.
79. Al-Barr — The Source of Goodness: He is perfectly kind and good to His servants.
80. At-Tawwab — The Accepter of Repentance: He repeatedly accepts repentance from His servants.
81. Al-Muntaqim — The Avenger: He takes just retribution against wrongdoing when He wills.
82. Al-‘Afuww — The Pardoner: He erases sins and overlooks faults.
83. Ar-Ra’uf — The Most Kind: He is extremely gentle and compassionate with His servants.
84. Malik-ul-Mulk — The Owner of All Sovereignty: All dominion and authority truly belong to Him.
85. Dhul-Jalali wal-Ikram — Lord of Majesty and Honor: He possesses perfect majesty, nobility, and generosity.
86. Al-Muqsit — The Equitable / The Just: He establishes perfect justice.
87. Al-Jami‘ — The Gatherer: He gathers creation together, especially on the Day of Judgment.
88. Al-Ghaniyy — The Self-Sufficient / The Rich: He is free of all need.
89. Al-Mughni — The Enricher: He grants sufficiency and wealth to whom He wills.
90. Al-Mani‘ — The Withholder / The Preventer: He withholds what He wills in wisdom.
91. Ad-Darr — The Bringer of Harm: No harm occurs except by His permission and wisdom.
92. An-Nafi‘ — The Bestower of Benefit: All true benefit ultimately comes from Him.
93. An-Nur — The Light: He is the light of the heavens and the earth, and the giver of guidance.
94. Al-Hadi — The Guide: He guides whom He wills to the straight path.
95. Al-Badi‘ — The Incomparable Originator: He creates in a unique way without any prior example.
96. Al-Baqi — The Everlasting: He remains forever and never perishes.
97. Al-Warith — The Inheritor: Everything ultimately returns to Him.
98. Ar-Rashid — The Guide to the Right Way: His guidance and decree are perfectly right and wise.
99. As-Sabur — The Most Patient / The Forbearing: He does not hasten punishment despite full power to do so.
''';

  static Map<int, String> _parseDetails(String raw) {
    final map = <int, String>{};
    final regex = RegExp(r'^\s*(\d+)\.\s*(.+)$');
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final match = regex.firstMatch(trimmed);
      if (match != null) {
        final index = int.tryParse(match.group(1) ?? '');
        final value = match.group(2)?.trim();
        if (index != null && value != null && value.isNotEmpty) {
          map[index] = value;
        }
      }
    }
    return map;
  }

  static final Map<int, String> _detailsDe = _parseDetails(_detailsRawDe);
  static final Map<int, String> _detailsAr = _parseDetails(_detailsRawAr);
  static final Map<int, String> _detailsEn = _parseDetails(_detailsRawEn);

  static const List<_AllahName> _names = [
    _AllahName(number: 1, arabic: 'اللَّه', transliteration: 'Allah', meaningDe: 'Allah', meaningEn: 'Allah', meaningAr: 'الله'),
    _AllahName(number: 2, arabic: 'الرَّحْمَٰن', transliteration: 'Ar-Rahman', meaningDe: 'Der Allerbarmer', meaningEn: 'The Most Compassionate', meaningAr: 'الرحمن'),
    _AllahName(number: 3, arabic: 'الرَّحِيم', transliteration: 'Ar-Rahim', meaningDe: 'Der Barmherzige', meaningEn: 'The Most Merciful', meaningAr: 'الرحيم'),
    _AllahName(number: 4, arabic: 'الْمَلِك', transliteration: 'Al-Malik', meaningDe: 'Der König', meaningEn: 'The King', meaningAr: 'الملك'),
    _AllahName(number: 5, arabic: 'الْقُدُّوس', transliteration: 'Al-Quddus', meaningDe: 'Der Heilige', meaningEn: 'The Most Holy', meaningAr: 'القدوس'),
    _AllahName(number: 6, arabic: 'السَّلَام', transliteration: 'As-Salam', meaningDe: 'Der Friede', meaningEn: 'The Source of Peace', meaningAr: 'السلام'),
    _AllahName(number: 7, arabic: 'الْمُؤْمِن', transliteration: 'Al-Mumin', meaningDe: 'Der Gewährer von Sicherheit', meaningEn: 'The Giver of Security', meaningAr: 'المؤمن'),
    _AllahName(number: 8, arabic: 'الْمُهَيْمِن', transliteration: 'Al-Muhaymin', meaningDe: 'Der Beschützer', meaningEn: 'The Guardian', meaningAr: 'المهيمن'),
    _AllahName(number: 9, arabic: 'الْعَزِيز', transliteration: 'Al-Aziz', meaningDe: 'Der Allmächtige', meaningEn: 'The Almighty', meaningAr: 'العزيز'),
    _AllahName(number: 10, arabic: 'الْجَبَّار', transliteration: 'Al-Jabbar', meaningDe: 'Der Gewaltige', meaningEn: 'The Compeller', meaningAr: 'الجبار'),
    _AllahName(number: 11, arabic: 'الْمُتَكَبِّر', transliteration: 'Al-Mutakabbir', meaningDe: 'Der Majestätische', meaningEn: 'The Supreme', meaningAr: 'المتكبر'),
    _AllahName(number: 12, arabic: 'الْخَالِق', transliteration: 'Al-Khaliq', meaningDe: 'Der Schöpfer', meaningEn: 'The Creator', meaningAr: 'الخالق'),
    _AllahName(number: 13, arabic: 'الْبَارِئ', transliteration: 'Al-Bari', meaningDe: 'Der Erschaffer', meaningEn: 'The Originator', meaningAr: 'البارئ'),
    _AllahName(number: 14, arabic: 'الْمُصَوِّر', transliteration: 'Al-Musawwir', meaningDe: 'Der Gestalter', meaningEn: 'The Fashioner', meaningAr: 'المصور'),
    _AllahName(number: 15, arabic: 'الْغَفَّار', transliteration: 'Al-Ghaffar', meaningDe: 'Der Vielvergebende', meaningEn: 'The Constant Forgiver', meaningAr: 'الغفار'),
    _AllahName(number: 16, arabic: 'الْقَهَّار', transliteration: 'Al-Qahhar', meaningDe: 'Der Allbezwinger', meaningEn: 'The All-Subduer', meaningAr: 'القهار'),
    _AllahName(number: 17, arabic: 'الْوَهَّاب', transliteration: 'Al-Wahhab', meaningDe: 'Der Schenkende', meaningEn: 'The Bestower', meaningAr: 'الوهاب'),
    _AllahName(number: 18, arabic: 'الرَّزَّاق', transliteration: 'Ar-Razzaq', meaningDe: 'Der Versorger', meaningEn: 'The Provider', meaningAr: 'الرزاق'),
    _AllahName(number: 19, arabic: 'الْفَتَّاح', transliteration: 'Al-Fattah', meaningDe: 'Der Öffnende', meaningEn: 'The Opener', meaningAr: 'الفتاح'),
    _AllahName(number: 20, arabic: 'الْعَلِيم', transliteration: 'Al-Alim', meaningDe: 'Der Allwissende', meaningEn: 'The All-Knowing', meaningAr: 'العليم'),
    _AllahName(number: 21, arabic: 'الْقَابِض', transliteration: 'Al-Qabid', meaningDe: 'Der Zurückhaltende', meaningEn: 'The Withholder', meaningAr: 'القابض'),
    _AllahName(number: 22, arabic: 'الْبَاسِط', transliteration: 'Al-Basit', meaningDe: 'Der Ausbreitende', meaningEn: 'The Extender', meaningAr: 'الباسط'),
    _AllahName(number: 23, arabic: 'الْخَافِض', transliteration: 'Al-Khafid', meaningDe: 'Der Erniedrigende', meaningEn: 'The Reducer', meaningAr: 'الخافض'),
    _AllahName(number: 24, arabic: 'الرَّافِع', transliteration: 'Ar-Rafi', meaningDe: 'Der Erhöhende', meaningEn: 'The Exalter', meaningAr: 'الرافع'),
    _AllahName(number: 25, arabic: 'الْمُعِزّ', transliteration: 'Al-Muizz', meaningDe: 'Der Verleiher von Ehre', meaningEn: 'The Honourer', meaningAr: 'المعز'),
    _AllahName(number: 26, arabic: 'الْمُذِلّ', transliteration: 'Al-Mudhill', meaningDe: 'Der Demütigende', meaningEn: 'The Dishonourer', meaningAr: 'المذل'),
    _AllahName(number: 27, arabic: 'السَّمِيع', transliteration: 'As-Sami', meaningDe: 'Der Allhörende', meaningEn: 'The All-Hearing', meaningAr: 'السميع'),
    _AllahName(number: 28, arabic: 'الْبَصِير', transliteration: 'Al-Basir', meaningDe: 'Der Allsehende', meaningEn: 'The All-Seeing', meaningAr: 'البصير'),
    _AllahName(number: 29, arabic: 'الْحَكَم', transliteration: 'Al-Hakam', meaningDe: 'Der Richter', meaningEn: 'The Judge', meaningAr: 'الحكم'),
    _AllahName(number: 30, arabic: 'الْعَدْل', transliteration: 'Al-Adl', meaningDe: 'Der Gerechte', meaningEn: 'The Just', meaningAr: 'العدل'),
    _AllahName(number: 31, arabic: 'اللَّطِيف', transliteration: 'Al-Latif', meaningDe: 'Der Feinfühlige', meaningEn: 'The Subtle One', meaningAr: 'اللطيف'),
    _AllahName(number: 32, arabic: 'الْخَبِير', transliteration: 'Al-Khabir', meaningDe: 'Der Allkundige', meaningEn: 'The All-Aware', meaningAr: 'الخبير'),
    _AllahName(number: 33, arabic: 'الْحَلِيم', transliteration: 'Al-Halim', meaningDe: 'Der Nachsichtige', meaningEn: 'The Most Forbearing', meaningAr: 'الحليم'),
    _AllahName(number: 34, arabic: 'الْعَظِيم', transliteration: 'Al-Azim', meaningDe: 'Der Gewaltige', meaningEn: 'The Magnificent', meaningAr: 'العظيم'),
    _AllahName(number: 35, arabic: 'الْغَفُور', transliteration: 'Al-Ghafur', meaningDe: 'Der Vergebende', meaningEn: 'The Most Forgiving', meaningAr: 'الغفور'),
    _AllahName(number: 36, arabic: 'الشَّكُور', transliteration: 'Ash-Shakur', meaningDe: 'Der Dankbare', meaningEn: 'The Most Appreciative', meaningAr: 'الشكور'),
    _AllahName(number: 37, arabic: 'الْعَلِيّ', transliteration: 'Al-Aliyy', meaningDe: 'Der Allerhöchste', meaningEn: 'The Most High', meaningAr: 'العلي'),
    _AllahName(number: 38, arabic: 'الْكَبِير', transliteration: 'Al-Kabir', meaningDe: 'Der Große', meaningEn: 'The Most Great', meaningAr: 'الكبير'),
    _AllahName(number: 39, arabic: 'الْحَفِيظ', transliteration: 'Al-Hafiz', meaningDe: 'Der Bewahrende', meaningEn: 'The Preserver', meaningAr: 'الحفيظ'),
    _AllahName(number: 40, arabic: 'الْمُقِيت', transliteration: 'Al-Muqit', meaningDe: 'Der Erhalter', meaningEn: 'The Sustainer', meaningAr: 'المقيت'),
    _AllahName(number: 41, arabic: 'الْحَسِيب', transliteration: 'Al-Hasib', meaningDe: 'Der Abrechnende', meaningEn: 'The Reckoner', meaningAr: 'الحسيب'),
    _AllahName(number: 42, arabic: 'الْجَلِيل', transliteration: 'Al-Jalil', meaningDe: 'Der Erhabene', meaningEn: 'The Majestic', meaningAr: 'الجليل'),
    _AllahName(number: 43, arabic: 'الْكَرِيم', transliteration: 'Al-Karim', meaningDe: 'Der Großzügige', meaningEn: 'The Most Generous', meaningAr: 'الكريم'),
    _AllahName(number: 44, arabic: 'الرَّقِيب', transliteration: 'Ar-Raqib', meaningDe: 'Der Wächter', meaningEn: 'The Watchful', meaningAr: 'الرقيب'),
    _AllahName(number: 45, arabic: 'الْمُجِيب', transliteration: 'Al-Mujib', meaningDe: 'Der Erhörende', meaningEn: 'The Responsive', meaningAr: 'المجيب'),
    _AllahName(number: 46, arabic: 'الْوَاسِع', transliteration: 'Al-Wasi', meaningDe: 'Der Umfassende', meaningEn: 'The All-Encompassing', meaningAr: 'الواسع'),
    _AllahName(number: 47, arabic: 'الْحَكِيم', transliteration: 'Al-Hakim', meaningDe: 'Der Allweise', meaningEn: 'The All-Wise', meaningAr: 'الحكيم'),
    _AllahName(number: 48, arabic: 'الْوَدُود', transliteration: 'Al-Wadud', meaningDe: 'Der Liebevolle', meaningEn: 'The Most Loving', meaningAr: 'الودود'),
    _AllahName(number: 49, arabic: 'الْمَجِيد', transliteration: 'Al-Majid', meaningDe: 'Der Ruhmreiche', meaningEn: 'The Most Glorious', meaningAr: 'المجيد'),
    _AllahName(number: 50, arabic: 'الْبَاعِث', transliteration: 'Al-Baith', meaningDe: 'Der Erwecker', meaningEn: 'The Resurrector', meaningAr: 'الباعث'),
    _AllahName(number: 51, arabic: 'الشَّهِيد', transliteration: 'Ash-Shahid', meaningDe: 'Der Zeuge', meaningEn: 'The Witness', meaningAr: 'الشهيد'),
    _AllahName(number: 52, arabic: 'الْحَقّ', transliteration: 'Al-Haqq', meaningDe: 'Die Wahrheit', meaningEn: 'The Truth', meaningAr: 'الحق'),
    _AllahName(number: 53, arabic: 'الْوَكِيل', transliteration: 'Al-Wakil', meaningDe: 'Der Sachwalter', meaningEn: 'The Trustee', meaningAr: 'الوكيل'),
    _AllahName(number: 54, arabic: 'الْقَوِيّ', transliteration: 'Al-Qawiyy', meaningDe: 'Der Starke', meaningEn: 'The All-Strong', meaningAr: 'القوي'),
    _AllahName(number: 55, arabic: 'الْمَتِين', transliteration: 'Al-Matin', meaningDe: 'Der Standhafte', meaningEn: 'The Firm One', meaningAr: 'المتين'),
    _AllahName(number: 56, arabic: 'الْوَلِيّ', transliteration: 'Al-Waliyy', meaningDe: 'Der Beschützerfreund', meaningEn: 'The Protecting Ally', meaningAr: 'الولي'),
    _AllahName(number: 57, arabic: 'الْحَمِيد', transliteration: 'Al-Hamid', meaningDe: 'Der Lobenswerte', meaningEn: 'The Praiseworthy', meaningAr: 'الحميد'),
    _AllahName(number: 58, arabic: 'الْمُحْصِي', transliteration: 'Al-Muhsi', meaningDe: 'Der Zählende', meaningEn: 'The Reckoner of All', meaningAr: 'المحصي'),
    _AllahName(number: 59, arabic: 'الْمُبْدِئ', transliteration: 'Al-Mubdi', meaningDe: 'Der Anfänger', meaningEn: 'The Originator', meaningAr: 'المبدئ'),
    _AllahName(number: 60, arabic: 'الْمُعِيد', transliteration: 'Al-Muid', meaningDe: 'Der Wiederhersteller', meaningEn: 'The Restorer', meaningAr: 'المعيد'),
    _AllahName(number: 61, arabic: 'الْمُحْيِي', transliteration: 'Al-Muhyi', meaningDe: 'Der Lebensgeber', meaningEn: 'The Giver of Life', meaningAr: 'المحيي'),
    _AllahName(number: 62, arabic: 'الْمُمِيت', transliteration: 'Al-Mumit', meaningDe: 'Der Verursacher des Todes', meaningEn: 'The Bringer of Death', meaningAr: 'المميت'),
    _AllahName(number: 63, arabic: 'الْحَيّ', transliteration: 'Al-Hayy', meaningDe: 'Der Ewig Lebende', meaningEn: 'The Ever-Living', meaningAr: 'الحي'),
    _AllahName(number: 64, arabic: 'الْقَيُّوم', transliteration: 'Al-Qayyum', meaningDe: 'Der Beständige', meaningEn: 'The Self-Subsisting', meaningAr: 'القيوم'),
    _AllahName(number: 65, arabic: 'الْوَاجِد', transliteration: 'Al-Wajid', meaningDe: 'Der Finder', meaningEn: 'The Finder', meaningAr: 'الواجد'),
    _AllahName(number: 66, arabic: 'الْمَاجِد', transliteration: 'Al-Majid', meaningDe: 'Der Edle', meaningEn: 'The Noble', meaningAr: 'الماجد'),
    _AllahName(number: 67, arabic: 'الْوَاحِد', transliteration: 'Al-Wahid', meaningDe: 'Der Eine', meaningEn: 'The One', meaningAr: 'الواحد'),
    _AllahName(number: 68, arabic: 'الصَّمَد', transliteration: 'As-Samad', meaningDe: 'Der Absolute', meaningEn: 'The Eternal Refuge', meaningAr: 'الصمد'),
    _AllahName(number: 69, arabic: 'الْقَادِر', transliteration: 'Al-Qadir', meaningDe: 'Der Allmächtige', meaningEn: 'The All-Powerful', meaningAr: 'القادر'),
    _AllahName(number: 70, arabic: 'الْمُقْتَدِر', transliteration: 'Al-Muqtadir', meaningDe: 'Der Vollmächtige', meaningEn: 'The Creator of All Power', meaningAr: 'المقتدر'),
    _AllahName(number: 71, arabic: 'الْمُقَدِّم', transliteration: 'Al-Muqaddim', meaningDe: 'Der Voranstellende', meaningEn: 'The Expediter', meaningAr: 'المقدم'),
    _AllahName(number: 72, arabic: 'الْمُؤَخِّر', transliteration: 'Al-Muakhkhir', meaningDe: 'Der Aufschiebende', meaningEn: 'The Delayer', meaningAr: 'المؤخر'),
    _AllahName(number: 73, arabic: 'الْأَوَّل', transliteration: 'Al-Awwal', meaningDe: 'Der Erste', meaningEn: 'The First', meaningAr: 'الأول'),
    _AllahName(number: 74, arabic: 'الْآخِر', transliteration: 'Al-Akhir', meaningDe: 'Der Letzte', meaningEn: 'The Last', meaningAr: 'الآخر'),
    _AllahName(number: 75, arabic: 'الظَّاهِر', transliteration: 'Az-Zahir', meaningDe: 'Der Offenbare', meaningEn: 'The Manifest', meaningAr: 'الظاهر'),
    _AllahName(number: 76, arabic: 'الْبَاطِن', transliteration: 'Al-Batin', meaningDe: 'Der Verborgene', meaningEn: 'The Hidden', meaningAr: 'الباطن'),
    _AllahName(number: 77, arabic: 'الْوَالِي', transliteration: 'Al-Wali', meaningDe: 'Der Lenker', meaningEn: 'The Governor', meaningAr: 'الوالي'),
    _AllahName(number: 78, arabic: 'الْمُتَعَالِي', transliteration: 'Al-Mutaali', meaningDe: 'Der Allerhöchste Erhabene', meaningEn: 'The Most Exalted', meaningAr: 'المتعالي'),
    _AllahName(number: 79, arabic: 'الْبَرّ', transliteration: 'Al-Barr', meaningDe: 'Der Gütige', meaningEn: 'The Source of Goodness', meaningAr: 'البر'),
    _AllahName(number: 80, arabic: 'التَّوَّاب', transliteration: 'At-Tawwab', meaningDe: 'Der Reue-Annehmende', meaningEn: 'The Acceptor of Repentance', meaningAr: 'التواب'),
    _AllahName(number: 81, arabic: 'الْمُنْتَقِم', transliteration: 'Al-Muntaqim', meaningDe: 'Der Vergeltende', meaningEn: 'The Avenger', meaningAr: 'المنتقم'),
    _AllahName(number: 82, arabic: 'الْعَفُوّ', transliteration: 'Al-Afuww', meaningDe: 'Der Verzeihende', meaningEn: 'The Pardoner', meaningAr: 'العفو'),
    _AllahName(number: 83, arabic: 'الرَّؤُوف', transliteration: 'Ar-Rauf', meaningDe: 'Der Gütige', meaningEn: 'The Most Kind', meaningAr: 'الرؤوف'),
    _AllahName(number: 84, arabic: 'مَالِكُ الْمُلْك', transliteration: 'Malik-ul-Mulk', meaningDe: 'Besitzer der Herrschaft', meaningEn: 'Owner of All Sovereignty', meaningAr: 'مالك الملك'),
    _AllahName(number: 85, arabic: 'ذُو الْجَلَالِ وَالْإِكْرَام', transliteration: 'Dhul-Jalali wal-Ikram', meaningDe: 'Herr von Majestät und Ehre', meaningEn: 'Lord of Glory and Honour', meaningAr: 'ذو الجلال والإكرام'),
    _AllahName(number: 86, arabic: 'الْمُقْسِط', transliteration: 'Al-Muqsit', meaningDe: 'Der Gerechte', meaningEn: 'The Equitable', meaningAr: 'المقسط'),
    _AllahName(number: 87, arabic: 'الْجَامِع', transliteration: 'Al-Jami', meaningDe: 'Der Versammler', meaningEn: 'The Gatherer', meaningAr: 'الجامع'),
    _AllahName(number: 88, arabic: 'الْغَنِيّ', transliteration: 'Al-Ghaniyy', meaningDe: 'Der Unabhängige', meaningEn: 'The Self-Sufficient', meaningAr: 'الغني'),
    _AllahName(number: 89, arabic: 'الْمُغْنِي', transliteration: 'Al-Mughni', meaningDe: 'Der Bereichernde', meaningEn: 'The Enricher', meaningAr: 'المغني'),
    _AllahName(number: 90, arabic: 'الْمَانِع', transliteration: 'Al-Mani', meaningDe: 'Der Zurückhaltende', meaningEn: 'The Preventer', meaningAr: 'المانع'),
    _AllahName(number: 91, arabic: 'الضَّارّ', transliteration: 'Ad-Darr', meaningDe: 'Der Schaden Zulassende', meaningEn: 'The Afflictor', meaningAr: 'الضار'),
    _AllahName(number: 92, arabic: 'النَّافِع', transliteration: 'An-Nafi', meaningDe: 'Der Nutzen Gebende', meaningEn: 'The Benefactor', meaningAr: 'النافع'),
    _AllahName(number: 93, arabic: 'النُّور', transliteration: 'An-Nur', meaningDe: 'Das Licht', meaningEn: 'The Light', meaningAr: 'النور'),
    _AllahName(number: 94, arabic: 'الْهَادِي', transliteration: 'Al-Hadi', meaningDe: 'Der Rechtleitende', meaningEn: 'The Guide', meaningAr: 'الهادي'),
    _AllahName(number: 95, arabic: 'الْبَدِيع', transliteration: 'Al-Badi', meaningDe: 'Der Einzigartige Schöpfer', meaningEn: 'The Incomparable Originator', meaningAr: 'البديع'),
    _AllahName(number: 96, arabic: 'الْبَاقِي', transliteration: 'Al-Baqi', meaningDe: 'Der Ewig Bleibende', meaningEn: 'The Everlasting', meaningAr: 'الباقي'),
    _AllahName(number: 97, arabic: 'الْوَارِث', transliteration: 'Al-Warith', meaningDe: 'Der Erbe', meaningEn: 'The Inheritor', meaningAr: 'الوارث'),
    _AllahName(number: 98, arabic: 'الرَّشِيد', transliteration: 'Ar-Rashid', meaningDe: 'Der recht Leitende', meaningEn: 'The Guide to the Right Path', meaningAr: 'الرشيد'),
    _AllahName(number: 99, arabic: 'الصَّبُور', transliteration: 'As-Sabur', meaningDe: 'Der Geduldige', meaningEn: 'The Most Patient', meaningAr: 'الصبور'),
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language') ?? 'de';
    final hasSeenIntro = prefs.getBool(_introSeenKey) ?? false;
    if (!mounted) {
      return;
    }
    setState(() {
      appLanguage = AppLanguage.values.firstWhere(
        (l) => l.code == langCode,
        orElse: () => AppLanguage.german,
      );
      _hasSeenIntro = hasSeenIntro;
    });

    if (!hasSeenIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showIntroDialog(firstTime: true);
        }
      });
    }
  }

  String _introTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Why the 99 Names matter';
      case AppLanguage.arabic:
        return 'لماذا أسماء الله الحسنى مهمة';
      case AppLanguage.german:
        return 'Warum die 99 Namen wichtig sind';
    }
  }

  String _introBody() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'The 99 Names of Allah are not only meant to be memorized. They should also be understood, internalized, and lived by in daily life. Each Name teaches us something about Allah’s attributes and helps us know Him better. When you learn one of His Names, ask yourself: What does this Name mean for my relationship with Allah?\n\n'
            'For example: Ar-Rahman — The Most Merciful. This Name reminds us never to lose hope in Allah’s mercy. It encourages us to ask Allah for forgiveness and to show mercy to others as well.';
      case AppLanguage.arabic:
        return 'أسماءُ اللهِ الحسنى ليست للحفظ فقط، بل ينبغي فهمُها واستحضارُها والعملُ بها في الحياة اليومية. فكلُّ اسمٍ منها يعرّفنا بشيءٍ من صفاتِ الله، ويساعدنا على التقرّب إليه ومعرفته أكثر. وعندما تتعلّم اسمًا من أسماء الله، فاسأل نفسك: ماذا يعني هذا الاسم لعلاقتي بالله؟\n\n'
            'مثال ذلك: الرحمن — كثير الرحمة، واسع الرحمة. يذكّرنا هذا الاسم ألّا نفقد الأمل أبدًا في رحمة الله، ويشجّعنا على طلب المغفرة منه، وأن نكون رحماء مع الآخرين أيضًا.';
      case AppLanguage.german:
        return 'Die 99 Namen Allahs sind nicht nur zum Auswendiglernen da. Sie sollen verstanden, verinnerlicht und im Alltag gelebt werden. Jeder Name zeigt uns etwas über Allahs Eigenschaften und hilft uns, Ihn besser kennenzulernen. Wenn du einen Namen lernst, frage dich: Was bedeutet dieser Name für meine Beziehung zu Allah?\n\n'
            'Zum Beispiel: Ar-Rahman – der Allerbarmer. Dieser Name erinnert uns daran, niemals die Hoffnung auf Allahs Barmherzigkeit zu verlieren. Er ermutigt uns, Allah um Vergebung zu bitten und auch mit anderen barmherzig umzugehen.';
    }
  }

  String _hadithTitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Hadith';
      case AppLanguage.arabic:
        return 'حديث';
      case AppLanguage.german:
        return 'Hadith';
    }
  }

  String _hadithText() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'The Prophet Muhammad ﷺ said:\n'
            '“Allah has ninety-nine names, one hundred minus one. Whoever comprehends them will enter Paradise.”\n'
            '(Sahih al-Bukhari, Sahih Muslim)';
      case AppLanguage.arabic:
        return 'قال النبي محمد ﷺ:\n'
            '«إنَّ للهِ تِسعةً وتسعين اسمًا، مائةً إلا واحدًا، من أحصاها دخل الجنة.»\n'
            '(رواه البخاري ومسلم)';
      case AppLanguage.german:
        return 'Der Prophet Muhammad ﷺ sagte:\n'
            '„Allah hat neunundneunzig Namen, hundert bis auf einen. Wer sie erfasst, wird das Paradies betreten.“\n'
            '(Sahih al-Bukhari, Sahih Muslim)';
    }
  }

  String _continueLabel() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Continue';
      case AppLanguage.arabic:
        return 'متابعة';
      case AppLanguage.german:
        return 'Weiter';
    }
  }

  Future<void> _showIntroDialog({required bool firstTime}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !firstTime,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _MyAppState.currentTheme.color, width: 2),
          ),
          title: Text(
            _introTitle(),
            style: TextStyle(
              color: _MyAppState.currentTheme.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _introBody(),
                  style: const TextStyle(color: Colors.white, height: 1.4),
                  textDirection: appLanguage == AppLanguage.arabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
                const SizedBox(height: 14),
                Text(
                  _hadithTitle(),
                  style: TextStyle(
                    color: _MyAppState.currentTheme.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _hadithText(),
                  style: const TextStyle(color: Colors.white, height: 1.45),
                  textDirection: appLanguage == AppLanguage.arabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (firstTime) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(_introSeenKey, true);
                  if (mounted) {
                    setState(() => _hasSeenIntro = true);
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                _continueLabel(),
                style: TextStyle(
                  color: _MyAppState.currentTheme.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _title() {
    switch (appLanguage) {
      case AppLanguage.english:
        return '99 Names of Allah';
      case AppLanguage.arabic:
        return 'أسماء الله الحسنى';
      case AppLanguage.german:
        return '99 Namen Allahs';
    }
  }

  String _subtitle() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Arabic, pronunciation and meaning';
      case AppLanguage.arabic:
        return 'الاسم بالعربية مع النطق والمعنى';
      case AppLanguage.german:
        return 'Arabisch, Aussprache und Bedeutung';
    }
  }

  String _searchHint() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Search by Arabic, transliteration or meaning';
      case AppLanguage.arabic:
        return 'ابحث بالعربية أو بالنطق أو بالمعنى';
      case AppLanguage.german:
        return 'Suche nach Arabisch, Aussprache oder Bedeutung';
    }
  }

  String _noResultsLabel() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'No names found for this search.';
      case AppLanguage.arabic:
        return 'لم يتم العثور على أسماء بهذه الكلمة.';
      case AppLanguage.german:
        return 'Keine Namen zu dieser Suche gefunden.';
    }
  }

  String _tapForMeaningLabel() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Tap to view the full meaning';
      case AppLanguage.arabic:
        return 'اضغط لرؤية المعنى الكامل';
      case AppLanguage.german:
        return 'Tippe, um die volle Bedeutung zu sehen';
    }
  }

  String _normalizeSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[\u2018\u2019\u201B\u2032'`\-_.\s]+"), '');
  }

  static String _nameKey(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\u0600-\u06FF]+"), '');
  }

  static Map<String, int> _buildDetailIndexByName() {
    final map = <String, int>{};
    final regex = RegExp(r'^\s*(\d+)\.\s*(.+?)\s*[—–]\s*');
    for (final line in _detailsRawEn.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final match = regex.firstMatch(trimmed);
      if (match == null) continue;
      final index = int.tryParse(match.group(1) ?? '');
      final rawName = match.group(2)?.trim();
      if (index == null || rawName == null || rawName.isEmpty) continue;
      map[_nameKey(rawName)] = index;
    }
    return map;
  }

  static final Map<String, int> _detailIndexByName = _buildDetailIndexByName();

  bool _isAllah(_AllahName item) {
    return _nameKey(item.transliteration) == 'allah';
  }

  int? _detailIndexFor(_AllahName item) {
    if (_isAllah(item)) {
      return null;
    }
    return _detailIndexByName[_nameKey(item.transliteration)];
  }

  int _displayNumberFor(_AllahName item) {
    return _detailIndexFor(item) ?? item.number;
  }

  List<_AllahName> _orderedNames() {
    final ordered = [..._names];
    ordered.sort((a, b) {
      final aIndex = _detailIndexFor(a);
      final bIndex = _detailIndexFor(b);
      if (aIndex == null && bIndex == null) return 0;
      if (aIndex == null) return -1;
      if (bIndex == null) return 1;
      return aIndex.compareTo(bIndex);
    });
    return ordered;
  }

  List<_AllahName> _filteredNames() {
    final query = _normalizeSearch(_searchQuery.trim());
    final ordered = _orderedNames();
    if (query.isEmpty) {
      return ordered;
    }

    return ordered.where((item) {
      final detailIndex = _detailIndexFor(item);
      final haystack = <String>[
        _displayNumberFor(item).toString(),
        item.arabic,
        item.transliteration,
        item.meaningDe,
        item.meaningEn,
        item.meaningAr,
        detailIndex == null ? '' : (_detailsDe[detailIndex] ?? ''),
        detailIndex == null ? '' : (_detailsEn[detailIndex] ?? ''),
        detailIndex == null ? '' : (_detailsAr[detailIndex] ?? ''),
      ].map(_normalizeSearch).join('|');
      return haystack.contains(query);
    }).toList();
  }

  String _detailFor(_AllahName item) {
    final detailIndex = _detailIndexFor(item);
    if (detailIndex == null) {
      return '';
    }
    switch (appLanguage) {
      case AppLanguage.english:
        return _detailsEn[detailIndex] ?? item.meaningEn;
      case AppLanguage.arabic:
        return _detailsAr[detailIndex] ?? item.meaningAr;
      case AppLanguage.german:
        return _detailsDe[detailIndex] ?? item.meaningDe;
    }
  }

  void _showNameDetail(_AllahName item) {
    if (_isAllah(item)) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.62,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _MyAppState.currentTheme.color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_displayNumberFor(item)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.transliteration,
                            style: TextStyle(
                              color: _MyAppState.currentTheme.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.arabic,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.notoNaskhArabic(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  child: Text(
                    _detailFor(item),
                    textDirection: appLanguage == AppLanguage.arabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNames();
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _MyAppState.currentTheme.color.withOpacity(0.35),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '99',
                      style: TextStyle(
                        color: _MyAppState.currentTheme.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(),
                        style: TextStyle(
                          color: _MyAppState.currentTheme.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    tooltip: _introTitle(),
                    onPressed: () => _showIntroDialog(firstTime: false),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _MyAppState.currentTheme.color,
                          size: 24,
                        ),
                        if (!_hasSeenIntro)
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 0.8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              textDirection:
                  appLanguage == AppLanguage.arabic ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: _searchHint(),
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: _MyAppState.currentTheme.color),
                suffixIcon: _searchQuery.trim().isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.close, color: _MyAppState.currentTheme.color),
                      )
                    : null,
                filled: true,
                fillColor: Colors.black.withOpacity(0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _MyAppState.currentTheme.color.withOpacity(0.45),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _MyAppState.currentTheme.color.withOpacity(0.45),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _MyAppState.currentTheme.color,
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        _noResultsLabel(),
                        textAlign: TextAlign.center,
                        textDirection: appLanguage == AppLanguage.arabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return GestureDetector(
                  onTap: _isAllah(item) ? null : () => _showNameDetail(item),
                  child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _MyAppState.currentTheme.color.withOpacity(0.18),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _MyAppState.currentTheme.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${_displayNumberFor(item)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.arabic,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.notoNaskhArabic(
                                color: Colors.black,
                                fontSize: 30,
                                height: 1.7,
                                fontWeight: FontWeight.w700,
                                textStyle: const TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.transliteration,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!_isAllah(item))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.meaning(appLanguage),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _tapForMeaningLabel(),
                                    style: TextStyle(
                                      color: _MyAppState.currentTheme.color,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textDirection: appLanguage == AppLanguage.arabic
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}