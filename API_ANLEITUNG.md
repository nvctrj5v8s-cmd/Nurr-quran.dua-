# 🔑 API SETUP ANLEITUNG

## 1️⃣ HADITH API (KOSTENLOS)
**Quelle:** https://hadith-api.vercel.app/
- ✅ Komplett kostenlos
- ✅ Keine Registrierung nötig
- ✅ Über 50.000 Hadiths

**Beispiel URL:**
```
https://hadith-api.vercel.app/hadiths/search?q=geduld&lang=de
```

**Was du tun musst:**
- NICHTS! Einfach nutzen


## 2️⃣ QURAN API (KOSTENLOS)
**Quelle:** https://api.alquran.cloud/v1/
- ✅ Komplett kostenlos
- ✅ Keine Registrierung nötig
- ✅ Deutsche Übersetzung verfügbar

**Beispiel URLs:**
```
# Alle Suren:
https://api.alquran.cloud/v1/quran/de.bubenheim

# Einzelne Surah (z.B. Al-Fatiha):
https://api.alquran.cloud/v1/surah/1/de.bubenheim
```

**Was du tun musst:**
- NICHTS! Einfach nutzen


## 3️⃣ CHATGPT API (KOSTENPFLICHTIG!)
**Quelle:** https://platform.openai.com/

**Schritte:**
1. Gehe zu: https://platform.openai.com/signup
2. Registriere dich mit E-Mail
3. Gehe zu: https://platform.openai.com/api-keys
4. Klicke "Create new secret key"
5. Kopiere den Key: `sk-proj-xxxxxxxxxxxxx`

**WICHTIG:**
- ⚠️ Kostet Geld (ca. $0.002 pro Anfrage)
- ⚠️ Du musst Kreditkarte hinterlegen
- ⚠️ Ersten $5 sind manchmal gratis (für neue Nutzer)

**Alternative (KOSTENLOS):**
- Gemini API von Google: https://ai.google.dev/
- Auch gut für Islam-Fragen
- Erste 60 Anfragen/Minute kostenlos


## 4️⃣ WIE FÜGE ICH DEN API KEY EIN?

**Für ChatGPT/Gemini:**
1. Erstelle Datei: `lib/config.dart`
2. Füge ein:
```dart
class Config {
  static const String openaiKey = 'sk-proj-DEIN_KEY_HIER';
  // ODER für Gemini:
  static const String geminiKey = 'DEIN_GEMINI_KEY_HIER';
}
```
3. **WICHTIG:** Füge in `.gitignore` hinzu:
```
lib/config.dart
```
4. Teile den Key NIEMALS öffentlich!


## 5️⃣ PACKAGES DIE WIR BRAUCHEN

In `pubspec.yaml` unter `dependencies:` hinzufügen:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # Für API Calls
  shared_preferences: ^2.2.2 # Für Gebet-Speicherung
```

Dann im Terminal:
```bash
flutter pub get
```

---

**ZUSAMMENFASSUNG:**
- ✅ Hadith API: Sofort nutzbar, kostenlos
- ✅ Quran API: Sofort nutzbar, kostenlos  
- ⚠️ ChatGPT API: Account erstellen, API Key holen, kostet Geld
- ✅ Alternative: Gemini API (kostenlos für Basic)

**Soll ich jetzt die App mit diesen APIs bauen?**
