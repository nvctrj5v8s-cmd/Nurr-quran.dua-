import 'package:flutter/material.dart';

import '../nurr_design.dart';
import 'onboarding_models.dart';
import 'onboarding_scene.dart';
import 'presentation_components.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({
    super.key,
    required this.index,
    required this.dark,
    required this.t,
    required this.animation,
    required this.goals,
    required this.onToggleGoal,
    required this.requestingLocation,
    required this.locationResult,
    required this.onLocation,
    required this.onManualLocation,
  });

  final int index;
  final bool dark;
  final OnboardingText t;
  final Animation<double> animation;
  final Set<OnboardingGoal> goals;
  final ValueChanged<OnboardingGoal> onToggleGoal;
  final bool requestingLocation;
  final String? locationResult;
  final VoidCallback onLocation;
  final VoidCallback onManualLocation;

  @override
  State<ModernOnboardingScreen> createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen> {
  bool _pagePreview = true;
  int _prayer = 3;
  int _collection = 0;
  int _dhikr = 0;
  bool get dark => widget.dark;
  String t(String de, String en, String ar) => widget.t(de, en, ar);
  Color get ink => NurrDesign.text(dark);
  Color get muted => NurrDesign.secondaryText(dark);
  Color get accent => dark ? NurrDesign.gold : NurrDesign.goldDark;

  Widget _heading(String eyebrow, String title, String description) =>
      PresentationHeading(
        dark: dark,
        eyebrow: eyebrow,
        title: title,
        description: description,
      );

  Widget _scene(String scene, {int selectedPrayer = 3}) => OnboardingScene(
    dark: dark,
    animation: widget.animation,
    scene: scene,
    selectedPrayer: selectedPrayer,
  );

  Widget _note(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: accent, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => switch (widget.index) {
    0 => _welcome(),
    1 => _quran(),
    2 => _prayers(),
    3 => _remembrance(),
    4 => _goals(),
    5 => _location(),
    _ => _ready(),
  };

  Widget _welcome() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t('WILLKOMMEN BEI NURR', 'WELCOME TO NURR', 'مرحبًا بك في نور'),
        t('Assalamu alaikum.', 'Assalamu alaikum.', 'السلام عليكم.'),
        t(
          'Ein ruhiger Moment für dich. Ein Begleiter für deinen Glauben – jeden Tag.',
          'A quiet moment for you. A companion for your faith, every day.',
          'لحظة هادئة لك. ورفيق يعينك على الخير كل يوم.',
        ),
      ),
      const SizedBox(height: 14),
      _scene('welcome'),
      const SizedBox(height: 4),
      PresentationSurface(
        dark: dark,
        child: Column(
          children: [
            PresentationFeature(
              dark: dark,
              icon: Icons.menu_book_rounded,
              title: t(
                'Lesen. Verstehen. Weitergehen.',
                'Read. Reflect. Keep going.',
                'اقرأ. تدبّر. وواصل.',
              ),
              subtitle: t(
                'Quran, Übersetzungen und dein eigener Leseplan.',
                'Quran, translations and your own reading plan.',
                'القرآن والترجمات وخطة قراءتك الخاصة.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Divider(
                height: 1,
                color: NurrDesign.gold.withValues(alpha: .16),
              ),
            ),
            PresentationFeature(
              dark: dark,
              icon: Icons.nights_stay_outlined,
              title: t(
                'Mehr Ruhe in deinem Alltag.',
                'More calm in your everyday life.',
                'طمأنينة في يومك.',
              ),
              subtitle: t(
                'Gebete, Duas und Dhikr an einem Ort.',
                'Prayers, duas and dhikr in one place.',
                'الصلاة والأدعية والأذكار في مكان واحد.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          PresentationChip(
            dark: dark,
            label: t('Kostenlos', 'Free', 'مجاني'),
            icon: Icons.favorite_border,
          ),
          PresentationChip(
            dark: dark,
            label: t('Ohne Werbung', 'Ad-free', 'بلا إعلانات'),
            icon: Icons.verified_outlined,
          ),
          PresentationChip(
            dark: dark,
            label: t('Dein Tempo', 'Your pace', 'على مهل'),
            icon: Icons.eco_outlined,
          ),
        ],
      ),
    ],
  );

  Widget _quran() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t('DEINE LESEZEIT', 'YOUR READING TIME', 'وقت قراءتك'),
        t(
          'Der Quran.\nSo, wie du liest.',
          'The Quran.\nThe way you read.',
          'القرآن.\nكما تحب أن تقرأ.',
        ),
        t(
          'Wähle deine Ansicht, markiere Verse und finde jederzeit zu deiner Lesestelle zurück.',
          'Choose your view, highlight verses and return to your reading position anytime.',
          'اختر طريقة العرض وظلّل الآيات وعُد إلى موضع قراءتك متى شئت.',
        ),
      ),
      const SizedBox(height: 16),
      _scene('quran'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          PresentationChip(
            key: const ValueKey('intro-preview-pages'),
            dark: dark,
            selected: _pagePreview,
            label: t('Seitenansicht', 'Page view', 'عرض الصفحات'),
            icon: Icons.auto_stories_outlined,
            onTap: () => setState(() => _pagePreview = true),
          ),
          PresentationChip(
            key: const ValueKey('intro-preview-verses'),
            dark: dark,
            selected: !_pagePreview,
            label: t('Versansicht', 'Verse view', 'عرض الآيات'),
            icon: Icons.view_agenda_outlined,
            onTap: () => setState(() => _pagePreview = false),
          ),
        ],
      ),
      const SizedBox(height: 12),
      AnimatedSwitcher(
        duration: presentationDuration(context, 400),
        child: PresentationSurface(
          key: ValueKey(_pagePreview),
          dark: dark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _pagePreview
                        ? Icons.chrome_reader_mode_outlined
                        : Icons.format_align_right,
                    color: accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pagePreview
                          ? t(
                              'In Ruhe Seite für Seite',
                              'A page at a time',
                              'صفحة تلو صفحة',
                            )
                          : t(
                              'Arabisch und Übersetzung',
                              'Arabic and translation',
                              'العربية والترجمة',
                            ),
                      style: TextStyle(color: ink, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _pagePreview
                    ? t(
                        'Ein zusammenhängender Lesefluss. Auf großen Displays auch nebeneinander.',
                        'A continuous reading experience. Side-by-side on larger displays, too.',
                        'قراءة متصلة. ويمكن عرض الصفحات جنبًا إلى جنب على الشاشات الكبيرة.',
                      )
                    : t(
                        'Jede Aya einzeln im Blick – mit Übersetzung, Lesezeichen und Markierungsfarben.',
                        'Each ayah at a glance, with translation, bookmarks and highlight colors.',
                        'كل آية أمامك مع الترجمة والإشارات المرجعية وألوان التظليل.',
                      ),
                style: TextStyle(color: muted, height: 1.5, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final color in [
                    NurrDesign.gold,
                    const Color(0xFF88A879),
                    const Color(0xFF7BA7C9),
                    const Color(0xFFC9828D),
                  ])
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    t('Deine Markierungen', 'Your highlights', 'تظليلاتك'),
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      OnboardingWeekPreview(dark: dark, t: t),
      const SizedBox(height: 12),
      _note(
        Icons.touch_app_outlined,
        t(
          'Probiere die Vorschau aus. Deinen Lesemodus wählst du später im Quran.',
          'Try the preview. Choose your actual reading mode later in the Quran.',
          'جرّب المعاينة. تختار وضع القراءة لاحقًا في القرآن.',
        ),
      ),
    ],
  );

  List<String> get _prayerNames => [
    t('Fajr', 'Fajr', 'الفجر'),
    t('Dhuhr', 'Dhuhr', 'الظهر'),
    t('Asr', 'Asr', 'العصر'),
    t('Maghrib', 'Maghrib', 'المغرب'),
    t('Isha', 'Isha', 'العشاء'),
  ];
  Widget _prayers() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t(
          'IM RHYTHMUS DEINES TAGES',
          'THE RHYTHM OF YOUR DAY',
          'في أوقات يومك',
        ),
        t(
          'Fünf Gebete.\nDein täglicher Anker.',
          'Five prayers.\nYour daily anchor.',
          'خمس صلوات.\nصلة تتجدد كل يوم.',
        ),
        t(
          'Gebetszeiten für deinen Ort und ein persönlicher Tracker helfen dir, deinen Tag bewusst zu gestalten.',
          'Local prayer times and a personal tracker help you shape your day with intention.',
          'مواقيت الصلاة لموقعك ومتابعة صلواتك تعينك على تنظيم يومك.',
        ),
      ),
      const SizedBox(height: 14),
      _scene('prayer', selectedPrayer: _prayer),
      const SizedBox(height: 12),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: List.generate(
          5,
          (i) => PresentationChip(
            key: ValueKey('intro-prayer-$i'),
            dark: dark,
            selected: _prayer == i,
            label: _prayerNames[i],
            onTap: () => setState(() => _prayer = i),
          ),
        ),
      ),
      const SizedBox(height: 14),
      PresentationSurface(
        dark: dark,
        green: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(
                'DEIN TAG IM ÜBERBLICK',
                'YOUR DAY AT A GLANCE',
                'نظرة على يومك',
              ),
              style: const TextStyle(
                color: NurrDesign.gold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 9),
            AnimatedSwitcher(
              duration: presentationDuration(context, 350),
              child: Align(
                key: ValueKey(_prayer),
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  _prayerNames[_prayer],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'Vom ersten Licht bis zur Nacht.',
                'From first light to nightfall.',
                'من أول الفجر إلى الليل.',
              ),
              style: const TextStyle(color: Color(0xFFE4EADD), fontSize: 14),
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(
                5,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: presentationDuration(context, 450),
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    height: i == _prayer ? 8 : 5,
                    decoration: BoxDecoration(
                      color: i <= _prayer ? NurrDesign.gold : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t(
                'Interaktive Vorschau · keine aktuellen Gebetszeiten',
                'Interactive preview · not current prayer times',
                'معاينة تفاعلية · ليست مواقيت الصلاة الحالية',
              ),
              style: const TextStyle(color: Color(0xFFD0DCD3), fontSize: 11),
            ),
          ],
        ),
      ),
      const SizedBox(height: 17),
      _note(
        Icons.check_circle_outline,
        t(
          'Ein Tippen im Tracker hält fest, welches Gebet du verrichtet hast.',
          'One tap in the tracker records a prayer you have completed.',
          'سجّل الصلاة التي أديتها بلمسة واحدة في المتابعة.',
        ),
      ),
    ],
  );

  Widget _remembrance() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t(
          'KLEINE MOMENTE DER ERINNERUNG',
          'SMALL MOMENTS OF REMEMBRANCE',
          'لحظات من الذكر',
        ),
        t(
          'Nimm dir einen\nMoment für Allah.',
          'Take a moment\nto remember Allah.',
          'خذ لحظة\nلذكر الله.',
        ),
        t(
          'Duas für deinen Alltag, Dhikr mit der Masbaha und die 99 Namen Allahs – begleitet von Bedeutung und Aussprache.',
          'Everyday duas, dhikr with the tasbih and the 99 Names of Allah, with meaning and pronunciation.',
          'أدعية يومية وذكر مع المسبحة وأسماء الله الحسنى مع المعنى والنطق.',
        ),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < 3; i++)
            PresentationChip(
              key: ValueKey('intro-collection-$i'),
              dark: dark,
              selected: _collection == i,
              label: [
                t('Duas', 'Duas', 'الأدعية'),
                t('Dhikr', 'Dhikr', 'الذكر'),
                t('99 Namen', '99 Names', 'الأسماء الحسنى'),
              ][i],
              icon: [
                Icons.volunteer_activism_outlined,
                Icons.touch_app_outlined,
                Icons.auto_awesome_outlined,
              ][i],
              onTap: () => setState(() => _collection = i),
            ),
        ],
      ),
      const SizedBox(height: 16),
      AnimatedSwitcher(
        duration: presentationDuration(context),
        child: PresentationSurface(
          key: ValueKey(_collection),
          dark: dark,
          child: switch (_collection) {
            1 => _dhikrPreview(),
            2 => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t(
                    '99 NAMEN ALLAHS',
                    '99 NAMES OF ALLAH',
                    'أسماء الله الحسنى',
                  ),
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'الرَّحْمَٰن',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: ink,
                    fontFamily: 'AmiriQuran',
                    fontSize: 44,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ar-Rahman',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t('Der Allerbarmer', 'The Most Merciful', 'الرَّحْمَٰن'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 15),
                ),
                const SizedBox(height: 24),
                _note(
                  Icons.menu_book_outlined,
                  t(
                    'Entdecke Bedeutung und Aussprache in der App.',
                    'Explore meaning and pronunciation in the app.',
                    'تعرّف على المعنى والنطق في التطبيق.',
                  ),
                ),
              ],
            ),
            _ => Column(
              children: [
                PresentationFeature(
                  dark: dark,
                  icon: Icons.wb_sunny_outlined,
                  title: t('Ein guter Morgen', 'A good morning', 'بداية صباحك'),
                  subtitle: t(
                    'Morgen-Duas entdecken',
                    'Explore morning duas',
                    'اكتشف أدعية الصباح',
                  ),
                ),
                const SizedBox(height: 21),
                PresentationFeature(
                  dark: dark,
                  icon: Icons.nightlight_outlined,
                  title: t(
                    'Ein ruhiger Abend',
                    'A peaceful evening',
                    'مساء مطمئن',
                  ),
                  subtitle: t(
                    'Mit Erinnerung abschließen',
                    'End the day with remembrance',
                    'اختم يومك بالذكر',
                  ),
                ),
                const SizedBox(height: 21),
                PresentationFeature(
                  dark: dark,
                  icon: Icons.favorite_outline,
                  title: t(
                    'Für deine Momente',
                    'For your moments',
                    'في لحظاتك',
                  ),
                  subtitle: t(
                    'Duas für viele Lebenssituationen',
                    'Duas for everyday situations',
                    'أدعية لمواقف الحياة',
                  ),
                ),
              ],
            ),
          },
        ),
      ),
      const SizedBox(height: 16),
      PresentationSurface(
        dark: dark,
        child: PresentationFeature(
          dark: dark,
          icon: Icons.spa_outlined,
          title: t(
            'Gutes im Alltag entdecken',
            'Discover good in everyday life',
            'اكتشف الخير في يومك',
          ),
          subtitle: t(
            'Sunnahs kennenlernen, eigene Notizen festhalten und deinen Garten wachsen sehen.',
            'Discover sunnahs, keep your notes and watch your garden grow.',
            'تعرّف على السنن ودوّن ملاحظاتك وشاهد حديقتك تنمو.',
          ),
        ),
      ),
    ],
  );

  Widget _dhikrPreview() => Column(
    children: [
      Text(
        t('EIN MOMENT DER RUHE', 'A MOMENT OF CALM', 'لحظة سكينة'),
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 24),
      Semantics(
        button: true,
        label: t(
          'Dhikr-Vorschau erhöhen',
          'Increase dhikr preview',
          'زيادة عداد المعاينة',
        ),
        child: InkWell(
          key: const ValueKey('intro-dhikr-tap'),
          customBorder: const CircleBorder(),
          onTap: () => setState(() => _dhikr = (_dhikr + 1) % 34),
          child: SizedBox.square(
            dimension: 172,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _dhikr / 33),
                    duration: presentationDuration(context, 350),
                    builder: (_, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      color: NurrDesign.gold,
                      backgroundColor: NurrDesign.gold.withValues(alpha: .14),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: presentationDuration(context, 220),
                      child: Text(
                        '$_dhikr',
                        key: ValueKey(_dhikr),
                        style: TextStyle(
                          color: ink,
                          fontSize: 50,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      t('von 33', 'of 33', 'من ٣٣'),
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 22),
      Text(
        t('Tippe auf den Kreis', 'Tap the circle', 'اضغط على الدائرة'),
        style: TextStyle(color: ink, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      Text(
        t(
          'Nur eine Vorschau – wird nicht mitgezählt.',
          'Preview only – does not add to your count.',
          'معاينة فقط · لا تُضاف إلى عدّادك.',
        ),
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 11, height: 1.4),
      ),
    ],
  );

  (String, String) _goalCopy(OnboardingGoal goal) => switch (goal) {
    OnboardingGoal.quran => (
      t('Mehr Quran lesen', 'Read more Quran', 'قراءة المزيد من القرآن'),
      t(
        'Seite für Seite, in deinem Tempo',
        'Page by page, at your pace',
        'صفحة تلو صفحة على مهل',
      ),
    ),
    OnboardingGoal.prayer => (
      t('Meine Gebete stärken', 'Strengthen my prayers', 'المحافظة على صلاتي'),
      t(
        'Die fünf Gebete bewusst begleiten',
        'Make room for the five prayers',
        'الاهتمام بالصلوات الخمس',
      ),
    ),
    OnboardingGoal.duas => (
      t('Mehr Duas lernen', 'Learn more duas', 'تعلّم المزيد من الأدعية'),
      t(
        'Für die kleinen und großen Momente',
        'For little moments and big ones',
        'للحظات الحياة المختلفة',
      ),
    ),
    OnboardingGoal.dhikr => (
      t('Täglich Dhikr machen', 'Make dhikr daily', 'الذكر يوميًا'),
      t(
        'Eine ruhige Gewohnheit entwickeln',
        'Build a peaceful habit',
        'اجعل الذكر عادة يومية',
      ),
    ),
    OnboardingGoal.names => (
      t('Allahs Namen lernen', 'Learn Allah’s Names', 'تعلّم أسماء الله'),
      t(
        'Bedeutung und Aussprache entdecken',
        'Explore meaning and pronunciation',
        'تعلّم المعنى والنطق',
      ),
    ),
    OnboardingGoal.all => (
      t('Alles gemeinsam entdecken', 'Explore everything', 'اكتشاف كل شيء'),
      t('Ein Schritt nach dem anderen', 'One step at a time', 'خطوة بعد خطوة'),
    ),
  };

  Widget _goals() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t('DEIN PERSÖNLICHER FOKUS', 'YOUR PERSONAL FOCUS', 'اهتماماتك'),
        t(
          'Was ist dir\ngerade wichtig?',
          'What matters\nto you right now?',
          'ما الذي تود\nالاهتمام به؟',
        ),
        t(
          'Wähle, was dich anspricht. Mehrere Antworten sind möglich; du kannst auch später entscheiden.',
          'Choose what speaks to you. Pick several, or decide later.',
          'اختر ما يهمك. يمكنك اختيار أكثر من إجابة أو اتخاذ القرار لاحقًا.',
        ),
      ),
      const SizedBox(height: 18),
      AnimatedSwitcher(
        duration: presentationDuration(context, 250),
        child: Align(
          key: ValueKey(widget.goals.length),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.goals.isEmpty
                ? t(
                    'Dein Weg beginnt mit einem kleinen Schritt.',
                    'Your journey starts with a small step.',
                    'رحلتك تبدأ بخطوة صغيرة.',
                  )
                : t(
                    '${widget.goals.length} ausgewählt · dein eigener Weg',
                    '${widget.goals.length} selected · your own path',
                    'اخترت ${widget.goals.length} · طريقك الخاص',
                  ),
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      ...OnboardingGoal.values.map((goal) {
        final selected = widget.goals.contains(goal);
        final copy = _goalCopy(goal);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Semantics(
            selected: selected,
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('intro-goal-${goal.name}'),
                onTap: () => widget.onToggleGoal(goal),
                borderRadius: BorderRadius.circular(23),
                child: AnimatedContainer(
                  duration: presentationDuration(context, 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color.alphaBlend(
                            NurrDesign.gold.withValues(alpha: .12),
                            NurrDesign.surface(dark),
                          )
                        : NurrDesign.surface(dark),
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(
                      color: selected
                          ? NurrDesign.gold
                          : NurrDesign.gold.withValues(alpha: .16),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: PresentationFeature(
                    dark: dark,
                    icon: goal.icon,
                    title: copy.$1,
                    subtitle: copy.$2,
                    trailing: AnimatedSwitcher(
                      duration: presentationDuration(context, 250),
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        key: ValueKey(selected),
                        color: selected ? accent : muted.withValues(alpha: .4),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: 8),
      _note(
        Icons.bookmark_border,
        t(
          'Deine Auswahl wird auf diesem Gerät gespeichert.',
          'Your choices are saved on this device.',
          'تُحفظ اختياراتك على هذا الجهاز.',
        ),
      ),
    ],
  );

  Widget _location() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t('DORT, WO DU BIST', 'WHEREVER YOU ARE', 'أينما كنت'),
        t(
          'Dein Ort.\nDeine Gebetszeiten.',
          'Your place.\nYour prayer times.',
          'موقعك.\nومواقيت صلاتك.',
        ),
        t(
          'Wähle deinen Standort für passende Gebetszeiten. Du entscheidest, ob du ihn freigibst oder deinen Ort selbst eingibst.',
          'Choose your location for local prayer times. Share your location or enter your place yourself.',
          'اختر موقعك لعرض مواقيت الصلاة. يمكنك مشاركة موقعك أو إدخاله بنفسك.',
        ),
      ),
      const SizedBox(height: 16),
      _scene('location'),
      const SizedBox(height: 14),
      PresentationSurface(
        dark: dark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PresentationFeature(
              dark: dark,
              icon: Icons.location_on_outlined,
              title: t(
                'Passend zu deinem Alltag',
                'Made for your daily life',
                'يناسب يومك',
              ),
              subtitle: t(
                'Für zu Hause und unterwegs.',
                'At home and on the go.',
                'في المنزل وأثناء التنقل.',
              ),
            ),
            const SizedBox(height: 18),
            PresentationPrimaryButton(
              key: const ValueKey('intro-location'),
              dark: dark,
              busy: widget.requestingLocation,
              icon: Icons.my_location_rounded,
              label: widget.requestingLocation
                  ? t(
                      'Standort wird ermittelt …',
                      'Finding your location…',
                      'جارٍ تحديد الموقع…',
                    )
                  : t('Standort verwenden', 'Use location', 'استخدام الموقع'),
              onPressed: widget.onLocation,
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: widget.onManualLocation,
              icon: Icon(
                Icons.edit_location_alt_outlined,
                size: 19,
                color: accent,
              ),
              label: Text(
                t(
                  'Ort manuell auswählen',
                  'Choose a place manually',
                  'اختيار الموقع يدويًا',
                ),
                style: TextStyle(color: accent),
              ),
            ),
            if (widget.locationResult != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.locationResult!,
                textAlign: TextAlign.center,
                style: TextStyle(color: ink, fontSize: 13, height: 1.5),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      _note(
        Icons.lock_outline,
        t(
          'Die Berechtigungsfrage erscheint erst nach deinem Tippen. Du kannst auch einfach weitergehen.',
          'Permission is requested only after you tap. You can also simply continue.',
          'لا يُطلب الإذن إلا بعد الضغط. ويمكنك المتابعة دون ذلك.',
        ),
      ),
    ],
  );

  Widget _ready() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        t('SCHÖN, DASS DU DA BIST', 'GOOD TO HAVE YOU HERE', 'يسعدنا انضمامك'),
        t(
          'Bismillah.\nDein Weg beginnt.',
          'Bismillah.\nYour journey begins.',
          'بسم الله.\nتبدأ رحلتك.',
        ),
        t(
          'Möge diese App dir Nutzen bringen und dich jeden Tag an Allah erinnern.',
          'May this app benefit you and remind you of Allah every day.',
          'نسأل الله أن ينفعك بهذا التطبيق ويذكّرك بالله كل يوم.',
        ),
      ),
      const SizedBox(height: 12),
      _scene('ready'),
      const SizedBox(height: 8),
      PresentationSurface(
        dark: dark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t(
                'DEIN ERSTER KLEINER SCHRITT',
                'YOUR FIRST SMALL STEP',
                'خطوتك الصغيرة الأولى',
              ),
              style: TextStyle(
                color: accent,
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            PresentationFeature(
              dark: dark,
              icon: widget.goals.isEmpty
                  ? Icons.menu_book_outlined
                  : widget.goals.first.icon,
              title: widget.goals.isEmpty
                  ? t(
                      'Nimm dir eine Seite Zeit.',
                      'Make time for one page.',
                      'خصص وقتًا لصفحة واحدة.',
                    )
                  : _goalCopy(widget.goals.first).$1,
              subtitle: t(
                'Entdecke deinen Bereich auf der Startseite.',
                'Find your space on the home screen.',
                'اكتشف ما يناسبك في الصفحة الرئيسية.',
              ),
              trailing: Icon(Icons.check_circle_outline, color: accent),
            ),
            if (widget.goals.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: widget.goals
                    .map(
                      (goal) => PresentationChip(
                        dark: dark,
                        label: _goalCopy(goal).$1,
                        icon: goal.icon,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 18),
      _note(
        Icons.favorite_outline,
        t(
          'Kein Druck. Dein Tempo. Ein Schritt nach dem anderen.',
          'No pressure. Your pace. One step at a time.',
          'بلا ضغط. على مهل. خطوة بعد خطوة.',
        ),
      ),
    ],
  );
}
