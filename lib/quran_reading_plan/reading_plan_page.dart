import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../nurr_design.dart';
import '../quran_reading_plan_navigation.dart';
import '../quran_text_repository.dart';
import 'reading_plan_store.dart';
import 'reading_plan_widgets.dart';

/// Both entry card and dashboard refresh at midnight and on returning to the
/// app, without polling or rebuilding the whole screen for an animation.
abstract class _LivePlanState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  late final ReadingPlanStore planStore;
  ReadingPlanStore? get suppliedStore => null;
  bool loading = true;
  bool loadFailed = false;
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    planStore = suppliedStore ?? ReadingPlanStore.instance;
    WidgetsBinding.instance.addObserver(this);
    planStore.addListener(_changed);
    unawaited(reload());
    _scheduleMidnight();
  }

  Future<void> reload() async {
    try {
      await planStore.load();
      if (mounted) {
        setState(() {
          loading = false;
          loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          loadFailed = true;
        });
      }
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(
      tomorrow.difference(now) + const Duration(seconds: 1),
      () {
        _changed();
        _scheduleMidnight();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(reload());
      _scheduleMidnight();
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    planStore.removeListener(_changed);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class QuranReadingPlanCard extends StatefulWidget {
  const QuranReadingPlanCard({
    super.key,
    required this.languageCode,
    required this.darkMode,
    this.store,
  });

  final String languageCode;
  final bool darkMode;
  final ReadingPlanStore? store;

  @override
  State<QuranReadingPlanCard> createState() => _QuranReadingPlanCardState();
}

class _QuranReadingPlanCardState extends _LivePlanState<QuranReadingPlanCard> {
  bool _opening = false;

  @override
  ReadingPlanStore? get suppliedStore => widget.store;

  String t(String de, String en, String ar) =>
      readingPlanText(widget.languageCode, de, en, ar);

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        transitionDuration: readingPlanDuration(context, 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuranReadingPlanPage(
              languageCode: widget.languageCode,
              darkMode: widget.darkMode,
              store: planStore,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
      ),
    );
    _opening = false;
    if (mounted) await reload();
  }

  @override
  Widget build(BuildContext context) {
    final plan = planStore.plan;
    final count = plan?.pagesReadOn(DateTime.now()) ?? 0;
    final goal = plan?.dailyGoal ?? 1;
    return Directionality(
      textDirection: widget.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: ReadingPlanPress(
        key: const ValueKey('quran-reading-plan-card'),
        borderRadius: 30,
        onTap: _open,
        child: ReadingPlanSurface(
          darkMode: widget.darkMode,
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _eyebrow(
                          t('DEIN LESEPLAN', 'YOUR READING PLAN', 'خطة قراءتك'),
                          widget.darkMode,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          plan == null
                              ? t(
                                  'Eine Seite.\nJeden Tag.',
                                  'One page.\nEvery day.',
                                  'صفحة واحدة.\nكل يوم.',
                                )
                              : plan.isComplete
                              ? t(
                                  'Dein Plan ist vollendet',
                                  'Your plan is complete',
                                  'أتممت خطتك',
                                )
                              : plan.paused
                              ? t(
                                  'In deinem Tempo',
                                  'At your own pace',
                                  'على مهل',
                                )
                              : count >= goal
                              ? t(
                                  'Heute geschafft',
                                  'Today, you did it',
                                  'أكملت هدف اليوم',
                                )
                              : t(
                                  'Zeit für deinen Quran',
                                  'Your Quran moment',
                                  'وقتك مع القرآن',
                                ),
                          style: TextStyle(
                            color: NurrDesign.text(widget.darkMode),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 108,
                    child: ReadingPlanArtwork(darkMode: widget.darkMode),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (loading)
                LinearProgressIndicator(
                  color: NurrDesign.gold,
                  backgroundColor: NurrDesign.gold.withValues(alpha: .12),
                )
              else ...[
                Text(
                  loadFailed
                      ? t(
                          'Tippen, um deinen Plan erneut zu laden.',
                          'Tap to load your plan again.',
                          'اضغط لإعادة تحميل خطتك.',
                        )
                      : plan == null
                      ? t(
                          'Ein kleiner Moment, der zu deinem Alltag gehört.',
                          'A small moment to make part of your day.',
                          'لحظة صغيرة تصبح جزءًا من يومك.',
                        )
                      : plan.isComplete
                      ? t(
                          '${plan.completedPages} Seiten gelesen · Dein Weg im Überblick',
                          '${plan.completedPages} pages read · See your journey',
                          'قرأت ${plan.completedPages} صفحة · تأمل رحلتك',
                        )
                      : plan.paused
                      ? t(
                          'Dein Lesestand bleibt erhalten.',
                          'Your reading position is saved.',
                          'موضع قراءتك محفوظ.',
                        )
                      : t(
                          '$count von $goal Seiten heute · Weiter bei Seite ${plan.nextPage}',
                          '$count of $goal pages today · Continue at page ${plan.nextPage}',
                          '$count من $goal صفحات اليوم · تابع من الصفحة ${plan.nextPage}',
                        ),
                  style: TextStyle(
                    color: NurrDesign.secondaryText(widget.darkMode),
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    if (plan != null) ...[
                      Expanded(
                        child: _progressBar(
                          context,
                          (count / goal).clamp(0, 1),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ] else
                      const Spacer(),
                    Text(
                      plan == null
                          ? t('Plan erstellen', 'Create a plan', 'أنشئ خطة')
                          : t('Plan öffnen', 'Open plan', 'افتح الخطة'),
                      style: TextStyle(
                        color: widget.darkMode
                            ? NurrDesign.gold
                            : NurrDesign.emerald,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: widget.darkMode
                          ? NurrDesign.gold
                          : NurrDesign.emerald,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class QuranReadingPlanPage extends StatefulWidget {
  const QuranReadingPlanPage({
    super.key,
    required this.languageCode,
    required this.darkMode,
    this.store,
  });

  final String languageCode;
  final bool darkMode;
  final ReadingPlanStore? store;

  @override
  State<QuranReadingPlanPage> createState() => _QuranReadingPlanPageState();
}

class _QuranReadingPlanPageState extends _LivePlanState<QuranReadingPlanPage> {
  final _pageScroll = ScrollController();
  int _goal = 1;
  int _savedPage = 1;
  bool _hasSavedPosition = false;
  bool _fromCurrent = false;
  bool _busy = false;

  @override
  ReadingPlanStore? get suppliedStore => widget.store;

  bool get dark => widget.darkMode;
  String t(String de, String en, String ar) =>
      readingPlanText(widget.languageCode, de, en, ar);

  @override
  void initState() {
    super.initState();
    unawaited(_readCurrentPosition());
  }

  @override
  void dispose() {
    _pageScroll.dispose();
    super.dispose();
  }

  void _scrollToStart() {
    if (mounted && _pageScroll.hasClients) _pageScroll.jumpTo(0);
  }

  Future<void> _readCurrentPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surah = prefs.getInt('quran_last_surah');
      final ayah = prefs.getInt('quran_last_ayah');
      if (surah == null || ayah == null) return;
      final data = await QuranTextRepository.instance.load();
      final page = data.verse('$surah:$ayah').page;
      if (mounted) {
        setState(() {
          _savedPage = page;
          _hasSavedPosition = true;
        });
      }
    } catch (_) {
      // The plan can still start at the beginning if no valid reading position exists.
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t(
                'Das hat gerade nicht geklappt. Bitte versuche es noch einmal.',
                'That did not work just now. Please try again.',
                'تعذر إتمام العملية الآن. حاول مرة أخرى.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read() => _run(() async {
    final plan = planStore.plan;
    if (plan == null || plan.isComplete) return;
    if (plan.paused) await planStore.setPaused(false);
    if (!mounted) return;
    await openQuranReadingPlanSession(
      context,
      languageCode: widget.languageCode,
      page: plan.nextPage,
      store: planStore,
    );
    if (mounted) await reload();
  });

  Future<void> _settings() async {
    final plan = planStore.plan;
    if (plan == null || _busy) return;
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NurrDesign.surface(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: widget.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _heading(t('Dein Tempo', 'Your pace', 'وتيرتك'), 23),
                const SizedBox(height: 8),
                _body(
                  t(
                    'Ändere dein Tagesziel jederzeit. Dein Lesestand bleibt erhalten.',
                    'Change your daily goal at any time. Your reading position stays saved.',
                    'غيّر هدفك اليومي متى شئت. سيبقى موضع قراءتك محفوظًا.',
                  ),
                ),
                const SizedBox(height: 20),
                _goalChoices(
                  plan.dailyGoal,
                  (value) => Navigator.pop(sheetContext, value),
                ),
                const SizedBox(height: 20),
                if (!plan.isComplete)
                  ListTile(
                    key: const ValueKey('reading-plan-pause'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      plan.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: NurrDesign.gold,
                    ),
                    title: Text(
                      plan.paused
                          ? t('Plan fortsetzen', 'Resume plan', 'استأنف الخطة')
                          : t(
                              'Plan pausieren',
                              'Pause plan',
                              'أوقف الخطة مؤقتًا',
                            ),
                      style: TextStyle(color: NurrDesign.text(dark)),
                    ),
                    onTap: () => Navigator.pop(sheetContext, -1),
                  ),
                ListTile(
                  key: const ValueKey('reading-plan-remove'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: NurrDesign.secondaryText(dark),
                  ),
                  title: Text(
                    t(
                      'Leseplan entfernen',
                      'Remove reading plan',
                      'احذف خطة القراءة',
                    ),
                    style: TextStyle(color: NurrDesign.text(dark)),
                  ),
                  onTap: () => Navigator.pop(sheetContext, -2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (result > 0) {
      await _run(() async {
        await planStore.setDailyGoal(result);
      });
    } else if (result == -1) {
      await _run(() async {
        await planStore.setPaused(!plan.paused);
      });
    } else {
      final remove = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: NurrDesign.surface(dark),
          title: _heading(
            t('Plan entfernen?', 'Remove this plan?', 'هل تريد حذف الخطة؟'),
            21,
          ),
          content: _body(
            t(
              'Der Leseplan und seine Fortschritte werden auf diesem Gerät gelöscht. Deine Quran-Lesezeichen und Markierungen bleiben erhalten.',
              'This plan and its progress will be deleted from this device. Your Quran bookmarks and highlights will stay.',
              'ستُحذف الخطة وتقدمها من هذا الجهاز. ستبقى إشاراتك المرجعية وتظليلات القرآن محفوظة.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                t('Behalten', 'Keep', 'احتفظ بها'),
                style: const TextStyle(color: NurrDesign.gold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                t('Entfernen', 'Remove', 'احذف'),
                style: TextStyle(color: NurrDesign.text(dark)),
              ),
            ),
          ],
        ),
      );
      if (remove == true && mounted) {
        await _run(() async {
          await planStore.reset();
          _scrollToStart();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = planStore.plan;
    return Directionality(
      textDirection: widget.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: NurrDesign.background(dark),
        appBar: AppBar(
          backgroundColor: NurrDesign.background(dark),
          foregroundColor: NurrDesign.text(dark),
          surfaceTintColor: Colors.transparent,
          title: Text(
            t('Mein Quran-Plan', 'My Quran plan', 'خطتي مع القرآن'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          actions: [
            if (plan != null)
              IconButton(
                key: const ValueKey('reading-plan-settings'),
                onPressed: _busy ? null : _settings,
                tooltip: t('Plan einstellen', 'Plan settings', 'إعدادات الخطة'),
                icon: const Icon(Icons.tune_rounded),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: NurrDesign.gold),
                )
              : loadFailed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _body(
                          t(
                            'Dein Plan konnte nicht geladen werden.',
                            'Your plan could not be loaded.',
                            'تعذر تحميل خطتك.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ReadingPlanButton(
                          label: t(
                            'Erneut versuchen',
                            'Try again',
                            'حاول مرة أخرى',
                          ),
                          onPressed: reload,
                          darkMode: dark,
                          icon: Icons.refresh_rounded,
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  controller: _pageScroll,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: AnimatedSwitcher(
                        duration: readingPlanDuration(context),
                        switchInCurve: Curves.easeOutCubic,
                        child: Column(
                          key: ValueKey(
                            plan == null
                                ? 'reading-plan-setup'
                                : 'reading-plan-dashboard',
                          ),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (plan == null)
                              ..._setup()
                            else
                              ..._dashboard(plan),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_iphone_rounded,
                                  size: 15,
                                  color: NurrDesign.secondaryText(dark),
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    t(
                                      'Dein Plan bleibt auf diesem Gerät.',
                                      'Your plan stays on this device.',
                                      'تبقى خطتك على هذا الجهاز.',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: NurrDesign.secondaryText(dark),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _setup() => [
    ReadingPlanSurface(
      darkMode: dark,
      accent: true,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: ReadingPlanArtwork(darkMode: dark),
          ),
          _eyebrow(
            t('EIN MOMENT FÜR DICH', 'A MOMENT FOR YOU', 'لحظة لك'),
            dark,
          ),
          const SizedBox(height: 12),
          _heading(
            t(
              'Eine Seite. Jeden Tag.',
              'One page. Every day.',
              'صفحة واحدة. كل يوم.',
            ),
            27,
            centered: true,
          ),
          const SizedBox(height: 12),
          _body(
            t(
              'Gib dem Quran einen festen Platz in deinem Alltag. Wähle ein Ziel, das sich für dich gut anfühlt.',
              'Make room for the Quran in your everyday life. Choose a goal that feels right for you.',
              'اجعل للقرآن مكانًا ثابتًا في يومك. اختر هدفًا يناسبك.',
            ),
            centered: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 28),
    _heading(
      t(
        'Wie viel möchtest du lesen?',
        'How much would you like to read?',
        'كم تريد أن تقرأ؟',
      ),
      20,
    ),
    const SizedBox(height: 7),
    _body(
      t(
        'Klein anfangen ist ein schöner Anfang.',
        'Starting small is a lovely beginning.',
        'البداية الصغيرة بداية جميلة.',
      ),
    ),
    const SizedBox(height: 16),
    _goalChoices(_goal, (value) => setState(() => _goal = value)),
    const SizedBox(height: 26),
    _heading(
      t(
        'Wo möchtest du beginnen?',
        'Where would you like to start?',
        'من أين تريد أن تبدأ؟',
      ),
      20,
    ),
    const SizedBox(height: 14),
    _startChoice(
      false,
      Icons.auto_stories_rounded,
      t('Am Anfang', 'At the beginning', 'من البداية'),
      t('Al-Fatiha · Seite 1', 'Al-Fatiha · Page 1', 'الفاتحة · الصفحة 1'),
    ),
    const SizedBox(height: 10),
    _startChoice(
      true,
      Icons.bookmark_outline_rounded,
      t('Bei meinem Lesestand', 'At my reading position', 'من موضع قراءتي'),
      _hasSavedPosition
          ? t(
              'Ab Seite $_savedPage',
              'From page $_savedPage',
              'من الصفحة $_savedPage',
            )
          : t(
              'Noch kein Lesestand gespeichert',
              'No reading position saved yet',
              'لا يوجد موضع قراءة محفوظ بعد',
            ),
    ),
    const SizedBox(height: 20),
    _body(
      t(
        'Gezählt werden die 604 Quran-Seiten der hinterlegten Seiteneinteilung – unabhängig von Schriftgröße und Ansicht. Nach dem Lesen bestätigst du jede Seite selbst.',
        'Progress uses the Quran’s 604-page division, regardless of font size or reading view. Confirm each page yourself after reading.',
        'يُحسب التقدم وفق تقسيم القرآن إلى 604 صفحات، بغض النظر عن حجم الخط وطريقة العرض. أكّد كل صفحة بنفسك بعد قراءتها.',
      ),
    ),
    const SizedBox(height: 22),
    ReadingPlanButton(
      key: const ValueKey('reading-plan-create'),
      label: t(
        'Meinen Leseplan beginnen',
        'Begin my reading plan',
        'ابدأ خطة قراءتي',
      ),
      icon: Icons.auto_stories_rounded,
      busy: _busy,
      darkMode: dark,
      onPressed: () => _run(() async {
        await planStore.create(
          dailyGoal: _goal,
          startPage: _fromCurrent ? _savedPage : 1,
        );
        _scrollToStart();
      }),
    ),
  ];

  Widget _goalChoices(int selected, ValueChanged<int> onSelect) =>
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 450 ? 4 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final goal in [1, 2, 5, 10])
                SizedBox(
                  width: width,
                  child: Semantics(
                    selected: goal == selected,
                    button: true,
                    child: ReadingPlanPress(
                      key: ValueKey('reading-plan-goal-$goal'),
                      onTap: _busy ? null : () => onSelect(goal),
                      child: AnimatedContainer(
                        duration: readingPlanDuration(context, 400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 17,
                        ),
                        decoration: BoxDecoration(
                          color: goal == selected
                              ? NurrDesign.gold.withValues(
                                  alpha: dark ? .17 : .13,
                                )
                              : NurrDesign.surface(dark),
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(
                            color: goal == selected
                                ? NurrDesign.gold
                                : NurrDesign.gold.withValues(alpha: .16),
                            width: goal == selected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$goal',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: NurrDesign.text(dark),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedSwitcher(
                                  duration: readingPlanDuration(context, 400),
                                  child: Icon(
                                    goal == selected
                                        ? Icons.check_circle_rounded
                                        : Icons.menu_book_rounded,
                                    key: ValueKey(goal == selected),
                                    size: 17,
                                    color: goal == selected
                                        ? (dark
                                              ? NurrDesign.gold
                                              : NurrDesign.emerald)
                                        : NurrDesign.secondaryText(dark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal == 1
                                  ? t(
                                      'Seite pro Tag',
                                      'page per day',
                                      'صفحة يوميًا',
                                    )
                                  : t(
                                      'Seiten pro Tag',
                                      'pages per day',
                                      'صفحات يوميًا',
                                    ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: NurrDesign.secondaryText(dark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );

  Widget _startChoice(
    bool current,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final selected = _fromCurrent == current;
    final enabled = !current || _hasSavedPosition;
    return Semantics(
      selected: selected,
      button: true,
      enabled: enabled,
      child: ReadingPlanPress(
        key: ValueKey(
          current
              ? 'reading-plan-start-current'
              : 'reading-plan-start-beginning',
        ),
        onTap: enabled && !_busy
            ? () => setState(() => _fromCurrent = current)
            : null,
        child: AnimatedContainer(
          duration: readingPlanDuration(context, 400),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected
                ? NurrDesign.gold.withValues(alpha: .10)
                : NurrDesign.surface(dark),
            border: Border.all(
              color: selected
                  ? NurrDesign.gold
                  : NurrDesign.gold.withValues(alpha: .14),
            ),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? (dark ? NurrDesign.gold : NurrDesign.emerald)
                    : NurrDesign.secondaryText(dark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled
                            ? NurrDesign.text(dark)
                            : NurrDesign.secondaryText(dark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: NurrDesign.secondaryText(dark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected
                    ? NurrDesign.gold
                    : NurrDesign.gold.withValues(alpha: .4),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _dashboard(ReadingPlan plan) {
    final now = DateTime.now();
    final today = plan.pagesReadOn(now);
    final met = today >= plan.dailyGoal;
    final days = (plan.remainingPages / plan.dailyGoal).ceil();
    return [
      ReadingPlanSurface(
        darkMode: dark,
        accent: true,
        child: Column(
          children: [
            _eyebrow(
              plan.isComplete
                  ? t('DEIN WEG', 'YOUR JOURNEY', 'رحلتك')
                  : plan.paused
                  ? t('EINE KLEINE PAUSE', 'A LITTLE PAUSE', 'استراحة قصيرة')
                  : t('DEIN MOMENT HEUTE', 'YOUR MOMENT TODAY', 'لحظتك اليوم'),
              dark,
            ),
            const SizedBox(height: 20),
            ReadingPlanProgressRing(
              value: plan.isComplete ? 1 : today / plan.dailyGoal,
              darkMode: dark,
              size: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: readingPlanDuration(context),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      plan.isComplete || met
                          ? Icons.check_rounded
                          : plan.paused
                          ? Icons.pause_rounded
                          : Icons.auto_stories_rounded,
                      key: ValueKey('${plan.isComplete}-$met-${plan.paused}'),
                      color: dark ? NurrDesign.gold : NurrDesign.emerald,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.isComplete
                        ? '${plan.completedPages}'
                        : '$today / ${plan.dailyGoal}',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      color: NurrDesign.text(dark),
                    ),
                  ),
                  Text(
                    plan.isComplete
                        ? t('Seiten gelesen', 'pages read', 'صفحة مقروءة')
                        : t('Seiten heute', 'pages today', 'صفحات اليوم'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: NurrDesign.secondaryText(dark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            _heading(
              plan.isComplete
                  ? t(
                      'Seite für Seite angekommen.',
                      'Page by page, you made it.',
                      'وصلت، صفحة بعد صفحة.',
                    )
                  : plan.paused
                  ? t(
                      'Dein Platz wartet auf dich.',
                      'Your place is waiting for you.',
                      'موضعك ينتظرك.',
                    )
                  : met
                  ? t(
                      'Ein schöner Schritt für heute.',
                      'A beautiful step for today.',
                      'خطوة جميلة لهذا اليوم.',
                    )
                  : t(
                      'Ein kleiner Schritt. Dein Rhythmus.',
                      'A small step. Your rhythm.',
                      'خطوة صغيرة. بإيقاعك.',
                    ),
              23,
              centered: true,
            ),
            const SizedBox(height: 10),
            _body(
              plan.isComplete
                  ? t(
                      'Du hast deinen Leseplan bis zur letzten Seite abgeschlossen. Nimm dir einen Moment für diesen Weg.',
                      'You have completed your reading plan through the last page. Take a moment to appreciate this journey.',
                      'أكملت خطة قراءتك حتى الصفحة الأخيرة. خذ لحظة للتأمل في هذه الرحلة.',
                    )
                  : plan.paused
                  ? t(
                      'Du kannst jederzeit weitermachen. Alles ist gespeichert.',
                      'Continue whenever you are ready. Everything is saved.',
                      'تابع متى كنت مستعدًا. كل شيء محفوظ.',
                    )
                  : met
                  ? t(
                      'Dein Tagesziel ist erreicht. Wenn du möchtest, lies ganz in Ruhe weiter.',
                      'You have reached your daily goal. Feel free to read a little more.',
                      'حققت هدفك اليومي. يمكنك متابعة القراءة بهدوء إن شئت.',
                    )
                  : t(
                      'Heute ist ein guter Tag für deine nächste Seite.',
                      'Today is a good day for your next page.',
                      'اليوم فرصة جميلة لقراءة صفحتك التالية.',
                    ),
              centered: true,
            ),
            const SizedBox(height: 22),
            if (!plan.isComplete) ...[
              ReadingPlanButton(
                key: const ValueKey('reading-plan-read'),
                label: plan.paused
                    ? t('Fortsetzen & lesen', 'Resume & read', 'استأنف واقرأ')
                    : met
                    ? t(
                        'Freiwillig weiterlesen',
                        'Keep reading',
                        'تابع القراءة إن شئت',
                      )
                    : t(
                        'Jetzt lesen · Seite ${plan.nextPage}',
                        'Read now · Page ${plan.nextPage}',
                        'اقرأ الآن · الصفحة ${plan.nextPage}',
                      ),
                onPressed: _read,
                darkMode: dark,
                icon: Icons.menu_book_rounded,
                busy: _busy,
              ),
              const SizedBox(height: 11),
              Text(
                t(
                  'Nach jeder Seite bestätigst du „Gelesen“.',
                  'Confirm “Read” after each page.',
                  'أكّد «تمت القراءة» بعد كل صفحة.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NurrDesign.secondaryText(dark),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 18),
      ReadingPlanSurface(
        darkMode: dark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(
              t(
                'Deine letzten 7 Tage',
                'Your last 7 days',
                'أيامك السبعة الأخيرة',
              ),
              18,
            ),
            const SizedBox(height: 18),
            _week(plan, now),
            const SizedBox(height: 15),
            _body(
              t(
                'Jeder neue Tag ist eine neue Gelegenheit.',
                'Every new day is a fresh opportunity.',
                'كل يوم جديد فرصة جديدة.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      ReadingPlanSurface(
        darkMode: dark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _heading(
                    t('Seite für Seite', 'Page by page', 'صفحة بعد صفحة'),
                    18,
                  ),
                ),
                Text(
                  '${(plan.progress * 100).round()} %',
                  style: TextStyle(
                    color: dark ? NurrDesign.gold : NurrDesign.emerald,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            _body(
              t(
                '${plan.completedPages} von ${plan.totalPages} Seiten deines Plans',
                '${plan.completedPages} of ${plan.totalPages} pages in your plan',
                '${plan.completedPages} من ${plan.totalPages} صفحة في خطتك',
              ),
            ),
            const SizedBox(height: 21),
            _progressBar(context, plan.progress),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t(
                    'Start · ${plan.startPage}',
                    'Start · ${plan.startPage}',
                    'البداية · ${plan.startPage}',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: NurrDesign.secondaryText(dark),
                  ),
                ),
                for (final milestone in [.25, .5, .75])
                  Icon(
                    plan.progress >= milestone
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 15,
                    color: plan.progress >= milestone
                        ? NurrDesign.gold
                        : NurrDesign.gold.withValues(alpha: .35),
                  ),
                Text(
                  t('Seite 604', 'Page 604', 'الصفحة 604'),
                  style: TextStyle(
                    fontSize: 11,
                    color: NurrDesign.secondaryText(dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final children = [
                  _stat(
                    Icons.calendar_today_rounded,
                    '$days',
                    t(
                      'Lesetage übrig*',
                      'reading days left*',
                      'أيام قراءة متبقية*',
                    ),
                  ),
                  _stat(
                    Icons.spa_outlined,
                    '${plan.streakOn(now)}',
                    t('Tage in Folge', 'days in a row', 'أيام متتالية'),
                  ),
                ];
                return constraints.maxWidth < 270
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          children[0],
                          const SizedBox(height: 16),
                          children[1],
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: children[0]),
                          const SizedBox(width: 12),
                          Expanded(child: children[1]),
                        ],
                      );
              },
            ),
            const SizedBox(height: 17),
            Text(
              t(
                '*Bei deinem aktuellen Tagesziel. Du bestimmst das Tempo.',
                '*At your current daily goal. You set the pace.',
                '*وفق هدفك اليومي الحالي. أنت تحدد الوتيرة.',
              ),
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: NurrDesign.secondaryText(dark),
              ),
            ),
          ],
        ),
      ),
      if (today > 0) ...[
        const SizedBox(height: 10),
        TextButton.icon(
          key: const ValueKey('reading-plan-undo'),
          onPressed: _busy
              ? null
              : () => _run(() async {
                  await planStore.undoLastPage();
                }),
          icon: const Icon(Icons.undo_rounded, size: 17),
          label: Text(
            t(
              'Letzte Bestätigung zurücknehmen',
              'Undo last confirmation',
              'تراجع عن آخر تأكيد',
            ),
            textAlign: TextAlign.center,
          ),
          style: TextButton.styleFrom(
            foregroundColor: NurrDesign.secondaryText(dark),
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    ];
  }

  Widget _week(ReadingPlan plan, DateTime now) {
    final labels = widget.languageCode == 'ar'
        ? ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
        : widget.languageCode == 'en'
        ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : ['M', 'D', 'M', 'D', 'F', 'S', 'S'];
    return Row(
      children: List.generate(7, (index) {
        final date = DateTime(now.year, now.month, now.day - 6 + index);
        final met = plan.goalMetOn(date);
        final count = plan.pagesReadOn(date);
        final current = index == 6;
        return Expanded(
          child: Semantics(
            label: '${date.day}.${date.month}.: $count / ${plan.dailyGoal}',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  Text(
                    labels[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                      color: NurrDesign.secondaryText(dark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedContainer(
                      duration: readingPlanDuration(context, 450),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: met
                            ? (dark
                                  ? NurrDesign.gold.withValues(alpha: .18)
                                  : NurrDesign.emerald)
                            : NurrDesign.gold.withValues(
                                alpha: count > 0 ? .19 : .06,
                              ),
                        border: Border.all(
                          color: current
                              ? NurrDesign.gold
                              : NurrDesign.gold.withValues(alpha: .12),
                          width: current ? 1.8 : 1,
                        ),
                      ),
                      child: Center(
                        child: met
                            ? Icon(
                                Icons.check_rounded,
                                color: dark ? NurrDesign.gold : Colors.white,
                                size: 18,
                              )
                            : Text(
                                count > 0 ? '$count' : '${date.day}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: count > 0
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: NurrDesign.text(dark),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: current ? NurrDesign.gold : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NurrDesign.gold.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 20,
          color: dark ? NurrDesign.gold : NurrDesign.emerald,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: NurrDesign.text(dark),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: NurrDesign.secondaryText(dark),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _heading(String text, double size, {bool centered = false}) => Text(
    text,
    textAlign: centered ? TextAlign.center : TextAlign.start,
    style: TextStyle(
      fontSize: size,
      height: 1.25,
      fontWeight: FontWeight.w800,
      color: NurrDesign.text(dark),
    ),
  );
  Widget _body(String text, {bool centered = false}) => Text(
    text,
    textAlign: centered ? TextAlign.center : TextAlign.start,
    style: TextStyle(
      fontSize: 13,
      height: 1.55,
      color: NurrDesign.secondaryText(dark),
    ),
  );
}

Widget _eyebrow(String text, bool dark) => Text(
  text,
  style: TextStyle(
    color: dark ? NurrDesign.gold : NurrDesign.goldDark,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
  ),
);

Widget _progressBar(BuildContext context, double value) =>
    TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: readingPlanDuration(context, 650),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => LinearProgressIndicator(
        value: progress,
        color: NurrDesign.gold,
        backgroundColor: NurrDesign.gold.withValues(alpha: .13),
        minHeight: 7,
        borderRadius: BorderRadius.circular(12),
      ),
    );
