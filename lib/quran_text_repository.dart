import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class QuranVerse {
  final int surah;
  final int ayah;
  final int page;
  final String arabic;
  final String german;
  final String english;

  const QuranVerse({
    required this.surah,
    required this.ayah,
    required this.page,
    required this.arabic,
    required this.german,
    required this.english,
  });

  String get key => '$surah:$ayah';

  String translationFor(String languageCode) =>
      languageCode == 'en' ? english : german;
}

class QuranSurah {
  final int number;
  final int ayahCount;
  final String arabicName;
  final String transliteratedName;
  final String englishName;
  final String revelationType;
  final List<QuranVerse> verses;

  const QuranSurah({
    required this.number,
    required this.ayahCount,
    required this.arabicName,
    required this.transliteratedName,
    required this.englishName,
    required this.revelationType,
    required this.verses,
  });
}

class QuranTextData {
  final List<QuranSurah> surahs;
  final List<QuranVerse> verses;

  const QuranTextData({required this.surahs, required this.verses});

  QuranVerse verse(String key) => verses.firstWhere((v) => v.key == key);
}

class QuranTextRepository {
  QuranTextRepository._();

  static final QuranTextRepository instance = QuranTextRepository._();
  Future<QuranTextData>? _cached;

  static const _arabicPath = 'assets/assets/data/quran_uthmani_tanzil_1_1.txt';
  static const _germanPath = 'assets/assets/data/translation_de_bubenheim.txt';
  static const _englishPath = 'assets/assets/data/translation_en_sahih.txt';
  static const _metadataPath =
      'assets/assets/data/quran_metadata_tanzil_1_0.js';
  static const basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  static const arabicSurahNames = <String>[
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس',
  ];

  static const expectedArabicSha256 =
      'ac0724796cbbda0f4801470fbbd11d0f3c5802067bae0493466d0128b0c667af';
  static const expectedGermanSha256 =
      '3c3c12c0189280e83eb52a2bbfd9d685bef16ffa9f4a307037367fe6dd00b958';
  static const expectedEnglishSha256 =
      'a1778a1a56695d9b59ae910809ec46d9f4a55f05961de51cd56e6ebcf9040883';

  static const expectedAyahCounts = <int>[
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6,
  ];

