import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'mushaf_reader_page.dart';

// ==================== ÜBERSETZUNGEN ====================
class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    'de': {
      'home': 'Home',
      'quran': 'Quran',
      'hadiths': 'Hadiths',
      'prayer_times': 'Gebetszeiten',
      'settings': 'Mehr',
      'share_app': 'App Teilen',
      'share_text': 'Schau dir diese tolle Quran & Dua App an!',
      'hijri_calendar': 'Islamischer Kalender',
      'tasbih': 'Tasbih Zähler',
      'reset': 'Zurücksetzen',
      'count': 'Anzahl',
      'prayer_tracker': '🕌 GEBETE TRACKER',
      'hadith_of_day': '⭐ HADITH DES TAGES',
      'changes_daily': '(Wechselt täglich automatisch)',
      'quran_title': '📖 AL-QURAN AL-KAREEM',
      'choose_language': '🌍 Sprache wählen',
      'hadith_title': '📖 Hadiths des Propheten ﷺ',
      'search_hint': 'Suche nach Thema (z.B. prayer, patience)...',
      'prayer_times_title': '🕌 GEBETSZEITEN',
      'based_on_location': 'Basierend auf deinem Standort',
      'loading_prayer_times': 'Gebetszeiten werden geladen...',
      'retry': 'Erneut versuchen',
      'next_prayer': 'Nächstes Gebet',
      'page': 'Seite',
      'of': 'von',
      'back': 'Zurück',
      'next': 'Weiter',
      'profile': 'Profil',
      'language': 'Sprache',
      'theme': 'Farbthema',
      'font_size': 'Schriftgröße',
      'notifications': 'Benachrichtigungen',
      'about': 'Über die App',
      'edit_name': 'Name ändern',
      'new_name': 'Neuer Name',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'change_language': '🌍 Sprache ändern',
      'example_text': 'Beispieltext',
      'app_info': 'Quran & Hadith App\nVersion 1.0.0\n\nDeveloped with ❤️ for the Muslim Ummah',
      'no_hadiths': 'Keine Hadiths gefunden',
      'ayahs': 'Ayahs',
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'dua': 'Dua',
      'morning_dua': '☀️ Morgen-Dua',
      'after_meal': '🍽️ Nach dem Essen',
      'before_sleep_dua': '🌙 Vor dem Schlafen',
      'when_leaving': '🚪 Beim Verlassen',
      'daily_dhikr': '📿 Täglicher Dhikr',
      'morning_duas': '🌅 Morgenbittgebete',
      'evening_duas': '🌙 Abendbittgebete',
      'leaving_home': '🚪 Beim Verlassen',
      'entering_home': '🏠 Beim Betreten',
      'before_sleep': '😴 Vor dem Schlaf',
      'after_wudu': '💧 Nach der Gebetswaschung',
      'before_exam': '📚 Vor der Prüfung',
      'when_traveling': '✈️ Beim Reisen',
      'when_sick': '🤒 Bei Krankheit',
      'for_parents': '👪 Für Eltern',
      'seeking_knowledge': '🎓 Wissen suchen',
      'times': 'Mal',
      'feedback_title': '💬 Nachricht an Entwickler',
      'feedback_hint': 'Schreibe hier deine Beschwerde oder deinen Wunsch...',
      'feedback_send': 'Senden',
      'feedback_success': 'Erfolgreich gesendet! Danke 💚',
      'feedback_error': 'Fehler beim Senden. Versuche es erneut.',
      'view_feedback': '📝 Feedback ansehen',
      'admin_panel': '🔒 Admin-Panel',
      'enter_password': 'Passwort eingeben',
      'password_hint': 'Admin-Passwort',
      'unlock': 'Entsperren',
      'wrong_password': 'Falsches Passwort!',
      'no_feedback': 'Keine Nachrichten vorhanden',
      'feedback_from': 'Von',
      'anonymous': 'Anonym',
      'delete': 'Löschen',
    },
    'en': {
      'home': 'Home',
      'quran': 'Quran',
      'hadiths': 'Hadiths',
      'prayer_times': 'Prayer Times',
      'settings': 'More',
      'share_app': 'Share App',
      'share_text': 'Check out this amazing Quran & Dua App!',
      'hijri_calendar': 'Hijri Calendar',
      'tasbih': 'Tasbih Counter',
      'reset': 'Reset',
      'count': 'Count',
      'prayer_tracker': '🕌 PRAYER TRACKER',
      'hadith_of_day': '⭐ HADITH OF THE DAY',
      'changes_daily': '(Changes daily automatically)',
      'quran_title': '📖 AL-QURAN AL-KAREEM',
      'choose_language': '🌍 Choose Language',
      'hadith_title': '📖 Hadiths of the Prophet ﷺ',
      'search_hint': 'Search for topic (e.g. prayer, patience)...',
      'prayer_times_title': '🕌 PRAYER TIMES',
      'based_on_location': 'Based on your location',
      'loading_prayer_times': 'Loading prayer times...',
      'retry': 'Try Again',
      'next_prayer': 'Next Prayer',
      'page': 'Page',
      'of': 'of',
      'back': 'Back',
      'next': 'Next',
      'profile': 'Profile',
      'language': 'Language',
      'theme': 'Color Theme',
      'font_size': 'Font Size',
      'notifications': 'Notifications',
      'about': 'About',
      'edit_name': 'Edit Name',
      'new_name': 'New Name',
      'cancel': 'Cancel',
      'save': 'Save',
      'change_language': '🌍 Change Language',
      'example_text': 'Example Text',
      'app_info': 'Quran & Hadith App\nVersion 1.0.0\n\nDeveloped with ❤️ for the Muslim Ummah',
      'no_hadiths': 'No Hadiths found',
      'ayahs': 'Ayahs',
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'dua': 'Dua',
      'morning_dua': '☀️ Morning Dua',
      'after_meal': '🍽️ After Meal',
      'before_sleep_dua': '🌙 Before Sleep',
      'when_leaving': '🚪 When Leaving',
      'daily_dhikr': '📿 Daily Dhikr',
      'morning_duas': '🌅 Morning Duas',
      'evening_duas': '🌙 Evening Duas',
      'leaving_home': '🚪 Leaving Home',
      'entering_home': '🏠 Entering Home',
      'before_sleep': '😴 Before Sleep',
      'after_wudu': '💧 After Ablution',
      'before_exam': '📚 Before Exam',
      'feedback_title': '💬 Message to Developer',
      'feedback_hint': 'Write your complaint or suggestion here...',
      'feedback_send': 'Send',
      'feedback_success': 'Successfully sent! Thank you 💚',
      'feedback_error': 'Error sending. Try again.',
      'when_traveling': '✈️ When Traveling',
      'when_sick': '🤒 When Sick',
      'for_parents': '👪 For Parents',
      'seeking_knowledge': '🎓 Seeking Knowledge',
      'times': 'times',
    },
    'ar': {
      'home': 'الرئيسية',
      'quran': 'القرآن',
      'hadiths': 'الأحاديث',
      'prayer_times': 'أوقات الصلاة',
      'settings': 'المزيد',
      'share_app': 'مشاركة التطبيق',
      'share_text': 'تفضل بتحميل هذا التطبيق الرائع للقرآن والدعاء!',
      'hijri_calendar': 'التقويم الهجري',
      'tasbih': 'عداد التسبيح',
      'reset': 'إعادة تعيين',
      'count': 'العدد',
      'prayer_tracker': '🕌 متتبع الصلاة',
      'hadith_of_day': '⭐ حديث اليوم',
      'changes_daily': '(يتغير يوميًا تلقائيًا)',
      'quran_title': '📖 القرآن الكريم',
      'choose_language': '🌍 اختر اللغة',
      'hadith_title': '📖 أحاديث النبي ﷺ',
      'search_hint': 'ابحث عن موضوع...',
      'prayer_times_title': '🕌 أوقات الصلاة',
      'based_on_location': 'بناءً على موقعك',
      'loading_prayer_times': 'جارٍ تحميل أوقات الصلاة...',
      'retry': 'حاول مرة أخرى',
      'next_prayer': 'الصلاة القادمة',
      'page': 'صفحة',
      'of': 'من',
      'back': 'رجوع',
      'next': 'التالي',
      'profile': 'الملف الشخصي',
      'language': 'اللغة',
      'theme': 'المظهر',
      'about': 'حول',
      'edit_name': 'تعديل الاسم',
      'new_name': 'اسم جديد',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'change_language': '🌍 تغيير اللغة',
      'example_text': 'نص تجريبي',
      'app_info': 'تطبيق القرآن والحديث\nالإصدار 1.0.0\n\nتم التطوير بـ ❤️ للأمة الإسلامية',
      'no_hadiths': 'لم يتم العثور على أحاديث',
      'ayahs': 'آيات',
      'fajr': 'الفجر',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
      'dua': 'دعاء',
      'morning_dua': '☀️ دعاء الصباح',
      'after_meal': '🍽️ بعد الطعام',
      'before_sleep_dua': '🌙 قبل النوم',
      'when_leaving': '🚪 عند الخروج',
      'daily_dhikr': '📿 الذكر اليومي',
      'morning_duas': '🌅 أذكار الصباح',
      'evening_duas': '🌙 أذكار المساء',
      'leaving_home': '🚪 عند الخروج',
      'entering_home': '🏠 عند الدخول',
      'before_sleep': '😴 قبل النوم',
      'after_wudu': '💧 بعد الوضوء',
      'before_exam': '📚 قبل الامتحان',
      'when_traveling': '✈️ عند السفر',
      'when_sick': '🤒 عند المرض',
      'for_parents': '👪 للوالدين',
      'seeking_knowledge': '🎓 طلب العلم',
      'times': 'مرات',
      'feedback_title': '💬 رسالة إلى المطور',
      'feedback_hint': 'اكتب شكواك أو اقتراحك هنا...',
      'feedback_send': 'إرسال',
      'feedback_success': 'تم الإرسال بنجاح! شكراً لك 💚',
      'feedback_error': 'خطأ في الإرسال. حاول مرة أخرى.',
      'view_feedback': '📝 عرض الرسائل',
      'admin_panel': '🔒 لوحة الإدارة',
      'enter_password': 'أدخل كلمة المرور',
      'password_hint': 'كلمة مرور الإدارة',
      'unlock': 'فتح',
      'wrong_password': 'كلمة مرور خاطئة!',
      'no_feedback': 'لا توجد رسائل',
      'feedback_from': 'من',
      'anonymous': 'مجهول',
      'delete': 'حذف',
    },
  };

  static String get(String key, String langCode) {
    return _translations[langCode]?[key] ?? _translations['de']?[key] ?? key;
  }
}

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

enum AppLanguage {
  german('Deutsch', '🇩🇪', 'de'),
  english('English', '🇬🇧', 'en'),
  arabic('العربية', '🇸🇦', 'ar');

  final String displayName;
  final String flag;
  final String code;
  const AppLanguage(this.displayName, this.flag, this.code);
}

enum AppTheme {
  classic(Colors.amber, 'Klassisch'),
  green(Colors.green, 'Grün'),
  blue(Colors.blue, 'Blau'),
  purple(Colors.purple, 'Lila'),
  teal(Colors.teal, 'Türkis');

  final Color color;
  final String name;
  const AppTheme(this.color, this.name);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme currentTheme = AppTheme.classic;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('app_theme') ?? 0;
    setState(() {
      currentTheme = AppTheme.values[themeIndex];
    });
  }

  void updateTheme(AppTheme newTheme) {
    setState(() {
      currentTheme = newTheme;
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
            return LanguageSelectionScreen(themeColor: currentTheme.color);
          }
          return MainPage(themeColor: currentTheme.color, onThemeChanged: updateTheme);
        },
      ),
    );
  }

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('app_language');
  }
}

// ==================== LANGUAGE SELECTION ====================
class LanguageSelectionScreen extends StatefulWidget {
  final Color themeColor;
  const LanguageSelectionScreen({super.key, required this.themeColor});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage? selectedLanguage;

