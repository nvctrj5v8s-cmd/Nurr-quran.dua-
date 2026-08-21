import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nurr_design.dart';
import 'spiritual_home_features.dart';

class ModernHomePage extends StatefulWidget {
  final String languageCode;
  final bool darkMode;
  final ValueChanged<int> onOpenTab;
  final VoidCallback onOpenMasbaha;
  final VoidCallback onContinueReading;
  final void Function(int surah, int ayah) onOpenQuranVerse;

  const ModernHomePage({
    super.key,
    required this.languageCode,
    required this.darkMode,
    required this.onOpenTab,
    required this.onOpenMasbaha,
    required this.onContinueReading,
    required this.onOpenQuranVerse,
  });

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage> {
  List<bool> _prayers = List.filled(5, false);

  bool get _ar => widget.languageCode == 'ar';
  bool get _en => widget.languageCode == 'en';
  String _t(String de, String en, String ar) => _ar ? ar : (_en ? en : de);

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  Future<void> _loadPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (prefs.getString('nurr_prayer_day') != today) {
      await prefs.setString('nurr_prayer_day', today);
      for (var index = 0; index < 5; index++) {
        await prefs.setBool('gebet_$index', false);
      }
    }
    final values = List.generate(
      5,
      (index) => prefs.getBool('gebet_$index') ?? false,
    );
    if (mounted) setState(() => _prayers = values);
  }

  Future<void> _togglePrayer(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [..._prayers];
    updated[index] = !updated[index];
    await prefs.setBool('gebet_$index', updated[index]);
    final raw = prefs.getString('nurr_prayer_journey_history');
    final history = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    history[today] = updated.where((value) => value).length;
    await prefs.setString('nurr_prayer_journey_history', jsonEncode(history));
    if (mounted) setState(() => _prayers = updated);
  }

