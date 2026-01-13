# Mushaf Reader - Performance-Optimierung

## 1. Caching-Strategie

### Image Caching (Empfohlen)
```dart
// In pubspec.yaml bereits: photo_view nutzt Flutter's Image Cache
// Standard Cache: 1000 Images = ~1.5GB RAM max

// Optional: Cache-Größe anpassen in main.dart
void main() {
  // Erhöhe Image Cache (Standard: 1000 Images)
  PaintingBinding.instance.imageCache.maximumSize = 100; // Nur 100 Bilder im RAM
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200MB max
  
  runApp(MyApp());
}
```

### Preloading benachbarter Seiten
```dart
// In _MushafReaderPageState nach _loadLastReadPage() hinzufügen:

void _preloadAdjacentPages(int currentPage) {
  // Lade vorherige und nächste Seite vor
  final pagesToPreload = [
    currentPage - 1,
    currentPage + 1,
  ];
  
  for (final page in pagesToPreload) {
    if (page >= 0 && page < totalPages) {
      precacheImage(
        AssetImage('assets/mushaf_pages/${_formatPageNumber(page + 1)}.png'),
        context,
      );
    }
  }
}

// In onPageChanged aufrufen:
onPageChanged: (index) {
  final logicalPage = totalPages - 1 - index;
  setState(() {
    _currentPage = logicalPage;
  });
  _preloadAdjacentPages(logicalPage); // NEU
  _saveReadingProgress();
},
```

## 2. Asset-Optimierung

### Bildformat & Größe
- **PNG**: Verlustfrei, große Dateien (~2-5 MB pro Seite = 1.2-3GB total)
- **WebP**: 30% kleiner, gute Qualität (~1-3 MB pro Seite)
- **JPEG**: Kleinste Dateien, Qualitätsverlust bei Text

**Empfehlung**: WebP mit 90% Qualität für beste Balance

### Konvertierung (ImageMagick Beispiel)
```bash
# Alle PNGs zu WebP konvertieren
for file in assets/mushaf_pages/*.png; do
  magick "$file" -quality 90 "${file%.png}.webp"
done

# Oder mit cwebp (Google's WebP Tool)
for file in assets/mushaf_pages/*.png; do
  cwebp -q 90 "$file" -o "${file%.png}.webp"
done
```

Dann in Code ändern:
```dart
'assets/mushaf_pages/${_formatPageNumber(logicalPage + 1)}.webp'
```

### Auflösung optimieren
- **1080x1920** (Full HD): Standard, gute Qualität
- **720x1280** (HD): 50% kleiner, ausreichend für meiste Geräte
- **1440x2560** (2K): Für Tablets/große Displays

## 3. Download-Mechanismus (Optional)

### Remote Assets statt lokaler Assets
```dart
class MushafDownloadManager {
  static const String baseUrl = 'https://dein-server.com/mushaf/';
  static const String localDir = 'mushaf_pages';
  
  Future<String> getPagePath(int pageNumber) async {
    final fileName = '${pageNumber.toString().padLeft(3, '0')}.webp';
    final localPath = await _getLocalPath(fileName);
    
    // Prüfe ob Seite lokal existiert
    final file = File(localPath);
    if (await file.exists()) {
      return localPath;
    }
    
    // Sonst downloade
    return await _downloadPage(pageNumber, localPath);
  }
  
  Future<String> _downloadPage(int page, String localPath) async {
    final fileName = '${page.toString().padLeft(3, '0')}.webp';
    final url = '$baseUrl$fileName';
    
    final response = await http.get(Uri.parse(url));
    final file = File(localPath);
    await file.writeAsBytes(response.bodyBytes);
    
    return localPath;
  }
  
  Future<String> _getLocalPath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mushafDir = Directory('${appDir.path}/$localDir');
    if (!await mushafDir.exists()) {
      await mushafDir.create(recursive: true);
    }
    return '${mushafDir.path}/$fileName';
  }
}
```

Dann in PhotoViewGallery:
```dart
imageProvider: FileImage(File(await downloadManager.getPagePath(logicalPage + 1))),
```

## 4. Progressive Loading

### Thumbnail-First Ansatz
```dart
// Zeige zuerst kleines Thumbnail, dann Full-Res
FadeInImage(
  placeholder: AssetImage('assets/mushaf_thumbs/${_formatPageNumber(page)}.jpg'),
  image: AssetImage('assets/mushaf_pages/${_formatPageNumber(page)}.webp'),
  fit: BoxFit.contain,
)
```

## 5. Memory Management

### Dispose Pattern
```dart
@override
void dispose() {
  // Cache leeren wenn Seite verlassen wird
  imageCache.clear();
  imageCache.clearLiveImages();
  
  _pageController.dispose();
  super.dispose();
}
```

## 6. PDF Alternative (Kleinere App-Größe)

### flutter_pdfview Package
```yaml
dependencies:
  flutter_pdfview: ^1.3.2
```

```dart
// Nur 1 PDF-Datei statt 604 PNGs (10-50 MB statt 1-3 GB!)
PDFView(
  filePath: 'assets/mushaf.pdf',
  pageNumber: _currentPage,
  onPageChanged: (page, total) {
    setState(() => _currentPage = page!);
  },
)
```

**Vorteil**: Kleinste App-Größe
**Nachteil**: Langsamer Zoom, weniger Kontrolle

## 7. Empfohlene Reihenfolge

1. **Start**: WebP Format, 720p Auflösung (200-800 MB total)
2. **Preloading**: ±1 Seite vorladen
3. **Cache**: 100 Bilder im RAM (nicht 1000)
4. **Später**: Download-Mechanismus für große Projekte
5. **Alternative**: PDF für kleinste App-Größe

## 8. Testing

```bash
# APK-Größe prüfen
flutter build apk --split-per-abi
# Ergebnis: 3 APKs (arm64, armv7, x86_64) je 20-30 MB + Assets

# Asset-Größe checken
du -sh assets/mushaf_pages/
```

## 9. Mushaf-Quellen

### Kostenlose hochqualitative Mushaf-Bilder:
- **Tanzil.net**: Bietet Quran-Seiten als Bilder
- **Madani Mushaf**: Standard 604-Seiten Layout
- **King Fahd Complex**: Offizielle Mushaf-Scans

Download-Links und Scripts erstelle ich gerne auf Anfrage!
