import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nurr_design.dart';

class NurrOnboardingPage extends StatefulWidget {
  final String languageCode;
  final Widget nextPage;

  const NurrOnboardingPage({
    super.key,
    required this.languageCode,
    required this.nextPage,
  });

  @override
  State<NurrOnboardingPage> createState() => _NurrOnboardingPageState();
}

class _NurrOnboardingPageState extends State<NurrOnboardingPage> {
  final _controller = PageController();
  int _page = 0;
  bool _darkMode = false;

  bool get _ar => widget.languageCode == 'ar';
  bool get _en => widget.languageCode == 'en';

  String _t(String de, String en, String ar) => _ar ? ar : (_en ? en : de);

  List<_IntroData> get _pages => [
    _IntroData(
      icon: Icons.auto_awesome_rounded,
      title: _t('Willkommen bei Nurr', 'Welcome to Nurr', 'مرحبًا بك في نور'),
      body: _t(
        'Dein ruhiger Begleiter für Quran, Gebet und Dua.',
        'Your peaceful companion for Quran, prayer and dua.',
        'رفيقك الهادئ للقرآن والصلاة والدعاء.',
      ),
    ),
    _IntroData(
      icon: Icons.menu_book_rounded,
      title: _t('Lies auf deine Weise', 'Read your way', 'اقرأ بطريقتك'),
      body: _t(
        'Arabisch, Deutsch oder Englisch – mit anpassbarer Ansicht, Lesezeichen und Suche.',
        'Arabic, German or English—with flexible display, bookmarks and search.',
        'بالعربية أو الألمانية أو الإنجليزية، مع عرض مرن وإشارات مرجعية وبحث.',
      ),
    ),
    _IntroData(
      icon: Icons.favorite_rounded,
      title: _t('Für deinen Alltag', 'For every day', 'ليومك كلّه'),
      body: _t(
        'Gebetszeiten, Gebetstracker, Duas und die 99 Namen Allahs an einem Ort.',
        'Prayer times, prayer tracking, duas and the 99 Names of Allah in one place.',
        'مواقيت الصلاة ومتابعة الصلوات والأدعية وأسماء الله الحسنى في مكان واحد.',
      ),
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nurr_onboarding_seen_v2', true);
    await prefs.setBool('nurr_app_dark_mode', _darkMode);
    await prefs.setBool('quran_reader_dark_mode', _darkMode);
    NurrDesign.darkMode.value = _darkMode;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.nextPage),
    );
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NurrDesign.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFBF1),
                  Color(0xFFF3E6C8),
                  Color(0xFFF8F4EA),
                ],
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: -70,
            child: _GlowCircle(size: 270, opacity: 0.16),
          ),
          Positioned(
            bottom: 100,
            left: -95,
            child: _GlowCircle(size: 230, opacity: 0.10),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: _ar ? Alignment.centerLeft : Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      _t('Überspringen', 'Skip', 'تخطي'),
                      style: const TextStyle(color: NurrDesign.ink),
                    ),
                  ),
                ),
                const Spacer(flex: 5),
                Expanded(
                  flex: 6,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFBF2DC), Colors.white],
                                ),
                                borderRadius: BorderRadius.circular(42),
                                border: Border.all(
                                  color: NurrDesign.gold.withValues(
                                    alpha: 0.28,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: NurrDesign.gold.withValues(
                                      alpha: 0.14,
                                    ),
                                    blurRadius: 32,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Icon(
                                data.icon,
                                color: NurrDesign.emerald,
                                size: 66,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              textDirection: _ar
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: const TextStyle(
                                color: NurrDesign.ink,
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data.body,
                              textAlign: TextAlign.center,
                              textDirection: _ar
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: const TextStyle(
                                color: NurrDesign.muted,
                                fontSize: 16,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: index == _page ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _page
                            ? NurrDesign.gold
                            : NurrDesign.gold.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                if (_page == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: NurrDesign.gold.withValues(alpha: 0.25),
                        ),
                      ),
                      child: SegmentedButton<bool>(
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
                        selected: {_darkMode},
                        onSelectionChanged: (value) =>
                            setState(() => _darkMode = value.first),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: NurrDesign.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _page == _pages.length - 1
                            ? _t('Loslegen', 'Get started', 'ابدأ الآن')
                            : _t('Weiter', 'Continue', 'متابعة'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
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

class _IntroData {
  final IconData icon;
  final String title;
  final String body;

  const _IntroData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: NurrDesign.gold.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
