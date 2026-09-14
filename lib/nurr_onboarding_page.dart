import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nurr_design.dart';
import 'onboarding/modern_onboarding_screens.dart';
import 'onboarding/onboarding_models.dart';
import 'onboarding/presentation_components.dart';

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
  bool _leaving = false;
  String? _locationResult;
  String? _error;
  bool get _ar => widget.languageCode == 'ar';
  bool get _dark => NurrDesign.darkMode.value;
  String _t(String de, String en, String ar) =>
      _ar ? ar : (widget.languageCode == 'en' ? en : de);

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
    _loadChoices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  Future<void> _loadChoices() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final saved =
        prefs.getStringList(OnboardingStorage.goals) ?? const <String>[];
    setState(() {
      _goals.addAll(
        OnboardingGoal.values.where((goal) => saved.contains(goal.name)),
      );
      _locationResult = prefs.getString(OnboardingStorage.manualLocation);
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setStringList(
      OnboardingStorage.goals,
      _goals.map((goal) => goal.name).toList(),
    )) {
      throw StateError('Could not save onboarding choices');
    }
  }

  void _toggleGoal(OnboardingGoal goal) {
    setState(() {
      _goals.contains(goal) ? _goals.remove(goal) : _goals.add(goal);
    });
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() {
      _finishing = true;
      _error = null;
    });
    try {
      await _saveGoals();
      final prefs = await SharedPreferences.getInstance();
      if (!widget.replay) {
        final saved = await prefs.setBool(OnboardingStorage.completed, true);
        if (!saved) throw StateError('Could not save onboarding completion');
        await prefs.setBool(OnboardingStorage.legacyCompleted, true);
      }
      if (!mounted) return;
      setState(() => _leaving = true);
      if (widget.replay || widget.nextPage == null) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder<void>(
            transitionDuration: presentationDuration(context, 500),
            pageBuilder: (_, animation, _) =>
                FadeTransition(opacity: animation, child: widget.nextPage!),
          ),
        );
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _finishing = false;
          _leaving = false;
          _error = _t(
            'Das Speichern hat nicht geklappt. Bitte versuche es erneut.',
            'Could not save. Please try again.',
            'تعذر الحفظ. يرجى المحاولة مرة أخرى.',
          );
        });
    }
  }

  void _go(int page) {
    if (!_controller.hasClients || _finishing) return;
    _controller.animateToPage(
      page.clamp(0, _count - 1),
      duration: presentationDuration(context),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() => _page == _count - 1 ? _finish() : _go(_page + 1);

  Future<void> _useLocation() async {
    if (_requestingLocation) return;
    setState(() => _requestingLocation = true);
    try {
      if (!kIsWeb) {
        if (!await Geolocator.isLocationServiceEnabled())
          throw StateError('Location disabled');
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied)
          permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever)
          throw StateError('Location denied');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(OnboardingStorage.locationChoice, 'automatic');
      await prefs.setDouble('nurr_prayer_latitude', position.latitude);
      await prefs.setDouble('nurr_prayer_longitude', position.longitude);
      if (mounted)
        setState(
          () => _locationResult = _t(
            'Standort gespeichert',
            'Location saved',
            'تم حفظ الموقع',
          ),
        );
    } catch (_) {
      if (mounted)
        setState(
          () => _locationResult = _t(
            'Kein Standortzugriff. Du kannst einen Ort eingeben oder weitergehen.',
            'No location access. Enter a place or simply continue.',
            'تعذر الوصول إلى الموقع. أدخل مكانًا أو تابع.',
          ),
        );
    } finally {
      if (mounted) setState(() => _requestingLocation = false);
    }
  }

  Future<void> _manualLocation() async {
    final input = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NurrDesign.surface(_dark),
        title: Text(
          _t('Ort auswählen', 'Choose a place', 'اختر المكان'),
          style: TextStyle(color: NurrDesign.text(_dark)),
        ),
        content: TextField(
          controller: input,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: NurrDesign.text(_dark)),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_city_outlined),
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

  List<String> get _chapterNames => [
    _t('Willkommen', 'Welcome', 'مرحبًا'),
    _t('Quran', 'Quran', 'القرآن'),
    _t('Gebete', 'Prayers', 'الصلاة'),
    _t('Erinnerung', 'Remembrance', 'الذكر'),
    _t('Dein Fokus', 'Your focus', 'اهتماماتك'),
    _t('Dein Ort', 'Your place', 'موقعك'),
    _t('Bereit', 'Ready', 'جاهز'),
  ];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: NurrDesign.darkMode,
    builder: (context, dark, _) => Directionality(
      textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
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
          body: AnimatedOpacity(
            opacity: _leaving ? 0 : 1,
            duration: presentationDuration(context, 400),
            child: SafeArea(
              child: Column(
                children: [
                  _header(dark),
                  Expanded(
                    child: PageView.builder(
                      key: const ValueKey('intro-pages'),
                      controller: _controller,
                      itemCount: _count,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) => TickerMode(
                        enabled: index == _page,
                        child: AnimatedBuilder(
                          animation: _controller,
                          child: _PresentationPageShell(
                            child: ModernOnboardingScreen(
                              key: ValueKey('intro-screen-$index'),
                              index: index,
                              dark: dark,
                              t: _t,
                              animation: _ambient,
                              goals: _goals,
                              onToggleGoal: _toggleGoal,
                              requestingLocation: _requestingLocation,
                              locationResult: _locationResult,
                              onLocation: _useLocation,
                              onManualLocation: _manualLocation,
                            ),
                          ),
                          builder: (context, child) {
                            final position = _controller.hasClients
                                ? (_controller.page ?? _page.toDouble())
                                : _page.toDouble();
                            final delta = (position - index).clamp(-1.0, 1.0);
                            final reduced = MediaQuery.disableAnimationsOf(
                              context,
                            );
                            return Opacity(
                              opacity: reduced ? 1 : 1 - delta.abs() * .4,
                              child: Transform.translate(
                                offset: Offset(reduced ? 0 : delta * 22, 0),
                                child: child,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  _footer(dark),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _header(bool dark) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 12, 16, 8),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NurrDesign.emerald,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.nightlight_round,
            color: NurrDesign.gold,
            size: 21,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'NURR',
          style: TextStyle(
            color: NurrDesign.text(dark),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 3,
          ),
        ),
        const Spacer(),
        if (_page > 0 && _page < _count - 1)
          TextButton(
            onPressed: _finishing ? null : _finish,
            child: Text(
              _t('Überspringen', 'Skip', 'تخطي'),
              style: TextStyle(
                color: NurrDesign.secondaryText(dark),
                fontSize: 12,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${_page + 1} / $_count',
              style: TextStyle(
                color: NurrDesign.secondaryText(dark),
                fontSize: 12,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _footer(bool dark) => Container(
    decoration: BoxDecoration(
      color: NurrDesign.background(dark),
      border: Border(
        top: BorderSide(color: NurrDesign.gold.withValues(alpha: .12)),
      ),
    ),
    padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _error!,
              style: TextStyle(color: NurrDesign.text(dark), fontSize: 12),
            ),
          ),
        Row(
          children: [
            Text(
              _chapterNames[_page],
              style: TextStyle(
                color: NurrDesign.secondaryText(dark),
                fontSize: 11,
              ),
            ),
            const Spacer(),
            ...List.generate(
              _count,
              (i) => AnimatedContainer(
                duration: presentationDuration(context, 350),
                margin: const EdgeInsetsDirectional.only(start: 4),
                height: 5,
                width: i == _page ? 22 : 5,
                decoration: BoxDecoration(
                  color: i == _page
                      ? NurrDesign.gold
                      : NurrDesign.gold.withValues(
                          alpha: i < _page ? .45 : .16,
                        ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_page > 0) ...[
              IconButton.filledTonal(
                key: const ValueKey('intro-back'),
                tooltip: _t('Zurück', 'Back', 'رجوع'),
                onPressed: _finishing ? null : () => _go(_page - 1),
                style: IconButton.styleFrom(
                  backgroundColor: NurrDesign.gold.withValues(alpha: .12),
                  foregroundColor: NurrDesign.text(dark),
                  minimumSize: const Size(52, 52),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: PresentationPrimaryButton(
                key: const ValueKey('intro-next'),
                label: _page == 0
                    ? _t('Los geht’s', 'Let’s begin', 'لنبدأ')
                    : _page == _count - 1
                    ? _t('App öffnen', 'Open app', 'فتح التطبيق')
                    : _t('Weiter', 'Next', 'التالي'),
                dark: dark,
                onPressed: _next,
                busy: _finishing,
              ),
            ),
          ],
        ),
        if (_page == 0) ...[
          const SizedBox(height: 9),
          Text(
            _t(
              'In deinem Tempo kennenlernen',
              'Explore at your own pace',
              'تعرّف عليه على مهل',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NurrDesign.secondaryText(dark),
              fontSize: 11,
            ),
          ),
        ],
      ],
    ),
  );
}

class _PresentationPageShell extends StatelessWidget {
  const _PresentationPageShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 570),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: presentationDuration(context, 620),
            curve: Curves.easeOutCubic,
            child: child,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
