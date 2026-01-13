import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Erstellt Demo-Mushaf-Seiten für Testing
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const numPages = 5;
  final outputDir = Directory('assets/mushaf_pages');
  
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  
  for (int page = 1; page <= numPages; page++) {
    await createDemoPage(page, outputDir.path);
    print('✓ Erstellt: ${page.toString().padLeft(3, '0')}.png');
  }
  
  print('\n✅ $numPages Demo-Seiten erstellt!');
  print('Starte die App und klicke auf den "Mushaf" Button!');
}

Future<void> createDemoPage(int pageNum, String outputPath) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  const width = 1080.0;
  const height = 1620.0;
  
  // Beiger Hintergrund (wie altes Papier)
  final bgPaint = Paint()..color = const Color(0xFFF5EFE0);
  canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
  
  // Rahmen
  final borderPaint = Paint()
    ..color = const Color(0xFF8B5A2B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  canvas.drawRect(
    const Rect.fromLTWH(50, 50, 980, 1520),
    borderPaint,
  );
  
  // Text: Seitenzahl (Arabisch)
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'صفحة $pageNum',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.rtl,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset((width - textPainter.width) / 2, 100));
  
  // Demo Text
  final demoText = TextPainter(
    text: TextSpan(
      text: 'DEMO SEITE $pageNum/604',
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 40,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  demoText.layout();
  demoText.paint(canvas, Offset((width - demoText.width) / 2, height / 2));
  
  // Konvertiere zu Bild
  final picture = recorder.endRecording();
  final img = await picture.toImage(width.toInt(), height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  // Speichere als PNG
  final file = File('$outputPath/${pageNum.toString().padLeft(3, '0')}.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());
}
