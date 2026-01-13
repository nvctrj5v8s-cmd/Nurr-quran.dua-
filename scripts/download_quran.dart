import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('📥 Lade kompletten Quran von Tanzil API...');
  
  final Map<String, dynamic> quranData = {};
  
  for (int surah = 1; surah <= 114; surah++) {
    print('📖 Lade Surah $surah/114...');
    
    final response = await http.get(
      Uri.parse('http://api.alquran.cloud/v1/surah/$surah/quran-uthmani'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final surahData = data['data'];
      
      quranData['surah_$surah'] = {
        'number': surahData['number'],
        'name': surahData['name'],
        'englishName': surahData['englishName'],
        'numberOfAyahs': surahData['numberOfAyahs'],
        'ayahs': (surahData['ayahs'] as List).map((ayah) => {
          'number': ayah['number'],
          'numberInSurah': ayah['numberInSurah'],
          'text': ayah['text'], // BYTE-IDENTISCH von API
        }).toList(),
      };
      
      await Future.delayed(Duration(milliseconds: 100)); // Rate limiting
    }
  }
  
  print('💾 Speichere Quran-Daten...');
  final file = File('../assets/data/quran-uthmani.json');
  await file.parent.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(quranData),
  );
  
  print('✅ Fertig! Quran gespeichert in: ${file.absolute.path}');
}
