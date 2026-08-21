import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nurr_design.dart';
import 'quran_text_repository.dart';

String _dayKey([DateTime? value]) {
  final day = value ?? DateTime.now();
  return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
}

class NurJourneyCard extends StatefulWidget {
  final String languageCode;
  final bool darkMode;
  const NurJourneyCard({
    super.key,
    required this.languageCode,
    required this.darkMode,
  });

  @override
  State<NurJourneyCard> createState() => _NurJourneyCardState();
}

class _NurJourneyCardState extends State<NurJourneyCard> {
  int _points = 0;

  String _t(String de, String en, String ar) => widget.languageCode == 'ar'
      ? ar
      : (widget.languageCode == 'en' ? en : de);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final prayers = List.generate(
      5,
      (i) => prefs.getBool('gebet_$i') ?? false,
    ).where((value) => value).length;
    final sunnahs =
        (prefs.getStringList('nurr_sunnah_${_dayKey()}') ?? const []).length;
    var dhikr = 0;
    try {
      final raw = prefs.getString('tasbih_counts_by_dhikr');
      if (raw != null) {
        final values = (jsonDecode(raw) as Map<String, dynamic>).values;
        dhikr = values.fold<int>(
          0,
          (sum, value) => sum + (value as num).toInt(),
        );
      }
    } catch (_) {}
    if (mounted) {
      setState(
        () => _points = prayers * 12 + sunnahs * 7 + math.min(dhikr, 100),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = 1 + _points ~/ 100;
    final progress = (_points % 100) / 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: widget.darkMode
            ? const LinearGradient(
                colors: [Color(0xFF15130F), Color(0xFF292216)],
              )
            : const LinearGradient(
                colors: [Color(0xFFFFFBED), Color(0xFFF4E2B4)],
              ),
        border: Border.all(color: NurrDesign.gold.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NurrDesign.gold.withValues(alpha: .12),
                boxShadow: [
                  BoxShadow(
                    color: NurrDesign.gold.withValues(alpha: .18 + value * .35),
                    blurRadius: 12 + value * 28,
                    spreadRadius: value * 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: NurrDesign.goldDark,
                size: 42,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(
                    'Dein Nūr-Weg · Stufe $level',
                    'Your Nūr journey · Level $level',
                    'طريق النور · المستوى $level',
                  ),
                  style: TextStyle(
                    color: NurrDesign.text(widget.darkMode),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _t(
                    'Eine Motivation für Beständigkeit – keine Bewertung deines Glaubens.',
                    'Motivation for consistency—not a judgment of faith.',
                    'تشجيع على الاستمرار، وليس حكمًا على الإيمان.',
                  ),
                  style: TextStyle(
                    color: NurrDesign.secondaryText(widget.darkMode),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(20),
                  color: NurrDesign.gold,
                  backgroundColor: NurrDesign.gold.withValues(alpha: .16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyImpulseCard extends StatefulWidget {
  final String languageCode;
  final bool darkMode;
  final void Function(int surah, int ayah) onOpenVerse;

  const DailyImpulseCard({
    super.key,
    required this.languageCode,
    required this.darkMode,
    required this.onOpenVerse,
  });

  @override
  State<DailyImpulseCard> createState() => _DailyImpulseCardState();
}

class _DailyImpulseCardState extends State<DailyImpulseCard> {
  static const _verses = <String>[
    '2:152',
    '2:186',
    '2:286',
    '3:139',
    '3:159',
    '8:46',
    '9:51',
    '12:87',
    '13:28',
    '16:97',
    '20:46',
    '29:69',
    '39:53',
    '65:3',
    '93:3',
    '94:5',
    '94:6',
    '103:3',
  ];

  static const _themes = <List<String>>[
    ['Dankbarkeit', 'Gratitude', 'الشكر'],
    ['Nähe', 'Closeness', 'القرب'],
    ['Zuversicht', 'Confidence', 'الثقة'],
    ['Mut', 'Courage', 'الشجاعة'],
    ['Sanftmut', 'Gentleness', 'الرفق'],
    ['Beständigkeit', 'Steadfastness', 'الثبات'],
    ['Vertrauen', 'Trust', 'التوكل'],
    ['Hoffnung', 'Hope', 'الأمل'],
    ['Ruhe', 'Peace', 'الطمأنينة'],
    ['Gutes Leben', 'A good life', 'الحياة الطيبة'],
    ['Begleitung', 'Companionship', 'المعية'],
    ['Bemühung', 'Striving', 'السعي'],
    ['Barmherzigkeit', 'Mercy', 'الرحمة'],
    ['Tawakkul', 'Reliance', 'التوكل'],
    ['Nicht verlassen', 'Never abandoned', 'لست متروكًا'],
    ['Erleichterung', 'Ease', 'اليسر'],
    ['Erleichterung', 'Ease', 'اليسر'],
    ['Geduld', 'Patience', 'الصبر'],
  ];

  late final Future<QuranVerse> _verse;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayNumber = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime.utc(2025)).inDays;
    final key = _verses[dayNumber % _verses.length];
    _verse = QuranTextRepository.instance.load().then(
      (data) => data.verse(key),
    );
  }

  String _t(String de, String en, String ar) => widget.languageCode == 'ar'
      ? ar
      : (widget.languageCode == 'en' ? en : de);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNumber = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime.utc(2025)).inDays;
    final theme = _themes[dayNumber % _themes.length];
    return FutureBuilder<QuranVerse>(
      future: _verse,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final verse = snapshot.data!;
        final translation = widget.languageCode == 'en'
            ? verse.english
            : verse.german;
        return InkWell(
          onTap: () => widget.onOpenVerse(verse.surah, verse.ayah),
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.darkMode
                    ? const [Color(0xFF251F14), Color(0xFF171717)]
                    : const [Color(0xFFFFF7DE), Color(0xFFFFFDF8)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: NurrDesign.gold.withValues(alpha: .32)),
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  end: -22,
                  top: -24,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 118,
                    color: NurrDesign.gold.withValues(alpha: .08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: NurrDesign.gold.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _t(
                                'IMPULS DES TAGES',
                                'DAILY IMPULSE',
                                'إلهام اليوم',
                              ),
                              style: const TextStyle(
                                color: NurrDesign.goldDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .6,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            theme[widget.languageCode == 'ar'
                                ? 2
                                : (widget.languageCode == 'en' ? 1 : 0)],
                            style: TextStyle(
                              color: NurrDesign.secondaryText(widget.darkMode),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        verse.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NurrDesign.text(widget.darkMode),
                          fontFamily: 'AmiriQuran',
                          fontSize: 25,
                          height: 1.8,
                        ),
                      ),
                      if (widget.languageCode != 'ar') ...[
                        const SizedBox(height: 12),
                        Text(
                          translation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: NurrDesign.text(widget.darkMode),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 13),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${verse.surah}:${verse.ayah}',
                            style: const TextStyle(
                              color: NurrDesign.goldDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: NurrDesign.goldDark,
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
    );
  }
}

class PrayerJourneyCard extends StatelessWidget {
  final String languageCode;
  final bool darkMode;
  final List<bool> prayers;
  final ValueChanged<int> onToggle;
  final VoidCallback onOpen;

  const PrayerJourneyCard({
    super.key,
    required this.languageCode,
    required this.darkMode,
    required this.prayers,
    required this.onToggle,
    required this.onOpen,
  });

  String _t(String de, String en, String ar) =>
      languageCode == 'ar' ? ar : (languageCode == 'en' ? en : de);

  @override
  Widget build(BuildContext context) {
    const names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final done = prayers.where((item) => item).length;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: NurrDesign.card(color: NurrDesign.surface(darkMode)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [NurrDesign.gold, NurrDesign.goldDark],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.mosque_rounded, color: Colors.white),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          'Mein Gebetsweg',
                          'My prayer journey',
                          'رحلتي مع الصلاة',
                        ),
                        style: TextStyle(
                          color: NurrDesign.text(darkMode),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _t(
                          '$done von 5 Lichtpunkten',
                          '$done of 5 lights',
                          '$done من 5 أنوار',
                        ),
                        style: TextStyle(
                          color: NurrDesign.secondaryText(darkMode),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                  color: NurrDesign.goldDark,
                ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) => Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: constraints.maxWidth / 10,
                    right: constraints.maxWidth / 10,
                    top: 19,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: darkMode ? Colors.white12 : Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final active = prayers[index];
                      return GestureDetector(
                        onTap: () => onToggle(index),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active
                                    ? NurrDesign.gold
                                    : NurrDesign.surface(darkMode),
                                border: Border.all(
                                  color: active
                                      ? const Color(0xFFFFD77A)
                                      : NurrDesign.gold.withValues(alpha: .45),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: NurrDesign.gold.withValues(
                                      alpha: active ? .38 : 0,
                                    ),
                                    blurRadius: active ? 15 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                active
                                    ? Icons.auto_awesome
                                    : Icons.circle_outlined,
                                size: 18,
                                color: active
                                    ? Colors.white
                                    : NurrDesign.goldDark,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              names[index],
                              style: TextStyle(
                                color: NurrDesign.text(darkMode),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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

class PrayerJourneyPage extends StatefulWidget {
  final String languageCode;
  final bool darkMode;

  const PrayerJourneyPage({
    super.key,
    required this.languageCode,
    required this.darkMode,
  });

  @override
  State<PrayerJourneyPage> createState() => _PrayerJourneyPageState();
}

class _PrayerJourneyPageState extends State<PrayerJourneyPage>
    with SingleTickerProviderStateMixin {
  static const _names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  List<bool> _values = List.filled(5, false);
  Map<String, int> _history = {};
  List<String> _statuses = List.filled(5, 'none');
  List<String> _notes = List.filled(5, '');
  int _selectedPrayer = 0;
  late final AnimationController _sky;

  String _t(String de, String en, String ar) => widget.languageCode == 'ar'
      ? ar
      : (widget.languageCode == 'en' ? en : de);

  @override
  void initState() {
    super.initState();
    _sky = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _sky.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dayKey();
    if (prefs.getString('nurr_prayer_day') != today) {
      await prefs.setString('nurr_prayer_day', today);
      for (var i = 0; i < 5; i++) {
        await prefs.setBool('gebet_$i', false);
      }
    }
    final historyRaw = prefs.getString('nurr_prayer_journey_history');
    final parsed = historyRaw == null
        ? <String, dynamic>{}
        : jsonDecode(historyRaw) as Map<String, dynamic>;
    if (!mounted) return;
    setState(() {
      _values = List.generate(5, (i) => prefs.getBool('gebet_$i') ?? false);
      _statuses = List.generate(
        5,
        (i) => prefs.getString('nurr_prayer_status_${today}_$i') ?? 'none',
      );
      _notes = List.generate(
        5,
        (i) => prefs.getString('nurr_prayer_note_${today}_$i') ?? '',
      );
      _history = parsed.map((key, value) => MapEntry(key, value as int));
    });
  }

  Future<void> _openPrayerDetails(int index) async {
    setState(() => _selectedPrayer = index);
    var draftStatus = _statuses[index];
    final noteController = TextEditingController(text: _notes[index]);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NurrDesign.surface(widget.darkMode),
      builder: (context) => SizedBox(
        height: math.min(MediaQuery.sizeOf(context).height * .82, 620),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: NurrDesign.secondaryText(
                          widget.darkMode,
                        ).withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _names[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: NurrDesign.text(widget.darkMode),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t(
                      'Wie möchtest du dieses Gebet eintragen?',
                      'How would you like to record this prayer?',
                      'كيف تريد تسجيل هذه الصلاة؟',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: NurrDesign.secondaryText(widget.darkMode),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    alignment: WrapAlignment.center,
                    children:
                        [
                              (
                                'congregation',
                                Icons.groups_rounded,
                                _t('Gemeinschaft', 'Congregation', 'جماعة'),
                              ),
                              (
                                'alone',
                                Icons.person_rounded,
                                _t('Allein', 'Alone', 'منفردًا'),
                              ),
                              (
                                'made_up',
                                Icons.history_rounded,
                                _t('Nachgetragen', 'Made up', 'قضاء'),
                              ),
                              (
                                'none',
                                Icons.remove_circle_outline_rounded,
                                _t(
                                  'Nicht eingetragen',
                                  'Not recorded',
                                  'غير مسجلة',
                                ),
                              ),
                            ]
                            .map(
                              (option) => ChoiceChip(
                                selected: draftStatus == option.$1,
                                selectedColor: NurrDesign.gold,
                                avatar: Icon(option.$2, size: 18),
                                label: Text(option.$3),
                                onSelected: (_) => setSheetState(
                                  () => draftStatus = option.$1,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: noteController,
                    maxLength: 120,
                    maxLines: 2,
                    style: TextStyle(color: NurrDesign.text(widget.darkMode)),
                    decoration: InputDecoration(
                      labelText: _t(
                        'Private Notiz (optional)',
                        'Private note (optional)',
                        'ملاحظة خاصة (اختياري)',
                      ),
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final completed = draftStatus != 'none';
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        'nurr_prayer_status_${_dayKey()}_$index',
                        draftStatus,
                      );
                      await prefs.setString(
                        'nurr_prayer_note_${_dayKey()}_$index',
                        noteController.text.trim(),
                      );
                      final next = [..._values]..[index] = completed;
                      await prefs.setBool('gebet_$index', completed);
                      final history = {
                        ..._history,
                        _dayKey(): next.where((v) => v).length,
                      };
                      await prefs.setString(
                        'nurr_prayer_journey_history',
                        jsonEncode(history),
                      );
                      if (!mounted) return;
                      setState(() {
                        _values = next;
                        _statuses[index] = draftStatus;
                        _notes[index] = noteController.text.trim();
                        _history = history;
                      });
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(_t('Speichern', 'Save', 'حفظ')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _quickToggle(int index) async {
    final completed = !_values[index];
    final status = completed ? 'completed' : 'none';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nurr_prayer_status_${_dayKey()}_$index', status);
    await prefs.setBool('gebet_$index', completed);
    final next = [..._values]..[index] = completed;
    final history = {..._history, _dayKey(): next.where((v) => v).length};
    await prefs.setString('nurr_prayer_journey_history', jsonEncode(history));
    if (!mounted) return;
    setState(() {
      _values = next;
      _statuses[index] = status;
      _history = history;
      _selectedPrayer = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _values.where((v) => v).length;
    const skySets = [
      [Color(0xFF355C83), Color(0xFFF3B98A)],
      [Color(0xFF4B9AC0), Color(0xFFBFE4EC)],
      [Color(0xFF5E91A8), Color(0xFFE7BB76)],
      [Color(0xFF553F68), Color(0xFFE17B62)],
      [Color(0xFF101B3D), Color(0xFF243F68)],
    ];
    return Scaffold(
      backgroundColor: NurrDesign.background(widget.darkMode),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: NurrDesign.text(widget.darkMode),
        title: Text(
          _t('Mein Gebetsweg', 'My prayer journey', 'رحلتي مع الصلاة'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          AnimatedBuilder(
            animation: _sky,
            builder: (context, child) => Container(
              height: 245,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: skySets[_selectedPrayer],
                ),
              ),
              child: CustomPaint(
                painter: _PrayerSkyPainter(
                  progress: _sky.value,
                  dark: widget.darkMode,
                  completed: done,
                  selectedPrayer: _selectedPrayer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('Heute', 'Today', 'اليوم'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: done / 5),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 58,
                                height: .9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 5,
                                left: 7,
                              ),
                              child: Text(
                                '/ 5',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 7,
                                backgroundColor: Colors.white24,
                                color: NurrDesign.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        done == 5
                            ? _t(
                                'Ein Tag voller Licht.',
                                'A day filled with light.',
                                'يومٌ مملوء بالنور',
                              )
                            : _t(
                                'Jedes Gebet ist eine neue Rückkehr.',
                                'Every prayer is a new return.',
                                'كل صلاة عودة جديدة',
                              ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PrayerLightPath(
            selected: _selectedPrayer,
            completed: _values,
            names: _names,
            darkMode: widget.darkMode,
            onSelected: (index) => setState(() => _selectedPrayer = index),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            5,
            (index) => _PrayerMomentTile(
              index: index,
              name: _names[index],
              active: _values[index],
              darkMode: widget.darkMode,
              languageCode: widget.languageCode,
              status: _statuses[index],
              hasNote: _notes[index].trim().isNotEmpty,
              onTap: () => _quickToggle(index),
              onDetails: () => _openPrayerDetails(index),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _t('Deine Woche', 'Your week', 'أسبوعك'),
            style: TextStyle(
              color: NurrDesign.text(widget.darkMode),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: NurrDesign.card(
              color: NurrDesign.surface(widget.darkMode),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (offset) {
                final day = DateTime.now().subtract(Duration(days: 6 - offset));
                final count = day.day == DateTime.now().day
                    ? done
                    : (_history[_dayKey(day)] ?? 0);
                return Column(
                  children: [
                    Text(
                      ['M', 'D', 'M', 'D', 'F', 'S', 'S'][day.weekday - 1],
                      style: TextStyle(
                        color: NurrDesign.secondaryText(widget.darkMode),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      width: 30,
                      height: 54,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: widget.darkMode
                            ? Colors.white10
                            : NurrDesign.cream,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 30,
                        height: 8 + count * 8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [NurrDesign.goldDark, NurrDesign.gold],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _t(
              'Dein Lichtpfad im Monat',
              'Your monthly path of light',
              'طريق النور في شهرك',
            ),
            style: TextStyle(
              color: NurrDesign.text(widget.darkMode),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _MonthlyPrayerSky(
            history: _history,
            todayCompleted: done,
            darkMode: widget.darkMode,
          ),
        ],
      ),
    );
  }
}

class _PrayerMomentTile extends StatelessWidget {
  final int index;
  final String name;
  final bool active;
  final bool darkMode;
  final String languageCode;
  final String status;
  final bool hasNote;
  final VoidCallback onTap;
  final VoidCallback onDetails;
  const _PrayerMomentTile({
    required this.index,
    required this.name,
    required this.active,
    required this.darkMode,
    required this.languageCode,
    required this.status,
    required this.hasNote,
    required this.onTap,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.wb_twilight_rounded,
      Icons.wb_sunny_rounded,
      Icons.light_mode_rounded,
      Icons.nights_stay_rounded,
      Icons.dark_mode_rounded,
    ];
    final statusLabel = switch (status) {
      'completed' =>
        languageCode == 'ar'
            ? 'أُديت'
            : (languageCode == 'en' ? 'Prayed' : 'Verrichtet'),
      'congregation' =>
        languageCode == 'ar'
            ? 'جماعة'
            : (languageCode == 'en' ? 'Together' : 'Gemeinschaft'),
      'alone' =>
        languageCode == 'ar'
            ? 'منفردًا'
            : (languageCode == 'en' ? 'Alone' : 'Allein'),
      'made_up' =>
        languageCode == 'ar'
            ? 'قضاء'
            : (languageCode == 'en' ? 'Made up' : 'Nachgetragen'),
      _ =>
        languageCode == 'ar'
            ? 'تسجيل'
            : (languageCode == 'en' ? 'Add' : 'Eintragen'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active
                ? NurrDesign.gold.withValues(alpha: darkMode ? .18 : .13)
                : NurrDesign.surface(darkMode),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: active
                  ? NurrDesign.gold
                  : NurrDesign.gold.withValues(alpha: .15),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? NurrDesign.gold
                      : (darkMode ? Colors.white10 : NurrDesign.cream),
                  boxShadow: [
                    BoxShadow(
                      color: NurrDesign.gold.withValues(
                        alpha: active ? .35 : 0,
                      ),
                      blurRadius: active ? 16 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  icons[index],
                  color: active ? Colors.white : NurrDesign.goldDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: NurrDesign.text(darkMode),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                statusLabel,
                style: TextStyle(
                  color: active
                      ? NurrDesign.goldDark
                      : NurrDesign.secondaryText(darkMode),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              if (hasNote) ...[
                const Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: NurrDesign.goldDark,
                ),
                const SizedBox(width: 5),
              ],
              IconButton(
                tooltip: languageCode == 'de'
                    ? 'Details und Notiz'
                    : (languageCode == 'en'
                          ? 'Details and note'
                          : 'التفاصيل والملاحظة'),
                onPressed: onDetails,
                icon: const Icon(Icons.more_horiz_rounded),
                color: NurrDesign.secondaryText(darkMode),
              ),
              Icon(
                active ? Icons.auto_awesome : Icons.circle_outlined,
                color: active
                    ? NurrDesign.gold
                    : NurrDesign.secondaryText(darkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerSkyPainter extends CustomPainter {
  final double progress;
  final bool dark;
  final int completed;
  final int selectedPrayer;
  const _PrayerSkyPainter({
    required this.progress,
    required this.dark,
    required this.completed,
    required this.selectedPrayer,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final night = selectedPrayer == 4;
    if (night) {
      for (var i = 0; i < 20; i++) {
        final pulse = .45 + math.sin(progress * math.pi * 2 + i) * .25;
        canvas.drawCircle(
          Offset((i * 71.0) % size.width, 18 + (i * 31.0) % 125),
          i.isEven ? 1.8 : 1.1,
          Paint()..color = Colors.white.withValues(alpha: pulse),
        );
      }
    }
    final celestialX = 42.0 + selectedPrayer * (size.width - 84) / 4;
    final celestialY = selectedPrayer == 2
        ? 35.0
        : 78.0 - (2 - (selectedPrayer - 2).abs()) * 15;
    final celestial = Paint()
      ..color = night ? const Color(0xFFFFEDB2) : const Color(0xFFFFD56A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(celestialX, celestialY),
      night ? 17 : 20,
      celestial,
    );
    if (night) {
      canvas.drawCircle(
        Offset(celestialX + 7, celestialY - 5),
        16,
        Paint()..color = const Color(0xFF101B3D),
      );
    }

    final cloud = Paint()
      ..color = Colors.white.withValues(alpha: night ? .1 : .3);
    for (var i = 0; i < 2; i++) {
      final x = ((progress * 38 + i * 220) % (size.width + 90)) - 45;
      final y = 62.0 + i * 42;
      canvas.drawCircle(Offset(x, y), 15, cloud);
      canvas.drawCircle(Offset(x + 20, y), 21, cloud);
      canvas.drawCircle(Offset(x + 42, y + 2), 14, cloud);
    }

    final horizon = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .72)
      ..quadraticBezierTo(
        size.width * .3,
        size.height * .61,
        size.width * .55,
        size.height * .74,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .62,
        size.width,
        size.height * .7,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      horizon,
      Paint()..color = const Color(0xFF173E39).withValues(alpha: .94),
    );

    final mosqueX = size.width * .72;
    final mosqueBase = size.height * .9;
    canvas.drawRect(
      Rect.fromLTWH(mosqueX - 44, mosqueBase - 67, 88, 67),
      Paint()..color = const Color(0xFF122D2D),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(mosqueX, mosqueBase - 67),
        width: 88,
        height: 64,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF122D2D)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(mosqueX + 50, mosqueBase - 105, 13, 105),
      Paint()..color = const Color(0xFF122D2D),
    );
    canvas.drawCircle(
      Offset(mosqueX + 56.5, mosqueBase - 108),
      10,
      Paint()..color = const Color(0xFF122D2D),
    );
    for (var i = 0; i < 5; i++) {
      final lit = i < completed;
      final windowPaint = Paint()
        ..color = NurrDesign.gold.withValues(alpha: lit ? .95 : .16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lit ? 8 : 1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(mosqueX - 31 + i * 14, mosqueBase - 46, 8, 15),
          const Radius.circular(4),
        ),
        windowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PrayerSkyPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.dark != dark ||
      oldDelegate.completed != completed ||
      oldDelegate.selectedPrayer != selectedPrayer;
}

class _PrayerLightPath extends StatelessWidget {
  final int selected;
  final List<bool> completed;
  final List<String> names;
  final bool darkMode;
  final ValueChanged<int> onSelected;
  const _PrayerLightPath({
    required this.selected,
    required this.completed,
    required this.names,
    required this.darkMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: NurrDesign.card(color: NurrDesign.surface(darkMode)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 17,
            left: 28,
            right: 28,
            child: Container(
              height: 2,
              color: NurrDesign.gold.withValues(alpha: .2),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final lit = completed[index] || index == selected;
              return Expanded(
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lit
                              ? NurrDesign.gold
                              : NurrDesign.background(darkMode),
                          border: Border.all(color: NurrDesign.gold),
                          boxShadow: [
                            BoxShadow(
                              color: NurrDesign.gold.withValues(
                                alpha: lit ? .38 : 0,
                              ),
                              blurRadius: lit ? 15 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          completed[index]
                              ? Icons.check_rounded
                              : Icons.brightness_5_rounded,
                          size: 18,
                          color: lit ? Colors.white : NurrDesign.goldDark,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        names[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: NurrDesign.text(darkMode),
                          fontSize: 10,
                          fontWeight: index == selected
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MonthlyPrayerSky extends StatelessWidget {
  final Map<String, int> history;
  final int todayCompleted;
  final bool darkMode;
  const _MonthlyPrayerSky({
    required this.history,
    required this.todayCompleted,
    required this.darkMode,
  });

  String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month + 1, 0).day;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: darkMode
              ? const [Color(0xFF111A32), Color(0xFF251E35)]
              : const [Color(0xFFDEEAF8), Color(0xFFFFE5BA)],
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: days,
        itemBuilder: (context, index) {
          final date = DateTime(now.year, now.month, index + 1);
          final count = date.day == now.day
              ? todayCompleted
              : (history[_key(date)] ?? 0);
          final future = date.isAfter(DateTime(now.year, now.month, now.day));
          return TweenAnimationBuilder<double>(
            tween: Tween(end: future ? 0 : count / 5),
            duration: Duration(milliseconds: 300 + index * 18),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Tooltip(
              message: '${index + 1}: $count/5',
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    Colors.white.withValues(alpha: .08),
                    NurrDesign.gold.withValues(alpha: .85),
                    future ? 0 : value,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NurrDesign.gold.withValues(alpha: value * .45),
                      blurRadius: value * 14,
                    ),
                  ],
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: value > .55 ? Colors.white : Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SunnahHabitsPage extends StatefulWidget {
  final String languageCode;
  final bool darkMode;
  const SunnahHabitsPage({
    super.key,
    required this.languageCode,
    required this.darkMode,
  });
  @override
  State<SunnahHabitsPage> createState() => _SunnahHabitsPageState();
}

class _SunnahItem {
  final IconData icon;
  final Color color;
  final List<String> title;
  final List<String> description;
  final String source;
  final String category;
  const _SunnahItem(
    this.icon,
    this.color,
    this.title,
    this.description,
    this.source, {
    this.category = 'daily',
  });
}

class _SunnahHabitsPageState extends State<SunnahHabitsPage> {
  static const _items = <_SunnahItem>[
    _SunnahItem(
      Icons.restaurant_rounded,
      Color(0xFFD69B45),
      [
        'Bismillah beim Essen',
        'Say Bismillah before eating',
        'التسمية قبل الطعام',
      ],
      [
        'Beginne mit Allahs Namen, iss mit der rechten Hand und von dem, was dir am nächsten ist.',
        'Begin with Allah’s name, eat with your right hand, and eat from what is nearest to you.',
        'ابدأ باسم الله، وكُل بيمينك، وكُل مما يليك.',
      ],
      'Sahih al-Bukhari 5376',
    ),
    _SunnahItem(
      Icons.water_drop_rounded,
      Color(0xFF4E9BC8),
      [
        'In drei Atemzügen trinken',
        'Drink in three breaths',
        'الشرب على ثلاثة أنفاس',
      ],
      [
        'Trinke ruhig in mehreren Zügen und atme außerhalb des Gefäßes. Die Überlieferung nennt drei Atemzüge – nicht zwingend genau drei Schlucke.',
        'Drink calmly in several draughts and breathe away from the vessel. The narration mentions three breaths, not necessarily exactly three sips.',
        'اشرب بهدوء على دفعات، وتنفّس خارج الإناء. وردت ثلاثة أنفاس، وليس بالضرورة ثلاث رشفات فقط.',
      ],
      'Sahih Muslim 2028',
    ),
    _SunnahItem(
      Icons.waving_hand_rounded,
      Color(0xFF52A886),
      ['Salam verbreiten', 'Spread salam', 'إفشاء السلام'],
      [
        'Begrüße Menschen mit Salam und stärke damit Nähe und Verbundenheit.',
        'Greet people with salam and strengthen closeness and connection.',
        'ألقِ السلام على الناس وانشر المحبة والألفة.',
      ],
      'Sahih Muslim 54',
    ),
    _SunnahItem(
      Icons.sentiment_very_satisfied_rounded,
      Color(0xFFE6B84B),
      ['Schenke ein Lächeln', 'Share a smile', 'الابتسامة'],
      [
        'Ein aufrichtiges freundliches Gesicht ist eine einfache Form des Guten.',
        'A sincere friendly face is a simple form of goodness.',
        'الوجه البشوش الصادق باب يسير من أبواب الخير.',
      ],
      'Jami at-Tirmidhi 1956 (hasan)',
    ),
    _SunnahItem(
      Icons.bedtime_rounded,
      Color(0xFF7772B7),
      [
        'Auf der rechten Seite schlafen',
        'Sleep on your right side',
        'النوم على الجانب الأيمن',
      ],
      [
        'Lege dich nach dem Wudu auf deine rechte Seite und sprich die überlieferte Schlaf-Dua.',
        'After wudu, lie on your right side and say the transmitted sleep supplication.',
        'توضأ ثم اضطجع على شقك الأيمن وقل دعاء النوم المأثور.',
      ],
      'Sahih al-Bukhari 247',
    ),
    _SunnahItem(
      Icons.cleaning_services_rounded,
      Color(0xFF6AA596),
      ['Miswak nutzen', 'Use the miswak', 'استعمال السواك'],
      [
        'Pflege deinen Mund besonders vor dem Gebet. Der Prophet ﷺ betonte den Miswak sehr.',
        'Care for your mouth, especially before prayer. The Prophet ﷺ strongly encouraged the miswak.',
        'اعتنِ بنظافة فمك، وخاصة قبل الصلاة؛ فقد حث النبي ﷺ على السواك.',
      ],
      'Sahih al-Bukhari 887',
    ),
    _SunnahItem(
      Icons.volunteer_activism_rounded,
      Color(0xFFC36F77),
      ['Gutes sprechen', 'Speak good', 'قول الخير'],
      [
        'Sprich etwas Gutes – oder bewahre bewusstes Schweigen.',
        'Say something good—or choose mindful silence.',
        'قل خيرًا، أو اختر الصمت الواعي.',
      ],
      'Sahih al-Bukhari 6018',
    ),
    _SunnahItem(
      Icons.family_restroom_rounded,
      Color(0xFFB98052),
      ['Freundlich zur Familie', 'Be kind to family', 'الإحسان إلى الأهل'],
      [
        'Zeige deine beste Seite zuerst den Menschen, mit denen du täglich lebst.',
        'Show your best character first to the people you live with every day.',
        'أظهر أحسن أخلاقك أولًا لمن تعيش معهم كل يوم.',
      ],
      'Jami at-Tirmidhi 3895 (sahih)',
    ),
    _SunnahItem(
      Icons.bed_rounded,
      Color(0xFF596A9D),
      [
        'Bett vor dem Schlafen abstreichen',
        'Dust the bed before sleep',
        'نفض الفراش قبل النوم',
      ],
      [
        'Streiche das Bett vor dem Hinlegen mit der Innenseite deines Gewandes ab.',
        'Dust your bed with the inside of your garment before lying down.',
        'انفض فراشك بداخلة إزارك قبل أن تضطجع.',
      ],
      'Sahih al-Bukhari 6320',
    ),
    _SunnahItem(
      Icons.wb_sunny_outlined,
      Color(0xFFE0A339),
      [
        'Allah nach dem Aufwachen loben',
        'Praise Allah after waking',
        'حمد الله عند الاستيقاظ',
      ],
      [
        'Beginne den neuen Tag mit dem überlieferten Lobpreis für Allah.',
        'Begin the new day with the transmitted praise of Allah.',
        'ابدأ يومك بحمد الله بالدعاء المأثور.',
      ],
      'Sahih al-Bukhari 6312',
    ),
    _SunnahItem(
      Icons.door_front_door_rounded,
      Color(0xFF65947A),
      [
        'Beim Betreten des Hauses Allah erwähnen',
        'Mention Allah when entering home',
        'ذكر الله عند دخول المنزل',
      ],
      [
        'Erwähne Allah beim Betreten und beim Essen.',
        'Mention Allah when entering your home and when eating.',
        'اذكر الله عند دخول البيت وعند الطعام.',
      ],
      'Sahih Muslim 2018',
    ),
    _SunnahItem(
      Icons.checkroom_rounded,
      Color(0xFF987B58),
      [
        'Rechts mit dem Anziehen beginnen',
        'Dress beginning with the right',
        'التيامن في اللباس',
      ],
      [
        'Beginne beim Anziehen und bei guten Handlungen bevorzugt mit der rechten Seite.',
        'Begin dressing and honorable actions with the right side.',
        'ابدأ باليمين في اللباس والأمور الكريمة.',
      ],
      'Sahih al-Bukhari 168',
    ),
    _SunnahItem(
      Icons.favorite_border_rounded,
      Color(0xFFC27878),
      [
        'Für andere im Verborgenen Dua machen',
        'Make dua for others privately',
        'الدعاء للآخرين بظهر الغيب',
      ],
      [
        'Bitte Allah im Verborgenen um Gutes für einen anderen Muslim.',
        'Privately ask Allah to grant goodness to another Muslim.',
        'ادعُ لأخيك المسلم بظهر الغيب بالخير.',
      ],
      'Sahih Muslim 2732',
    ),
    _SunnahItem(
      Icons.clean_hands_rounded,
      Color(0xFF488FA0),
      ['Wudu sorgfältig verrichten', 'Perform wudu carefully', 'إسباغ الوضوء'],
      [
        'Vervollständige den Wudu ruhig und sorgfältig.',
        'Complete wudu calmly and carefully.',
        'أسبغ الوضوء بهدوء وعناية.',
      ],
      'Sahih Muslim 223',
    ),
    _SunnahItem(
      Icons.chair_alt_rounded,
      Color(0xFF8D735D),
      ['Im Sitzen trinken', 'Drink while seated', 'الشرب جالسًا'],
      [
        'Trinke nach Möglichkeit ruhig im Sitzen.',
        'When possible, drink calmly while seated.',
        'اشرب جالسًا بهدوء ما أمكن.',
      ],
      'Sahih Muslim 2024',
    ),
    _SunnahItem(
      Icons.auto_awesome_rounded,
      Color(0xFF8B75B5),
      [
        'Vor dem Schlafen Tasbih sprechen',
        'Recite tasbih before sleep',
        'تسبيح فاطمة قبل النوم',
      ],
      [
        'Sprich vor dem Schlafen 33-mal SubhanAllah, 33-mal Alhamdulillah und 34-mal Allahu Akbar.',
        'Before sleep say SubhanAllah 33 times, Alhamdulillah 33 times, and Allahu Akbar 34 times.',
        'قل قبل النوم: سبحان الله ٣٣، والحمد لله ٣٣، والله أكبر ٣٤.',
      ],
      'Sahih al-Bukhari 6318',
      category: 'sleep',
    ),
    _SunnahItem(
      Icons.thumb_up_alt_rounded,
      Color(0xFFD59A3D),
      [
        'Allah nach dem Essen loben',
        'Praise Allah after eating',
        'حمد الله بعد الطعام',
      ],
      [
        'Sage nach dem Essen bewusst Alhamdulillah.',
        'Consciously say Alhamdulillah after eating.',
        'قل الحمد لله بعد الطعام بقلب حاضر.',
      ],
      'Jami at-Tirmidhi 3458 (hasan)',
      category: 'food',
    ),
    _SunnahItem(
      Icons.cleaning_services_outlined,
      Color(0xFF6CA987),
      [
        'Einen gefallenen Bissen aufheben',
        'Pick up a fallen morsel',
        'رفع اللقمة الساقطة',
      ],
      [
        'Entferne Schmutz von einem gefallenen Bissen und verschwende ihn nicht.',
        'Remove any dirt from a fallen morsel and do not waste it.',
        'أزل الأذى عن اللقمة الساقطة ولا تتركها.',
      ],
      'Sahih Muslim 2033',
      category: 'food',
    ),
    _SunnahItem(
      Icons.directions_walk_rounded,
      Color(0xFF4D9279),
      [
        'Schaden vom Weg entfernen',
        'Remove harm from the road',
        'إماطة الأذى عن الطريق',
      ],
      [
        'Räume etwas Gefährliches oder Störendes aus dem Weg.',
        'Remove something harmful or obstructive from the path.',
        'أزل ما يؤذي الناس من الطريق.',
      ],
      'Sahih Muslim 1009',
      category: 'character',
    ),
    _SunnahItem(
      Icons.sick_rounded,
      Color(0xFF6B8FC1),
      ['Kranke besuchen', 'Visit the sick', 'عيادة المريض'],
      [
        'Schenke einem kranken Menschen Zeit, Trost und eine Dua.',
        'Give a sick person time, comfort, and a supplication.',
        'زُر المريض وواسِه وادعُ له.',
      ],
      'Sahih al-Bukhari 5649',
      category: 'community',
    ),
    _SunnahItem(
      Icons.mosque_rounded,
      Color(0xFF4C8B78),
      [
        'Zwei Rakʿah beim Moscheebesuch',
        'Two rakʿahs when entering a mosque',
        'ركعتا تحية المسجد',
      ],
      [
        'Setze dich in der Moschee erst nach zwei Rakʿah.',
        'Before sitting in the mosque, pray two rakʿahs.',
        'إذا دخلت المسجد فصل ركعتين قبل الجلوس.',
      ],
      'Sahih al-Bukhari 444',
      category: 'worship',
    ),
    _SunnahItem(
      Icons.bedtime_outlined,
      Color(0xFF7269AB),
      [
        'Āyat al-Kursī vor dem Schlafen',
        'Ayat al-Kursi before sleep',
        'آية الكرسي قبل النوم',
      ],
      [
        'Lies vor dem Schlafen Āyat al-Kursī.',
        'Recite Ayat al-Kursi before sleeping.',
        'اقرأ آية الكرسي قبل النوم.',
      ],
      'Sahih al-Bukhari 2311',
      category: 'sleep',
    ),
    _SunnahItem(
      Icons.auto_stories_rounded,
      Color(0xFF8072B5),
      [
        'Die letzten zwei Verse der Baqarah',
        'Last two verses of Al-Baqarah',
        'آخر آيتين من البقرة',
      ],
      [
        'Lies nachts die letzten zwei Verse der Sure Al-Baqarah.',
        'Recite the last two verses of Surah Al-Baqarah at night.',
        'اقرأ آخر آيتين من سورة البقرة في الليل.',
      ],
      'Sahih al-Bukhari 5009',
      category: 'evening',
    ),
    _SunnahItem(
      Icons.shield_moon_rounded,
      Color(0xFF6570A5),
      [
        'Die drei Schutzsuren lesen',
        'Recite the three protective surahs',
        'قراءة المعوذات',
      ],
      [
        'Lies vor dem Schlafen Al-Ikhlāṣ, Al-Falaq und An-Nās.',
        'Before sleep, recite Al-Ikhlas, Al-Falaq, and An-Nas.',
        'اقرأ الإخلاص والفلق والناس قبل النوم.',
      ],
      'Sahih al-Bukhari 5017',
      category: 'sleep',
    ),
    _SunnahItem(
      Icons.wb_twilight_rounded,
      Color(0xFFE0A13D),
      ['Sayyid al-Istighfār', 'Sayyid al-Istighfar', 'سيد الاستغفار'],
      [
        'Sprich die überlieferte Dua morgens oder abends mit Überzeugung.',
        'Recite the transmitted supplication morning or evening with conviction.',
        'قل سيد الاستغفار صباحًا أو مساءً موقنًا به.',
      ],
      'Sahih al-Bukhari 6306',
      category: 'morning',
    ),
    _SunnahItem(
      Icons.air_rounded,
      Color(0xFF4F9FA2),
      ['Adab beim Niesen', 'Etiquette of sneezing', 'أدب العطاس'],
      [
        'Sage Alhamdulillah; antworte einem Niesenden mit YarhamukAllah.',
        'Say Alhamdulillah; reply to a sneezer with YarhamukAllah.',
        'قل الحمد لله، وشمّت العاطس بقول يرحمك الله.',
      ],
      'Sahih al-Bukhari 6224',
      category: 'daily',
    ),
    _SunnahItem(
      Icons.ice_skating_rounded,
      Color(0xFF98765A),
      [
        'Schuhe rechts anziehen',
        'Put the right shoe on first',
        'التيامن في لبس النعل',
      ],
      [
        'Ziehe den rechten Schuh zuerst an und den linken zuerst aus.',
        'Put the right shoe on first and remove the left one first.',
        'ابدأ باليمين عند لبس النعل وباليسار عند خلعه.',
      ],
      'Sahih al-Bukhari 5855',
      category: 'daily',
    ),
    _SunnahItem(
      Icons.door_back_door_rounded,
      Color(0xFF648D78),
      [
        'Dua beim Verlassen des Hauses',
        'Dua when leaving home',
        'دعاء الخروج من المنزل',
      ],
      [
        'Sprich beim Hinausgehen: Bismillah, tawakkaltu ʿalAllah …',
        'When leaving, say: Bismillah, tawakkaltu alAllah …',
        'قل عند الخروج: بسم الله، توكلت على الله …',
      ],
      'Sunan Abi Dawud 5095 (sahih)',
      category: 'daily',
    ),
    _SunnahItem(
      Icons.calendar_month_rounded,
      Color(0xFFB08746),
      [
        'Freitags Ghusl verrichten',
        'Perform ghusl on Friday',
        'غسل يوم الجمعة',
      ],
      [
        'Bereite dich am Freitag mit der Ganzkörperwaschung auf das Gebet vor.',
        'Prepare for Friday prayer with the ritual bath.',
        'اغتسل يوم الجمعة استعدادًا للصلاة.',
      ],
      'Sahih al-Bukhari 877',
      category: 'worship',
    ),
    _SunnahItem(
      Icons.favorite_rounded,
      Color(0xFFC27C83),
      [
        'Salawāt am Freitag vermehren',
        'Increase salawat on Friday',
        'الإكثار من الصلاة على النبي يوم الجمعة',
      ],
      [
        'Sprich am Freitag öfter Segenswünsche für den Propheten ﷺ.',
        'Send more blessings upon the Prophet ﷺ on Friday.',
        'أكثر من الصلاة على النبي ﷺ يوم الجمعة.',
      ],
      'Sunan Abi Dawud 1047 (sahih)',
      category: 'worship',
    ),
  ];

  Set<int> _done = {};
  Map<int, String> _notes = {};
  Set<int> _favorites = {};
  Set<int> _weekPlan = {};
  List<String> _customReminders = [];
  Set<int> _customDone = {};
  String _category = 'all';
  int _gardenGrowth = 0;
  String _t(List<String> values) =>
      values[widget.languageCode == 'ar'
          ? 2
          : (widget.languageCode == 'en' ? 1 : 0)];

  String _categoryFor(int index) {
    const originalCategories = <String>[
      'food',
      'food',
      'community',
      'character',
      'sleep',
      'worship',
      'character',
      'community',
      'sleep',
      'morning',
      'daily',
      'daily',
      'community',
      'worship',
      'food',
      'sleep',
    ];
    return index < originalCategories.length
        ? originalCategories[index]
        : _items[index].category;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('nurr_sunnah_${_dayKey()}') ?? [];
    final favorites = prefs.getStringList('nurr_sunnah_favorites') ?? [];
    final weekPlan = prefs.getStringList('nurr_sunnah_week_plan') ?? [];
    final custom = prefs.getStringList('nurr_sunnah_custom') ?? [];
    final customDone =
        prefs.getStringList('nurr_sunnah_custom_${_dayKey()}') ?? [];
    final notes = <int, String>{};
    for (var i = 0; i < _items.length; i++) {
      final note = prefs.getString('nurr_sunnah_note_$i') ?? '';
      if (note.isNotEmpty) notes[i] = note;
    }
    if (mounted) {
      setState(() {
        _done = raw.map(int.parse).toSet();
        _notes = notes;
        _favorites = favorites.map(int.parse).toSet();
        _weekPlan = weekPlan.map(int.parse).toSet();
        _gardenGrowth = prefs.getInt('nurr_sunnah_garden_growth') ?? 0;
        _customReminders = custom;
        _customDone = customDone.map(int.parse).toSet();
      });
    }
    if (!(prefs.getBool('nurr_sunnah_intro_seen') ?? false) && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSunnahIntro());
    }
  }

  Future<void> _showSunnahIntro() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NurrDesign.surface(widget.darkMode),
        surfaceTintColor: Colors.transparent,
        icon: const Icon(
          Icons.favorite_rounded,
          color: NurrDesign.gold,
          size: 38,
        ),
        title: Text(
          _t([
            'Lass die Sunnah deinen Alltag verschönern',
            'Let the Sunnah beautify your daily life',
            'دع السنة تجمّل حياتك اليومية',
          ]),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: NurrDesign.text(widget.darkMode),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t([
                  'Allah nennt den Propheten Muhammad ﷺ für die Gläubigen ein schönes Vorbild und beschreibt seinen großartigen Charakter. Seine authentisch überlieferte Sunnah zeigt, wie Glaube im Alltag gelebt werden kann: mit Barmherzigkeit, Geduld, Dankbarkeit, Sauberkeit und gutem Umgang.\n\nDiese Seite ist eine freundliche Erinnerung – keine Bewertung deines Glaubens und keine Berechnung von Lohn. Wähle freiwillige Sunnahs, die du bewusst und aufrichtig leben möchtest. Mit kleinen, beständigen Schritten darf auch dein Charakter wachsen.',
                  'Allah calls Prophet Muhammad ﷺ a beautiful example for believers and describes his outstanding character. His authentically transmitted Sunnah shows how faith can be lived daily: with mercy, patience, gratitude, cleanliness, and beautiful conduct.\n\nThis page is a gentle reminder—not a judgment of faith or a calculation of reward. Choose voluntary Sunnahs you wish to practice consciously and sincerely. Small, steady steps can help good character grow.',
                  'ذكر الله أن النبي محمدًا ﷺ أسوة حسنة للمؤمنين، ووصفه بالخُلُق العظيم. وتبين سنته الصحيحة كيف نعيش الإيمان في يومنا بالرحمة والصبر والشكر والنظافة وحسن المعاملة.\n\nهذه الصفحة تذكير لطيف، وليست حكمًا على الإيمان ولا حسابًا للأجر. اختر من السنن المستحبة ما تريد تطبيقه بوعي وإخلاص، فبالخطوات الصغيرة الدائمة تنمو الأخلاق الحسنة.',
                ]),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NurrDesign.text(widget.darkMode),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _t([
                  'Quran 33:21 · Quran 68:4',
                  'Quran 33:21 · Quran 68:4',
                  'القرآن ٣٣:٢١ · القرآن ٦٨:٤',
                ]),
                style: const TextStyle(
                  color: NurrDesign.goldDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _t([
                'Meine erste Sunnah entdecken',
                'Discover my first Sunnah',
                'اكتشف أول سنة',
              ]),
            ),
          ),
        ],
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nurr_sunnah_intro_seen', true);
  }

  Future<void> _openGarden() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SunnahGardenPage(
          languageCode: widget.languageCode,
          darkMode: widget.darkMode,
          completed: _done.length,
          total: 40,
          growth: _gardenGrowth,
        ),
      ),
    );
  }

  Future<void> _toggle(int index) async {
    final next = {..._done};
    if (!next.add(index)) {
      next.remove(index);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nurr_sunnah_${_dayKey()}',
      next.map((e) => '$e').toList(),
    );
    var growth = prefs.getInt('nurr_sunnah_garden_growth') ?? 0;
    final earned = prefs.getStringList('nurr_sunnah_garden_earned') ?? [];
    final token = '${_dayKey()}:$index';
    if (next.contains(index) && !earned.contains(token)) {
      earned.add(token);
      growth++;
      await prefs.setStringList('nurr_sunnah_garden_earned', earned);
      await prefs.setInt('nurr_sunnah_garden_growth', growth);
    }
    if (mounted) {
      setState(() {
        _done = next;
        _gardenGrowth = growth;
      });
    }
  }

  Future<void> _toggleFavorite(int index) async {
    final next = {..._favorites};
    next.contains(index) ? next.remove(index) : next.add(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nurr_sunnah_favorites',
      next.map((e) => '$e').toList(),
    );
    if (mounted) setState(() => _favorites = next);
  }

  Future<void> _toggleWeekPlan(int index) async {
    final next = {..._weekPlan};
    if (next.contains(index)) {
      next.remove(index);
    } else if (next.length < 5) {
      next.add(index);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t([
              'Wähle höchstens fünf Sunnahs.',
              'Choose up to five Sunnahs.',
              'اختر خمس سنن كحد أقصى.',
            ]),
          ),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nurr_sunnah_week_plan',
      next.map((e) => '$e').toList(),
    );
    if (mounted) setState(() => _weekPlan = next);
  }

  void _showSource(int index) {
    final item = _items[index];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: NurrDesign.surface(widget.darkMode),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: item.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _t(item.title),
                      style: TextStyle(
                        color: NurrDesign.text(widget.darkMode),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _t(item.description),
                style: TextStyle(
                  color: NurrDesign.text(widget.darkMode),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NurrDesign.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: NurrDesign.goldDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.source,
                        style: TextStyle(
                          color: NurrDesign.text(widget.darkMode),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t([
                  'Der Text ist eine kurze Alltagserklärung der genannten Überlieferung. Öffne die Referenz in einer verlässlichen Hadith-Ausgabe für Wortlaut und Einordnung.',
                  'This is a short practical summary of the cited narration. Consult a reliable hadith edition for its full wording and context.',
                  'هذا شرح عملي مختصر للرواية المذكورة. راجع مصدرًا موثوقًا للحديث لمعرفة النص الكامل والسياق.',
                ]),
                style: TextStyle(
                  color: NurrDesign.secondaryText(widget.darkMode),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCustomReminder() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NurrDesign.surface(widget.darkMode),
        icon: const Icon(Icons.add_task_rounded, color: NurrDesign.goldDark),
        title: Text(
          _t(['Eigene Erinnerung', 'Personal reminder', 'تذكير شخصي']),
          style: TextStyle(color: NurrDesign.text(widget.darkMode)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLength: 80,
              autofocus: true,
              style: TextStyle(color: NurrDesign.text(widget.darkMode)),
              decoration: InputDecoration(
                hintText: _t([
                  'Zum Beispiel: Eltern anrufen',
                  'For example: call my parents',
                  'مثال: الاتصال بوالديّ',
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t([
                'Eigene Einträge sind persönliche Erinnerungen und werden nicht automatisch als überlieferte Sunnah bezeichnet.',
                'Personal entries are reminders and are not automatically presented as transmitted Sunnahs.',
                'الإضافات الشخصية تذكيرات خاصة ولا تُعرض تلقائيًا على أنها سنة ثابتة.',
              ]),
              style: TextStyle(
                color: NurrDesign.secondaryText(widget.darkMode),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(['Abbrechen', 'Cancel', 'إلغاء'])),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(_t(['Hinzufügen', 'Add', 'إضافة'])),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) return;
    final next = [..._customReminders, value];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('nurr_sunnah_custom', next);
    if (mounted) setState(() => _customReminders = next);
  }

  Future<void> _toggleCustom(int index) async {
    final next = {..._customDone};
    next.contains(index) ? next.remove(index) : next.add(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nurr_sunnah_custom_${_dayKey()}',
      next.map((e) => '$e').toList(),
    );
    if (mounted) setState(() => _customDone = next);
  }

  Future<void> _editNote(int index) async {
    final controller = TextEditingController(text: _notes[index] ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NurrDesign.surface(widget.darkMode),
        title: Text(
          _t(['Persönliche Notiz', 'Personal note', 'ملاحظة شخصية']),
          style: TextStyle(color: NurrDesign.text(widget.darkMode)),
        ),
        content: TextField(
          controller: controller,
          maxLength: 240,
          maxLines: 4,
          style: TextStyle(color: NurrDesign.text(widget.darkMode)),
          decoration: InputDecoration(
            hintText: _t([
              'Was möchtest du dir dazu merken?',
              'What would you like to remember?',
              'ماذا تريد أن تتذكر؟',
            ]),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(['Abbrechen', 'Cancel', 'إلغاء'])),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(_t(['Speichern', 'Save', 'حفظ'])),
          ),
        ],
      ),
    );
    if (result == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nurr_sunnah_note_$index', result);
    if (!mounted) return;
    setState(() {
      if (result.isEmpty) {
        _notes.remove(index);
      } else {
        _notes[index] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = <(String, IconData, List<String>)>[
      ('all', Icons.grid_view_rounded, ['Alle', 'All', 'الكل']),
      (
        'favorites',
        Icons.favorite_rounded,
        ['Favoriten', 'Favorites', 'المفضلة'],
      ),
      ('daily', Icons.wb_sunny_rounded, ['Alltag', 'Daily life', 'اليوم']),
      ('food', Icons.restaurant_rounded, ['Essen', 'Food', 'الطعام']),
      ('morning', Icons.wb_twilight_rounded, ['Morgen', 'Morning', 'الصباح']),
      ('evening', Icons.nights_stay_rounded, ['Abend', 'Evening', 'المساء']),
      ('sleep', Icons.bedtime_rounded, ['Schlafen', 'Sleep', 'النوم']),
      ('worship', Icons.mosque_rounded, ['Ibadah', 'Worship', 'العبادة']),
      (
        'character',
        Icons.volunteer_activism_rounded,
        ['Charakter', 'Character', 'الأخلاق'],
      ),
      (
        'community',
        Icons.groups_rounded,
        ['Miteinander', 'Community', 'المجتمع'],
      ),
    ];
    final visible = List<int>.generate(_items.length, (i) => i).where((i) {
      if (_category == 'all') return true;
      if (_category == 'favorites') return _favorites.contains(i);
      return _categoryFor(i) == _category;
    }).toList();
    final weekIndex =
        (DateTime.now().difference(DateTime(DateTime.now().year)).inDays ~/ 7) %
        _items.length;
    return Scaffold(
      backgroundColor: NurrDesign.background(widget.darkMode),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: NurrDesign.text(widget.darkMode),
        title: Text(_t(['Sunnahs im Alltag', 'Everyday Sunnahs', 'سنن يومية'])),
        actions: [
          IconButton(
            tooltip: _t([
              'Eigene Erinnerung',
              'Personal reminder',
              'تذكير شخصي',
            ]),
            onPressed: _addCustomReminder,
            icon: const Icon(Icons.add_task_rounded),
          ),
          IconButton(
            onPressed: _showSunnahIntro,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
              child: _SunnahHero(
                done: _done.length,
                total: _items.length,
                darkMode: widget.darkMode,
                languageCode: widget.languageCode,
                onOpenGarden: _openGarden,
              ),
            ),
          ),
          if (_customReminders.isNotEmpty &&
              (_category == 'all' || _category == 'favorites'))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NurrDesign.surface(widget.darkMode),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: NurrDesign.gold.withValues(alpha: .2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(['Meine Erinnerungen', 'My reminders', 'تذكيراتي']),
                        style: TextStyle(
                          color: NurrDesign.text(widget.darkMode),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        _customReminders.length,
                        (i) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _customDone.contains(i),
                          onChanged: (_) => _toggleCustom(i),
                          activeColor: NurrDesign.emerald,
                          title: Text(
                            _customReminders[i],
                            style: TextStyle(
                              color: NurrDesign.text(widget.darkMode),
                              decoration: _customDone.contains(i)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            _t([
                              'Persönliche Erinnerung',
                              'Personal reminder',
                              'تذكير شخصي',
                            ]),
                            style: TextStyle(
                              color: NurrDesign.secondaryText(widget.darkMode),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NurrDesign.gold.withValues(
                        alpha: widget.darkMode ? .22 : .16,
                      ),
                      NurrDesign.emerald.withValues(
                        alpha: widget.darkMode ? .18 : .09,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: NurrDesign.gold.withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: NurrDesign.gold.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: NurrDesign.goldDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t([
                              'Sunnah der Woche',
                              'Sunnah of the week',
                              'سنة الأسبوع',
                            ]),
                            style: const TextStyle(
                              color: NurrDesign.goldDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _t(_items[weekIndex].title),
                            style: TextStyle(
                              color: NurrDesign.text(widget.darkMode),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleWeekPlan(weekIndex),
                      icon: Icon(
                        _weekPlan.contains(weekIndex)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_add_outlined,
                        color: NurrDesign.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final entry = categories[i];
                  return ChoiceChip(
                    selected: _category == entry.$1,
                    avatar: Icon(entry.$2, size: 17),
                    label: Text(_t(entry.$3)),
                    onSelected: (_) => setState(() => _category = entry.$1),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _t(['Deine Sunnahs', 'Your Sunnahs', 'سننك']),
                      style: TextStyle(
                        color: NurrDesign.text(widget.darkMode),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${_done.length}/${_items.length}',
                    style: const TextStyle(
                      color: NurrDesign.goldDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent >= 760 ? 2 : 1;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 282,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final itemIndex = visible[index];
                    final item = _items[itemIndex];
                    final active = _done.contains(itemIndex);
                    return _SunnahCard(
                      item: item,
                      active: active,
                      darkMode: widget.darkMode,
                      title: _t(item.title),
                      description: _t(item.description),
                      doneLabel: _t([
                        'Heute umgesetzt',
                        'Practiced today',
                        'طبقتها اليوم',
                      ]),
                      hasNote: (_notes[itemIndex] ?? '').isNotEmpty,
                      favorite: _favorites.contains(itemIndex),
                      inWeekPlan: _weekPlan.contains(itemIndex),
                      noteLabel: _t(['Notiz', 'Note', 'ملاحظة']),
                      onNote: () => _editNote(itemIndex),
                      onFavorite: () => _toggleFavorite(itemIndex),
                      onWeekPlan: () => _toggleWeekPlan(itemIndex),
                      onSource: () => _showSource(itemIndex),
                      onTap: () => _toggle(itemIndex),
                    );
                  }, childCount: visible.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SunnahGardenPage extends StatefulWidget {
  final String languageCode;
  final bool darkMode;
  final int completed;
  final int total;
  final int growth;

  const SunnahGardenPage({
    super.key,
    required this.languageCode,
    required this.darkMode,
    required this.completed,
    required this.total,
    required this.growth,
  });

  @override
  State<SunnahGardenPage> createState() => _SunnahGardenPageState();
}

enum _GardenAction {
  automatic,
  quran,
  prayer,
  dhikr,
  watering,
  resting,
  sleeping,
}

class _SunnahGardenPageState extends State<SunnahGardenPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wind;
  _GardenAction _action = _GardenAction.automatic;

  String _t(String de, String en, String ar) => widget.languageCode == 'ar'
      ? ar
      : (widget.languageCode == 'en' ? en : de);

  @override
  void initState() {
    super.initState();
    _wind = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _showGardenIntro();
  }

  Future<void> _showGardenIntro({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!force && (prefs.getBool('nurr_sunnah_garden_intro_seen') ?? false)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: NurrDesign.surface(widget.darkMode),
          surfaceTintColor: Colors.transparent,
          icon: const Icon(
            Icons.local_florist_rounded,
            color: NurrDesign.gold,
            size: 42,
          ),
          title: Text(
            _t(
              'Das ist dein Sunnah-Garten',
              'This is your Sunnah garden',
              'هذه حديقة السنن الخاصة بك',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NurrDesign.text(widget.darkMode),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            _t(
              'Jede Sunnah, die du heute bewusst lebst, lässt deinen Garten wachsen. Neue Blätter, Blumen und warmes Licht erscheinen. Es geht nicht um einen Wettbewerb – der Garten soll dich freundlich daran erinnern, wie aus kleinen guten Gewohnheiten etwas Schönes entsteht.',
              'Every Sunnah you consciously practice today helps your garden grow. New leaves, flowers, and warm light appear. This is not a competition—the garden is a gentle reminder that small good habits can grow into something beautiful.',
              'كل سنة تطبقها بوعي اليوم تساعد حديقتك على النمو. تظهر أوراق وزهور وأنوار دافئة جديدة. ليست مسابقة، بل تذكير لطيف بأن العادات الطيبة الصغيرة تنمو لتصبح شيئًا جميلًا.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NurrDesign.text(widget.darkMode),
              height: 1.55,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _t('Garten entdecken', 'Explore garden', 'استكشف الحديقة'),
              ),
            ),
          ],
        ),
      );
      await prefs.setBool('nurr_sunnah_garden_intro_seen', true);
    });
  }

  @override
  void dispose() {
    _wind.dispose();
    super.dispose();
  }

  String _actionLabel(_GardenAction action) => switch (action) {
    _GardenAction.automatic => _t('Automatisch', 'Automatic', 'تلقائي'),
    _GardenAction.quran => _t('Quran lesen', 'Read Quran', 'قراءة القرآن'),
    _GardenAction.prayer => _t('Beten', 'Pray', 'الصلاة'),
    _GardenAction.dhikr => _t('Dhikr machen', 'Make dhikr', 'الذكر'),
    _GardenAction.watering => _t(
      'Garten gießen',
      'Water garden',
      'سقي الحديقة',
    ),
    _GardenAction.resting => _t('Ausruhen', 'Rest', 'الاستراحة'),
    _GardenAction.sleeping => _t('Schlafen', 'Sleep', 'النوم'),
  };

  Future<void> _chooseAction() async {
    final selected = await showModalBottomSheet<_GardenAction>(
      context: context,
      backgroundColor: NurrDesign.surface(widget.darkMode),
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _t('Animation ansehen', 'Preview animation', 'معاينة الحركة'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NurrDesign.text(widget.darkMode),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _GardenAction.values
                    .where((action) => action != _GardenAction.prayer)
                    .map((action) {
                      final icon = switch (action) {
                        _GardenAction.automatic => Icons.auto_awesome_rounded,
                        _GardenAction.quran => Icons.menu_book_rounded,
                        _GardenAction.prayer => Icons.mosque_rounded,
                        _GardenAction.dhikr =>
                          Icons.radio_button_checked_rounded,
                        _GardenAction.watering => Icons.water_drop_rounded,
                        _GardenAction.resting => Icons.park_rounded,
                        _GardenAction.sleeping => Icons.bedtime_rounded,
                      };
                      return ChoiceChip(
                        selected: _action == action,
                        avatar: Icon(icon, size: 18),
                        label: Text(_actionLabel(action)),
                        onSelected: (_) => Navigator.pop(context, action),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _action = selected);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.total == 0
        ? 0.0
        : (widget.growth / widget.total).clamp(0.0, 1.0);
    final season = (widget.growth ~/ 10) % 4;
    final sky = switch (season) {
      1 => const [
        Color(0xFF72C7E7),
        Color(0xFFFFE4A3),
        Color(0xFF5AA55B),
        Color(0xFF287247),
      ],
      2 => const [
        Color(0xFF91C4D8),
        Color(0xFFFFD09A),
        Color(0xFF8FA54B),
        Color(0xFF58713D),
      ],
      3 => const [
        Color(0xFF9AB7D7),
        Color(0xFFE6EDF5),
        Color(0xFF789D75),
        Color(0xFF3F704F),
      ],
      _ => const [
        Color(0xFF8FD3E8),
        Color(0xFFDDF2CF),
        Color(0xFF4F9B52),
        Color(0xFF267044),
      ],
    };
    return Scaffold(
      backgroundColor: NurrDesign.background(widget.darkMode),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: NurrDesign.text(widget.darkMode),
        title: Text(
          _t('Mein Sunnah-Garten', 'My Sunnah garden', 'حديقة السنن'),
        ),
        actions: [
          IconButton(
            onPressed: () => _showGardenIntro(force: true),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: AnimatedBuilder(
                  animation: _wind,
                  builder: (context, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: sky,
                            stops: [0, .43, .44, 1],
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: _GrowingGardenPainter(
                          progress: progress,
                          wind: _wind.value,
                          action: _action,
                        ),
                      ),
                      PositionedDirectional(
                        top: 18,
                        end: 18,
                        child: _GardenActivityBadge(
                          languageCode: widget.languageCode,
                          action: _action,
                        ),
                      ),
                      PositionedDirectional(
                        start: 18,
                        top: 18,
                        child: FilledButton.tonalIcon(
                          onPressed: _chooseAction,
                          icon: const Icon(
                            Icons.play_circle_outline_rounded,
                            size: 18,
                          ),
                          label: Text(_t('Testen', 'Preview', 'جرّب')),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color:
                                (widget.darkMode ? Colors.black : Colors.white)
                                    .withValues(alpha: .82),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: NurrDesign.gold.withValues(alpha: .35),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _t(
                                  'Dein Garten ist durch ${widget.growth} Sunnah-Schritte gewachsen',
                                  'Your garden has grown through ${widget.growth} Sunnah steps',
                                  'نمت حديقتك مع ${widget.growth} خطوات من السنة',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: NurrDesign.text(widget.darkMode),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 9),
                              TweenAnimationBuilder<double>(
                                tween: Tween(end: progress),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) =>
                                    LinearProgressIndicator(
                                      value: value,
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(20),
                                      backgroundColor: NurrDesign.gold
                                          .withValues(alpha: .15),
                                      color: NurrDesign.gold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children:
                  [
                        (
                          5,
                          Icons.local_florist_rounded,
                          _t('Blumenbeet', 'Flower bed', 'حوض الزهور'),
                        ),
                        (
                          12,
                          Icons.alt_route_rounded,
                          _t('Gartenweg', 'Garden path', 'ممر الحديقة'),
                        ),
                        (
                          20,
                          Icons.light_rounded,
                          _t('Laternen', 'Lanterns', 'الفوانيس'),
                        ),
                        (
                          30,
                          Icons.park_rounded,
                          _t('Obstbäume', 'Fruit trees', 'أشجار مثمرة'),
                        ),
                      ]
                      .map(
                        (reward) => Chip(
                          avatar: Icon(
                            reward.$2,
                            size: 17,
                            color: widget.growth >= reward.$1
                                ? NurrDesign.goldDark
                                : NurrDesign.secondaryText(widget.darkMode),
                          ),
                          label: Text(
                            widget.growth >= reward.$1
                                ? reward.$3
                                : '${reward.$1} · ${reward.$3}',
                          ),
                          backgroundColor: widget.growth >= reward.$1
                              ? NurrDesign.gold.withValues(alpha: .15)
                              : NurrDesign.surface(widget.darkMode),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),
            Text(
              _t(
                'Kleine Gewohnheiten dürfen in Ruhe wachsen.',
                'Small habits are allowed to grow gently.',
                'دع العادات الصغيرة تنمو بهدوء.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NurrDesign.secondaryText(widget.darkMode),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenActivityBadge extends StatelessWidget {
  final String languageCode;
  final _GardenAction action;
  const _GardenActivityBadge({
    required this.languageCode,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final resolved = action == _GardenAction.automatic
        ? (hour >= 22 || hour < 5
              ? _GardenAction.sleeping
              : (hour % 3 == 0 ? _GardenAction.dhikr : _GardenAction.quran))
        : action;
    final sleeping = resolved == _GardenAction.sleeping;
    final praying = resolved == _GardenAction.prayer;
    final doingDhikr = resolved == _GardenAction.dhikr;
    final icon = sleeping
        ? Icons.bedtime_rounded
        : (praying
              ? Icons.mosque_rounded
              : (doingDhikr
                    ? Icons.auto_awesome_rounded
                    : Icons.menu_book_rounded));
    final labels = sleeping
        ? ['Er ruht sich aus', 'Resting', 'يستريح']
        : praying
        ? ['Zeit für das Gebet', 'Prayer time', 'وقت الصلاة']
        : doingDhikr
        ? ['Er macht Dhikr', 'Making dhikr', 'يذكر الله']
        : resolved == _GardenAction.watering
        ? ['Er gießt den Garten', 'Watering the garden', 'يسقي الحديقة']
        : resolved == _GardenAction.resting
        ? [
            'Er ruht unter dem Baum',
            'Resting under the tree',
            'يستريح تحت الشجرة',
          ]
        : ['Er liest Quran', 'Reading Quran', 'يقرأ القرآن'];
    final text =
        labels[languageCode == 'ar' ? 2 : (languageCode == 'en' ? 1 : 0)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: NurrDesign.emerald),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: NurrDesign.emerald,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowingGardenPainter extends CustomPainter {
  final double progress;
  final double wind;
  final _GardenAction action;
  const _GrowingGardenPainter({
    required this.progress,
    required this.wind,
    required this.action,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hour = DateTime.now().hour;
    final resolved = action == _GardenAction.automatic
        ? (hour >= 22 || hour < 5
              ? _GardenAction.sleeping
              : (hour % 3 == 0 ? _GardenAction.dhikr : _GardenAction.quran))
        : action;
    final sleeping = resolved == _GardenAction.sleeping;
    if (sleeping) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF102345).withValues(alpha: .72),
      );
      canvas.drawCircle(
        Offset(size.width * .18, size.height * .16),
        25,
        Paint()..color = const Color(0xFFFFE8A4),
      );
      for (var i = 0; i < 14; i++) {
        canvas.drawCircle(
          Offset((i * 71.0) % size.width, 22 + (i * 29.0) % 125),
          i.isEven ? 1.8 : 1.1,
          Paint()..color = Colors.white.withValues(alpha: .65 + wind * .3),
        );
      }
    } else {
      final cloud = Paint()..color = Colors.white.withValues(alpha: .48);
      for (var i = 0; i < 3; i++) {
        final cx = ((i * 170.0 + wind * 28) % (size.width + 100)) - 50;
        final cy = 48.0 + i * 43;
        canvas.drawCircle(Offset(cx, cy), 20, cloud);
        canvas.drawCircle(Offset(cx + 23, cy + 2), 27, cloud);
        canvas.drawCircle(Offset(cx + 50, cy + 4), 18, cloud);
      }
    }
    final count = (progress * 32).round();
    final groundTop = size.height * .43;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5, groundTop + 18),
        width: size.width * 1.15,
        height: 90,
      ),
      Paint()..color = const Color(0xFF78B85B).withValues(alpha: .5),
    );
    final path = Path()
      ..moveTo(size.width * .57, size.height)
      ..quadraticBezierTo(
        size.width * .53,
        size.height * .68,
        size.width * .64,
        groundTop,
      )
      ..lineTo(size.width * .72, groundTop)
      ..quadraticBezierTo(
        size.width * .64,
        size.height * .7,
        size.width * .76,
        size.height,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFD5C58E));

    final houseLeft = size.width * .69;
    final houseTop = groundTop - 86;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(houseLeft, houseTop, 112, 92),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFF0D8AD),
    );
    final roof = Path()
      ..moveTo(houseLeft - 10, houseTop + 6)
      ..lineTo(houseLeft + 56, houseTop - 48)
      ..lineTo(houseLeft + 124, houseTop + 6)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF9A5544));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(houseLeft + 45, houseTop + 44, 28, 48),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF79513E),
    );
    final windowColor = sleeping
        ? const Color(0xFFFFD66B)
        : const Color(0xFF9BCFE0);
    for (final dx in [16.0, 82.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(houseLeft + dx, houseTop + 25, 19, 24),
          const Radius.circular(4),
        ),
        Paint()
          ..color = windowColor
          ..maskFilter = sleeping
              ? const MaskFilter.blur(BlurStyle.normal, 5)
              : null,
      );
    }

    final treeCount = count ~/ 6;
    for (var i = 0; i < treeCount; i++) {
      final depth = i.isEven ? .62 : .82;
      final x = 34.0 + (i * 109.0) % math.max(50.0, size.width - 70);
      final baseY = groundTop + (size.height - groundTop) * depth;
      final scale = .55 + depth * .45;
      final sway = (wind - .5) * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, baseY - 38 * scale),
            width: 12 * scale,
            height: 70 * scale,
          ),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF765139),
      );
      final crown = Paint()
        ..color = Color.lerp(
          const Color(0xFF327446),
          const Color(0xFF5DA954),
          i.isEven ? .2 : .8,
        )!;
      for (var crownPart = 0; crownPart < 5; crownPart++) {
        canvas.drawCircle(
          Offset(
            x + sway + (crownPart - 2) * 13 * scale,
            baseY - (76 + (crownPart.isEven ? 8 : 0)) * scale,
          ),
          24 * scale,
          crown,
        );
      }
    }

    const flowerColors = [
      Color(0xFFFFD66B),
      Color(0xFFF39B9B),
      Color(0xFFF7F0D0),
      Color(0xFFB8D8C0),
      Color(0xFFD5B8E8),
    ];
    for (var i = 0; i < count; i++) {
      final depth = .48 + ((i * 37) % 48) / 100;
      final x = 22.0 + (i * 83.0) % math.max(45.0, size.width - 44);
      final baseY = groundTop + (size.height - groundTop) * depth;
      final scale = .45 + depth * .6;
      final height = (22.0 + (i % 4) * 7) * scale;
      final sway = (wind - .5) * (5 + i % 3) * scale;
      final top = Offset(x + sway, baseY - height);
      canvas.drawLine(
        Offset(x, baseY),
        top,
        Paint()
          ..color = const Color(0xFF266D3E)
          ..strokeWidth = 3 * scale
          ..strokeCap = StrokeCap.round,
      );
      final leaf = Paint()
        ..color = const Color(0xFF55946A).withValues(alpha: .9);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - 8, baseY - height * .45),
          width: 18 * scale,
          height: 8 * scale,
        ),
        leaf,
      );
      final flower = Paint()..color = flowerColors[i % flowerColors.length];
      for (var petal = 0; petal < 6; petal++) {
        final angle = petal * math.pi / 3;
        canvas.drawCircle(
          top +
              Offset(math.cos(angle) * 7 * scale, math.sin(angle) * 7 * scale),
          4.8 * scale,
          flower,
        );
      }
      canvas.drawCircle(top, 3.5 * scale, Paint()..color = NurrDesign.goldDark);
    }

    final personX = size.width * .24;
    final personY = size.height * .7;
    if (sleeping) {
      for (var i = 0; i < 3; i++) {
        final rise = ((wind + i * .3) % 1) * 22;
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'Z',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .9 - i * .2),
              fontSize: 18.0 + i * 5,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(houseLeft + 82 + i * 12, houseTop - 18 - rise),
        );
      }
    } else {
      final cycle = .5 - math.cos(wind * math.pi * 2) / 2;
      final skin = Paint()..color = const Color(0xFFD7A071);
      final clothing = Paint()
        ..color = const Color(0xFFF1E7D3)
        ..strokeCap = StrokeCap.round;
      final vest = Paint()
        ..color = const Color(0xFF275D4A)
        ..strokeCap = StrokeCap.round;
      final outline = Paint()
        ..color = const Color(0xFF33443D)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(personX, personY + 35),
          width: 92,
          height: 18,
        ),
        Paint()..color = Colors.black.withValues(alpha: .15),
      );

      void drawFriendlyHead(Offset center, {bool lookingDown = false}) {
        canvas.drawCircle(center, 17, skin);
        canvas.drawArc(
          Rect.fromCenter(
            center: center.translate(0, -7),
            width: 30,
            height: 20,
          ),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFF3F2D25)
            ..strokeWidth = 7
            ..style = PaintingStyle.stroke,
        );
        final blink = cycle > .92;
        final eyeY = center.dy + (lookingDown ? 4 : 1);
        final eyePaint = Paint()
          ..color = const Color(0xFF3B2B24)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        for (final dx in [-6.0, 6.0]) {
          if (blink || lookingDown) {
            canvas.drawArc(
              Rect.fromCenter(
                center: Offset(center.dx + dx, eyeY),
                width: 6,
                height: 3,
              ),
              0,
              math.pi,
              false,
              eyePaint,
            );
          } else {
            canvas.drawCircle(
              Offset(center.dx + dx, eyeY),
              1.7,
              Paint()..color = const Color(0xFF3B2B24),
            );
          }
        }
        canvas.drawArc(
          Rect.fromCenter(center: center.translate(0, 8), width: 10, height: 6),
          .15,
          math.pi * .7,
          false,
          Paint()
            ..color = const Color(0xFF794C3A)
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke,
        );
      }

      if (resolved == _GardenAction.prayer) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(personX + 5, personY + 28),
              width: 82,
              height: 20,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xFFB76B55),
        );
        final phase = (wind * 4).floor().clamp(0, 3);
        if (phase == 0) {
          final head = Offset(personX, personY - 67);
          canvas.drawLine(
            Offset(personX, personY - 39),
            Offset(personX, personY + 16),
            clothing..strokeWidth = 27,
          );
          canvas.drawLine(
            Offset(personX, personY - 38),
            Offset(personX, personY + 5),
            vest..strokeWidth = 16,
          );
          drawFriendlyHead(head, lookingDown: true);
          canvas.drawLine(
            Offset(personX - 13, personY - 28),
            Offset(personX + 7, personY - 12),
            outline..strokeWidth = 5,
          );
          canvas.drawLine(
            Offset(personX + 13, personY - 28),
            Offset(personX + 7, personY - 12),
            outline..strokeWidth = 5,
          );
          canvas.drawCircle(Offset(personX + 7, personY - 12), 4, skin);
          canvas.drawLine(
            Offset(personX - 8, personY + 10),
            Offset(personX - 9, personY + 25),
            outline..strokeWidth = 6,
          );
          canvas.drawLine(
            Offset(personX + 8, personY + 10),
            Offset(personX + 9, personY + 25),
            outline..strokeWidth = 6,
          );
        } else if (phase == 1) {
          final shoulder = Offset(personX - 19, personY - 26);
          final hip = Offset(personX + 24, personY - 12);
          canvas.drawLine(shoulder, hip, clothing..strokeWidth = 27);
          canvas.drawLine(shoulder, hip, vest..strokeWidth = 16);
          drawFriendlyHead(
            Offset(personX + 41, personY - 12),
            lookingDown: true,
          );
          canvas.drawLine(
            Offset(personX - 5, personY - 17),
            Offset(personX + 19, personY + 8),
            outline..strokeWidth = 5,
          );
          canvas.drawCircle(Offset(personX + 19, personY + 8), 4, skin);
          canvas.drawLine(
            Offset(personX + 9, personY - 5),
            Offset(personX + 35, personY + 8),
            outline..strokeWidth = 5,
          );
          canvas.drawCircle(Offset(personX + 35, personY + 8), 4, skin);
          canvas.drawLine(
            Offset(personX - 12, personY - 4),
            Offset(personX - 12, personY + 25),
            outline..strokeWidth = 7,
          );
          canvas.drawLine(
            Offset(personX + 4, personY - 1),
            Offset(personX + 5, personY + 25),
            outline..strokeWidth = 7,
          );
        } else if (phase == 2) {
          final hip = Offset(personX - 14, personY + 2);
          final shoulder = Offset(personX + 18, personY + 11);
          canvas.drawLine(hip, shoulder, clothing..strokeWidth = 25);
          canvas.drawLine(hip, shoulder, vest..strokeWidth = 14);
          drawFriendlyHead(
            Offset(personX + 37, personY + 18),
            lookingDown: true,
          );
          canvas.drawLine(
            Offset(personX + 12, personY + 17),
            Offset(personX + 48, personY + 28),
            outline..strokeWidth = 5,
          );
          canvas.drawCircle(Offset(personX + 48, personY + 28), 4, skin);
          canvas.drawLine(
            Offset(personX - 18, personY + 5),
            Offset(personX - 34, personY + 24),
            outline..strokeWidth = 8,
          );
          canvas.drawLine(
            Offset(personX - 7, personY + 7),
            Offset(personX - 20, personY + 27),
            outline..strokeWidth = 8,
          );
        } else {
          final head = Offset(personX - 4, personY - 29);
          canvas.drawLine(
            Offset(personX - 24, personY + 10),
            Offset(personX + 18, personY + 17),
            clothing..strokeWidth = 24,
          );
          canvas.drawLine(
            Offset(personX - 5, personY - 5),
            Offset(personX - 4, personY + 15),
            clothing..strokeWidth = 25,
          );
          canvas.drawLine(
            Offset(personX - 5, personY - 6),
            Offset(personX - 4, personY + 10),
            vest..strokeWidth = 14,
          );
          drawFriendlyHead(head, lookingDown: true);
          canvas.drawLine(
            Offset(personX - 14, personY + 2),
            Offset(personX - 24, personY + 13),
            outline..strokeWidth = 5,
          );
          canvas.drawLine(
            Offset(personX + 5, personY + 2),
            Offset(personX + 14, personY + 13),
            outline..strokeWidth = 5,
          );
        }
      } else {
        final breathing = math.sin(wind * math.pi * 2) * 1.5;
        canvas.drawLine(
          Offset(personX - 24, personY + 21),
          Offset(personX + 25, personY + 21),
          clothing..strokeWidth = 20,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(personX, personY - 13 + breathing),
              width: 42,
              height: 58,
            ),
            const Radius.circular(15),
          ),
          clothing,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(personX, personY - 16 + breathing),
              width: 29,
              height: 48,
            ),
            const Radius.circular(10),
          ),
          vest,
        );
        final headY = personY - 57 + breathing;
        drawFriendlyHead(
          Offset(personX, headY),
          lookingDown: resolved == _GardenAction.quran,
        );

        if (resolved == _GardenAction.dhikr) {
          final handY = personY - 5 + math.sin(wind * math.pi * 4) * 4;
          canvas.drawLine(
            Offset(personX - 14, personY - 17),
            Offset(personX + 18, handY),
            outline..strokeWidth = 6,
          );
          for (var i = 0; i < 11; i++) {
            final angle = i * math.pi / 10;
            canvas.drawCircle(
              Offset(
                personX + 18 + math.cos(angle) * 15,
                handY + 8 + math.sin(angle) * 10,
              ),
              2.3,
              Paint()..color = NurrDesign.gold,
            );
          }
          final phrases = [
            'SubhanAllah',
            'Alhamdulillah',
            'Allahu Akbar',
            'Astaghfirullah',
          ];
          final phrase = phrases[(wind * phrases.length).floor().clamp(0, 3)];
          final bubble = RRect.fromRectAndRadius(
            Rect.fromLTWH(personX + 34, personY - 105, 102, 35),
            const Radius.circular(16),
          );
          canvas.drawRRect(
            bubble,
            Paint()..color = Colors.white.withValues(alpha: .93),
          );
          final tail = Path()
            ..moveTo(personX + 44, personY - 72)
            ..lineTo(personX + 34, personY - 62)
            ..lineTo(personX + 56, personY - 72)
            ..close();
          canvas.drawPath(
            tail,
            Paint()..color = Colors.white.withValues(alpha: .93),
          );
          final label = TextPainter(
            text: TextSpan(
              text: phrase,
              style: const TextStyle(
                color: Color(0xFF275D4A),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          label.paint(canvas, Offset(personX + 45, personY - 94));
        } else if (resolved == _GardenAction.watering) {
          final tilt = math.sin(wind * math.pi) * .2;
          canvas.save();
          canvas.translate(personX + 28, personY - 3);
          canvas.rotate(tilt);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-14, -11, 30, 23),
              const Radius.circular(8),
            ),
            Paint()..color = const Color(0xFF6FAFC2),
          );
          canvas.restore();
          for (var i = 0; i < 7; i++) {
            canvas.drawCircle(
              Offset(
                personX + 50 + i * 6,
                personY + 5 + ((wind * 30 + i * 8) % 24),
              ),
              2,
              Paint()..color = const Color(0xFFB9E8F3),
            );
          }
        } else if (resolved == _GardenAction.resting) {
          canvas.drawLine(
            Offset(personX - 24, personY + 10),
            Offset(personX + 29, personY + 27),
            clothing..strokeWidth = 15,
          );
        } else {
          final pageTurn = cycle > .72 ? (cycle - .72) / .28 : 0.0;
          final bookCenter = Offset(personX + 4, personY + 1);
          final leftPage = Path()
            ..moveTo(bookCenter.dx, bookCenter.dy + 13)
            ..lineTo(bookCenter.dx - 31, bookCenter.dy + 5)
            ..lineTo(bookCenter.dx - 29, bookCenter.dy - 17)
            ..lineTo(bookCenter.dx, bookCenter.dy - 8)
            ..close();
          final rightPage = Path()
            ..moveTo(bookCenter.dx, bookCenter.dy + 13)
            ..lineTo(bookCenter.dx + 31, bookCenter.dy + 5)
            ..lineTo(bookCenter.dx + 29, bookCenter.dy - 17)
            ..lineTo(bookCenter.dx, bookCenter.dy - 8)
            ..close();
          canvas.drawPath(leftPage, Paint()..color = const Color(0xFFFFF3CE));
          canvas.drawPath(rightPage, Paint()..color = const Color(0xFFFFE8B2));
          for (var line = 0; line < 3; line++) {
            canvas.drawLine(
              Offset(bookCenter.dx - 24, bookCenter.dy - 10 + line * 5),
              Offset(bookCenter.dx - 5, bookCenter.dy - 5 + line * 5),
              Paint()
                ..color = const Color(0xFF826D42)
                ..strokeWidth = 1,
            );
            canvas.drawLine(
              Offset(bookCenter.dx + 5, bookCenter.dy - 5 + line * 5),
              Offset(bookCenter.dx + 24, bookCenter.dy - 10 + line * 5),
              Paint()
                ..color = const Color(0xFF826D42)
                ..strokeWidth = 1,
            );
          }
          canvas.drawLine(
            Offset(personX - 14, personY - 17),
            Offset(personX - 19 + cycle * 34, personY - 2),
            outline..strokeWidth = 5,
          );
          if (pageTurn > 0) {
            final page = Path()
              ..moveTo(bookCenter.dx, bookCenter.dy - 8)
              ..quadraticBezierTo(
                bookCenter.dx + 24 - pageTurn * 38,
                bookCenter.dy - 27,
                bookCenter.dx - 20 * pageTurn,
                bookCenter.dy + 2,
              )
              ..lineTo(bookCenter.dx, bookCenter.dy + 13)
              ..close();
            canvas.drawPath(page, Paint()..color = const Color(0xFFFFF8DD));
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrowingGardenPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.wind != wind ||
      oldDelegate.action != action;
}

class _SunnahHero extends StatelessWidget {
  final int done, total;
  final bool darkMode;
  final String languageCode;
  final VoidCallback onOpenGarden;
  const _SunnahHero({
    required this.done,
    required this.total,
    required this.darkMode,
    required this.languageCode,
    required this.onOpenGarden,
  });
  String _t(String de, String en, String ar) =>
      languageCode == 'ar' ? ar : (languageCode == 'en' ? en : de);
  @override
  Widget build(BuildContext context) => Container(
    height: 250,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [NurrDesign.emerald, Color(0xFF276F61)],
      ),
      borderRadius: BorderRadius.circular(32),
      image: DecorationImage(
        image: const AssetImage(
          'assets/assets/images/sunnah_garden_hero_v1.webp',
        ),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        colorFilter: ColorFilter.mode(
          NurrDesign.emerald.withValues(alpha: .48),
          BlendMode.multiply,
        ),
      ),
    ),
    child: Stack(
      children: [
        PositionedDirectional(
          end: -12,
          bottom: -12,
          child: CustomPaint(
            size: const Size(180, 150),
            painter: const _SunnahGardenPainter(),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t(
                'Kleine Sunnahs.\nGroße Nähe.',
                'Small Sunnahs.\nDeeper connection.',
                'سنن صغيرة،\nوقرب أكبر.',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: onOpenGarden,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .9),
                  foregroundColor: NurrDesign.emerald,
                ),
                icon: const Icon(Icons.local_florist_rounded, size: 18),
                label: Text(
                  _t('Meinen Garten ansehen', 'View my garden', 'شاهد حديقتي'),
                ),
              ),
            ),
            const Spacer(),
            Text(
              _t(
                '$done von $total heute gelebt',
                '$done of $total practiced today',
                '$done من $total اليوم',
              ),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: done / total),
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: const Color(0xFFFFD77A),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SunnahCard extends StatelessWidget {
  final _SunnahItem item;
  final bool active, darkMode;
  final String title, description, doneLabel;
  final bool hasNote;
  final bool favorite, inWeekPlan;
  final String noteLabel;
  final VoidCallback onTap;
  final VoidCallback onNote;
  final VoidCallback onFavorite, onWeekPlan, onSource;
  const _SunnahCard({
    required this.item,
    required this.active,
    required this.darkMode,
    required this.title,
    required this.description,
    required this.doneLabel,
    required this.hasNote,
    required this.favorite,
    required this.inWeekPlan,
    required this.noteLabel,
    required this.onTap,
    required this.onNote,
    required this.onFavorite,
    required this.onWeekPlan,
    required this.onSource,
  });
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 450),
    decoration: BoxDecoration(
      color: active
          ? item.color.withValues(alpha: darkMode ? .18 : .11)
          : NurrDesign.surface(darkMode),
      borderRadius: BorderRadius.circular(27),
      border: Border.all(
        color: active ? item.color : NurrDesign.gold.withValues(alpha: .16),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: active ? 1 : 0),
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutBack,
                builder: (context, value, _) => Transform.scale(
                  scale: .9 + value * .12,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Icon(item.icon, color: item.color, size: 29),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: onSource,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      item.source,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: NurrDesign.secondaryText(darkMode),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Favorit',
                visualDensity: VisualDensity.compact,
                onPressed: onFavorite,
                icon: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favorite
                      ? const Color(0xFFC7616B)
                      : NurrDesign.secondaryText(darkMode),
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: TextStyle(
              color: NurrDesign.text(darkMode),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: NurrDesign.secondaryText(darkMode),
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: active
                        ? item.color
                        : (darkMode ? Colors.white10 : NurrDesign.cream),
                    foregroundColor: active
                        ? Colors.white
                        : NurrDesign.text(darkMode),
                  ),
                  icon: Icon(
                    active ? Icons.auto_awesome : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(doneLabel),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: noteLabel,
                onPressed: onNote,
                icon: Icon(
                  hasNote ? Icons.edit_note_rounded : Icons.note_add_outlined,
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Wochenplan',
                onPressed: onWeekPlan,
                icon: Icon(
                  inWeekPlan
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_add_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SunnahGardenPainter extends CustomPainter {
  const _SunnahGardenPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFFFD77A).withValues(alpha: .75);
    final pale = Paint()..color = Colors.white.withValues(alpha: .16);
    canvas.drawCircle(Offset(size.width * .62, size.height * .22), 25, gold);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .23,
        size.height * .55,
        size.width * .7,
        size.height * .45,
      ),
      pale,
    );
    canvas.drawCircle(Offset(size.width * .58, size.height * .55), 45, pale);
    for (var i = 0; i < 5; i++) {
      final x = 18.0 + i * 32;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + 8, size.height - 42 - i % 2 * 12),
        gold..strokeWidth = 3,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 14, size.height - 34 - i % 2 * 12),
          width: 20,
          height: 9,
        ),
        gold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
