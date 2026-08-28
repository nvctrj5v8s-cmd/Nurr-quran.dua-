import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nurr_design.dart';
import 'onboarding/onboarding_components.dart';
import 'onboarding/onboarding_models.dart';

typedef _T = String Function(String de, String en, String ar);

class NurrOnboardingPage extends StatefulWidget {
  const NurrOnboardingPage({
    super.key,
    required this.languageCode,
    this.nextPage,
    this.replay = false,
  });

  final String languageCode;
  final Widget? nextPage;
  final bool replay;

  @override
  State<NurrOnboardingPage> createState() => _NurrOnboardingPageState();
}

class _NurrOnboardingPageState extends State<NurrOnboardingPage>
    with SingleTickerProviderStateMixin {
  static const _count = 7;
  final _controller = PageController();
  final Set<OnboardingGoal> _goals = {};
  late final AnimationController _ambient;
  int _page = 0;
  bool _requestingLocation = false;
  bool _finishing = false;
  String? _locationResult;

  bool get _ar => widget.languageCode == 'ar';
  bool get _en => widget.languageCode == 'en';
  bool get _dark => NurrDesign.darkMode.value;
  String _t(String de, String en, String ar) => _ar ? ar : (_en ? en : de);

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _loadChoices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ambient.stop();
      _ambient.value = 0;
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  Future<void> _loadChoices() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(OnboardingStorage.goals) ?? const [];
    if (!mounted) return;
    setState(() {
      for (final goal in OnboardingGoal.values) {
        if (saved.contains(goal.name)) _goals.add(goal);
      }
      _locationResult = prefs.getString(OnboardingStorage.manualLocation);
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      OnboardingStorage.goals,
      _goals.map((goal) => goal.name).toList(),
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await _saveGoals();
    final prefs = await SharedPreferences.getInstance();
    if (!widget.replay) {
      await prefs.setBool(OnboardingStorage.completed, true);
      await prefs.setBool(OnboardingStorage.legacyCompleted, true);
    }
    if (!mounted) return;
    if (widget.replay || widget.nextPage == null) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, _) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: widget.nextPage!,
          ),
        ),
      );
    }
  }

  void _go(int page) => _controller.animateToPage(
    page.clamp(0, _count - 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 520),
    curve: Curves.easeInOutCubic,
  );

  void _next() => _page == _count - 1 ? _finish() : _go(_page + 1);

  Future<void> _useLocation() async {
    if (_requestingLocation) return;
    setState(() => _requestingLocation = true);
    try {
      if (!kIsWeb) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw Exception('service-disabled');
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('permission-denied');
        }
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(OnboardingStorage.locationChoice, 'automatic');
      await prefs.setDouble('nurr_prayer_latitude', position.latitude);
      await prefs.setDouble('nurr_prayer_longitude', position.longitude);
      if (mounted) {
        setState(
          () => _locationResult = _t(
            'Standort gespeichert',
            'Location saved',
            'تم حفظ الموقع',
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _locationResult = _t(
            'Kein Zugriff – du kannst einen Ort eingeben oder fortfahren.',
            'No access—you can enter a place or continue.',
            'لا يوجد وصول — يمكنك إدخال موقع أو المتابعة.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingLocation = false);
    }
  }

  Future<void> _manualLocation() async {
    final input = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('Ort auswählen', 'Choose a place', 'اختر المكان')),
        content: TextField(
          controller: input,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_city_rounded),
            hintText: _t('z. B. Berlin', 'e.g. London', 'مثلاً برلين'),
          ),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('Abbrechen', 'Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text.trim()),
            child: Text(_t('Speichern', 'Save', 'حفظ')),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OnboardingStorage.locationChoice, 'manual');
    await prefs.setString(OnboardingStorage.manualLocation, result);
    if (mounted) setState(() => _locationResult = result);
  }

  @override
  void dispose() {
    _ambient.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Directionality(
      textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: NurrDesign.background(_dark),
        body: AnimatedOpacity(
          opacity: _finishing ? 0 : 1,
          duration: reduced ? Duration.zero : const Duration(milliseconds: 420),
          child: Stack(
            children: [
              OnboardingBackdrop(
                dark: _dark,
                animation: _ambient,
                reducedMotion: reduced,
              ),
              OnboardingLivingLayer(
                dark: _dark,
                animation: _ambient,
                reducedMotion: reduced,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: _page > 0 && _page < _count - 1
                          ? Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: _finish,
                                child: Text(
                                  _t('Überspringen', 'Skip', 'تخطي'),
                                  style: TextStyle(
                                    color: NurrDesign.secondaryText(_dark),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _count,
                        onPageChanged: (value) => setState(() => _page = value),
                        itemBuilder: (context, index) => AnimatedBuilder(
                          animation: _controller,
                          child: _PageShell(
                            child: _PageEntrance(
                              key: ValueKey('onboarding-page-$index'),
                              child: _screen(index),
                            ),
                          ),
                          builder: (context, child) {
                            final position = _controller.hasClients
                                ? (_controller.page ?? _page.toDouble())
                                : _page.toDouble();
                            final distance = (position - index).abs().clamp(
                              0,
                              1,
                            );
                            return Opacity(
                              opacity: 1 - distance * .22,
                              child: Transform.translate(
                                offset: Offset(
                                  reduced ? 0 : (position - index) * 28,
                                  reduced ? 0 : distance * 10,
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (_page > 0) _navigation(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigation() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: TextButton(
            onPressed: () => _go(_page - 1),
            child: Text(_t('Zurück', 'Back', 'رجوع')),
          ),
        ),
        Expanded(
          child: Center(
            child: AnimatedPageIndicators(count: _count, current: _page),
          ),
        ),
        SizedBox(
          width: 88,
          child: TextButton(
            onPressed: _next,
            child: Text(
              _page == _count - 1
                  ? _t('Öffnen', 'Open', 'فتح')
                  : _t('Weiter', 'Next', 'التالي'),
              style: const TextStyle(
                color: NurrDesign.goldDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _screen(int index) => switch (index) {
    0 => _Welcome(dark: _dark, animation: _ambient, t: _t, onContinue: _next),
    1 => _QuranIntro(dark: _dark, animation: _ambient, t: _t),
    2 => _PrayerIntro(dark: _dark, animation: _ambient, t: _t),
    3 => _DhikrIntro(dark: _dark, animation: _ambient, t: _t),
    4 => _Goals(
      dark: _dark,
      t: _t,
      selected: _goals,
      animation: _ambient,
      onToggle: (goal) => setState(() {
        _goals.contains(goal) ? _goals.remove(goal) : _goals.add(goal);
        _saveGoals();
      }),
    ),
    5 => _Location(
      dark: _dark,
      t: _t,
      requesting: _requestingLocation,
      result: _locationResult,
      animation: _ambient,
      onUse: _useLocation,
      onManual: _manualLocation,
      onSkip: _next,
    ),
    _ => _Ready(
      dark: _dark,
      animation: _ambient,
      t: _t,
      goals: _goals,
      finishing: _finishing,
      onOpen: _finish,
    ),
  };
}

class _PageEntrance extends StatelessWidget {
  const _PageEntrance({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 680),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 28 * (1 - value)),
        child: Transform.scale(scale: .97 + value * .03, child: child),
      ),
    ),
    child: child,
  );
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth > 700
            ? constraints.maxWidth * .16
            : 22,
        vertical: 8,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class _Copy extends StatelessWidget {
  const _Copy({required this.dark, required this.title, required this.body});
  final bool dark;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: NurrDesign.text(dark),
          fontSize: 29,
          height: 1.12,
          fontWeight: FontWeight.w900,
          letterSpacing: -.55,
        ),
      ),
      const SizedBox(height: 11),
      Text(
        body,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: NurrDesign.secondaryText(dark),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    ],
  );
}

class _Welcome extends StatelessWidget {
  const _Welcome({
    required this.dark,
    required this.animation,
    required this.t,
    required this.onContinue,
  });
  final bool dark;
  final Animation<double> animation;
  final _T t;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          MosqueSkyIllustration(dark: dark, animation: animation),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => PositionedDirectional(
              start: 13 + math.sin(animation.value * math.pi * 2) * 5,
              bottom: -17 + math.cos(animation.value * math.pi * 2) * 3,
              child: const _FloatingSymbol(
                icon: Icons.menu_book_rounded,
                color: NurrDesign.emerald,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => PositionedDirectional(
              end: 18 + math.cos(animation.value * math.pi * 2) * 5,
              bottom: -12 + math.sin(animation.value * math.pi * 2) * 4,
              child: const _FloatingSymbol(
                icon: Icons.favorite_rounded,
                color: NurrDesign.goldDark,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _Copy(
        dark: dark,
        title: t(
          'Assalamu alaikum 🌙',
          'Assalamu alaikum 🌙',
          'السلام عليكم 🌙',
        ),
        body: t(
          'Quran lesen, Gebete im Blick behalten, Duas lernen, Dhikr machen und jeden Tag Allah näherkommen.',
          'Read Quran, keep track of prayers, learn duas, make dhikr and grow closer to Allah every day.',
          'اقرأ القرآن، وتابع صلواتك، وتعلّم الأدعية، واذكر الله واقترب منه كل يوم.',
        ),
      ),
      const SizedBox(height: 8),
      Text(
        t(
          'Dein Begleiter für jeden Tag',
          'Your companion every day',
          'رفيقك في كل يوم',
        ),
        style: const TextStyle(
          color: NurrDesign.goldDark,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 22),
      OnboardingActionButton(
        label: t('Los geht’s', 'Let’s begin', 'لنبدأ'),
        icon: Icons.arrow_forward_rounded,
        onPressed: onContinue,
      ),
      const SizedBox(height: 8),
      Text(
        t(
          'Dauert weniger als eine Minute',
          'Takes less than a minute',
          'يستغرق أقل من دقيقة',
        ),
        style: TextStyle(color: NurrDesign.secondaryText(dark), fontSize: 12),
      ),
    ],
  );
}

class _FloatingSymbol extends StatelessWidget {
  const _FloatingSymbol({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: NurrDesign.paper,
      shape: BoxShape.circle,
      border: Border.all(color: NurrDesign.gold.withValues(alpha: .3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 16,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Icon(icon, color: color, size: 24),
  );
}

class _QuranIntro extends StatelessWidget {
  const _QuranIntro({
    required this.dark,
    required this.animation,
    required this.t,
  });
  final bool dark;
  final Animation<double> animation;
  final _T t;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: .88, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 650),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 80),
            child: child,
          ),
        ),
        child: OnboardingCard(
          dark: dark,
          child: _Book(animation: animation),
        ),
      ),
      const SizedBox(height: 24),
      _Copy(
        dark: dark,
        title: t(
          'Der Quran – immer bei dir',
          'The Quran—always with you',
          'القرآن معك دائمًا',
        ),
        body: t(
          'Lies den Quran auf Arabisch oder mit Übersetzung und setze Lesezeichen, damit du jederzeit weiterlesen kannst.',
          'Read the Quran in Arabic or with translation and save bookmarks so you can continue anytime.',
          'اقرأ القرآن بالعربية أو مع الترجمة واحفظ موضعك لتتابع القراءة في أي وقت.',
        ),
      ),
      const SizedBox(height: 17),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(
            Icons.menu_book_rounded,
            t('Arabischer Quran', 'Arabic Quran', 'القرآن العربي'),
          ),
          _Chip(
            Icons.translate_rounded,
            t('Übersetzungen', 'Translations', 'الترجمات'),
          ),
          _Chip(
            Icons.bookmark_rounded,
            t('Lesezeichen', 'Bookmarks', 'الإشارات المرجعية'),
          ),
          _Chip(Icons.search_rounded, t('Suche', 'Search', 'البحث')),
        ],
      ),
      const SizedBox(height: 13),
      AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Transform.translate(
          offset: Offset(0, math.sin(animation.value * math.pi * 2) * 2.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: NurrDesign.emerald.withValues(alpha: dark ? .22 : .08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: NurrDesign.emerald.withValues(alpha: .2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: NurrDesign.emerald,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t(
                      'Weiterlesen · Al-Baqara',
                      'Continue · Al-Baqara',
                      'متابعة القراءة · البقرة',
                    ),
                    style: const TextStyle(
                      color: NurrDesign.emerald,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.bookmark_rounded,
                  color: NurrDesign.goldDark,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _Book extends StatelessWidget {
  const _Book({required this.animation});
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final phase = animation.value * math.pi * 2;
      final lift = math.sin(phase) * 3;
      final pageTurn = (math.sin(phase * .55) + 1) / 2;
      return Transform.translate(
        offset: Offset(0, lift),
        child: SizedBox(
          height: 165,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 260,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NurrDesign.gold.withValues(alpha: .25),
                      NurrDesign.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Container(
                width: 240,
                height: 128,
                decoration: BoxDecoration(
                  color: NurrDesign.emerald,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: NurrDesign.emerald.withValues(alpha: .24),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  2,
                  (i) => Container(
                    width: 106,
                    height: 118,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEE),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(i == 0 ? 20 : 4),
                        right: Radius.circular(i == 1 ? 20 : 4),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (_) => Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: NurrDesign.gold.withValues(alpha: .48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 23,
                right: 90 + pageTurn * 25,
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .001)
                    ..rotateY(pageTurn * 1.15),
                  child: Container(
                    width: 80,
                    height: 108,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7DF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x19000000), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                color: NurrDesign.goldDark,
                size: 30,
              ),
              Positioned(
                bottom: 7,
                child: Container(
                  width: 13,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: NurrDesign.gold,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: NurrDesign.gold.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: NurrDesign.gold.withValues(alpha: .22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: NurrDesign.goldDark),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ],
    ),
  );
}

class _PrayerIntro extends StatelessWidget {
  const _PrayerIntro({
    required this.dark,
    required this.animation,
    required this.t,
  });
  final bool dark;
  final Animation<double> animation;
  final _T t;
  @override
  Widget build(BuildContext context) {
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MosqueSkyIllustration(dark: dark, animation: animation, compact: true),
        Transform.translate(
          offset: const Offset(0, -24),
          child: OnboardingCard(
            dark: dark,
            child: Column(
              children: [
                Text(
                  t('Nächstes Gebet', 'Next prayer', 'الصلاة القادمة'),
                  style: TextStyle(
                    color: NurrDesign.secondaryText(dark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Maghrib · 20:33',
                  style: TextStyle(
                    color: NurrDesign.text(dark),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t('in 42 Minuten', 'in 42 minutes', 'بعد 42 دقيقة'),
                  style: const TextStyle(
                    color: NurrDesign.goldDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => LinearProgressIndicator(
                      minHeight: 4,
                      value: .18 + animation.value * .68,
                      backgroundColor: NurrDesign.emerald.withValues(
                        alpha: .10,
                      ),
                      color: NurrDesign.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    prayers.length,
                    (index) => Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : Duration(milliseconds: 300 + index * 90),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: .8 + value * .2,
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == 3
                                    ? NurrDesign.gold
                                    : NurrDesign.emerald.withValues(alpha: .35),
                              ),
                            ),
                            const SizedBox(height: 5),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                prayers[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: NurrDesign.secondaryText(dark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _Copy(
          dark: dark,
          title: t(
            'Verpasse kein Gebet',
            'Never miss a prayer',
            'لا تفوّت صلاة',
          ),
          body: t(
            'Erhalte Gebetszeiten passend zu deinem Standort und behalte deine fünf täglichen Gebete im Blick.',
            'Get prayer times for your location and keep track of your five daily prayers.',
            'احصل على مواقيت الصلاة حسب موقعك وتابع صلواتك الخمس كل يوم.',
          ),
        ),
      ],
    );
  }
}

class _DhikrIntro extends StatelessWidget {
  const _DhikrIntro({
    required this.dark,
    required this.animation,
    required this.t,
  });
  final bool dark;
  final Animation<double> animation;
  final _T t;
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.wb_sunny_outlined,
        t('Morgen-Duas', 'Morning duas', 'أذكار الصباح'),
      ),
      (
        Icons.nights_stay_outlined,
        t('Abend-Duas', 'Evening duas', 'أذكار المساء'),
      ),
      (Icons.favorite_outline_rounded, t('Duas', 'Duas', 'الأدعية')),
      (Icons.touch_app_outlined, t('Masbaha', 'Masbaha', 'المسبحة')),
      (
        Icons.auto_awesome_outlined,
        t('99 Namen Allahs', '99 Names of Allah', 'أسماء الله الحسنى'),
      ),
    ];
    const positions = [
      Alignment(-.82, -.72),
      Alignment(.78, -.58),
      Alignment(-.66, .47),
      Alignment(.72, .58),
      Alignment(0, 0),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 275,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _DhikrRing(dark: dark, animation: animation),
              ...List.generate(
                items.length,
                (index) => AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Align(
                    alignment: positions[index],
                    child: Transform.translate(
                      offset: Offset(
                        math.cos(animation.value * math.pi * 2 + index) * 4,
                        math.sin(animation.value * math.pi * 2 + index * .8) *
                            7,
                      ),
                      child: child,
                    ),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : Duration(milliseconds: 380 + index * 70),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: OnboardingCard(
                      dark: dark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            items[index].$1,
                            color: index == 4
                                ? NurrDesign.goldDark
                                : NurrDesign.emerald,
                            size: 21,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            items[index].$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _Copy(
          dark: dark,
          title: t('Erinnere dich an Allah', 'Remember Allah', 'اذكر الله'),
          body: t(
            'Duas für deinen Alltag, Dhikr mit der Masbaha und die 99 Namen Allahs mit Bedeutung und Aussprache.',
            'Duas for daily life, dhikr with the masbaha, and the 99 Names of Allah with meaning and pronunciation.',
            'أدعية ليومك، وذكر بالمسبحة، وأسماء الله الحسنى مع المعنى والنطق.',
          ),
        ),
      ],
    );
  }
}

class _Goals extends StatelessWidget {
  const _Goals({
    required this.dark,
    required this.t,
    required this.selected,
    required this.animation,
    required this.onToggle,
  });
  final bool dark;
  final _T t;
  final Set<OnboardingGoal> selected;
  final Animation<double> animation;
  final ValueChanged<OnboardingGoal> onToggle;

  (String, String) _copy(OnboardingGoal goal) => switch (goal) {
    OnboardingGoal.quran => (
      t('Mehr Quran lesen', 'Read more Quran', 'قراءة المزيد من القرآن'),
      t(
        'Regelmäßig Quran lesen',
        'Read Quran regularly',
        'قراءة القرآن بانتظام',
      ),
    ),
    OnboardingGoal.prayer => (
      t('Meine Gebete stärken', 'Strengthen my prayers', 'تقوية صلاتي'),
      t(
        'Die fünf Gebete bewusster einhalten',
        'Observe the five prayers mindfully',
        'المحافظة على الصلوات الخمس بوعي',
      ),
    ),
    OnboardingGoal.duas => (
      t('Mehr Duas lernen', 'Learn more duas', 'تعلّم المزيد من الأدعية'),
      t(
        'Duas für verschiedene Situationen',
        'Duas for different situations',
        'أدعية لمواقف مختلفة',
      ),
    ),
    OnboardingGoal.dhikr => (
      t('Täglich Dhikr machen', 'Make dhikr daily', 'الذكر يوميًا'),
      t(
        'Allah regelmäßig gedenken',
        'Remember Allah regularly',
        'ذكر الله بانتظام',
      ),
    ),
    OnboardingGoal.names => (
      t('Allahs Namen lernen', 'Learn Allah’s Names', 'تعلّم أسماء الله'),
      t(
        'Die 99 Namen und ihre Bedeutungen',
        'The 99 Names and their meanings',
        'الأسماء الحسنى ومعانيها',
      ),
    ),
    OnboardingGoal.all => (
      t(
        'Alles gemeinsam verbessern',
        'Improve everything together',
        'تحسين كل شيء معًا',
      ),
      t('Ein Schritt nach dem anderen', 'One step at a time', 'خطوة بعد خطوة'),
    ),
  };

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Copy(
        dark: dark,
        title: t(
          'Was möchtest du erreichen?',
          'What would you like to achieve?',
          'ماذا تريد أن تحقق؟',
        ),
        body: t(
          'Wähle aus, worauf du dich konzentrieren möchtest.',
          'Choose what you want to focus on.',
          'اختر ما تريد التركيز عليه.',
        ),
      ),
      const SizedBox(height: 16),
      _GrowingPath(
        dark: dark,
        progress: selected.length / OnboardingGoal.values.length,
        animation: animation,
      ),
      const SizedBox(height: 20),
      ...OnboardingGoal.values.map((goal) {
        final active = selected.contains(goal);
        final copy = _copy(goal);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedScale(
            scale: active ? 1.015 : 1,
            duration: const Duration(milliseconds: 220),
            child: Material(
              color: active
                  ? NurrDesign.gold.withValues(alpha: dark ? .16 : .11)
                  : NurrDesign.surface(dark),
              borderRadius: BorderRadius.circular(23),
              child: InkWell(
                onTap: () => onToggle(goal),
                borderRadius: BorderRadius.circular(23),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(
                      color: active
                          ? NurrDesign.gold
                          : NurrDesign.gold.withValues(alpha: .16),
                      width: active ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (active ? NurrDesign.gold : NurrDesign.emerald)
                              .withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          goal.icon,
                          color: active
                              ? NurrDesign.goldDark
                              : NurrDesign.emerald,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy.$1,
                              style: TextStyle(
                                color: NurrDesign.text(dark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              copy.$2,
                              style: TextStyle(
                                color: NurrDesign.secondaryText(dark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: active
                            ? const Icon(
                                Icons.check_circle_rounded,
                                key: ValueKey(true),
                                color: NurrDesign.goldDark,
                              )
                            : Icon(
                                Icons.circle_outlined,
                                key: const ValueKey(false),
                                color: NurrDesign.secondaryText(
                                  dark,
                                ).withValues(alpha: .4),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ],
  );
}

class _DhikrRing extends StatelessWidget {
  const _DhikrRing({required this.dark, required this.animation});
  final bool dark;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => Transform.rotate(
      angle: animation.value * math.pi * .16,
      child: SizedBox(
        width: 158,
        height: 158,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: NurrDesign.gold.withValues(alpha: .18),
                  width: 2,
                ),
              ),
            ),
            ...List.generate(12, (index) {
              final angle = index / 12 * math.pi * 2;
              return Transform.translate(
                offset: Offset(math.cos(angle) * 63, math.sin(angle) * 63),
                child: Container(
                  width: index % 3 == 0 ? 12 : 9,
                  height: index % 3 == 0 ? 12 : 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index % 3 == 0
                        ? NurrDesign.gold
                        : NurrDesign.emerald,
                    boxShadow: [
                      BoxShadow(
                        color: NurrDesign.gold.withValues(alpha: .18),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
              );
            }),
            Icon(
              Icons.touch_app_rounded,
              color: dark ? NurrDesign.gold : NurrDesign.emerald,
              size: 35,
            ),
          ],
        ),
      ),
    ),
  );
}

class _GrowingPath extends StatelessWidget {
  const _GrowingPath({
    required this.dark,
    required this.progress,
    required this.animation,
  });
  final bool dark;
  final double progress;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOutBack,
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: NurrDesign.surface(dark),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: NurrDesign.gold.withValues(alpha: .18)),
    ),
    child: Row(
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => Transform.rotate(
            angle: math.sin(animation.value * math.pi * 2) * .025,
            alignment: Alignment.bottomCenter,
            child: Icon(
              progress == 0 ? Icons.spa_outlined : Icons.park_rounded,
              color: progress == 0
                  ? NurrDesign.secondaryText(dark)
                  : NurrDesign.emerald,
              size: 28 + progress * 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: NurrDesign.gold.withValues(alpha: .1),
              color: NurrDesign.gold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(progress * 100).round()}%',
          style: TextStyle(
            color: NurrDesign.text(dark),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _Location extends StatelessWidget {
  const _Location({
    required this.dark,
    required this.t,
    required this.requesting,
    required this.result,
    required this.animation,
    required this.onUse,
    required this.onManual,
    required this.onSkip,
  });
  final bool dark;
  final _T t;
  final bool requesting;
  final String? result;
  final Animation<double> animation;
  final VoidCallback onUse;
  final VoidCallback onManual;
  final VoidCallback onSkip;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      OnboardingCard(
        dark: dark,
        child: SizedBox(
          height: 175,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NurrDesign.gold.withValues(alpha: .11),
                ),
              ),
              const Icon(
                Icons.mosque_rounded,
                color: NurrDesign.emerald,
                size: 88,
              ),
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final pulse =
                      .85 + math.sin(animation.value * math.pi * 2).abs() * .15;
                  return Positioned(
                    right: 76,
                    top: 16,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: pulse,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NurrDesign.gold.withValues(
                                  alpha: .42 * (2 - pulse),
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(
                            0,
                            math.sin(animation.value * math.pi * 2) * 4,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: NurrDesign.goldDark,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (result != null)
                const Positioned(
                  bottom: 8,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: NurrDesign.emerald,
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 23),
      _Copy(
        dark: dark,
        title: t(
          'Gebetszeiten für deinen Ort',
          'Prayer times for your location',
          'مواقيت الصلاة لموقعك',
        ),
        body: t(
          'Damit wir dir genaue Gebetszeiten anzeigen können, benötigen wir deinen Standort.',
          'To show accurate prayer times, we need your location.',
          'لعرض مواقيت صلاة دقيقة، نحتاج إلى موقعك.',
        ),
      ),
      if (result != null) ...[
        const SizedBox(height: 13),
        Text(
          result!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: NurrDesign.emerald,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
      const SizedBox(height: 22),
      OnboardingActionButton(
        label: requesting
            ? t(
                'Standort wird ermittelt …',
                'Finding location…',
                'جارٍ تحديد الموقع…',
              )
            : t('Standort verwenden', 'Use location', 'استخدام الموقع'),
        icon: requesting ? null : Icons.my_location_rounded,
        onPressed: requesting ? null : onUse,
      ),
      TextButton.icon(
        onPressed: onManual,
        icon: const Icon(Icons.edit_location_alt_outlined),
        label: Text(
          t(
            'Ort manuell auswählen',
            'Choose place manually',
            'اختيار الموقع يدويًا',
          ),
        ),
      ),
      TextButton(
        onPressed: onSkip,
        child: Text(
          t('Vorerst überspringen', 'Skip for now', 'تخطي الآن'),
          style: TextStyle(color: NurrDesign.secondaryText(dark)),
        ),
      ),
    ],
  );
}

class _Ready extends StatelessWidget {
  const _Ready({
    required this.dark,
    required this.animation,
    required this.t,
    required this.goals,
    required this.finishing,
    required this.onOpen,
  });
  final bool dark;
  final Animation<double> animation;
  final _T t;
  final Set<OnboardingGoal> goals;
  final bool finishing;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final glow =
              .75 + math.sin(animation.value * math.pi * 2).abs() * .25;
          return Container(
            width: 175,
            height: 175,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NurrDesign.gold.withValues(alpha: .2 * glow),
                  blurRadius: 55,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.nightlight_round,
                  size: 112,
                  color: NurrDesign.gold,
                ),
                ...List.generate(
                  5,
                  (i) => Align(
                    alignment: Alignment(
                      math.cos(i * 1.25) * .82,
                      math.sin(i * 1.25) * .82,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: i.isEven ? 14 : 9,
                      color: NurrDesign.gold.withValues(alpha: .65),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      _Copy(
        dark: dark,
        title: t(
          'Bismillah – dein Weg beginnt',
          'Bismillah—your journey begins',
          'بسم الله — تبدأ رحلتك',
        ),
        body: t(
          'Alles ist bereit. Möge diese App dir Nutzen bringen und dich jeden Tag an Allah erinnern.',
          'Everything is ready. May this app benefit you and remind you of Allah every day.',
          'كل شيء جاهز. نسأل الله أن ينفعك بهذا التطبيق ويذكّرك بالله كل يوم.',
        ),
      ),
      if (goals.isNotEmpty) ...[
        const SizedBox(height: 17),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: goals
              .map(
                (goal) => Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: NurrDesign.gold.withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, size: 20, color: NurrDesign.goldDark),
                ),
              )
              .toList(),
        ),
      ],
      const SizedBox(height: 27),
      OnboardingActionButton(
        label: t('App öffnen', 'Open app', 'فتح التطبيق'),
        icon: Icons.arrow_forward_rounded,
        onPressed: finishing ? null : onOpen,
      ),
    ],
  );
}
