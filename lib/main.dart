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
                const DuaCategoriesPage(),
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
              BottomNavigationBarItem(icon: const Icon(Icons.menu_book), label: _navLabel('Dua', 'Dua', 'دعاء')),
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

class _DuaCategory {
  final String id;
  final String de;
  final String en;
  final String ar;
  final IconData icon;
  final List<String> duas;

  const _DuaCategory({
    required this.id,
    required this.de,
    required this.en,
    required this.ar,
    required this.icon,
    required this.duas,
  });

  String title(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return en;
      case AppLanguage.arabic:
        return ar;
      case AppLanguage.german:
        return de;
    }
  }
}

// ==================== DUA PAGE ====================
class DuaCategoriesPage extends StatefulWidget {
  const DuaCategoriesPage({super.key});

  @override
  State<DuaCategoriesPage> createState() => _DuaCategoriesPageState();
}

class _DuaCategoriesPageState extends State<DuaCategoriesPage> {
  AppLanguage appLanguage = AppLanguage.german;

  static const List<_DuaCategory> _categories = [
    _DuaCategory(
      id: 'test',
      de: 'Dua Test',
      en: 'Test Dua',
      ar: 'دعاء تجريبي',
      icon: Icons.science,
      duas: [
        'اللَّهُمَّ هَذَا دُعَاءٌ تَجْرِيبِيٌّ.',
      ],
    ),
    _DuaCategory(
      id: 'forgiveness',
      de: 'Vergebung',
      en: 'Forgiveness',
      ar: 'الاستغفار',
      icon: Icons.favorite,
      duas: [
        'أَسْتَغْفِرُ اللَّهَ رَبِّي مِنْ كُلِّ ذَنْبٍ وَأَتُوبُ إِلَيْهِ',
        'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَتُبْ عَلَيَّ',
      ],
    ),
    _DuaCategory(
      id: 'after_wudu',
      de: 'Nach Wudu',
      en: 'After Wudu',
      ar: 'بعد الوضوء',
      icon: Icons.water_drop,
      duas: [
        'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
      ],
    ),
    _DuaCategory(
      id: 'morning',
      de: 'Morgen',
      en: 'Morning',
      ar: 'أذكار الصباح',
      icon: Icons.wb_sunny,
      duas: [
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
      ],
    ),
    _DuaCategory(
      id: 'evening',
      de: 'Abend',
      en: 'Evening',
      ar: 'أذكار المساء',
      icon: Icons.nightlight_round,
      duas: [
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language') ?? 'de';
    if (mounted) {
      setState(() {
        appLanguage = AppLanguage.values.firstWhere(
          (l) => l.code == langCode,
          orElse: () => AppLanguage.german,
        );
      });
    }
  }

  String _title() {
    switch (appLanguage) {
      case AppLanguage.english:
        return 'Dua';
      case AppLanguage.arabic:
        return 'صفحة الدعاء';
      case AppLanguage.german:
        return 'Dua Seite';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: _MyAppState.currentTheme.color, size: 30),
                const SizedBox(width: 10),
                Text(
                  _title(),
                  style: TextStyle(
                    color: _MyAppState.currentTheme.color,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DuaDetailPage(
                          language: appLanguage,
                          category: category,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category.icon, color: _MyAppState.currentTheme.color, size: 42),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            category.title(appLanguage),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

class DuaDetailPage extends StatelessWidget {
  final AppLanguage language;
  final _DuaCategory category;

  const DuaDetailPage({
    super.key,
    required this.language,
    required this.category,
  });

  String _backText() {
    switch (language) {
      case AppLanguage.english:
        return 'Back';
      case AppLanguage.arabic:
        return 'رجوع';
      case AppLanguage.german:
        return 'Zurück';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: _MyAppState.currentTheme.color,
        title: Text(category.title(language)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: category.duas.length,
        itemBuilder: (context, index) {
          final dua = category.duas[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _MyAppState.currentTheme.color, width: 2),
            ),
            child: Text(
              dua,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                height: 1.9,
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.amiriQuran().fontFamily,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: Text(_backText()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _MyAppState.currentTheme.color,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}