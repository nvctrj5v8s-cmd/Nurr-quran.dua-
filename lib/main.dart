import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'mushaf_reader_page.dart';

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
  altImage('assets/images/hintergrund2.jpg', 'Hintergrund 2');

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
                const HomePage(),
                MushafReaderPage(themeColor: _MyAppState.currentTheme.color),
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int hadithIndex = 0;
  AppLanguage appLanguage = AppLanguage.german;
  List<bool> gebete = [false, false, false, false, false];
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

  @override
  void initState() {
    super.initState();
    _checkAndResetDaily();
    _loadGebete();
    _loadAppLanguage();
    _setDailyHadith();
  }

  Future<void> _loadAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language') ?? 'de';
    setState(() {
      appLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.code == langCode,
        orElse: () => AppLanguage.german,
      );
    });
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
    final heute = DateTime.now();
    final heuteString = '${heute.year}-${heute.month}-${heute.day}';
    final gespeichertesDatum = prefs.getString('gebet_datum') ?? '';

    if (gespeichertesDatum != heuteString) {
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
    setState(() {
      gebete[index] = value;
    });
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
          ],
        ),
      ),
    );
  }
}

// ==================== QURAN PAGE ====================
class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

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
    loadLanguagePreference();
    loadSurahs();
  }

  Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('quran_language') ?? 'arabic';
    setState(() {
      selectedLanguage = QuranLanguage.values.firstWhere(
        (lang) => lang.name == savedLang,
        orElse: () => QuranLanguage.arabic,
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
        Uri.parse('http://api.alquran.cloud/v1/surah'),
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
            child: isLoading
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

// ==================== SURAH DETAIL PAGE ====================
class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final QuranLanguage language;
  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.language,
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

  final int ayahsPerPage = 15;

  @override
  void initState() {
    super.initState();
    loadSurah();
  }

  Future<void> loadSurah() async {
    try {
      final url = 'http://api.alquran.cloud/v1/surah/${widget.surahNumber}/${widget.language.apiEdition}';

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
                            'Seite ${currentPage + 1} von $totalPages',
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
                        children: widget.language == QuranLanguage.arabic
                            ? [
                                ElevatedButton.icon(
                                  onPressed: currentPage < totalPages - 1
                                      ? goToNextPage
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('التالي'),
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
                                  label: const Text('السابق'),
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
                                  label: const Text('Zurück'),
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
                                  label: const Text('Weiter'),
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
    final selected = dhikrOptions.contains(savedDhikr)
      ? savedDhikr
      : dhikrOptions.first;
    final savedCount = (countsRaw[selected] as num?)?.toInt() ?? legacyCount;

    setState(() {
      appLanguage = AppLanguage.values.firstWhere(
        (l) => l.code == langCode,
        orElse: () => AppLanguage.german,
      );
      appBackground = AppBackground.fromAssetPath(backgroundAsset);
      selectedDhikr = selected;
      tasbihCount = savedCount;
    });
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
  static const String _introSeenKey = 'names_of_allah_intro_seen_v1';

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

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _names.length,
              itemBuilder: (context, index) {
                final item = _names[index];
                return Container(
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
                            '${item.number}',
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
                            Text(
                              item.meaning(appLanguage),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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