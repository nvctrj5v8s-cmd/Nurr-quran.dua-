import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran_text_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled Quran data is complete and passes integrity validation',
    () async {
      final data = await QuranTextRepository.instance.load();

      expect(data.surahs, hasLength(114));
      expect(data.verses, hasLength(6236));
      expect(data.surahs.first.verses, hasLength(7));
      expect(data.surahs.last.verses, hasLength(6));
      expect(data.verses.first.key, '1:1');
      expect(data.verses.last.key, '114:6');
      expect(data.verses.map((verse) => verse.page).toSet(), hasLength(604));
      expect(data.verses.every((verse) => verse.arabic.isNotEmpty), isTrue);
      expect(data.verses.every((verse) => verse.german.isNotEmpty), isTrue);
      expect(data.verses.every((verse) => verse.english.isNotEmpty), isTrue);
      expect(data.surahs.first.arabicName, 'الفاتحة');
      expect(data.surahs.last.arabicName, 'الناس');

      for (final surah in data.surahs.skip(1)) {
        expect(
          surah.verses.first.arabic.startsWith(QuranTextRepository.basmala),
          isFalse,
          reason: 'Basmala must be a heading, not part of ${surah.number}:1',
        );
      }
    },
  );
}