  String get _dateLabel {
    final now = DateTime.now();
    const de = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const ar = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final days = _ar ? ar : (_en ? en : de);
    return '${days[now.weekday - 1]}, ${now.day}.${now.month}.${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NurrDesign.background(widget.darkMode),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 980
                ? 940.0
                : constraints.maxWidth;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(
                        languageCode: widget.languageCode,
                        date: _dateLabel,
                        darkMode: widget.darkMode,
                      ),
                      const SizedBox(height: 20),
                      _ContinueReadingCard(
                        languageCode: widget.languageCode,
                        darkMode: widget.darkMode,
                        onTap: widget.onContinueReading,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        darkMode: widget.darkMode,
                        title: _t('Entdecken', 'Explore', 'استكشف'),
                        subtitle: _t(
                          'Alles Wichtige schnell erreichen',
                          'Everything important at a glance',
                          'كل ما تحتاجه في مكان واحد',
                        ),
                      ),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: constraints.maxWidth >= 720 ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: constraints.maxWidth >= 720
                            ? 1.35
                            : 1.18,
                        children: [
                          _QuickAction(
                            darkMode: widget.darkMode,
                            icon: Icons.menu_book_rounded,
                            title: _t('Quran', 'Quran', 'القرآن'),
                            subtitle: _t(
                              'Lesen & suchen',
                              'Read & search',
                              'قراءة وبحث',
                            ),
                            onTap: () => widget.onOpenTab(1),
                          ),
                          _QuickAction(
                            darkMode: widget.darkMode,
                            icon: Icons.eco_rounded,
                            title: _t('Sunnahs', 'Sunnahs', 'السنن'),
                            subtitle: _t(
                              'Heute schön leben',
                              'Practice beautifully',
                              'عِشها اليوم',
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SunnahHabitsPage(
                                  languageCode: widget.languageCode,
                                  darkMode: widget.darkMode,
                                ),
                              ),
                            ),
                          ),
                          _QuickAction(
                            darkMode: widget.darkMode,
                            icon: Icons.favorite_rounded,
                            title: _t('Duas', 'Duas', 'الأدعية'),
                            subtitle: _t(
                              'Für jeden Moment',
                              'For every moment',
                              'لكل وقت',
                            ),
                            onTap: () => widget.onOpenTab(3),
                          ),
                          _QuickAction(
                            darkMode: widget.darkMode,
                            icon: Icons.touch_app_rounded,
                            title: _t('Masbaha', 'Tasbih', 'المسبحة'),
                            subtitle: _t(
                              'Dhikr zählen',
                              'Count your dhikr',
                              'عدّ الأذكار',
                            ),
                            onTap: widget.onOpenMasbaha,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PrayerJourneyCard(
                        languageCode: widget.languageCode,
                        darkMode: widget.darkMode,
                        prayers: _prayers,
                        onToggle: _togglePrayer,
                        onOpen: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrayerJourneyPage(
                                languageCode: widget.languageCode,
                                darkMode: widget.darkMode,
                              ),
                            ),
                          );
                          _loadPrayers();
                        },
                      ),
                      const SizedBox(height: 18),
                      DailyImpulseCard(
                        languageCode: widget.languageCode,
                        darkMode: widget.darkMode,
                        onOpenVerse: widget.onOpenQuranVerse,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String languageCode;
  final String date;
  final bool darkMode;
  const _Header({
    required this.languageCode,
    required this.date,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final ar = languageCode == 'ar';
    final en = languageCode == 'en';
    final greeting = ar
        ? 'السلام عليكم'
        : (en ? 'Peace be upon you' : 'Assalamu alaikum');
    final subtitle = ar
        ? 'نتمنى لك يومًا مباركًا'
        : (en ? 'May your day be blessed' : 'Einen gesegneten Tag für dich');
    return Row(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: NurrDesign.emerald,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.nightlight_round, color: Colors.white),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: NurrDesign.text(darkMode),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: NurrDesign.secondaryText(darkMode),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: NurrDesign.surface(darkMode),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            date,
            style: TextStyle(
              color: NurrDesign.secondaryText(darkMode),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final String languageCode;
  final bool darkMode;
  final VoidCallback onTap;
  const _ContinueReadingCard({
    required this.languageCode,
    required this.darkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ar = languageCode == 'ar';
    final en = languageCode == 'en';
    String t(String de, String english, String arabic) =>
        ar ? arabic : (en ? english : de);
    final primaryText = NurrDesign.text(darkMode);
    final secondaryText = NurrDesign.secondaryText(darkMode);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [NurrDesign.emerald, Color(0xFF236A5E)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33174C43),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFFFDB89),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Weiterlesen', 'Continue reading', 'متابعة القراءة'),
                    style: TextStyle(
                      color: darkMode ? const Color(0xFFFFDB89) : primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    t('Öffne deinen Quran', 'Open your Quran', 'افتح القرآن'),
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    t(
                      'Deine Einstellungen und Lesezeichen warten auf dich.',
                      'Your settings and bookmarks are ready.',
                      'إعداداتك وإشاراتك المرجعية محفوظة.',
                    ),
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: primaryText),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool darkMode;
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.darkMode,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: NurrDesign.text(darkMode),
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: TextStyle(
          color: NurrDesign.secondaryText(darkMode),
          fontSize: 13,
        ),
      ),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  final bool darkMode;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickAction({
    required this.darkMode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Ink(
      padding: const EdgeInsets.all(16),
      decoration: NurrDesign.card(color: NurrDesign.surface(darkMode)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: NurrDesign.gold.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: NurrDesign.goldDark, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: NurrDesign.text(darkMode),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: NurrDesign.secondaryText(darkMode),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

// Kept temporarily for rollback compatibility with the previous home layout.
// ignore: unused_element
class _PrayerTracker extends StatelessWidget {
  final String languageCode;
  final bool darkMode;
  final List<String> names;
  final List<bool> values;
  final ValueChanged<int> onToggle;
  const _PrayerTracker({
    required this.languageCode,
    required this.darkMode,
    required this.names,
    required this.values,
    required this.onToggle,
  });
  @override
  Widget build(BuildContext context) {
    final ar = languageCode == 'ar';
    final en = languageCode == 'en';
    final title = ar
        ? 'صلوات اليوم'
        : (en ? "Today's prayers" : 'Heutige Gebete');
    final complete = values.where((value) => value).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NurrDesign.card(color: NurrDesign.surface(darkMode)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: NurrDesign.text(darkMode),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$complete/5',
                style: const TextStyle(
                  color: NurrDesign.goldDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List.generate(names.length, (index) {
              final active = values[index];
              return FilterChip(
                selected: active,
                showCheckmark: true,
                selectedColor: NurrDesign.emerald,
                checkmarkColor: Colors.white,
                backgroundColor: darkMode
                    ? const Color(0xFF252525)
                    : NurrDesign.cream,
                labelStyle: TextStyle(
                  color: active ? Colors.white : NurrDesign.text(darkMode),
                  fontWeight: FontWeight.w600,
                ),
                label: Text(names[index]),
                onSelected: (_) => onToggle(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Kept temporarily for rollback compatibility with the previous home layout.
// ignore: unused_element
class _DailyCard extends StatelessWidget {
  final String languageCode;
  final bool darkMode;
  const _DailyCard({required this.languageCode, required this.darkMode});
  @override
  Widget build(BuildContext context) {
    final ar = languageCode == 'ar';
    final en = languageCode == 'en';
    final title = ar
        ? 'تذكير اليوم'
        : (en ? 'Daily reminder' : 'Impuls des Tages');
    final text = ar
        ? 'إن مع العسر يسرا'
        : (en
              ? 'Indeed, with hardship comes ease.'
              : 'Gewiss, mit der Erschwernis ist Erleichterung.');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NurrDesign.card(
        color: darkMode ? const Color(0xFF211D15) : const Color(0xFFFFF8E8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: NurrDesign.goldDark,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: NurrDesign.goldDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: NurrDesign.text(darkMode),
                    fontSize: ar ? 21 : 15,
                    fontFamily: ar ? 'AmiriQuran' : null,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '94:5',
                  style: TextStyle(
                    color: NurrDesign.secondaryText(darkMode),
                    fontSize: 11,
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
