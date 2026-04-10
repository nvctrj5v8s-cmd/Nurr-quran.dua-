# AGENT.md

## Zweck

Diese Datei fasst die wichtigsten Projektinformationen fuer Agenten und Mitwirkende zusammen. Sie muss bei relevanten Aenderungen am Projekt mit aktualisiert werden.

Update-Pflicht:
- Bei Aenderungen an Features, App-Flow, Ordnerstruktur, Assets, Dependencies, externen APIs, Permissions, lokal gespeicherten Daten oder Legal-Texten muss diese Datei geprueft und aktualisiert werden.
- Privacy Policy und Support-Seite muessen immer mit dem echten technischen Stand des Projekts uebereinstimmen.

## Projektueberblick

Nurr ist eine Flutter-App fuer Quran- und Dua-Inhalte mit Fokus auf:
- Quran-Lesen in mehreren Darstellungen/Sprachen
- Mushaf-Ansicht mit Bildseiten
- deutsche und englische/arabische Leserouten
- Dua-Inhalte
- Gebetszeiten auf Basis des Standorts
- Gebets-Tracking / lokale Nutzungsdaten
- 99 Namen Allahs
- Theme- und Hintergrundauswahl

Technischer Stand:
- Flutter/Dart App
- Hauptlogik liegt aktuell hauptsaechlich in `lib/main.dart`
- Weitere grosse UI-/Feature-Dateien:
  - `lib/mushaf_reader_page.dart`
  - `lib/german_reader_page.dart`
  - `lib/dua_page.dart`

## Wichtige Ordner

- `lib/`: App-Code
- `assets/`: statische App-Inhalte, Bilder, Quran-/Mushaf-Seiten, Daten
- `legal/`: rechtliche Texte wie Privacy und Support
- `scripts/`: Hilfsskripte fuer Datenbeschaffung und Asset-Erzeugung
- `docs/`: Web-Deploy-Artefakte / statische Build-Ausgabe
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`: Plattformprojekte
- `build/`: generierte Build-Artefakte, nicht als fachliche Quelle behandeln
- `tools/`: lokale Hilfstools

## Aktuelle Features

- Sprachwahl fuer App-UI: Deutsch, Englisch, Arabisch
- Quran-/Mushaf-Navigation
- gespeicherte letzte Leseposition
- Bookmarks
- Dua-Seiten
- Gebetszeiten mit Standortabfrage
- Gebets- / Checklisten-Tracking
- Tasbih-/Counter-nahe lokale Zustandsdaten
- 99 Namen Allahs
- Theme- und Hintergrundanpassung
- Intro/Tutorial-Zustand

## Lokale Datenspeicherung

Die App nutzt `shared_preferences` fuer lokale Persistenz. Je nach Feature werden u. a. gespeichert:
- App-Sprache
- Theme / Hintergrund
- letzte gelesene Seite
- Bookmark-Daten
- Prayer-Tracking / Verlauf
- Intro-/Tutorial-Status
- weitere UI- und Feature-Zustaende

Wichtig:
- Wenn neue lokal gespeicherte Daten hinzukommen, muessen `legal/privacy.md` und ggf. `legal/support.md` angepasst werden.

## Externe Services / Netzwerk

Der Code nutzt aktuell externe Requests u. a. zu:
- `https://api.alquran.cloud/` fuer Quran-Inhalte
- `https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/` fuer Hadith-Inhalte
- `https://ipapi.co/json/` fuer Web-Fallback bei Standortermittlung
- `https://api.aladhan.com/v1/timings` fuer Gebetszeiten

Moeglich je nach Plattform/Build:
- `google_fonts` kann externe Font-Infrastruktur nutzen

Wichtig:
- Neue APIs, CDNs oder Drittanbieter muessen in `AGENT.md` und den Legal-Texten nachgezogen werden.
- Fuer neue Endpunkte moeglichst HTTPS verwenden.

## Permissions / Plattformhinweise

Aktuell relevant:
- Internet
- coarse location
- fine location
- iOS Location Usage Descriptions in `ios/Runner/Info.plist`

Wenn sich Permissions aendern:
- Plattformdateien aktualisieren
- Privacy Policy aktualisieren
- Store-Angaben pruefen

## Code-Struktur und Arbeitsweise

Aktueller Realitaetscheck:
- `lib/main.dart` ist gross und enthaelt viel Feature-Logik.
- Es existieren Backup-/Altdateien wie `main_backup.dart`, `main23.dart`, `main.dart.backup`, `main.dart_clean_part1`.

Richtlinien:
- Neue Features nicht weiter ungeordnet in `main.dart` stapeln, wenn es vermeidbar ist.
- Fachlogik, Widgets, Modelle und Services sauber trennen.
- Kleine, klar benannte Dateien bevorzugen.
- Ordner kurz und uebersichtlich halten.
- Keine unnoetigen Tiefen in der Ordnerstruktur.
- Generierte Dateien und Build-Outputs nicht manuell als fachliche Quelle bearbeiten, ausser es ist explizit Teil des Tasks.

## Flutter Best Practices

Es soll sich an Best Practices gehalten werden:
- kleine Widgets statt uebergrosser Monolith-Dateien
- klare Trennung von UI, Zustand, Datenzugriff und Hilfslogik
- sprechende Namen fuer Klassen, Methoden, Keys und Dateien
- `const` nutzen, wo sinnvoll
- unnoetige Rebuilds vermeiden
- Async-Logik robust behandeln
- Fehlerfaelle bei Netzwerk- und Asset-Zugriff explizit abfangen
- nur wirklich benoetigte Dependencies aufnehmen
- keine toten Backups oder ungenutzten Dateien weiter vermehren
- bestehende Lint-Regeln respektieren (`flutter_lints`)
- Performance bei grossen Bild-Assets mitdenken
- Plattformbesonderheiten fuer Web, Android und iOS beruecksichtigen

## Legal- und Konsistenzregel

Rechtliche Texte muessen technisch korrekt bleiben. Bei jeder Aenderung an:
- Storage
- Tracking
- Analytics
- Crash Reporting
- Ads
- Login / Account
- Zahlungsfunktionen
- Permissions
- Standortnutzung
- Drittanbieter-APIs

muessen mindestens diese Dateien geprueft werden:
- `legal/privacy.md`
- `legal/support.md`
- `AGENT.md`

## Was Agenten vor Aenderungen pruefen sollen

- Welche Feature-Dateien wirklich produktiv verwendet werden
- Ob eine Aenderung neue lokale Daten speichert
- Ob eine Aenderung neue Netzwerkziele oder Drittanbieter einfuehrt
- Ob Permissions oder Store-Angaben betroffen sind
- Ob bestehende Assets / grosse Bilddaten Performance-Auswirkungen haben
- Ob die Ordner- und Dateistruktur weiter schlank bleibt

## Nicht vergessen

- Diese Datei ist lebende Projektdokumentation.
- Bei jeder relevanten Projektaenderung mit aktualisieren.
