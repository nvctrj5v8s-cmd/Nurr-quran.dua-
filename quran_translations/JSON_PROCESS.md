# Quran Translation JSON Process

Diese Ablage definiert das Zielformat fuer Quran-Uebersetzungen in diesem Projekt.

## Ziel

Neue Uebersetzungen sollen kuenftig immer in das gleiche einfache JSON-Format gebracht werden:

- eine Datei `manifest.json` pro Datensatz
- eine Datei pro Sure
- nur reiner Vers-Text
- keine Fussnoten
- keine Fussnoten-Referenzen wie `[2]`

## Script

Das Konvertierungs-Script liegt hier:

- [scripts/convert_translation_csv_to_json.py](/c:/Users/moham/quran/scripts/convert_translation_csv_to_json.py)

## Eingabe

Das Script erwartet eine CSV-Datei mit:

- einem moeglichen Metadatenblock vor dem CSV-Header
- dem Header `id,sura,aya,translation,footnotes`

## Ausgabestruktur

Die generierten Dateien liegen unter:

- `quran_translations/json/<dataset-name>/manifest.json`
- `quran_translations/json/<dataset-name>/surah_1.json`
- `quran_translations/json/<dataset-name>/surah_2.json`
- `quran_translations/json/<dataset-name>/surah_114.json`

## Verbindliches JSON-Format

`manifest.json` enthaelt:

- `source_file`
- `format_version`
- `translation`
- `counts`
- `surahs`

Beispiel:

```json
{
  "source_file": "quran_translations/example.csv",
  "format_version": 1,
  "translation": {
    "id": "english_saheeh",
    "language": "English",
    "source": "https://example.com",
    "url": "https://example.com/file",
    "last_update": "2025-06-24 16:37:27",
    "check_for_updates": "https://example.com/check"
  },
  "counts": {
    "surahs": 114,
    "ayahs": 6236
  },
  "surahs": [
    {
      "surah": 1,
      "ayah_count": 7,
      "path": "surah_1.json"
    }
  ]
}
```

Jede `surah_<nummer>.json` enthaelt:

- `surah`
- `verses`

Beispiel:

```json
{
  "surah": 1,
  "verses": {
    "1": "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
    "2": "Praise be to Allah, Lord of the worlds."
  }
}
```

## Reinigungsregeln

Beim Umwandeln muessen diese Regeln eingehalten werden:

- Fussnoten-Felder werden komplett ignoriert
- numerische Marker wie `[2]`, `[15]`, `[2017]` werden aus dem Vers-Text entfernt
- normale Uebersetzungs-Ergaenzungen wie `[All]` oder `[Your]` bleiben erhalten
- Datei-Encoding bleibt UTF-8

## Ausfuehren

Im Projektverzeichnis:

```powershell
py scripts/convert_translation_csv_to_json.py
```

Optional mit eigenem Input:

```powershell
py scripts/convert_translation_csv_to_json.py quran_translations/meine_datei.csv
```

## Hinweise fuer die App

- zuerst `manifest.json` laden
- danach nur die benoetigte Datei wie `surah_1.json` laden
- das Format ist bewusst flach gehalten, damit es einfach und skalierbar bleibt