  Future<void> _saveLanguage() async {
    if (selectedLanguage == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', selectedLanguage!.code);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen(themeColor: widget.themeColor)),
      );
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
                Text(
                  'Welche Sprache möchtest du nutzen?',
                  style: TextStyle(
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
                    onTap: () => setState(() => selectedLanguage = lang),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: isSelected ? widget.themeColor.withOpacity(0.2) : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? widget.themeColor : Colors.grey.shade700,
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 40)),
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
                          if (isSelected) Icon(Icons.check_circle, color: widget.themeColor, size: 32),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: selectedLanguage != null ? _saveLanguage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedLanguage != null ? widget.themeColor : Colors.grey,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    selectedLanguage != null 
                      ? (selectedLanguage == AppLanguage.german ? 'WEITER' : selectedLanguage == AppLanguage.english ? 'CONTINUE' : 'التالي')
                      : 'WEITER',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== WELCOME SCREEN ====================
class WelcomeScreen extends StatefulWidget {
  final Color themeColor;
  const WelcomeScreen({super.key, required this.themeColor});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  String langCode = 'de';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      langCode = prefs.getString('app_language') ?? 'de';
    });
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainPage(
            themeColor: widget.themeColor,
            onThemeChanged: (theme) {},
          ),
        ),
      );
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
              children: [
                Text(
                  'السلام عليكم',
                  style: GoogleFonts.amiriQuran(color: widget.themeColor, fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Text(
                  langCode == 'de' 
                    ? 'Wie heißt du?' 
                    : langCode == 'en' 
                      ? "What's your name?" 
                      : 'ما اسمك؟',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: langCode == 'de' 
                      ? 'Dein Name' 
                      : langCode == 'en' 
                        ? 'Your Name' 
                        : 'اسمك',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: widget.themeColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: widget.themeColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: widget.themeColor, width: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Image.asset('assets/images/quran_app_logo.png', width: 180, height: 180),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  ),
                  child: Text(
                    langCode == 'de' ? 'WEITER' : langCode == 'en' ? 'CONTINUE' : 'التالي',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
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
  final Color themeColor;
  final Function(AppTheme) onThemeChanged;
  
  const MainPage({super.key, required this.themeColor, required this.onThemeChanged});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tab = 0;
  String langCode = 'de';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      langCode = prefs.getString('app_language') ?? 'de';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/hintergrund.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          [
            HomePage(themeColor: widget.themeColor, langCode: langCode),
            QuranPage(themeColor: widget.themeColor),
            SunnahPage(themeColor: widget.themeColor),
            DuaPage(themeColor: widget.themeColor, langCode: langCode),
            SettingsPage(themeColor: widget.themeColor, onThemeChanged: widget.onThemeChanged, langCode: langCode),
          ][tab],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) => setState(() => tab = i),
        backgroundColor: Colors.black87,
        selectedItemColor: widget.themeColor,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppTranslations.get('home', langCode)),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: AppTranslations.get('quran', langCode)),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: AppTranslations.get('hadiths', langCode)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: AppTranslations.get('dua', langCode)),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppTranslations.get('settings', langCode)),
        ],
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class HomePage extends StatefulWidget {
  final Color themeColor;
  final String langCode;
  const HomePage({super.key, required this.themeColor, required this.langCode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int hadithIndex = 0;
  List<bool> duaTracker = [false, false, false, false, false];
  
  List<String> get duaNames => [
    AppTranslations.get('morning_dua', widget.langCode),
    AppTranslations.get('after_meal', widget.langCode),
    AppTranslations.get('before_sleep_dua', widget.langCode),
    AppTranslations.get('when_leaving', widget.langCode),
    AppTranslations.get('daily_dhikr', widget.langCode),
  ];
  
  Map<String, List<String>> get hadithsByLanguage => {
    'de': [
      '💫 Prophet ﷺ: "Allah ist barmherziger zu Seinen Dienern als eine Mutter zu ihrem Kind" (Bukhari & Muslim)',
      '🌟 Prophet ﷺ: "Die besten unter euch sind diejenigen, die den Quran lernen und lehren" (Bukhari)',
      '✨ Prophet ﷺ: "Allah liebt diejenigen, die Gutes tun, und Allah ist mit den Geduldigen" (Bukhari)',
      '💖 Prophet ﷺ: "Derjenige, der kein Erbarmen zeigt, dem wird kein Erbarmen gezeigt" (Bukhari & Muslim)',
      '🌙 Prophet ﷺ: "Lächle deinen Bruder an, das ist eine Sadaqah (Almosen)" (Tirmidhi)',
      '☀️ Prophet ﷺ: "Wenn Allah jemanden liebt, prüft Er ihn. Wer geduldig ist, bekommt Geduld als Belohnung" (Bukhari)',
      '💚 Prophet ﷺ: "Die Starken sind nicht die, die im Kampf gewinnen, sondern die, die sich selbst kontrollieren können" (Bukhari)',
      '🕊️ Prophet ﷺ: "Wer an Allah und den Jüngsten Tag glaubt, soll Gutes sprechen oder schweigen" (Bukhari & Muslim)',
      '🌸 Prophet ﷺ: "Ein gutes Wort ist Sadaqah (Almosen)" (Bukhari & Muslim)',
      '🌺 Prophet ﷺ: "Allah schaut nicht auf euren Körper oder euer Aussehen, sondern auf eure Herzen und Taten" (Muslim)',
    ],
    'en': [
      '💫 Prophet ﷺ: "Allah is more merciful to His servants than a mother is to her child" (Bukhari & Muslim)',
      '🌟 Prophet ﷺ: "The best among you are those who learn the Quran and teach it" (Bukhari)',
      '✨ Prophet ﷺ: "Allah loves those who do good, and Allah is with the patient" (Bukhari)',
      '💖 Prophet ﷺ: "He who does not show mercy will not be shown mercy" (Bukhari & Muslim)',
      '🌙 Prophet ﷺ: "Smile at your brother, that is charity" (Tirmidhi)',
      '☀️ Prophet ﷺ: "When Allah loves someone, He tests them. Whoever is patient receives patience as reward" (Bukhari)',
      '💚 Prophet ﷺ: "The strong are not those who win in battle, but those who control themselves" (Bukhari)',
      '🕊️ Prophet ﷺ: "Whoever believes in Allah and the Last Day should speak good or remain silent" (Bukhari & Muslim)',
      '🌸 Prophet ﷺ: "A good word is charity" (Bukhari & Muslim)',
      '🌺 Prophet ﷺ: "Allah does not look at your bodies or appearance, but at your hearts and deeds" (Muslim)',
    ],
    'ar': [
      '💫 النبي ﷺ: "إن الله أرحم بعباده من الوالدة بولدها" (البخاري ومسلم)',
      '🌟 النبي ﷺ: "خيركم من تعلم القرآن وعلمه" (البخاري)',
      '✨ النبي ﷺ: "إن الله يحب المحسنين، وإن الله مع الصابرين" (البخاري)',
      '💖 النبي ﷺ: "من لا يَرحم لا يُرحم" (البخاري ومسلم)',
      '🌙 النبي ﷺ: "تبسمك في وجه أخيك صدقة" (الترمذي)',
      '☀️ النبي ﷺ: "إذا أحب الله عبداً ابتلاه، فمن صبر فله الصبر" (البخاري)',
      '💚 النبي ﷺ: "ليس الشديد بالصُّرَعة، إنما الشديد الذي يملك نفسه عند الغضب" (البخاري)',
      '🕊️ النبي ﷺ: "من كان يؤمن بالله واليوم الآخر فليقل خيراً أو ليصمت" (البخاري ومسلم)',
      '🌸 النبي ﷺ: "الكلمة الطيبة صدقة" (البخاري ومسلم)',
      '🌺 النبي ﷺ: "إن الله لا ينظر إلى أجسادكم ولا إلى صوركم، ولكن ينظر إلى قلوبكم وأعمالكم" (مسلم)',
    ],
  };
  
  List<String> get hadiths => hadithsByLanguage[widget.langCode] ?? hadithsByLanguage['de']!;

  @override
  void initState() {
    super.initState();
    _checkAndResetDaily();
    _loadDuaTracker();
    _setDailyHadith();
  }

  Future<void> _checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final heute = DateTime.now();
    final heuteString = '${heute.year}-${heute.month}-${heute.day}';
    final gespeichertesDatum = prefs.getString('dua_datum') ?? '';

    if (gespeichertesDatum != heuteString) {
      for (int i = 0; i < 5; i++) {
        await prefs.setBool('dua_$i', false);
      }
      await prefs.setString('dua_datum', heuteString);
    }
  }

  Future<void> _loadDuaTracker() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < 5; i++) {
        duaTracker[i] = prefs.getBool('dua_$i') ?? false;
      }
    });
  }

  Future<void> _saveDua(int index, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dua_$index', value);
    setState(() {
      duaTracker[index] = value;
    });
  }

  void _setDailyHadith() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    setState(() {
      hadithIndex = dayOfYear % hadiths.length;
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
            // Bittgebete Tracker
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.themeColor, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    AppTranslations.get('prayer_tracker', widget.langCode),
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...List.generate(
                    5,
                    (i) {
                      final duaKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppTranslations.get(duaKeys[i], widget.langCode),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _saveDua(i, !duaTracker[i]),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: duaTracker[i]
                                      ? Colors.green
                                      : Colors.grey.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  duaTracker[i] ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Hadith of the Day
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.themeColor, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    AppTranslations.get('hadith_of_day', widget.langCode),
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    hadithsByLanguage[widget.langCode]?[hadithIndex] ?? hadiths[hadithIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    AppTranslations.get('changes_daily', widget.langCode),
                    style: TextStyle(
                      color: widget.themeColor,
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

// ==================== SURAH LANGUAGE ENUM ====================
enum SurahLanguage {
  arabic('العربية', '🇸🇦', 'ar', 'ar.alafasy'),
  english('English', '🇬🇧', 'en', 'en.sahih'),
  german('Deutsch', '🇩🇪', 'de', 'de.bubenheim');

  final String displayName;
  final String flag;
  final String code;
  final String editionId;
  const SurahLanguage(this.displayName, this.flag, this.code, this.editionId);
}

// ==================== SURAH API SERVICE ====================
// Nutzt AlQuran Cloud API - kostenlos, ohne Limits, alle Sprachen!
class SurahApiService {
  static const int totalSurahs = 114;
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  
  // Lade alle Verse für eine Sure mit optionaler Übersetzung
  static Future<Map<String, dynamic>> getSurahVerses(
    int surahNumber, 
    SurahLanguage language,
  ) async {
    try {
      // AlQuran Cloud API - lädt ALLE Verse automatisch!
      String url = '$baseUrl/surah/$surahNumber/${language.editionId}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] != 200 || data['data'] == null) {
          throw Exception('API returned error: ${data['status']}');
        }
        
        final surahData = data['data'];
        List<Map<String, dynamic>> verses = [];
        
        for (var ayah in surahData['ayahs']) {
          verses.add({
            'text': ayah['text'],
            'verse_number': ayah['numberInSurah'],
          });
        }
        
        String surahName = surahData['englishName'];
        String surahNameArabic = surahData['name'];
        
        return {
          'verses': verses,
          'surah_name': surahName,
          'surah_name_arabic': surahNameArabic,
          'surah_number': surahNumber,
        };
      } else {
        throw Exception('Failed to load surah $surahNumber (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('Error loading surah $surahNumber: $e');
      rethrow;
    }
  }
}

// ==================== QURAN PAGE (SURAH LIST) ====================
class QuranPage extends StatefulWidget {
  final Color themeColor;
  const QuranPage({super.key, required this.themeColor});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> surahs = [];
  SurahLanguage selectedLanguage = SurahLanguage.arabic;
  int? lastReadSurah;
  int? bookmarkedSurah;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadSurahList();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadSurah = prefs.getInt('last_read_surah');
      bookmarkedSurah = prefs.getInt('bookmarked_surah');
    });
  }

  Future<void> _loadSurahList() async {
    try {
      // AlQuran Cloud API endpoint for all surahs
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          setState(() {
            surahs = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('surah_language') ?? 'ar';
    setState(() {
      selectedLanguage = SurahLanguage.values.firstWhere(
        (lang) => lang.code == langCode,
        orElse: () => SurahLanguage.arabic,
      );
    });
  }

  Future<void> _saveLanguage(SurahLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('surah_language', language.code);
    setState(() {
      selectedLanguage = language;
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: widget.themeColor, width: 2),
          ),
          title: Text(
            'Wähle Sprache',
            style: TextStyle(
              color: widget.themeColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SurahLanguage.values.map((lang) {
              final isSelected = lang == selectedLanguage;
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : widget.themeColor.withOpacity(0.3),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  tileColor: isSelected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                  leading: Text(lang.flag, style: TextStyle(fontSize: 32)),
                  title: Text(
                    lang.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white,
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.green, size: 28)
                    : null,
                  onTap: () {
                    _saveLanguage(lang);
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

  void _showSurahList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Color(0xFF1a1a1a),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: widget.themeColor, width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.list, color: widget.themeColor),
                    SizedBox(width: 10),
                    Text(
                      'Surahs',
                      style: GoogleFonts.amiriQuran(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.themeColor,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                  ? Center(child: CircularProgressIndicator(color: widget.themeColor))
                  : ListView.builder(
                      controller: controller,
                      padding: EdgeInsets.all(15),
                      itemCount: surahs.length,
                      itemBuilder: (context, index) => _buildSurahCard(index),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(int index) {
    final surah = surahs[index];
    final surahNumber = surah['number'];
    final isLastRead = lastReadSurah == surahNumber;
    final isBookmarked = bookmarkedSurah == surahNumber;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context); // Schließe Modal
        // Sprung zur Mushaf-Seite
        int mushafPage = _getMushafPageForSurah(surahNumber);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MushafReaderPage(
              themeColor: widget.themeColor,
              onShowSurahList: _showSurahList,
              // Startet auf der richtigen Seite
              key: ValueKey(mushafPage),
            ),
          ),
        );
        _loadBookmarks();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBookmarked 
              ? widget.themeColor.withOpacity(0.15)
              : Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isBookmarked ? Colors.amber : widget.themeColor,
            width: isBookmarked ? 3 : 2,
          ),
          boxShadow: isBookmarked ? [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isBookmarked ? Colors.amber : widget.themeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${surah['number']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          surah['englishName'] ?? '',
                          style: TextStyle(
                            color: isBookmarked ? widget.themeColor : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isBookmarked)
                        Icon(Icons.bookmark, color: Colors.amber, size: 20),
                      if (isLastRead && !isBookmarked)
                        Icon(Icons.history, color: widget.themeColor.withOpacity(0.7), size: 18),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${surah['numberOfAyahs']} Verse • ${surah['revelationType'] ?? ''}',
                    style: TextStyle(
                      color: isBookmarked ? Colors.white.withOpacity(0.8) : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              surah['name'] ?? '',
              style: TextStyle(
                color: widget.themeColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  // Mapping Surah → Mushaf-Seite (Beispiel: Surah 1 = Seite 3, Surah 114 = Seite 604)
  int _getMushafPageForSurah(int surahNumber) {
    // TODO: Ersetze durch echte Zuordnung falls vorhanden
    if (surahNumber == 1) return 2; // Seite 3 (Index 2)
    if (surahNumber == 114) return 603; // Seite 604 (Index 603)
    // ... Mapping für alle Surahs
    return 2 + (surahNumber - 1) * 5; // Dummy: jede Surah 5 Seiten Abstand
  }

  @override
  Widget build(BuildContext context) {
    return MushafReaderPage(
      themeColor: widget.themeColor,
      onShowSurahList: _showSurahList,
    );
  }
}

// ==================== FULL SURAH PAGE (ALLE VERSE MIT WISCH-SEITEN) ====================
class FullSurahPage extends StatefulWidget {
  final int surahNumber;
  final Color themeColor;
  final SurahLanguage language;

  const FullSurahPage({
    super.key,
    required this.surahNumber,
    required this.themeColor,
    required this.language,
  });

  @override
  State<FullSurahPage> createState() => _FullSurahPageState();
}

class _FullSurahPageState extends State<FullSurahPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool isBookmarked = false;
  Map<String, Color> highlightedVerses = {}; // "surah_verse" -> Color
  Color? selectedHighlightColor;
  bool showColorPicker = false;

  // Highlight-Farben
  final Map<String, Color> highlightColors = {
    '💛 Gelb': Colors.yellow.shade300,
    '💚 Grün': Colors.green.shade200,
    '💙 Blau': Colors.blue.shade200,
    '💗 Rosa': Colors.pink.shade200,
    '🟠 Orange': Colors.orange.shade200,
  };

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
    _saveLastRead();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final highlightsJson = prefs.getString('verse_highlights') ?? '{}';
    try {
      final Map<String, dynamic> decoded = json.decode(highlightsJson);
      setState(() {
        highlightedVerses = decoded.map((key, value) => 
          MapEntry(key, Color(value as int))
        );
      });
    } catch (e) {
      print('Error loading highlights: $e');
    }
  }

  Future<void> _saveHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final highlightsJson = json.encode(
      highlightedVerses.map((key, value) => MapEntry(key, value.value))
    );
    await prefs.setString('verse_highlights', highlightsJson);
  }

  void _toggleVerseHighlight(int verseNumber) {
    final key = '${widget.surahNumber}_$verseNumber';
    
    if (highlightedVerses.containsKey(key)) {
      // Bereits markiert - entfernen
      setState(() {
        highlightedVerses.remove(key);
      });
      _saveHighlights();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Markierung entfernt'),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: Duration(seconds: 1),
        ),
      );
    } else if (selectedHighlightColor != null) {
      // Markieren mit gewählter Farbe
      setState(() {
        highlightedVerses[key] = selectedHighlightColor!;
      });
      _saveHighlights();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Vers markiert!'),
          backgroundColor: selectedHighlightColor,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Keine Farbe gewählt - Hinweis
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('👆 Wähle zuerst eine Farbe oben'),
          backgroundColor: widget.themeColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedSurah = prefs.getInt('bookmarked_surah');
    setState(() {
      isBookmarked = bookmarkedSurah == widget.surahNumber;
    });
  }

  Future<void> _saveLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', widget.surahNumber);
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    if (isBookmarked) {
      await prefs.remove('bookmarked_surah');
      setState(() => isBookmarked = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lesezeichen entfernt'),
            backgroundColor: Colors.red.withOpacity(0.8),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await prefs.setInt('bookmarked_surah', widget.surahNumber);
      setState(() => isBookmarked = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📖 Lesezeichen gesetzt!'),
            backgroundColor: widget.themeColor,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F3E8),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Surah ${widget.surahNumber}',
          style: GoogleFonts.amiriQuran(
            color: widget.themeColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: widget.themeColor),
        actions: [
          // Color Picker Toggle
          IconButton(
            icon: Icon(
              showColorPicker ? Icons.palette : Icons.palette_outlined,
              color: showColorPicker ? Colors.amber : widget.themeColor,
              size: 26,
            ),
            onPressed: () {
              setState(() {
                showColorPicker = !showColorPicker;
              });
            },
            tooltip: 'Farbe zum Markieren wählen',
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : widget.themeColor,
              size: 28,
            ),
            onPressed: _toggleBookmark,
            tooltip: isBookmarked ? 'Lesezeichen entfernen' : 'Lesezeichen setzen',
          ),
        ],
      ),
      body: Column(
        children: [
          // Color Picker Bar
          if (showColorPicker)
            Container(
              color: Colors.black.withOpacity(0.9),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Text(
                    '👇 Farbe wählen, dann Verse antippen zum Markieren',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: highlightColors.entries.map((entry) {
                        final isSelected = selectedHighlightColor == entry.value;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedHighlightColor = isSelected ? null : entry.value;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ] : [],
                            ),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 5),
                  if (selectedHighlightColor != null)
                    Text(
                      '✓ Gewählt - jetzt Verse antippen',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                    ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: SurahApiService.getSurahVerses(widget.surahNumber, widget.language),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
              child: CircularProgressIndicator(color: widget.themeColor),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.black38),
                  SizedBox(height: 20),
                  Text(
                    'Fehler beim Laden',
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final allVerses = data['verses'] as List<Map<String, dynamic>>;
          final surahName = data['surah_name'];
          final surahNameArabic = data['surah_name_arabic'];
          
          // RTL für Arabisch (links = vorwärts), LTR für Englisch/Deutsch (rechts = vorwärts)
          bool isRTL = widget.language == SurahLanguage.arabic;

          return PageView(
            controller: _pageController,
            reverse: isRTL,
            onPageChanged: (index) {
              setState(() => _currentPageIndex = index);
            },
            children: [
              // Seite 1: Surah Info + ALLE Verse
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 2.5,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Surah Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: widget.themeColor, width: 3),
                        ),
                        child: Column(
                          children: [
                            Text(
                              surahNameArabic,
                              style: GoogleFonts.amiriQuran(
                                fontSize: 32,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              surahName,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${allVerses.length} Verse',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      // Bismillah
                      if (_shouldShowBismillah(widget.surahNumber)) ...[
                        _buildBismillah(),
                        SizedBox(height: 30),
                      ],
                      // ALLE Verse - einzeln anklickbar
                      ...allVerses.map((verse) {
                        final verseNumber = verse['verse_number'] as int;
                        final key = '${widget.surahNumber}_$verseNumber';
                        final isHighlighted = highlightedVerses.containsKey(key);
                        final highlightColor = highlightedVerses[key];

                        return GestureDetector(
                          onTap: () => _toggleVerseHighlight(verseNumber),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.all(isHighlighted ? 12 : 8),
                            decoration: BoxDecoration(
                              color: isHighlighted ? highlightColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isHighlighted ? Border.all(
                                color: Colors.black.withOpacity(0.2),
                                width: 1,
                              ) : null,
                            ),
                            child: _buildSingleVerse(verse),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 100), // Space at bottom
                    ],
                  ),
                ),
              ),
            ],
          );
        },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleVerse(Map<String, dynamic> verse) {
    final text = verse['text'];
    final verseNumber = verse['verse_number'].toString();
    
    // Arabische Versnummer
    final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String arabicNumber = verseNumber.split('').map((digit) {
      return arabicNumerals[int.parse(digit)];
    }).join();

    if (widget.language == SurahLanguage.arabic) {
      return RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: GoogleFonts.amiriQuran(
                fontSize: 24,
                color: Colors.black,
                height: 2.0,
                letterSpacing: 0.3,
              ),
            ),
            TextSpan(
              text: ' ﴿$arabicNumber﴾ ',
              style: GoogleFonts.amiriQuran(
                fontSize: 20,
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.8,
              ),
            ),
            TextSpan(
              text: ' ﴿$arabicNumber﴾',
              style: GoogleFonts.amiriQuran(
                fontSize: 16,
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBismillah() {
    const bismillahArabic = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
    const bismillahTranslation = {
      'en': 'In the name of Allah, the Most Gracious, the Most Merciful',
      'de': 'Im Namen Allahs, des Allerbarmers, des Barmherzigen',
    };

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: widget.themeColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          if (widget.language == SurahLanguage.arabic)
            Text(
              bismillahArabic,
              style: GoogleFonts.amiriQuran(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          else ...[
            Text(
              bismillahTranslation[widget.language.code] ?? bismillahTranslation['en']!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  List<InlineSpan> _buildVerses(List<Map<String, dynamic>> verses) {
    List<InlineSpan> spans = [];

    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final text = verse['text'];
      final verseNumber = verse['verse_number'].toString();

      if (widget.language == SurahLanguage.arabic) {
        // Arabisch: KOMPLETT SCHWARZ (inkl. Harakat!)
        spans.add(TextSpan(
          text: text,
          style: GoogleFonts.amiriQuran(
            fontSize: 24,
            color: Colors.black, // SCHWARZ - KEINE ROTEN HARAKAT!
            height: 2.0,
            letterSpacing: 0.3,
            shadows: [], // Keine Schatten
            decoration: TextDecoration.none,
            decorationColor: Colors.black,
          ),
        ));
      } else {
        // Übersetzungen
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.8,
          ),
        ));
      }

      // Versnummer mit arabischen Ziffern
      final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String arabicNumber = verseNumber.split('').map((digit) {
        return arabicNumerals[int.parse(digit)];
      }).join();

      spans.add(TextSpan(
        text: ' ﴿$arabicNumber﴾ ',
        style: GoogleFonts.amiriQuran(
          fontSize: widget.language == SurahLanguage.arabic ? 20 : 16,
          color: widget.themeColor,
          fontWeight: FontWeight.bold,
        ),
      ));

      if (i < verses.length - 1) {
        spans.add(TextSpan(text: widget.language == SurahLanguage.arabic ? '  ' : ' '));
      }
    }

    return spans;
  }

  bool _shouldShowBismillah(int surahNumber) {
    return surahNumber != 1 && surahNumber != 9;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ==================== OLD QURAN PAGE (TEXT-BASED READER) ====================
class OldQuranPage extends StatefulWidget {
  final Color themeColor;
  const OldQuranPage({super.key, required this.themeColor});

  @override
  State<OldQuranPage> createState() => _OldQuranPageState();
}

class _OldQuranPageState extends State<OldQuranPage> {
  List<dynamic> surahs = [];
  bool isLoading = true;
  QuranLanguage selectedLanguage = QuranLanguage.arabic;
  String langCode = 'de';

  @override
  void initState() {
    super.initState();
    _loadAppLanguage();
    loadLanguagePreference();
    loadSurahs();
  }

  Future<void> _loadAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      langCode = prefs.getString('app_language') ?? 'de';
    });
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
            side: BorderSide(color: widget.themeColor, width: 2),
          ),
          title: Text(
            AppTranslations.get('choose_language', langCode),
            style: TextStyle(
              color: widget.themeColor,
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
                      color: isSelected ? Colors.green : widget.themeColor.withOpacity(0.3),
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
                  AppTranslations.get('quran_title', langCode),
                  style: TextStyle(
                    color: widget.themeColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        backgroundColor: widget.themeColor,
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
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranPage(
                              themeColor: widget.themeColor,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book, size: 20),
                      label: const Text(
                        'Mushaf',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor.withOpacity(0.8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: widget.themeColor),
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
                              builder: (context) =>
                                  SurahDetailPage(
                                    surahNumber: surah['number'],
                                    language: selectedLanguage,
                                    themeColor: widget.themeColor,
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
                            border: Border.all(color: widget.themeColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: widget.themeColor,
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
                                      '${surah['numberOfAyahs']} ${AppTranslations.get('ayahs', langCode)} • ${surah['revelationType']}',
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
                                  color: widget.themeColor,
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
  final Color themeColor;
  
  const SurahDetailPage({
    super.key, 
    required this.surahNumber,
    required this.language,
    required this.themeColor,
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
  String langCode = 'de';

  final int ayahsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadAppLanguage();
    loadSurah();
  }

  Future<void> _loadAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      langCode = prefs.getString('app_language') ?? 'de';
    });
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
            
            if (verseNumber == 1 && widget.surahNumber != 1 && widget.surahNumber != 9) {
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

    // Harakat/Tashkeel Zeichen (sollen schwarz bleiben)
    bool isHarakat(String char) {
      int code = char.codeUnitAt(0);
      return (code >= 0x064B && code <= 0x065F) || // Harakat
             code == 0x0670 || // Alif Khanjariyah
             (code >= 0x06D6 && code <= 0x06ED); // Additional marks
    }

    // Liste von Allah-Namen zum Markieren (MIT Harakat wie im Original)
    final allahNames = [
      'ٱللَّهُ', 'ٱللَّهِ', 'ٱللَّهَ', // Allah
      'ٱلرَّحْمَٰنُ', 'ٱلرَّحْمَٰنِ', // Ar-Rahman
      'ٱلرَّحِيمُ', 'ٱلرَّحِيمِ', // Ar-Raheem
      'رَبُّ', 'رَبِّ', 'رَبَّ', 'رَبِّكَ', 'رَبُّكُمْ', 'رَبَّنَا', // Rabb (Lord)
    ];

    for (int i = 0; i < pageAyahs.length; i++) {
      final ayah = pageAyahs[i];
      final verseKey = ayah['verse_key'];
      final text = ayah['text_uthmani'];

      // Markiere Allah-Namen mit separater Farbe für Harakat
      String remainingText = text;
      while (remainingText.isNotEmpty) {
        bool foundName = false;
        
        for (String name in allahNames) {
          if (remainingText.startsWith(name)) {
            // Splitte den Namen Zeichen für Zeichen
            for (int charIdx = 0; charIdx < name.length; charIdx++) {
              String char = name[charIdx];
              if (isHarakat(char)) {
                // Harakat in schwarz
                spans.add(TextSpan(
                  text: char,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: widget.language == QuranLanguage.arabic ? 36 : 22,
                    height: widget.language == QuranLanguage.arabic ? 2.5 : 2.0,
                    fontFamily: widget.language == QuranLanguage.arabic 
                      ? GoogleFonts.amiriQuran().fontFamily
                      : null,
                    fontWeight: FontWeight.w400,
                  ),
                ));
              } else {
                // Buchstabe in rot
                spans.add(TextSpan(
                  text: char,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: widget.language == QuranLanguage.arabic ? 36 : 22,
                    height: widget.language == QuranLanguage.arabic ? 2.5 : 2.0,
                    fontFamily: widget.language == QuranLanguage.arabic 
                      ? GoogleFonts.amiriQuran().fontFamily
                      : null,
                    fontWeight: FontWeight.bold,
                  ),
                ));
              }
            }
            
            remainingText = remainingText.substring(name.length);
            foundName = true;
            break;
          }
        }
        
        if (!foundName) {
          // Nächstes Zeichen hinzufügen (normal schwarz)
          spans.add(TextSpan(
            text: remainingText[0],
            style: TextStyle(
              color: Colors.black,
              fontSize: widget.language == QuranLanguage.arabic ? 36 : 22,
              height: widget.language == QuranLanguage.arabic ? 2.5 : 2.0,
              fontFamily: widget.language == QuranLanguage.arabic 
                ? GoogleFonts.amiriQuran().fontFamily
                : null,
              fontWeight: FontWeight.w400,
              letterSpacing: widget.language == QuranLanguage.arabic ? 0.8 : 0.4,
            ),
          ));
          remainingText = remainingText.substring(1);
        }
      }

      // Traditionelle Āya-Markierung mit arabischen-indischen Ziffern
      final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String arabicVerseNumber = verseKey.split('').map((digit) {
        return arabicNumerals[int.parse(digit)];
      }).join();
      
      spans.add(TextSpan(
        text: ' ﴿$arabicVerseNumber﴾ ',
        style: TextStyle(
          color: widget.themeColor,
          fontSize: widget.language == QuranLanguage.arabic ? 32 : 20,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.amiriQuran().fontFamily,
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
                color: widget.themeColor,
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
              child: CircularProgressIndicator(color: widget.themeColor),
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
                        color: widget.themeColor.withOpacity(0.15),
                        border: Border(
                          bottom: BorderSide(
                            color: widget.themeColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${AppTranslations.get('page', langCode)} ${currentPage + 1} ${AppTranslations.get('of', langCode)} $totalPages',
                            style: TextStyle(
                              color: widget.themeColor,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (currentPage == 0 && widget.surahNumber != 1 && widget.surahNumber != 9)
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
                                              color: Colors.black,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            )
                                          : const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                Expanded(
                                  child: SelectableText.rich(
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
                            color: widget.themeColor.withOpacity(0.3),
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
                                  backgroundColor: widget.themeColor,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade800,
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
                                onPressed:
                                    currentPage > 0 ? goToPreviousPage : null,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('السابق'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.themeColor,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade800,
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
                                onPressed:
                                    currentPage > 0 ? goToPreviousPage : null,
                                icon: const Icon(Icons.arrow_back),
                                label: Text(AppTranslations.get('back', langCode)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.themeColor,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade800,
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
                                label: Text(AppTranslations.get('next', langCode)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.themeColor,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade800,
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

// ==================== HADITH-SPRACH-MODELL ====================
enum HadithLanguage {
  arabic('العربية', 'ara-bukhari', '🇸🇦'),
  english('English', 'eng-bukhari', '🇬🇧');

  final String displayName;
  final String apiEdition;
  final String flag;
  const HadithLanguage(this.displayName, this.apiEdition, this.flag);
}

// ==================== DUA PAGE ====================
class DuaPage extends StatefulWidget {
  final Color themeColor;
  final String langCode;
  const DuaPage({super.key, required this.themeColor, required this.langCode});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'key': 'morning_duas', 'icon': '🌅', 'gradient': [Colors.orange.shade700, Colors.amber.shade500]},
    {'key': 'evening_duas', 'icon': '🌙', 'gradient': [Colors.deepPurple.shade700, Colors.purple.shade400]},
    {'key': 'leaving_home', 'icon': '🚪', 'gradient': [Colors.blue.shade700, Colors.cyan.shade500]},
    {'key': 'entering_home', 'icon': '🏠', 'gradient': [Colors.green.shade700, Colors.lightGreen.shade500]},
    {'key': 'before_sleep', 'icon': '😴', 'gradient': [Colors.indigo.shade800, Colors.blue.shade600]},
    {'key': 'after_wudu', 'icon': '💧', 'gradient': [Colors.teal.shade700, Colors.cyan.shade400]},
    {'key': 'before_exam', 'icon': '📚', 'gradient': [Colors.pink.shade700, Colors.red.shade400]},
    {'key': 'when_traveling', 'icon': '✈️', 'gradient': [Colors.lightBlue.shade700, Colors.blue.shade400]},
    {'key': 'when_sick', 'icon': '🤒', 'gradient': [Colors.deepOrange.shade700, Colors.orange.shade500]},
    {'key': 'for_parents', 'icon': '👪', 'gradient': [Colors.purple.shade700, Colors.pink.shade400]},
    {'key': 'seeking_knowledge', 'icon': '🎓', 'gradient': [Colors.cyan.shade700, Colors.teal.shade400]},
  ];

  final Map<String, List<Map<String, dynamic>>> duaData = {
    'morning_duas': [
      {
        'number': '1️⃣',
        'arabic': 'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ',
        'transliteration': 'A\'udhu billahi minash-shaytanir-rajim',
        'german': 'Ich suche Zuflucht bei Allah vor dem verfluchten Satan',
        'english': 'I seek refuge with Allah from the accursed Satan',
        'source': 'Quran',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلاَّ بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        'transliteration': 'Allahu la ilaha illa huwa al-hayyul-qayyum, la ta\'khudhahu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-ard, man dhal-ladhi yashfa\'u \'indahu illa bi-idhnih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bi-shay\'in min \'ilmihi illa bima sha\'a, wasi\'a kursiyyuhus-samawati wal-ard, wa la ya\'uduhu hifdhuhuma, wa huwal-\'aliyyul-\'adhim',
        'german': 'Allah - es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen. Ihn überkommt weder Schlummer noch Schlaf. Ihm gehört, was in den Himmeln und was auf der Erde ist. Wer ist es denn, der bei Ihm Fürsprache einlegen könnte außer mit Seiner Erlaubnis? Er weiß, was vor ihnen und was hinter ihnen liegt, während sie nichts von Seinem Wissen erfassen, außer was Er will. Sein Thron umfasst die Himmel und die Erde, und ihre Behütung beschwert Ihn nicht. Er ist der Erhabene und Allgewaltige.',
        'english': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Throne extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        'source': 'Quran 2:255',
      },
      {
        'number': '3️⃣',
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        'transliteration': 'Qul huwa Allahu ahad, Allahus-samad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad',
        'german': 'Sprich: Er ist Allah, ein Einziger, Allah, der Absolute. Er zeugt nicht und ist nicht gezeugt worden, und Ihm ebenbürtig ist keiner.',
        'english': 'Say: He is Allah, the One, Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
        'source': 'Surah Al-Ikhlas',
      },
      {
        'number': '4️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        'transliteration': 'Qul a\'udhu bi rabbil-falaq...',
        'german': 'Sprich: Ich nehme Zuflucht beim Herrn der Morgendämmerung vor dem Übel dessen, was Er erschaffen hat...',
        'english': 'Say: I seek refuge in the Lord of daybreak from the evil of that which He created...',
        'source': 'Surah Al-Falaq',
      },
      {
        'number': '5️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
        'transliteration': 'Qul a\'udhu bi rabbin-nas...',
        'german': 'Sprich: Ich nehme Zuflucht beim Herrn der Menschen, dem König der Menschen, dem Gott der Menschen...',
        'english': 'Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind...',
        'source': 'Surah An-Nas',
      },
      {
        'number': '6️⃣',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ للهِ، وَالْحَمْدُ للهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ',
        'transliteration': 'Asbahna wa asbahal-mulku lillah...',
        'german': 'Wir haben den Morgen erreicht und die Herrschaft gehört Allah. Alles Lob gebührt Allah...',
        'english': 'We have reached the morning and the sovereignty belongs to Allah. All praise is for Allah...',
        'source': 'Muslim',
      },
      {
        'number': '7️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma anta rabbi la ilaha illa ant...',
        'german': 'O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener...',
        'english': 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant...',
        'source': 'Sayyid Al-Istighfar - Bukhari',
      },
      {
        'number': '8️⃣',
        'arabic': 'رَضِيتُ بِاللهِ رَبَّاً، وَبِالْإِسْلَامِ دِينَاً، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيَّاً',
        'transliteration': 'Raditu billahi rabban, wa bil-Islami dinan, wa bi-Muhammadin nabiyyan',
        'german': 'Ich bin zufrieden mit Allah als Herrn, mit dem Islam als Religion und mit Muhammad als Propheten',
        'english': 'I am pleased with Allah as Lord, with Islam as religion, and with Muhammad as Prophet',
        'source': 'Abu Dawud',
      },
      {
        'number': '9️⃣',
        'arabic': 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'La ilaha illallahu wahdahu la sharika lah...',
        'german': 'Es gibt keinen Gott außer Allah allein, ohne Partner. Ihm gehört die Herrschaft und Ihm gebührt das Lob...',
        'english': 'There is no god but Allah alone, without partner. To Him belongs dominion and praise...',
        'source': 'Bukhari & Muslim',
        'times': '100',
      },
      {
        'number': '🔟',
        'arabic': 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدَاً عَبْدُكَ وَرَسُولُكَ',
        'transliteration': 'Allahumma inni asbahtu ushhiduka...',
        'german': 'O Allah, ich bezeuge am Morgen vor Dir, den Trägern Deines Thrones, Deinen Engeln und all Deiner Schöpfung...',
        'english': 'O Allah, I have reached the morning and call on You, the bearers of Your Throne, Your angels...',
        'source': 'Abu Dawud',
        'times': '4',
      },
      {
        'number': '1️⃣1️⃣',
        'arabic': 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
        'transliteration': 'Allahumma ma asbaha bi min ni\'matin...',
        'german': 'O Allah, welche Gnade auch immer ich oder eines Deiner Geschöpfe am Morgen hat, so ist sie von Dir allein...',
        'english': 'O Allah, whatever blessing I or any of Your creation have received in the morning is from You alone...',
        'source': 'Abu Dawud & An-Nasa\'i',
      },
      {
        'number': '1️⃣2️⃣',
        'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma \'afini fi badani...',
        'german': 'O Allah, gewähre mir Gesundheit in meinem Körper, in meinem Gehör, in meinem Sehvermögen...',
        'english': 'O Allah, grant me health in my body, in my hearing, in my sight...',
        'source': 'Abu Dawud',
        'times': '3',
      },
      {
        'number': '1️⃣3️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma inni a\'udhu bika minal-kufri wal-faqr...',
        'german': 'O Allah, ich suche Zuflucht bei Dir vor Unglauben und Armut, und ich suche Zuflucht bei Dir vor der Qual des Grabes...',
        'english': 'O Allah, I seek refuge with You from disbelief and poverty, and from the punishment of the grave...',
        'source': 'Abu Dawud',
        'times': '3',
      },
      {
        'number': '1️⃣4️⃣',
        'arabic': 'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        'transliteration': 'Hasbiyallahu la ilaha illa huwa \'alayhi tawakkaltu...',
        'german': 'Allah genügt mir, es gibt keinen Gott außer Ihm. Auf Ihn vertraue ich, und Er ist der Herr des gewaltigen Thrones.',
        'english': 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
        'source': 'Abu Dawud',
        'times': '7',
      },
      {
        'number': '1️⃣5️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
        'transliteration': 'Allahumma inni as\'alukal-\'afwa wal-\'afiyah...',
        'german': 'O Allah, ich bitte Dich um Vergebung und Wohlergehen in dieser Welt und im Jenseits...',
        'english': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter...',
        'source': 'Abu Dawud & Ibn Majah',
      },
      {
        'number': '1️⃣6️⃣',
        'arabic': 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءَاً أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ',
        'transliteration': 'Allahumma \'alimal-ghaybi wash-shahadah...',
        'german': 'O Allah, Kenner des Verborgenen und Sichtbaren, Schöpfer der Himmel und der Erde...',
        'english': 'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth...',
        'source': 'At-Tirmidhi',
      },
      {
        'number': '1️⃣7️⃣',
        'arabic': 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        'transliteration': 'Bismillahil-ladhi la yadurru ma\'as-mihi shay\'un...',
        'german': 'Im Namen Allahs, mit dessen Namen nichts auf Erden und im Himmel schaden kann, und Er ist der Allhörende, der Allwissende.',
        'english': 'In the Name of Allah with whose Name nothing on earth or in the heaven can cause harm, and He is the All-Hearing, All-Knowing.',
        'source': 'Abu Dawud & At-Tirmidhi',
        'times': '3',
      },
      {
        'number': '1️⃣8️⃣',
        'arabic': 'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، حَنِيفَاً مُسْلِمَاً، وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
        'transliteration': 'Asbahna \'ala fitratil-Islam...',
        'german': 'Wir haben den Morgen in der natürlichen Veranlagung des Islam erreicht, mit dem Wort des reinen Glaubens...',
        'english': 'We have reached the morning upon the fitrah of Islam, and upon the word of sincere devotion...',
        'source': 'Ahmad',
      },
      {
        'number': '1️⃣9️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
        'transliteration': 'Subhanallahi wa bihamdihi \'adada khalqihi...',
        'german': 'Preis sei Allah und Lob sei Ihm, entsprechend der Anzahl Seiner Schöpfung, Seiner Zufriedenheit...',
        'english': 'Glory is to Allah and praise is to Him, by the multitude of His creation, His pleasure...',
        'source': 'Muslim',
        'times': '3',
      },
      {
        'number': '2️⃣0️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمَاً نَافِعَاً، وَرِزْقَاً طَيِّبَاً، وَعَمَلَاً مُتَقَبَّلَاً',
        'transliteration': 'Allahumma inni as\'aluka \'ilman nafi\'an...',
        'german': 'O Allah, ich bitte Dich um nützliches Wissen, gute Versorgung und angenommene Taten.',
        'english': 'O Allah, I ask You for beneficial knowledge, good provision, and acceptable deeds.',
        'source': 'Ibn Majah',
      },
      {
        'number': '2️⃣1️⃣',
        'arabic': 'أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ',
        'transliteration': 'Astaghfirullaha wa atubu ilayh',
        'german': 'Ich bitte Allah um Vergebung und bereue zu Ihm.',
        'english': 'I seek forgiveness from Allah and repent to Him.',
        'source': 'Bukhari',
        'times': '100',
      },
      {
        'number': '2️⃣2️⃣',
        'arabic': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
        'transliteration': 'Ya Hayyu ya Qayyum, bi-rahmatika astaghith...',
        'german': 'O Lebendiger, O Beständiger, durch Deine Barmherzigkeit rufe ich um Hilfe...',
        'english': 'O Ever-Living, O Sustainer, through Your mercy I seek help...',
        'source': 'An-Nasa\'i',
      },
      {
        'number': '2️⃣3️⃣',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ للهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذَا الْيَوْمِ: فَتْحَهُ، وَنَصْرَهُ، وَنُورَهُ، وَبَرَكَتَهُ، وَهُدَاهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهِ وَشَرِّ مَا بَعْدَهُ',
        'transliteration': 'Asbahna wa asbahal-mulku lillahi rabbil-\'alamin...',
        'german': 'Wir haben den Morgen erreicht und die Herrschaft gehört Allah, dem Herrn der Welten...',
        'english': 'We have reached the morning and the sovereignty belongs to Allah, Lord of the worlds...',
        'source': 'Abu Dawud',
      },
      {
        'number': '2️⃣4️⃣',
        'arabic': 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
        'transliteration': 'Allahumma bika asbahna wa bika amsayna...',
        'german': 'O Allah, mit Dir haben wir den Morgen erreicht, mit Dir erreichen wir den Abend, mit Dir leben wir, mit Dir sterben wir...',
        'english': 'O Allah, by You we have reached the morning, by You we reach the evening, by You we live, by You we die...',
        'source': 'At-Tirmidhi',
      },
      {
        'number': '2️⃣5️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
        'transliteration': 'Allahumma anta khalaqta nafsi wa anta tawaffaha...',
        'german': 'O Allah, Du hast meine Seele erschaffen und Du nimmst sie zurück. Dir gehört ihr Tod und ihr Leben...',
        'english': 'O Allah, You have created my soul and You take it back. To You belongs its death and its life...',
        'source': 'Muslim',
      },
      {
        'number': '2️⃣6️⃣',
        'arabic': 'اللَّهُمَّ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، لَا إِلَهَ إِلَّا أَنْتَ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ',
        'transliteration': 'Allahumma fatiris-samawati wal-ard...',
        'german': 'O Allah, Schöpfer der Himmel und der Erde, Kenner des Verborgenen und Sichtbaren...',
        'english': 'O Allah, Creator of the heavens and the earth, Knower of the unseen and seen...',
        'source': 'At-Tirmidhi & Abu Dawud',
      },
      {
        'number': '2️⃣7️⃣',
        'arabic': 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'La ilaha illallahu wahdahu la sharika lahu...',
        'german': 'Es gibt keinen Gott außer Allah allein, ohne Partner. Ihm gehört die Herrschaft, Ihm gebührt das Lob. Er gibt Leben und Tod...',
        'english': 'There is no god but Allah alone with no partner. His is the dominion and to Him belongs all praise. He gives life and causes death...',
        'source': 'At-Tirmidhi',
        'times': '10',
      },
      {
        'number': '2️⃣8️⃣',
        'arabic': 'سُبْحَانَ اللهِ',
        'transliteration': 'SubhanAllah',
        'german': 'Preis sei Allah',
        'english': 'Glory be to Allah',
        'source': 'Daily Dhikr',
        'times': '33',
      },
      {
        'number': '2️⃣9️⃣',
        'arabic': 'الْحَمْدُ للهِ',
        'transliteration': 'Alhamdulillah',
        'german': 'Alles Lob gebührt Allah',
        'english': 'All praise is for Allah',
        'source': 'Daily Dhikr',
        'times': '33',
      },
      {
        'number': '3️⃣0️⃣',
        'arabic': 'اللهُ أَكْبَرُ',
        'transliteration': 'Allahu Akbar',
        'german': 'Allah ist der Größte',
        'english': 'Allah is the Greatest',
        'source': 'Daily Dhikr',
        'times': '34',
      },
      {
        'number': '3️⃣1️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        'transliteration': 'Subhanallahi wa bihamdihi',
        'german': 'Preis sei Allah und Lob sei Ihm',
        'english': 'Glory be to Allah and praise be to Him',
        'source': 'Bukhari & Muslim',
        'times': '100',
      },
    ],
    'leaving_home': [
      {
        'number': '1️⃣',
        'arabic': 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        'transliteration': 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
        'german': 'Im Namen Allahs. Ich vertraue auf Allah. Es gibt keine Kraft und keine Macht außer durch Allah.',
        'english': 'In the name of Allah. I place my trust in Allah. There is no power and no strength except through Allah.',
        'source': 'Abu Dawud & Tirmidhi',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ أَوْ أُضَلَّ، أَوْ أَزِلَّ أَوْ أُزَلَّ، أَوْ أَظْلِمَ أَوْ أُظْلَمَ، أَوْ أَجْهَلَ أَوْ يُجْهَلَ عَلَيَّ',
        'transliteration': 'Allahumma inni a\'udhu bika an adilla aw udalla, aw azilla aw uzalla, aw adhlima aw udhlama, aw ajhala aw yujhala \'alayya',
        'german': 'Oh Allah, ich suche Zuflucht bei Dir davor, fehlzugehen oder andere fehlzuleiten, auszurutschen oder andere zum Ausrutschen zu bringen, Unrecht zu tun oder Unrecht zu erleiden, unwissend zu handeln oder unwissend behandelt zu werden.',
        'english': 'O Allah, I seek refuge in You from going astray or leading others astray, from slipping or causing others to slip, from committing injustice or having injustice committed against me, and from acting ignorantly or being treated ignorantly.',
        'source': 'Abu Dawud & Tirmidhi',
      },
    ],
    'entering_home': [
      {
        'number': '1️⃣',
        'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        'transliteration': 'Bismillahi walajna, wa bismillahi kharajna, wa \'alallahi rabbina tawakkalna',
        'german': 'Im Namen Allahs treten wir ein, und im Namen Allahs gehen wir hinaus, und auf Allah, unseren Herrn, vertrauen wir.',
        'english': 'In the name of Allah we enter, and in the name of Allah we leave, and upon Allah, our Lord, we place our trust.',
        'source': 'Abu Dawud',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلَجِ وَخَيْرَ الْمَخْرَجِ، بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        'transliteration': 'Allahumma inni as\'aluka khayral-mawlaji wa khayral-makhraji, bismillahi walajna, wa bismillahi kharajna, wa \'alallahi rabbina tawakkalna',
        'german': 'O Allah, ich bitte Dich um das Beste beim Eintreten und das Beste beim Verlassen. Im Namen Allahs treten wir ein, und im Namen Allahs gehen wir hinaus, und auf Allah, unseren Herrn, vertrauen wir.',
        'english': 'O Allah, I ask You for the best entering and the best leaving. In the name of Allah we enter, and in the name of Allah we leave, and upon Allah, our Lord, we place our trust.',
        'source': 'Abu Dawud',
      },
    ],
    'before_sleep': [
      {
        'number': '1️⃣',
        'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
        'transliteration': 'Bismika rabbi wada\'tu janbi, wa bika arfa\'uh, in amsakta nafsi farhamha, wa in arsaltaha fahfadhha bima tahfadhu bihi \'ibadakas-salihin',
        'german': 'In Deinem Namen, mein Herr, lege ich meine Seite nieder, und durch Dich hebe ich sie wieder. Wenn Du meine Seele nimmst, erbarme Dich ihrer, und wenn Du sie zurücksendest, beschütze sie so, wie Du Deine rechtschaffenen Diener beschützt.',
        'english': 'In Your name, my Lord, I lie down, and in Your name I rise. If You take my soul, have mercy upon it, and if You return it, protect it as You protect Your righteous servants.',
        'source': 'Bukhari & Muslim',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
        'transliteration': 'Allahumma innaka khalaqta nafsi wa anta tawaffaha, laka mamatuha wa mahyaha, in ahyaytaha fahfadhha, wa in amattaha faghfir laha, allahumma inni as\'alukal-\'afiyah',
        'german': 'O Allah, Du hast meine Seele erschaffen und Du nimmst sie. Dir gehört ihr Tod und ihr Leben. Wenn Du sie am Leben erhältst, beschütze sie, und wenn Du sie sterben lässt, vergib ihr. O Allah, ich bitte Dich um Wohlbefinden.',
        'english': 'O Allah, You created my soul and You take it. To You belongs its death and its life. If You give it life, protect it, and if You cause it to die, forgive it. O Allah, I ask You for well-being.',
        'source': 'Muslim',
      },
      {
        'number': '3️⃣',
        'arabic': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        'transliteration': 'Allahumma qini \'adhabaka yawma tab\'athu \'ibadak',
        'german': 'O Allah, bewahre mich vor Deiner Strafe am Tag, an dem Du Deine Diener auferweckst.',
        'english': 'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '4️⃣',
        'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        'transliteration': 'Bismika Allahumma amutu wa ahya',
        'german': 'In Deinem Namen, O Allah, sterbe ich und lebe ich.',
        'english': 'In Your name, O Allah, I die and I live.',
        'source': 'Bukhari',
      },
      {
        'number': '5️⃣',
        'arabic': 'الْحَمْدُ للهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَكَفَانَا، وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ',
        'transliteration': 'Alhamdulillahil-ladhi at\'amana wa saqana, wa kafana, wa awana, fakam mimman la kafiya lahu wa la mu\'wi',
        'german': 'Alles Lob gebührt Allah, Der uns speiste und tränkte, uns genügen ließ und uns Unterkunft gab. Wie viele gibt es, die niemanden haben, der ihnen genügt oder Unterkunft gibt.',
        'english': 'All praise is for Allah, Who fed us and gave us drink, and Who is sufficient for us and has sheltered us. How many have none to suffice them or shelter them.',
        'source': 'Muslim',
      },
      {
        'number': '6️⃣',
        'arabic': 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ الْأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ، وَأَنْتَ الْآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُونَكَ شَيْءٌ، اقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ',
        'transliteration': 'Allahumma rabbas-samawatis-sab\'i wa rabbal-\'arshil-\'adhim, rabbana wa rabba kulli shay\', faliqal-habbi wan-nawa, wa munzilat-tawrati wal-injili wal-furqan, a\'udhu bika min sharri kulli shay\'in anta akhidhun binasiyatih, allahumma antal-awwalu falaysa qablaka shay\', wa antal-akhiru falaysa ba\'daka shay\', wa antadh-dhahiru falaysa fawqaka shay\', wa antal-batinu falaysa dunaka shay\', iqdi \'annad-dayna wa aghnina minal-faqr',
        'german': 'O Allah, Herr der sieben Himmel und Herr des gewaltigen Thrones, unser Herr und Herr aller Dinge, Spalter des Korns und der Dattelkerne, Herabsender der Tora, des Evangeliums und des Qurans, ich suche Zuflucht bei Dir vor dem Übel von allem, dessen Stirnlocke Du hältst. O Allah, Du bist der Erste, nichts war vor Dir, und Du bist der Letzte, nichts wird nach Dir sein, und Du bist der Offenbare, nichts ist über Dir, und Du bist der Verborgene, nichts ist näher als Du. Begleiche unsere Schulden und mache uns frei von Armut.',
        'english': 'O Allah, Lord of the seven heavens and Lord of the great Throne, our Lord and Lord of everything, Splitter of the grain and the date-stone, Revealer of the Torah, the Gospel and the Quran, I seek refuge in You from the evil of everything that You seize by the forelock. O Allah, You are the First, nothing is before You, and You are the Last, nothing is after You, and You are the Manifest, nothing is above You, and You are the Hidden, nothing is nearer than You. Settle our debt and make us free from poverty.',
        'source': 'Muslim',
      },
      {
        'number': '7️⃣',
        'arabic': 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
        'transliteration': 'Allahumma aslamtu nafsi ilayk, wa fawwadtu amri ilayk, wa wajjahtu wajhi ilayk, wa alja\'tu dhahri ilayk, raghbatan wa rahbatan ilayk, la malja\'a wa la manja minka illa ilayk, amantu bikitabikal-ladhi anzalt, wa binabiyyikal-ladhi arsalt',
        'german': 'O Allah, ich übergebe mich Dir, vertraue Dir meine Angelegenheiten an, wende mein Gesicht Dir zu und lehne meinen Rücken an Dich an, aus Verlangen nach Dir und in Ehrfurcht vor Dir. Es gibt keine Zuflucht und keine Rettung vor Dir außer zu Dir. Ich glaube an Dein Buch, das Du herabgesandt hast, und an Deinen Propheten, den Du gesandt hast.',
        'english': 'O Allah, I submit myself to You, entrust my affairs to You, turn my face to You, and lay myself down depending upon You, hoping in You and fearing You. There is no refuge and no escape from You except to You. I believe in Your Book which You revealed, and Your Prophet whom You sent.',
        'source': 'Bukhari & Muslim',
      },
    ],
    'after_wudu': [
      {
        'number': '1️⃣',
        'arabic': 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        'transliteration': 'Ashhadu an la ilaha illallahu wahdahu la sharika lah, wa ashhadu anna Muhammadan \'abduhu wa rasuluh',
        'german': 'Ich bezeuge, dass es keinen Gott gibt außer Allah allein, ohne Partner, und ich bezeuge, dass Muhammad Sein Diener und Gesandter ist.',
        'english': 'I bear witness that there is no god but Allah alone, without partner, and I bear witness that Muhammad is His servant and Messenger.',
        'source': 'Muslim',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ، وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
        'transliteration': 'Allahummaj-\'alni minat-tawwabin, waj-\'alni minal-mutatahhirin',
        'german': 'O Allah, mache mich zu einem von denen, die bereuen, und zu einem von denen, die sich reinigen.',
        'english': 'O Allah, make me among those who repent, and make me among those who purify themselves.',
        'source': 'Tirmidhi',
      },
      {
        'number': '3️⃣',
        'arabic': 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
        'transliteration': 'Subhanaka Allahumma wa bihamdik, ashhadu an la ilaha illa ant, astaghfiruka wa atubu ilayk',
        'german': 'Gepriesen seist Du, O Allah, und aller Lobpreis gebührt Dir. Ich bezeuge, dass es keinen Gott gibt außer Dir. Ich bitte Dich um Vergebung und wende mich reuevoll Dir zu.',
        'english': 'Glory be to You, O Allah, and all praise is Yours. I bear witness that there is no god but You. I seek Your forgiveness and repent to You.',
        'source': 'An-Nasa\'i',
      },
    ],
    'evening_duas': [
      {
        'number': '1️⃣',
        'arabic': 'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ',
        'transliteration': 'A\'udhu billahi minash-shaytanir-rajim',
        'german': 'Ich suche Zuflucht bei Allah vor dem verfluchten Satan.',
        'english': 'I seek refuge with Allah from the accursed Satan.',
        'source': 'Quran',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ، لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ، مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        'transliteration': 'Allahu la ilaha illa huwal-hayyul-qayyum, la ta\'khudhahu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-ard, man dhal-ladhi yashfa\'u \'indahu illa bi-idhnih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bi-shay\'in min \'ilmihi illa bima sha\'a, wasi\'a kursiyyuhus-samawati wal-ard, wa la ya\'uduhu hifdhuhuma, wa huwal-\'aliyyul-\'adhim',
        'german': 'Allah – es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen. Ihn erfasst weder Schlummer noch Schlaf. Ihm gehört, was in den Himmeln und auf der Erde ist. Wer kann bei Ihm Fürsprache einlegen außer mit Seiner Erlaubnis? Er weiß, was vor ihnen und was hinter ihnen ist. Sie umfassen nichts von Seinem Wissen außer dem, was Er will. Sein Thron umfasst die Himmel und die Erde, und ihre Bewahrung ermüdet Ihn nicht. Und Er ist der Erhabene, der Gewaltige.',
        'english': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Throne extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        'source': 'Quran 2:255',
      },
      {
        'number': '3️⃣',
        'arabic': 'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ وَقَالُوا سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ. لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
        'transliteration': 'Amanar-rasulu bima unzila ilayhi min rabbihi wal-mu\'minun, kullun amana billahi wa mala\'ikatihi wa kutubihi wa rusulihi, la nufarriqu bayna ahadin min rusulihi, wa qalu sami\'na wa ata\'na ghufranaka rabbana wa ilaykal-masir. La yukallifullahu nafsan illa wus\'aha, laha ma kasabat wa \'alayha mak-tasabat, rabbana la tu\'akhidhna in nasina aw akhta\'na, rabbana wa la tahmil \'alayna isran kama hamaltahu \'alal-ladhina min qablina, rabbana wa la tuhammilna ma la taqata lana bih, wa\'fu \'anna waghfir lana warhamna, anta mawlana fansurna \'alal-qawmil-kafirin',
        'german': 'Der Gesandte glaubt an das, was zu ihm von seinem Herrn herabgesandt worden ist, und ebenso die Gläubigen. Alle glauben an Allah, Seine Engel, Seine Bücher und Seine Gesandten. Wir machen keinen Unterschied zwischen irgendeinem Seiner Gesandten. Und sie sagen: Wir hören und wir gehorchen. (Wir bitten um) Deine Vergebung, unser Herr, und zu Dir ist die Rückkehr. Allah belastet keine Seele über ihr Vermögen hinaus. Ihr steht zu, was sie erworben hat, und gegen sie ist, was sie erworben hat. Unser Herr, ziehe uns nicht zur Rechenschaft, wenn wir vergessen oder Fehler begehen. Unser Herr, und lege uns keine Bürde auf, wie Du sie denen vor uns auferlegt hast. Unser Herr, und belaste uns nicht mit dem, was wir nicht zu tragen vermögen. Und verzeihe uns, vergib uns und erbarme Dich unser. Du bist unser Schutzherr, so hilf uns gegen das ungläubige Volk.',
        'english': 'The Messenger has believed in what was revealed to him from his Lord, and so have the believers. All of them have believed in Allah and His angels and His books and His messengers, saying, "We make no distinction between any of His messengers." And they say, "We hear and we obey. We seek Your forgiveness, our Lord, and to You is the final destination." Allah does not charge a soul except with that within its capacity. It will have the consequence of what it has gained, and it will bear the consequence of what it has earned. Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us, and forgive us, and have mercy upon us. You are our protector, so give us victory over the disbelieving people.',
        'source': 'Quran 2:285-286',
      },
      {
        'number': '4️⃣',
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
        'transliteration': 'Qul huwa Allahu ahad, Allahus-samad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad',
        'german': 'Sprich: Er ist Allah, der Eine. Allah, der Unabhängige. Er zeugt nicht und ist nicht gezeugt worden. Und keiner ist Ihm ebenbürtig.',
        'english': 'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
        'source': 'Surah Al-Ikhlas',
        'times': '3',
      },
      {
        'number': '5️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، مِنْ شَرِّ مَا خَلَقَ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        'transliteration': 'Qul a\'udhu bi rabbil-falaq, min sharri ma khalaq, wa min sharri ghasiqin idha waqab, wa min sharrin-naffathati fil-\'uqad, wa min sharri hasidin idha hasad',
        'german': 'Sprich: Ich suche Zuflucht beim Herrn des Tagesanbruchs, vor dem Übel dessen, was Er erschaffen hat, vor dem Übel der Dunkelheit, wenn sie hereinbricht, vor dem Übel der Knotenanbläserinnen und vor dem Übel eines Neiders, wenn er neidet.',
        'english': 'Say: I seek refuge in the Lord of daybreak, from the evil of that which He created, and from the evil of darkness when it settles, and from the evil of the blowers in knots, and from the evil of an envier when he envies.',
        'source': 'Surah Al-Falaq',
        'times': '3',
      },
      {
        'number': '6️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ، مَلِكِ النَّاسِ، إِلَٰهِ النَّاسِ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ، الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ، مِنَ الْجِنَّةِ وَالنَّاسِ',
        'transliteration': 'Qul a\'udhu bi rabbin-nas, malikin-nas, ilahin-nas, min sharril-waswasil-khannas, alladhi yuwaswisu fi sudurin-nas, minal-jinnati wan-nas',
        'german': 'Sprich: Ich suche Zuflucht beim Herrn der Menschen, dem König der Menschen, dem Gott der Menschen, vor dem Übel des Einflüsterers, der sich zurückzieht, der in die Herzen der Menschen einflüstert, sei er von den Dschinn oder von den Menschen.',
        'english': 'Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer, who whispers into the breasts of mankind, from among the jinn and mankind.',
        'source': 'Surah An-Nas',
        'times': '3',
      },
      {
        'number': '7️⃣',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ وَالْحَمْدُ للهِ، لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَٰذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَٰذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
        'transliteration': 'Amsayna wa amsal-mulku lillah walhamdulillah, la ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu, wa huwa \'ala kulli shay\'in qadir, rabbi as\'aluka khayra ma fi hadhihil-laylati wa khayra ma ba\'daha, wa a\'udhu bika min sharri ma fi hadhihil-laylati wa sharri ma ba\'daha, rabbi a\'udhu bika minal-kasali wa su\'il-kibar, rabbi a\'udhu bika min \'adhabin fin-nari wa \'adhabin fil-qabr',
        'german': 'Wir haben den Abend erreicht, und das Königreich gehört Allah. Alles Lob gebührt Allah. Es gibt keinen Gott außer Allah allein, ohne Teilhaber. Ihm gehört die Herrschaft und Ihm gehört der Lobpreis, und Er hat Macht über alle Dinge. Mein Herr, ich bitte Dich um das Gute dieser Nacht und das Gute danach, und ich suche Zuflucht bei Dir vor dem Übel dieser Nacht und dem Übel danach. Mein Herr, ich suche Zuflucht bei Dir vor Trägheit und vor schlechtem Altern. Mein Herr, ich suche Zuflucht bei Dir vor einer Strafe im Feuer und vor der Strafe im Grab.',
        'english': 'We have reached the evening and the sovereignty belongs to Allah. All praise is for Allah. There is no god but Allah alone, without partner. To Him belongs dominion and praise, and He has power over all things. My Lord, I ask You for the good of this night and the good that follows it, and I seek refuge in You from the evil of this night and the evil that follows it. My Lord, I seek refuge in You from laziness and from bad old age. My Lord, I seek refuge in You from punishment in the Fire and punishment in the grave.',
        'source': 'Muslim',
      },
      {
        'number': '8️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma anta rabbi la ilaha illa ant, khalaqtani wa ana \'abduk, wa ana \'ala \'ahdika wa wa\'dika mas-tata\'t, a\'udhu bika min sharri ma sana\'t, abu\'u laka bini\'matika \'alayya wa abu\'u bidhanbi faghfir li fa\'innahu la yaghfirudh-dhunuba illa ant',
        'german': 'O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener. Ich halte an Deinem Bund und Deinem Versprechen fest, so gut ich kann. Ich suche Zuflucht bei Dir vor dem Übel dessen, was ich getan habe. Ich erkenne Deine Gnade an mir an und ich bekenne meine Sünde. So vergib mir, denn niemand vergibt die Sünden außer Dir.',
        'english': 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant. I abide by Your covenant and promise as much as I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for verily none can forgive sins except You.',
        'source': 'Sayyid Al-Istighfar - Bukhari',
      },
      {
        'number': '9️⃣',
        'arabic': 'رَضِيتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا وَرَسُولًا',
        'transliteration': 'Raditu billahi rabban, wa bil-Islami dinan, wa bi-Muhammadin sallallahu \'alayhi wa sallama nabiyyan wa rasulan',
        'german': 'Ich bin zufrieden mit Allah als meinem Herrn, mit dem Islam als meiner Religion und mit Muhammad ﷺ als Propheten und Gesandten.',
        'english': 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad ﷺ as a Prophet and Messenger.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '🔟',
        'arabic': 'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللهُ لَا إِلَٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ سَيِّدَنَا مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
        'transliteration': 'Allahumma inni amsaytu ushhiduk, wa ushhidu hamalata \'arshik, wa mala\'ikatak, wa jami\'a khalqik, annaka antallahu la ilaha illa anta wahdaka la sharika lak, wa anna sayyidana Muhammadan \'abduka wa rasuluk',
        'german': 'O Allah, wahrlich, ich habe den Abend erreicht und nehme Dich zum Zeugen, und ich nehme die Träger Deines Thrones, Deine Engel und die gesamte Schöpfung zu Zeugen, dass Du Allah bist: Es gibt keinen Gott außer Dir allein, ohne Teilhaber, und dass unser Herr Muhammad Dein Diener und Dein Gesandter ist.',
        'english': 'O Allah, I have reached the evening and call on You, the bearers of Your Throne, Your angels, and all of Your creation to witness that You are Allah: None has the right to be worshipped except You, alone, without partner, and that Muhammad is Your servant and Messenger.',
        'source': 'Abu Dawud',
        'times': '4',
      },
      {
        'number': '1️⃣1️⃣',
        'arabic': 'اللَّهُمَّ مَا أَمْسَىٰ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
        'transliteration': 'Allahumma ma amsa bi min ni\'matin aw bi-ahadin min khalqika faminka wahdaka la sharika lak, falakal-hamdu wa lakash-shukr',
        'german': 'O Allah, jede Gnade, die mich oder eines Deiner Geschöpfe am Abend erreicht hat, stammt allein von Dir. Dir gebührt aller Lobpreis und aller Dank.',
        'english': 'O Allah, whatever blessing I or any of Your creation have received in the evening is from You alone, without partner, so to You belongs all praise and all thanks.',
        'source': 'Abu Dawud & An-Nasa\'i',
      },
      {
        'number': '1️⃣2️⃣',
        'arabic': 'حَسْبِيَ اللهُ لَا إِلَٰهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        'transliteration': 'Hasbiyallahu la ilaha illa huwa, \'alayhi tawakkaltu wa huwa rabbul-\'arshil-\'adhim',
        'german': 'Allah genügt mir. Es gibt keinen Gott außer Ihm. Auf Ihn vertraue ich, und Er ist der Herr des gewaltigen Thrones.',
        'english': 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
        'source': 'Abu Dawud',
        'times': '7',
      },
      {
        'number': '1️⃣3️⃣',
        'arabic': 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        'transliteration': 'Bismillahil-ladhi la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-sami\'ul-\'alim',
        'german': 'Im Namen Allahs, bei dessen Namen nichts auf der Erde und im Himmel schadet, und Er ist der Allhörende, der Allwissende.',
        'english': 'In the name of Allah with whose name nothing is harmed on earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '1️⃣4️⃣',
        'arabic': 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
        'transliteration': 'Allahumma bika amsayna wa bika asbahna wa bika nahya wa bika namutu wa ilaykal-masir',
        'german': 'O Allah, durch Dich erreichen wir den Abend, durch Dich erreichen wir den Morgen, durch Dich leben wir und durch Dich sterben wir, und zu Dir ist die Rückkehr.',
        'english': 'O Allah, by You we reach the evening, by You we reach the morning, by You we live, by You we die, and to You is the return.',
        'source': 'Abu Dawud & Tirmidhi',
      },
      {
        'number': '1️⃣5️⃣',
        'arabic': 'أَمْسَيْنَا عَلَىٰ فِطْرَةِ الْإِسْلَامِ، وَعَلَىٰ كَلِمَةِ الْإِخْلَاصِ، وَعَلَىٰ دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَىٰ مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
        'transliteration': 'Amsayna \'ala fitratil-Islam, wa \'ala kalimatul-ikhlas, wa \'ala dini nabiyyina Muhammadin sallallahu \'alayhi wa sallam, wa \'ala millati abina Ibrahima hanifan musliman wa ma kana minal-mushrikin',
        'german': 'Wir haben den Abend auf der natürlichen Veranlagung des Islam erreicht, auf dem Wort der Aufrichtigkeit, auf der Religion unseres Propheten Muhammad ﷺ und auf der Gemeinschaft unseres Vaters Ibrahim.',
        'english': 'We have reached the evening upon the natural religion of Islam, and upon the word of sincere devotion, and upon the religion of our Prophet Muhammad ﷺ, and upon the religion of our father Ibrahim, inclining toward truth, and he was not of the polytheists.',
        'source': 'Ahmad',
      },
      {
        'number': '1️⃣6️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
        'transliteration': 'Subhanallahi wa bihamdihi, \'adada khalqih, wa rida nafsih, wa zinata \'arshih, wa midada kalimatih',
        'german': 'Gepriesen ist Allah und alles Lob gebührt Ihm, entsprechend der Anzahl Seiner Schöpfung, dem Wohlgefallen Seiner Selbst, dem Gewicht Seines Thrones und der Fülle Seiner Worte.',
        'english': 'Glory be to Allah and praise Him, by the number of His creation, by His pleasure, by the weight of His Throne, and by the ink of His words.',
        'source': 'Muslim',
        'times': '3',
      },
      {
        'number': '1️⃣7️⃣',
        'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma \'afini fi badani, allahumma \'afini fi sam\'i, allahumma \'afini fi basari, la ilaha illa ant',
        'german': 'O Allah, schenke mir Gesundheit in meinem Körper, in meinem Gehör und in meinem Sehvermögen. Es gibt keinen Gott außer Dir.',
        'english': 'O Allah, grant me health in my body, in my hearing, and in my sight. There is no deity except You.',
        'source': 'Abu Dawud',
        'times': '3',
      },
      {
        'number': '1️⃣8️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
        'transliteration': 'Allahumma inni as\'alukal-\'afwa wal-\'afiyah fid-dunya wal-akhirah, allahumma inni as\'alukal-\'afwa wal-\'afiyah fi dini wa dunyaya wa ahli wa mali, allahummast-ur \'awrati wa amin raw\'ati, allahummahf-adhni min bayni yadayya wa min khalfi wa \'an yamini wa \'an shimali, wa min fawqi, wa a\'udhu bi\'adhamatika an ughtala min tahti',
        'german': 'O Allah, ich bitte Dich um Vergebung und Wohlergehen im Diesseits und im Jenseits. O Allah, ich bitte Dich um Vergebung und Wohlergehen in meiner Religion, in meinem weltlichen Leben, bei meiner Familie und in meinem Besitz. O Allah, bedecke meine Fehler und schenke mir Sicherheit vor meinen Ängsten. O Allah, bewahre mich von vorne und von hinten, von meiner Rechten und von meiner Linken und von oben. Und ich suche Zuflucht bei Deiner Erhabenheit davor, dass ich von unten her zugrunde gehe.',
        'english': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter. O Allah, I ask You for pardon and well-being in my religion and my worldly affairs, in my family and my wealth. O Allah, veil my weaknesses and set at ease my dismay. O Allah, preserve me from the front and from behind, from my right and from my left, and from above, and I take refuge with Your greatness lest I be swallowed up by the earth.',
        'source': 'Abu Dawud & Ibn Majah',
      },
      {
        'number': '1️⃣9️⃣',
        'arabic': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
        'transliteration': 'Ya Hayyu Ya Qayyumu birahmatika astaghith, aslih li sha\'ni kullah, wa la takilni ila nafsi tarfata \'ayn',
        'german': 'O Du Lebendiger, o Du Beständiger, durch Deine Barmherzigkeit suche ich Hilfe. Ordne mir all meine Angelegenheiten und überlasse mich nicht mir selbst, auch nicht für einen Augenblick.',
        'english': 'O Ever-Living, O Self-Subsisting Sustainer! By Your mercy I seek help. Rectify for me all of my affairs, and do not leave me to myself even for the blink of an eye.',
        'source': 'An-Nasa\'i',
        'times': '3',
      },
      {
        'number': '2️⃣0️⃣',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَٰذِهِ اللَّيْلَةِ فَتْحَهَا وَنَصْرَهَا، وَنُورَهَا وَبَرَكَتَهَا، وَهُدَاهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهَا وَشَرِّ مَا بَعْدَهَا',
        'transliteration': 'Amsayna wa amsal-mulku lillahi rabbil-\'alamin, allahumma inni as\'aluka khayra hadhihil-laylati fat-haha wa nasraha, wa nuraha wa barakataha, wa hudaha, wa a\'udhu bika min sharri ma fiha wa sharri ma ba\'daha',
        'german': 'Wir haben den Abend erreicht, und die Herrschaft gehört Allah, dem Herrn der Welten. O Allah, ich bitte Dich um das Gute dieser Nacht: ihren Erfolg, ihren Sieg, ihr Licht, ihren Segen und ihre Rechtleitung. Und ich suche Zuflucht bei Dir vor dem Übel dessen, was in ihr ist, und vor dem Übel dessen, was nach ihr kommt.',
        'english': 'We have reached the evening and the sovereignty belongs to Allah, Lord of the worlds. O Allah, I ask You for the good of this night: its opening, its victory, its light, its blessing, and its guidance. And I seek refuge in You from the evil that is in it and the evil that comes after it.',
        'source': 'Abu Dawud',
      },
      {
        'number': '2️⃣1️⃣',
        'arabic': 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ',
        'transliteration': 'Allahumma \'alimal-ghaybi wash-shahadati fatiras-samawati wal-ard, rabba kulli shay\'in wa malikah, ashhadu an la ilaha illa ant, a\'udhu bika min sharri nafsi wa min sharrish-shaytani wa shirkih, wa an aqtarifa \'ala nafsi su\'an aw ajurrahu ila muslim',
        'german': 'O Allah, Du Kenner des Verborgenen und des Offenbaren, Schöpfer der Himmel und der Erde, Herr und Besitzer aller Dinge. Ich bezeuge, dass es keinen Gott gibt außer Dir. Ich suche Zuflucht bei Dir vor dem Übel meiner eigenen Seele und vor dem Übel des Satans und seinem Beigesellen (seiner Verführung), und davor, dass ich mir selbst Böses zufüge oder es auf einen Muslim übertrage.',
        'english': 'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things. I bear witness that there is no deity except You. I seek refuge in You from the evil of my soul, from the evil of Satan and his association (polytheism), and from committing evil upon myself or bringing it upon a Muslim.',
        'source': 'At-Tirmidhi',
      },
      {
        'number': '2️⃣2️⃣',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'transliteration': 'A\'udhu bikalimatiallahit-tammati min sharri ma khalaq',
        'german': 'Ich suche Zuflucht bei den vollkommenen Worten Allahs vor dem Übel dessen, was Er erschaffen hat.',
        'english': 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        'source': 'Muslim',
        'times': '3',
      },
      {
        'number': '2️⃣3️⃣',
        'arabic': 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَىٰ سَيِّدِنَا مُحَمَّدٍ',
        'transliteration': 'Allahumma salli wa sallim wa barik \'ala sayyidina Muhammad',
        'german': 'O Allah, sende Deinen Segen, Deinen Frieden und Deinen Segen (Baraka) auf unseren Herrn Muhammad.',
        'english': 'O Allah, send blessings, peace and blessings upon our master Muhammad.',
        'source': 'Various',
        'times': '10',
      },
      {
        'number': '2️⃣4️⃣',
        'arabic': 'اللَّهُمَّ إِنَّا نَعُوذُ بِكَ مِنْ أَنْ نُشْرِكَ بِكَ شَيْئًا نَعْلَمُهُ، وَنَسْتَغْفِرُكَ لِمَا لَا نَعْلَمُهُ',
        'transliteration': 'Allahumma inna na\'udhu bika min an nushrika bika shay\'an na\'lamuh, wa nastaghfiruka lima la na\'lamuh',
        'german': 'O Allah, wir suchen Zuflucht bei Dir davor, Dir wissentlich etwas beizugesellen, und wir bitten Dich um Vergebung für das, was wir nicht wissen.',
        'english': 'O Allah, we seek refuge in You from knowingly associating anything with You, and we seek Your forgiveness for what we do not know.',
        'source': 'Ahmad',
        'times': '3',
      },
      {
        'number': '2️⃣5️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ، وَقَهْرِ الرِّجَالِ',
        'transliteration': 'Allahumma inni a\'udhu bika minal-hammi wal-hazan, wa a\'udhu bika minal-\'ajzi wal-kasal, wa a\'udhu bika minal-jubni wal-bukhl, wa a\'udhu bika min ghalabatid-dayni wa qahrir-rijal',
        'german': 'O Allah, ich suche Zuflucht bei Dir vor Sorge und Traurigkeit, und ich suche Zuflucht bei Dir vor Unfähigkeit und Trägheit, und ich suche Zuflucht bei Dir vor Feigheit und Geiz, und ich suche Zuflucht bei Dir vor der Übermacht der Schulden und vor der Unterdrückung durch Menschen.',
        'english': 'O Allah, I seek refuge in You from anxiety and sorrow, from weakness and laziness, from miserliness and cowardice, from being overcome by debt and from being overpowered by men.',
        'source': 'Bukhari',
        'times': '3',
      },
      {
        'number': '2️⃣6️⃣',
        'arabic': 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ، الْحَيُّ الْقَيُّومُ، وَأَتُوبُ إِلَيْهِ',
        'transliteration': 'Astaghfirullaha al-\'adhimal-ladhi la ilaha illa huwal-hayyul-qayyum, wa atubu ilayh',
        'german': 'Ich bitte Allah, den Erhabenen, um Vergebung – denn es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen – und ich wende mich reumütig zu Ihm zurück.',
        'english': 'I seek forgiveness from Allah the Magnificent, whom there is no deity except Him, the Ever-Living, the Sustainer of existence, and I repent to Him.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '2️⃣7️⃣',
        'arabic': 'يَا رَبِّ، لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ، وَلِعَظِيمِ سُلْطَانِكَ',
        'transliteration': 'Ya Rabbi, lakal-hamdu kama yanbaghi lijalali wajhik, wa li\'adhimi sultanik',
        'german': 'O mein Herr, Dir gebührt aller Lobpreis, so wie es der Erhabenheit Deines Angesichts und der Größe Deiner Macht entspricht.',
        'english': 'O my Lord, to You belongs all praise as befits the majesty of Your Countenance and the greatness of Your Sovereignty.',
        'source': 'Ibn Majah',
        'times': '3',
      },
      {
        'number': '2️⃣8️⃣',
        'arabic': 'لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli shay\'in qadir',
        'german': 'Es gibt keinen Gott außer Allah allein, ohne Teilhaber. Ihm gehört die Herrschaft und Ihm gebührt aller Lobpreis, und Er hat Macht über alle Dinge.',
        'english': 'There is no deity except Allah, alone, without partner. To Him belongs dominion and to Him belongs all praise, and He is over all things competent.',
        'source': 'Bukhari & Muslim',
        'times': '10',
      },
      {
        'number': '2️⃣9️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، عَلَيْكَ تَوَكَّلْتُ، وَأَنْتَ رَبُّ الْعَرْشِ الْعَظِيمِ. مَا شَاءَ اللهُ كَانَ، وَمَا لَمْ يَشَأْ لَمْ يَكُنْ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ الْعَلِيِّ الْعَظِيمِ، أَعْلَمُ أَنَّ اللهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، وَأَنَّ اللهَ قَدْ أَحَاطَ بِكُلِّ شَيْءٍ عِلْمًا، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ كُلِّ دَابَّةٍ أَنْتَ آخِذٌ بِنَاصِيَتِهَا، إِنَّ رَبِّي عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ',
        'transliteration': 'Allahumma anta rabbi la ilaha illa ant, \'alayka tawakkaltu, wa anta rabbul-\'arshil-\'adhim. Ma sha\'allahu kan, wa ma lam yasha\' lam yakun, wa la hawla wa la quwwata illa billahil-\'aliyyil-\'adhim, a\'lamu annallaha \'ala kulli shay\'in qadir, wa annallaha qad ahata bikulli shay\'in \'ilma, allahumma inni a\'udhu bika min sharri nafsi, wa min sharri kulli dabbatin anta akhidhun binasiyatiha, inna rabbi \'ala siratin mustaqim',
        'german': 'Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Auf Dich habe ich mein Vertrauen gesetzt, und Du bist der Herr des gewaltigen Thrones. Was Allah will, geschieht, und was Er nicht will, geschieht nicht. Es gibt keine Macht und keine Kraft außer bei Allah, dem Erhabenen, dem Allgewaltigen. Ich weiß, dass Allah zu allem fähig ist und dass Allah alles mit Seinem Wissen umfasst hat. O Allah, ich suche Zuflucht bei Dir vor dem Übel meiner eigenen Seele und vor dem Übel jedes Lebewesens, dessen Schopf Du in Deiner Hand hältst. Wahrlich, mein Herr ist auf einem geraden Weg.',
        'english': 'O Allah, You are my Lord; there is no deity except You. Upon You I have relied, and You are the Lord of the Great Throne. What Allah wills will be, and what He does not will shall not be. There is no power and no strength except with Allah, the Most High, the Most Great. I know that Allah is over all things competent, and that Allah has encompassed all things in knowledge. O Allah, I seek refuge in You from the evil of my soul, and from the evil of every creature You are holding by the forelock. Indeed, my Lord is on a straight path.',
        'source': 'Abu Dawud',
      },
      {
        'number': '3️⃣0️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        'transliteration': 'Subhanallahi wa bihamdih',
        'german': 'Gepriesen ist Allah, und alles Lob gebührt Ihm.',
        'english': 'Glory be to Allah and praise Him.',
        'source': 'Bukhari & Muslim',
        'times': '100',
      },
    ],
    'before_exam': [
      {
        'number': '1️⃣',
        'arabic': 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا',
        'transliteration': 'Allahumma la sahla illa ma ja\'altahu sahlan, wa anta taj\'alul-hazna idha shi\'ta sahlan',
        'german': 'O Allah, nichts ist einfach außer dem, was Du einfach machst, und Du machst das Schwierige einfach, wenn Du willst.',
        'english': 'O Allah, nothing is easy except what You make easy, and You make the difficult easy if You wish.',
        'source': 'Ibn Hibban',
      },
      {
        'number': '2️⃣',
        'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي، وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي، يَفْقَهُوا قَوْلِي',
        'transliteration': 'Rabbish-rah li sadri, wa yassir li amri, wahlul \'uqdatan min lisani, yafqahu qawli',
        'german': 'Mein Herr, erweitere mir meine Brust, und erleichtere mir meine Angelegenheit, und löse den Knoten in meiner Zunge, damit sie meine Rede verstehen.',
        'english': 'My Lord, expand for me my breast, and ease for me my task, and untie the knot from my tongue, that they may understand my speech.',
        'source': 'Quran 20:25-28',
      },
    ],
    'when_traveling': [
      {
        'number': '1️⃣',
        'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        'transliteration': 'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila rabbina lamunqalibun',
        'german': 'Gepriesen sei Der, Der uns dies dienstbar gemacht hat, und wir hätten es nicht selbst bezwingen können, und wir werden sicherlich zu unserem Herrn zurückkehren.',
        'english': 'Glory be to Him Who has subjected this to us, and we could never have it by our efforts. And to our Lord, surely, we are to return.',
        'source': 'Quran 43:13-14',
      },
    ],
    'when_sick': [
      {
        'number': '1️⃣',
        'arabic': 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
        'transliteration': 'Allahumma rabban-nas, adh-hibil-ba\'s, ishfi antash-shafi, la shifa\'a illa shifa\'uk, shifa\'an la yughadiru saqaman',
        'german': 'O Allah, Herr der Menschen, beseitige das Leiden. Heile, denn Du bist der Heiler. Es gibt keine Heilung außer Deiner Heilung, eine Heilung, die keine Krankheit zurücklässt.',
        'english': 'O Allah, Lord of mankind, remove the hardship. Heal, for You are the Healer. There is no healing except Your healing, a healing that leaves no illness.',
        'source': 'Bukhari & Muslim',
      },
    ],
    'for_parents': [
      {
        'number': '1️⃣',
        'arabic': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        'transliteration': 'Rabbir-hamhuma kama rabbayani saghira',
        'german': 'Mein Herr, erbarme Dich ihrer, so wie sie mich aufzogen, als ich klein war.',
        'english': 'My Lord, have mercy upon them as they brought me up when I was small.',
        'source': 'Quran 17:24',
      },
      {
        'number': '2️⃣',
        'arabic': 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
        'transliteration': 'Rabbanagh-fir li wa li-walidayya wa lil-mu\'minina yawma yaqumal-hisab',
        'german': 'Unser Herr, vergib mir und meinen Eltern und den Gläubigen am Tag, da die Abrechnung stattfindet.',
        'english': 'Our Lord, forgive me and my parents and the believers the Day the account is established.',
        'source': 'Quran 14:41',
      },
    ],
    'seeking_knowledge': [
      {
        'number': '1️⃣',
        'arabic': 'رَبِّ زِدْنِي عِلْمًا',
        'transliteration': 'Rabbi zidni \'ilma',
        'german': 'Mein Herr, mehre mein Wissen.',
        'english': 'My Lord, increase me in knowledge.',
        'source': 'Quran 20:114',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ انْفَعْنِي بِمَا عَلَّمْتَنِي، وَعَلِّمْنِي مَا يَنْفَعُنِي، وَزِدْنِي عِلْمًا',
        'transliteration': 'Allahumman-fa\'ni bima \'allamtani, wa \'allimni ma yanfa\'uni, wa zidni \'ilma',
        'german': 'O Allah, lass mich von dem profitieren, was Du mich gelehrt hast, lehre mich, was mir nützt, und mehre mein Wissen.',
        'english': 'O Allah, benefit me with what You have taught me, teach me what will benefit me, and increase me in knowledge.',
        'source': 'Ibn Majah',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (selectedCategory == null) {
      return _buildCategoryGrid();
    } else {
      return _buildDuaList();
    }
  }

  Widget _buildCategoryGrid() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          AppTranslations.get('dua', widget.langCode),
          style: TextStyle(
            color: widget.themeColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey.shade900],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat['key'] as String;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cat['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (cat['gradient'] as List<Color>)[0].withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat['icon'] as String,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        AppTranslations.get(cat['key'] as String, widget.langCode),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDuaList() {
    final duas = duaData[selectedCategory] ?? [];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedCategory = null;
            });
          },
        ),
        title: Text(
          AppTranslations.get(selectedCategory!, widget.langCode),
          style: TextStyle(
            color: widget.themeColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.grey.shade900],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: duas.length,
            itemBuilder: (context, index) {
              final dua = duas[index];
              return _buildDuaCard(dua);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDuaCard(Map<String, dynamic> dua) {
    final translation = widget.langCode == 'de' 
        ? dua['german'] 
        : (widget.langCode == 'ar' ? dua['arabic'] : dua['english']);
    
    final showTimes = dua.containsKey('times');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeColor.withOpacity(0.15),
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.themeColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number and Source Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dua['number'],
                  style: const TextStyle(fontSize: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.themeColor, width: 1),
                  ),
                  child: Text(
                    dua['source'],
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Arabic Text
            Text(
              dua['arabic'],
              textAlign: TextAlign.right,
              style: GoogleFonts.amiriQuran(
                fontSize: 24,
                color: Colors.white,
                height: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            // Divider
            Divider(color: widget.themeColor.withOpacity(0.3), thickness: 1),
            const SizedBox(height: 15),
            // Transliteration
            Text(
              dua['transliteration'],
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Translation
            Text(
              translation,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
            // Times to recite
            if (showTimes) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔄', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '${dua['times']}x ${AppTranslations.get('times', widget.langCode)}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== SUNNAH PAGE ====================
class SunnahPage extends StatefulWidget {
  final Color themeColor;
  const SunnahPage({super.key, required this.themeColor});

  @override
  State<SunnahPage> createState() => _SunnahPageState();
}

class _SunnahPageState extends State<SunnahPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> arabicHadiths = [];
  List<Map<String, dynamic>> englishHadiths = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;
  HadithLanguage selectedLanguage = HadithLanguage.english;
  String langCode = 'de';

  @override
  void initState() {
    super.initState();
    _loadAppLanguage();
    loadHadiths();
  }

  Future<void> _loadAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      langCode = prefs.getString('app_language') ?? 'de';
    });
  }

  Future<void> loadHadiths() async {
    setState(() => isLoading = true);
    
    try {
      // Lade BEIDE Sprachen gleichzeitig
      final arabicUrl = Uri.parse('https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-bukhari.json');
      final englishUrl = Uri.parse('https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-bukhari.json');
      
      final results = await Future.wait([
        http.get(arabicUrl),
        http.get(englishUrl),
      ]);
      
      if (results[0].statusCode == 200) {
        final data = json.decode(results[0].body);
        arabicHadiths = List<Map<String, dynamic>>.from(data['hadiths']);
      }
      
      if (results[1].statusCode == 200) {
        final data = json.decode(results[1].body);
        englishHadiths = List<Map<String, dynamic>>.from(data['hadiths']);
      }
      
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void changeLanguage(HadithLanguage language) {
    setState(() {
      selectedLanguage = language;
      searchResults = [];
      _searchController.clear();
    });
  }
  
  List<Map<String, dynamic>> get currentHadiths {
    return selectedLanguage == HadithLanguage.arabic ? arabicHadiths : englishHadiths;
  }

  Future<void> searchHadith(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      isSearching = true;
      searchResults = [];
    });
    
    await Future.delayed(Duration(milliseconds: 100));
    
    final keywords = query.toLowerCase().split(' ');
    final filtered = currentHadiths.where((h) {
      final text = (h['text'] ?? '').toString();
      final searchText = selectedLanguage == HadithLanguage.arabic 
        ? text 
        : text.toLowerCase();
      return keywords.any((k) => k.length > 2 && searchText.contains(k));
    }).take(50).toList();
    
    setState(() {
      searchResults = filtered;
      isSearching = false;
    });
  }

  List<Map<String, dynamic>> getFilteredHadiths(String category) {
    // Zeige ALLE Hadiths für jede Kategorie (keine Filter mehr)
    // Nutzer kann mit Suche selbst filtern
    return currentHadiths.take(200).toList(); // Erste 200 Hadiths
  }

  List<Map<String, String>> getCategories() {
    // Vereinfachte Kategorien basierend auf Hadith-Bereichen
    switch (selectedLanguage) {
      case HadithLanguage.arabic:
        return [
          {'name': 'الكتاب كامل (جميع الأحاديث)', 'key': 'All'},
        ];
      case HadithLanguage.english:
        return [
          {'name': 'Complete Book (All Hadiths)', 'key': 'All'},
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
          side: BorderSide(color: widget.themeColor, width: 2),
        ),
        title: Text(
          '🌍 Sprache wählen',
          style: TextStyle(color: widget.themeColor, fontSize: 22, fontWeight: FontWeight.bold),
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
                    color: isSelected ? Colors.green : widget.themeColor.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                tileColor: isSelected ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                leading: Text(lang.flag, style: const TextStyle(fontSize: 32)),
                title: Text(
                  lang.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.green : Colors.white,
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green, size: 28) : null,
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
              border: Border(bottom: BorderSide(color: widget.themeColor, width: 2)),
            ),
            child: Column(
              children: [
                Text(
                  AppTranslations.get('hadith_title', langCode),
                  style: TextStyle(color: widget.themeColor, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: showLanguageDialog,
                  icon: Text(selectedLanguage.flag, style: const TextStyle(fontSize: 20)),
                  label: Text(
                    selectedLanguage.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppTranslations.get('search_hint', langCode),
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: widget.themeColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: widget.themeColor),
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
                ? Center(child: CircularProgressIndicator(color: widget.themeColor))
                : isSearching
                ? Center(child: CircularProgressIndicator(color: widget.themeColor))
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
                          border: Border.all(color: widget.themeColor, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: widget.themeColor,
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
                                fontSize: selectedLanguage == HadithLanguage.arabic ? 20 : 16,
                                height: selectedLanguage == HadithLanguage.arabic ? 2.0 : 1.6,
                                fontFamily: selectedLanguage == HadithLanguage.arabic
                                    ? GoogleFonts.amiriQuran().fontFamily
                                    : null,
                              ),
                              textAlign: selectedLanguage == HadithLanguage.arabic ? TextAlign.right : TextAlign.left,
                              textDirection: selectedLanguage == HadithLanguage.arabic ? TextDirection.rtl : TextDirection.ltr,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () {
                        final filtered = getFilteredHadiths('All');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HadithListPage(
                              hadiths: filtered,
                              categoryName: selectedLanguage == HadithLanguage.arabic 
                                ? 'صحيح البخاري' 
                                : 'Sahih Bukhari',
                              language: selectedLanguage,
                              themeColor: widget.themeColor,
                              langCode: langCode,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.themeColor.withOpacity(0.3),
                              Colors.black.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: widget.themeColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: widget.themeColor.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: widget.themeColor,
                              size: 80,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              selectedLanguage == HadithLanguage.arabic 
                                ? 'صحيح البخاري' 
                                : 'Sahih Bukhari',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: selectedLanguage == HadithLanguage.arabic
                                    ? GoogleFonts.amiriQuran().fontFamily
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: widget.themeColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${currentHadiths.length} ${selectedLanguage == HadithLanguage.arabic ? 'حديث' : 'Hadiths'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedLanguage == HadithLanguage.arabic 
                                    ? 'اضغط للقراءة' 
                                    : 'Tap to read',
                                  style: TextStyle(
                                    color: widget.themeColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: widget.themeColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== HADITH LIST PAGE ====================
class HadithListPage extends StatelessWidget {
  final List<Map<String, dynamic>> hadiths;
  final String categoryName;
  final HadithLanguage language;
  final Color themeColor;
  final String langCode;

  const HadithListPage({
    super.key,
    required this.hadiths,
    required this.categoryName,
    required this.language,
    required this.themeColor,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          categoryName,
          style: TextStyle(
            color: themeColor,
            fontFamily: language == HadithLanguage.arabic
                ? GoogleFonts.amiriQuran().fontFamily
                : null,
          ),
        ),
        centerTitle: true,
      ),
      body: hadiths.isEmpty
          ? Center(
              child: Text(
                AppTranslations.get('no_hadiths', langCode),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: hadiths.length,
              itemBuilder: (context, index) {
                final hadith = hadiths[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: themeColor, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hadith ${hadith['hadithnumber']}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        hadith['text'] ?? 'Kein Text verfügbar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: language == HadithLanguage.arabic ? 20 : 16,
                          height: language == HadithLanguage.arabic ? 2.0 : 1.7,
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

// ==================== PRAYER TIMES PAGE ====================
// ==================== SETTINGS PAGE ====================
class SettingsPage extends StatefulWidget {
  final Color themeColor;
  final Function(AppTheme) onThemeChanged;
  final String langCode;
  
  const SettingsPage({super.key, required this.themeColor, required this.onThemeChanged, required this.langCode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userName = '';
  AppTheme selectedTheme = AppTheme.classic;
  AppLanguage selectedLanguage = AppLanguage.german;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? '';
      selectedTheme = AppTheme.values[prefs.getInt('app_theme') ?? 0];
      
      final langCode = prefs.getString('app_language') ?? 'de';
      selectedLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.code == langCode,
        orElse: () => AppLanguage.german,
      );
    });
  }

  Future<void> _changeTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', theme.index);
    setState(() => selectedTheme = theme);
    widget.onThemeChanged(theme);
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: widget.themeColor, width: 2),
        ),
        title: Text(
          AppTranslations.get('edit_name', widget.langCode),
          style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppTranslations.get('new_name', widget.langCode),
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.grey.shade800,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('cancel', widget.langCode), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_name', controller.text.trim());
                setState(() => userName = controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.black,
            ),
            child: Text(AppTranslations.get('save', widget.langCode)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: widget.themeColor, width: 2),
        ),
        title: Text(
          AppTranslations.get('change_language', widget.langCode),
          style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = lang == selectedLanguage;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.green : widget.themeColor.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                tileColor: isSelected ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                leading: Text(lang.flag, style: const TextStyle(fontSize: 32)),
                title: Text(
                  lang.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.green : Colors.white,
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green, size: 28) : null,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_language', lang.code);
                  if (context.mounted) {
                    Navigator.pop(context);
                    // App neu starten
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MyApp()),
                      (route) => false,
                    );
                  }
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
                  Icon(Icons.settings, color: widget.themeColor, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    AppTranslations.get('settings', widget.langCode),
                    style: TextStyle(color: widget.themeColor, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name
                  _buildCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: widget.themeColor, size: 28),
                            const SizedBox(width: 12),
                            Text(AppTranslations.get('profile', widget.langCode), style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(userName, style: const TextStyle(color: Colors.white, fontSize: 18)),
                            IconButton(
                              onPressed: _showEditNameDialog,
                              icon: Icon(Icons.edit, color: widget.themeColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sprache
                  _buildCard(
                    child: InkWell(
                      onTap: _showLanguageDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.language, color: widget.themeColor, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppTranslations.get('language', widget.langCode), style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(selectedLanguage.displayName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: widget.themeColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Farbthema
                  _buildCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.palette, color: widget.themeColor, size: 28),
                            const SizedBox(width: 12),
                            Text(AppTranslations.get('theme', widget.langCode), style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: AppTheme.values.map((theme) {
                            final isSelected = selectedTheme == theme;
                            return GestureDetector(
                              onTap: () => _changeTheme(theme),
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? theme.color : theme.color.withOpacity(0.3),
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(color: theme.color, shape: BoxShape.circle),
                                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      theme.name,
                                      style: TextStyle(
                                        color: theme.color,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
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
                  
                  // App Teilen
                  _buildCard(
                    child: InkWell(
                      onTap: () async {
                        await Share.share(
                          AppTranslations.get('share_text', widget.langCode),
                          subject: 'Nurr - Quran & Dua App',
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.share, color: widget.themeColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppTranslations.get('share_app', widget.langCode),
                              style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: widget.themeColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Hijri Kalender
                  _buildCard(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HijriCalendarPage(
                              themeColor: widget.themeColor,
                              langCode: widget.langCode,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: widget.themeColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppTranslations.get('hijri_calendar', widget.langCode),
                              style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: widget.themeColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tasbih Zähler
                  _buildCard(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TasbihPage(
                              themeColor: widget.themeColor,
                              langCode: widget.langCode,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.adjust, color: widget.themeColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppTranslations.get('tasbih', widget.langCode),
                              style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: widget.themeColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Über die App
                  _buildCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: widget.themeColor, size: 28),
                            const SizedBox(width: 12),
                            Text(AppTranslations.get('about', widget.langCode), style: TextStyle(color: widget.themeColor, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppTranslations.get('app_info', widget.langCode),
                          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                          textAlign: TextAlign.center,
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

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.themeColor.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}

// ==================== HIJRI CALENDAR PAGE ====================
class HijriCalendarPage extends StatelessWidget {
  final Color themeColor;
  final String langCode;
  
  const HijriCalendarPage({super.key, required this.themeColor, required this.langCode});

  String getHijriDate() {
    // Einfache Berechnung: Hijri ist ca. 11 Tage kürzer pro Jahr
    final now = DateTime.now();
    final gregorianYear = now.year;
    final hijriYear = ((gregorianYear - 622) * 1.030684).round();
    
    final months = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
      'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'
    ];
    
    // Ungefähre Monatsberechnung
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final hijriMonth = ((dayOfYear / 29.5) % 12).floor();
    final hijriDay = ((dayOfYear % 29.5).floor() + 1);
    
    return '$hijriDay ${months[hijriMonth]} $hijriYear AH';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/hintergrund.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        AppTranslations.get('hijri_calendar', langCode),
                        style: TextStyle(color: themeColor, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: themeColor, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month, color: themeColor, size: 80),
                          const SizedBox(height: 30),
                          Text(
                            getHijriDate(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            DateTime.now().toString().split(' ')[0],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
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
  }
}

// ==================== TASBIH PAGE ====================
class TasbihPage extends StatefulWidget {
  final Color themeColor;
  final String langCode;
  
  const TasbihPage({super.key, required this.themeColor, required this.langCode});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int count = 0;
  
  void _increment() {
    setState(() => count++);
  }
  
  void _reset() {
    setState(() => count = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0A0A0A),
          ),
          Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                color: const Color(0xFF0A0A0A),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppTranslations.get('tasbih', widget.langCode),
                      style: TextStyle(color: widget.themeColor, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFF0A0A0A),
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Zähler Display
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              shape: BoxShape.circle,
                              border: Border.all(color: widget.themeColor, width: 6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppTranslations.get('count', widget.langCode),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  count.toString(),
                                  style: TextStyle(
                                    color: widget.themeColor,
                                    fontSize: 90,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Zähl-Button
                          GestureDetector(
                            onTap: _increment,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: widget.themeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.themeColor.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Reset Button
                          ElevatedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh),
                            label: Text(AppTranslations.get('reset', widget.langCode)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
