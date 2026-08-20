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
- lokalisierte Farb- und Hintergrundnamen auf Deutsch, Englisch und Arabisch
- einheitlich eingepasste Mushaf-Seiten mit Pinch-Zoom auf allen Displaygrößen
- Arabische und englische Mushaf-Seiten werden platzsparend als hochqualitative WebP-Assets ausgeliefert; deutsche JPG-Seiten bleiben unverändert.

Technischer Stand:
- Flutter/Dart App
- Modernes Nurr-UI in Creme, Weiss, Gold und dezentem Dunkelgruen mit Material 3 Navigation, responsiver Startseite und dreisprachigem Onboarding. Keine Ramadan-spezifischen Motive.
- Die produktiven Hauptseiten verwenden eine feste Nurr-Farbidentitaet. Hellmodus nutzt dunkle Texte, Dunkelmodus helle Texte.
- Sprachwahl und Onboarding sind vollstaendig codebasiert (Gradienten, Formen und Material-Symbole) und besitzen keine Abhaengigkeit von externen oder generierten Hintergrundbildern.
- Vor dem Abschluss des Onboardings wird Hell oder Dunkel gewaehlt. Die Einstellung `nurr_app_dark_mode` ist spaeter unter Mehr aenderbar und wird mit dem Quran-Lesemodus synchronisiert.
- Alte frei waehlbare Hintergrundbilder werden nicht mehr hinter den Hauptseiten gerendert und die Hintergrundauswahl ist aus der produktiven Einstellungsoberflaeche entfernt.
- Die Dua-Kategorien verwenden einheitliche Material-Symbole statt Emoji-Kacheln. Die Home-Schnellaktionen enthalten Masbaha statt eines doppelten Zugriffs auf die 99 Namen.
- Die Masbaha rendert keine alten Hintergrundbilder mehr und verwendet dieselben Nurr-Flaechen, Karten und Goldakzente wie Home.
- Die vorherige `HomePage` bleibt als nicht produktiv verwendete Rueckfallimplementierung in `lib/main.dart`. Rueckbauhinweise stehen in `REDESIGN_ROLLBACK.md`.
- Der produktive Quran-Reader arbeitet offline mit gebuendelten Textdaten statt mit Seitenbildern.
- Er bietet Arabisch mit deutscher oder englischer Uebersetzung, Nur-Arabisch und Nur-Uebersetzung, zwei Lesemodi, getrennte Schriftgroessen, Versabstand, Suche, Vers-Lesezeichen, Kopieren und Teilen.
- Home-Weiterlesen speichert die zuletzt geoeffnete Sure und den zuletzt angezeigten Seitenbeginn und oeffnet diese Lesestelle direkt wieder.
- Die Basmala wird bei Suren 2-8 und 10-114 als eigene zentrierte Ueberschrift dargestellt und nicht als Bestandteil von Vers 1; Sure 1 behaelt sie als Vers 1, Sure 9 hat keine Basmala-Ueberschrift.
- Der Quran-Reader besitzt einen persistenten Hell-/Dunkelmodus. Die Auswahl wird beim ersten Einsatz dieser Einstellung abgefragt und kann spaeter in den Anzeigeeinstellungen geaendert werden.
- In der Seitenansicht kann auf breiten Displays optional Arabisch und Uebersetzung nebeneinander oder einzeln angezeigt werden. Horizontales Wischen wechselt zur vorherigen bzw. naechsten Seite innerhalb der Sure.
- Arabischer Qurantext bleibt RTL, wird aber mit symmetrischen Seitenabstaenden, zentrierten Zeilen und einer auf breiten Displays begrenzten Lesebreite Mushaf-aehnlich dargestellt. Die Darstellung darf den gebuendelten Text niemals veraendern.
- Die Sichtbarkeit von Arabisch und Uebersetzung wird pro App-Sprache gespeichert. Bei erstmaliger arabischer UI-Nutzung ist nur der arabische Text aktiv; eine Uebersetzung muss bewusst eingeschaltet werden.
- Tafsir und Audio sind nur als spaetere Funktionen gekennzeichnet und noch nicht aktiv.
- Quran-Daten: Tanzil Uthmani 1.1, Bubenheim & Elyas und Saheeh International. Alle 6.236 Verse werden mit festen SHA-256-Pruefsummen und Strukturpruefungen validiert.
- Ein fehlgeschlagener Quran-Ladeversuch wird nicht dauerhaft im Repository zwischengespeichert; die Fehleransicht bietet einen erneuten Ladeversuch. Repository- und Widget-Tests pruefen Datenintegritaet und das sichtbare Laden der Surenliste.
- Tanzil-Uebersetzungen sind nur fuer nicht kommerzielle Nutzung freigegeben. Nurr muss daher dauerhaft kostenlos und werbefrei bleiben und darf keine In-App-Kaeufe oder Abos fuer diese Inhalte enthalten.
- Die alten grossen Mushaf-Bildordner koennen lokal noch vorhanden sein, werden aber nicht mehr ueber `pubspec.yaml` in die App gebuendelt.
- Quran-Schrift: Amiri Quran unter SIL Open Font License 1.1.
- Hauptlogik liegt aktuell hauptsaechlich in `lib/main.dart`
- Weitere grosse UI-/Feature-Dateien:
  - `lib/mushaf_reader_page.dart`
  - `lib/german_reader_page.dart`
  - `lib/dua_page.dart`
  - `lib/quran_text_reader_page.dart`
  - `lib/quran_text_repository.dart`

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
- globaler Nurr-Onboarding-Status (`nurr_onboarding_seen_v2`)
- globaler Hell-/Dunkelmodus (`nurr_app_dark_mode`)
- weitere UI- und Feature-Zustaende
- Quran-Anzeigemodus, Uebersetzungssprache, getrennte Schriftgroessen, Versabstand und Vers-Lesezeichen
- letzte Quran-Lesestelle (`quran_last_surah`, `quran_last_ayah`)

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
- Der produktive Quran-Reader benoetigt zum Lesen und Suchen keine Netzwerkverbindung. Die bestehende Al-Quran-Cloud-Nutzung gehoert zu altem Code bzw. anderen Quran-Routen.

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

## Git-Arbeitsregel

Standardvorgabe fuer dieses Projekt:
- Nicht mit zusaetzlichen Branches, Worktrees oder anderen Git-Sonderwegen arbeiten, ausser der User verlangt das ausdruecklich.
- Standardziel fuer normale Aenderungen ist `main`.
- Wenn der User bestaetigt, dass die aktuellen Aenderungen auf GitHub veroeffentlicht werden sollen, dann direkt diesen Ablauf verwenden:
- `git add .`
- `git commit -m "(Passende Beschreibung auf Deutsch)"`
- `git push origin main`
- Agenten sollen den User in sinnvollen Abstaenden aktiv fragen, ob die fertigen Aenderungen nach GitHub gepusht werden sollen.
- Nur wenn der User das ausdruecklich will, sollen Pushes ausgefuehrt werden.

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
- Im Quran-Reader wechselt horizontales Wischen nach der letzten Seite beziehungsweise am unteren Ende einer Sure zur naechsten Sure. Am Anfang fuehrt Wischen zur vorherigen Sure; die Zurueck-Navigation zur Surenuebersicht bleibt erhalten.
- Hell- und Dunkelmodus gelten konsistent fuer die gesamte App und fuer Quran-Dialoge, Einstellungen und Aktionsmenues; helle Ansichten verwenden dunkle, dunkle Ansichten helle Schrift.
