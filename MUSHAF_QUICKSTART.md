# Mushaf Reader - Schnellstart

## ✅ Was wurde erstellt:

### 1. **pubspec.yaml** 
- ✅ `photo_view: ^0.14.0` hinzugefügt (Zoom/Pan)
- ✅ `assets/mushaf_pages/` Ordner konfiguriert

### 2. **mushaf_reader_page.dart**
Vollständiges Widget mit:
- ✅ PageView mit RTL (rechts nach links wie echtes Buch)
- ✅ Pinch-to-Zoom + Doppeltipp-Zoom
- ✅ SharedPreferences: Merkt letzte Seite + Zoom
- ✅ 604 Seiten Support (Standard Madani Mushaf)
- ✅ Seitenzahl-Anzeige
- ✅ Sprung zu beliebiger Seite
- ✅ Navigation-Buttons

### 3. **Performance-Guide** (MUSHAF_PERFORMANCE.md)
- Caching-Strategien
- Preloading benachbarter Seiten
- WebP Konvertierung (70% kleiner als PNG)
- Download-Mechanismus
- PDF Alternative

## 🚀 So verwendest du es:

### Schritt 1: Mushaf-Bilder besorgen

Du brauchst 604 PNG/WebP Bilder:
```
assets/mushaf_pages/001.png
assets/mushaf_pages/002.png
...
assets/mushaf_pages/604.png
```

**Wo bekomme ich die Bilder?**

Option A: **Tanzil.net** (Empfohlen)
```bash
# Download-Script (erstelle ich auf Anfrage)
# Lädt automatisch alle 604 Seiten vom Madani Mushaf
```

Option B: **Selbst generieren**
- Nutze einen Quran-Font (z.B. hafs_madina)
- Generiere Seiten mit richtiger Ayah-Platzierung
- Komplexer, aber volle Kontrolle

Option C: **Kommerzielle Quellen**
- King Fahd Complex (lizenziert)
- Diverse Mushaf Apps (Rechte beachten!)

### Schritt 2: In main.dart einbinden

```dart
// In deiner QuranHomePage oder Navigation:
ListTile(
  leading: Icon(Icons.book, color: themeColor),
  title: const Text('Mushaf Ansicht'),
  subtitle: const Text('Quran wie gedrucktes Buch'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MushafReaderPage(
          themeColor: themeColor,
        ),
      ),
    );
  },
)
```

### Schritt 3: Testen

1. Füge mindestens 1 Test-Bild hinzu:
   ```
   assets/mushaf_pages/001.png
   ```

2. Baue die App:
   ```bash
   flutter pub get
   flutter run
   ```

3. Navigiere zur Mushaf-Ansicht
4. Teste Zoom (Pinch/Doppeltipp)
5. Teste Blättern (Swipe links/rechts)

## 📱 Features im Detail:

### Zoom & Navigation
- **Pinch**: Zwei Finger zum Zoomen
- **Doppeltipp**: Schnell reinzoomen
- **Swipe**: Links/Rechts blättern (RTL!)
- **Buttons**: FABs unten rechts für Navigation
- **Grid-Icon**: Direkter Sprung zu beliebiger Seite

### Persistenz
- Letzte gelesene Seite wird gespeichert
- Zoom-Level wird gespeichert
- Beim nächsten Öffnen genau da weiterlesen

### Performance
- Smooth Scrolling durch PhotoViewGallery
- Lazy Loading (nur sichtbare Seiten im RAM)
- Cache für schnelles Blättern

## 🎨 Anpassungen:

### Farben ändern
```dart
MushafReaderPage(
  themeColor: Colors.teal, // Deine Theme-Farbe
)
```

### Seitenzahl-Format ändern
```dart
// Von 001-604 zu 1-604:
String _formatPageNumber(int page) {
  return page.toString(); // Statt padLeft(3, '0')
}
```

### Andere Mushaf-Typen
```dart
// Für 15-Zeilen Mushaf (andere Seitenzahl):
static const int totalPages = 558; // Statt 604
```

## 📦 Asset-Größen:

| Format | Auflösung | Pro Seite | Gesamt (604 Seiten) |
|--------|-----------|-----------|---------------------|
| PNG    | 1080x1920 | ~3 MB     | ~1.8 GB            |
| WebP   | 1080x1920 | ~1 MB     | ~600 MB            |
| WebP   | 720x1280  | ~500 KB   | ~300 MB            |
| JPEG   | 1080x1920 | ~800 KB   | ~480 MB            |

**Empfehlung**: WebP 720p für beste Balance (300 MB)

## 🔧 Nächste Schritte:

1. **Mushaf-Bilder besorgen** (ich helfe dir dabei!)
2. **Test mit 5 Seiten** (001-005.png)
3. **Performance-Optimierung** (siehe MUSHAF_PERFORMANCE.md)
4. **Alle 604 Seiten hinzufügen**
5. **Optional**: Text-Overlay für Ayah-Highlight

## ❓ FAQ:

**Q: App wird zu groß mit 604 Bildern?**
A: Nutze WebP + Download-on-demand (siehe Performance-Guide)

**Q: Kann ich PDFs statt Bilder nutzen?**
A: Ja! Siehe MUSHAF_PERFORMANCE.md Abschnitt 6

**Q: RTL funktioniert nicht richtig?**
A: PageView nutzt `reverse: false` + Index-Umrechnung für RTL

**Q: Zoom ist zu langsam?**
A: Reduziere Bildauflösung auf 720p oder nutze WebP

Soll ich dir jetzt helfen, die Mushaf-Bilder zu besorgen? 📖