  Future<QuranTextData> load() {
    final existing = _cached;
    if (existing != null) return existing;

    final loading = _loadAndVerify();
    _cached = loading;
    return loading.catchError((Object error, StackTrace stackTrace) {
      if (identical(_cached, loading)) _cached = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  void clearCache() => _cached = null;

  Future<QuranTextData> _loadAndVerify() async {
    final arabicBytes = await rootBundle.load(_arabicPath);
    final germanBytes = await rootBundle.load(_germanPath);
    final englishBytes = await rootBundle.load(_englishPath);
    final metadata = await rootBundle.loadString(_metadataPath);

    _verifyHash(arabicBytes, expectedArabicSha256, 'Tanzil Uthmani 1.1');
    _verifyHash(germanBytes, expectedGermanSha256, 'Bubenheim & Elyas');
    _verifyHash(englishBytes, expectedEnglishSha256, 'Saheeh International');

    final arabicLines = _contentLines(_decode(arabicBytes));
    final german = _parseTranslation(_decode(germanBytes), 'Deutsch');
    final english = _parseTranslation(_decode(englishBytes), 'English');
    final metadataResult = _parseMetadata(metadata);

    if (arabicLines.length != 6236 ||
        german.length != 6236 ||
        english.length != 6236) {
      throw const FormatException(
        'Quran integrity check failed: every source must contain 6236 verses.',
      );
    }
    if (metadataResult.surahs.length != 114 ||
        metadataResult.pageStarts.length != 604) {
      throw const FormatException(
        'Quran metadata integrity check failed: expected 114 surahs and 604 pages.',
      );
    }

    final allVerses = <QuranVerse>[];
    final surahs = <QuranSurah>[];
    var absoluteIndex = 0;
    var currentPage = 1;
    var nextPageIndex = 1;

    for (var surahIndex = 0; surahIndex < 114; surahIndex++) {
      final surahNumber = surahIndex + 1;
      final expectedCount = expectedAyahCounts[surahIndex];
      final meta = metadataResult.surahs[surahIndex];
      if (meta.ayahCount != expectedCount) {
        throw FormatException('Ayah count mismatch in surah $surahNumber.');
      }

      final verses = <QuranVerse>[];
      for (var ayah = 1; ayah <= expectedCount; ayah++) {
        final key = '$surahNumber:$ayah';
        while (nextPageIndex < metadataResult.pageStarts.length &&
            metadataResult.pageStarts[nextPageIndex] == key) {
          currentPage = nextPageIndex + 1;
          nextPageIndex++;
        }
        final germanText = german[key];
        final englishText = english[key];
        if (germanText == null || englishText == null) {
          throw FormatException('Missing translation for verse $key.');
        }
        var arabicText = arabicLines[absoluteIndex];
        if (surahNumber != 1 && surahNumber != 9 && ayah == 1) {
          const alternateBasmala = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
          final matchingBasmala = [
            basmala,
            alternateBasmala,
          ].where((value) => arabicText.startsWith('$value ')).firstOrNull;
          if (matchingBasmala == null) {
            throw FormatException(
              'Expected Basmala before $surahNumber:1 was not found.',
            );
          }
          arabicText = arabicText.substring(matchingBasmala.length + 1);
        }
        final verse = QuranVerse(
          surah: surahNumber,
          ayah: ayah,
          page: currentPage,
          arabic: arabicText,
          german: germanText,
          english: englishText,
        );
        verses.add(verse);
        allVerses.add(verse);
        absoluteIndex++;
      }
      surahs.add(
        QuranSurah(
          number: surahNumber,
          ayahCount: expectedCount,
          arabicName: arabicSurahNames[surahNumber - 1],
          transliteratedName: meta.transliteratedName,
          englishName: meta.englishName,
          revelationType: meta.revelationType,
          verses: List.unmodifiable(verses),
        ),
      );
    }

    if (absoluteIndex != 6236 || allVerses.last.key != '114:6') {
      throw const FormatException('Quran verse ordering check failed.');
    }
    return QuranTextData(
      surahs: List.unmodifiable(surahs),
      verses: List.unmodifiable(allVerses),
    );
  }

  static void _verifyHash(ByteData data, String expected, String source) {
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final actual = sha256.convert(bytes).toString();
    if (actual != expected) {
      throw FormatException('$source checksum mismatch.');
    }
  }

  static String _decode(ByteData data) {
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return utf8.decode(bytes);
  }

  static List<String> _contentLines(String input) => input
      .split(RegExp(r'\r?\n'))
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toList(growable: false);

  static Map<String, String> _parseTranslation(String input, String name) {
    final result = <String, String>{};
    final pattern = RegExp(r'^(\d+)\|(\d+)\|(.*)$');
    for (final line in input.split(RegExp(r'\r?\n'))) {
      final match = pattern.firstMatch(line);
      if (match == null) continue;
      final key = '${match.group(1)}:${match.group(2)}';
      if (result.containsKey(key)) {
        throw FormatException('Duplicate $name translation key $key.');
      }
      result[key] = match.group(3)!;
    }
    return result;
  }

  static _MetadataResult _parseMetadata(String input) {
    final surahSection = input.substring(
      input.indexOf('QuranData.Sura = ['),
      input.indexOf('//------------------ Juz Data'),
    );
    final surahPattern = RegExp(
      r'''\[\d+,\s*(\d+),\s*\d+,\s*\d+,\s*'([^']*)',\s*"([^"]*)",\s*'([^']*)',\s*'([^']*)'\]''',
    );
    final surahs = surahPattern
        .allMatches(surahSection)
        .map((match) {
          return _SurahMetadata(
            ayahCount: int.parse(match.group(1)!),
            arabicName: match.group(2)!,
            transliteratedName: match.group(3)!,
            englishName: match.group(4)!,
            revelationType: match.group(5)!,
          );
        })
        .toList(growable: false);

    final pageSection = input.substring(input.indexOf('QuranData.Page = ['));
    final pagePattern = RegExp(r'\[(\d+),\s*(\d+)\]');
    final pageStarts = pagePattern
        .allMatches(pageSection)
        .map((match) => '${match.group(1)}:${match.group(2)}')
        .where((key) => key != '115:1')
        .take(604)
        .toList(growable: false);

    return _MetadataResult(surahs: surahs, pageStarts: pageStarts);
  }
}

class _SurahMetadata {
  final int ayahCount;
  final String arabicName;
  final String transliteratedName;
  final String englishName;
  final String revelationType;

  const _SurahMetadata({
    required this.ayahCount,
    required this.arabicName,
    required this.transliteratedName,
    required this.englishName,
    required this.revelationType,
  });
}

class _MetadataResult {
  final List<_SurahMetadata> surahs;
  final List<String> pageStarts;

  const _MetadataResult({required this.surahs, required this.pageStarts});
}
