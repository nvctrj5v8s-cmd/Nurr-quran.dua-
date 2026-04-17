#!/usr/bin/env python3
"""
Convert a Quran translation CSV export with metadata comments into
simple surah JSON files.

The input format expected here matches files like:
quran_translations/english_saheeh_v1.1.2-csv.1.csv
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any


HEADER = ["id", "sura", "aya", "translation", "footnotes"]
FOOTNOTE_MARKER_PATTERN = re.compile(r"\[(\d+)\]")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert Quran translation CSV files into clean, scalable JSON."
    )
    parser.add_argument(
        "input_csv",
        nargs="?",
        default="quran_translations/english_saheeh_v1.1.2-csv.1.csv",
        help="Path to the source CSV file.",
    )
    parser.add_argument(
        "--output-root",
        default="quran_translations/json",
        help="Base output directory for generated JSON.",
    )
    return parser.parse_args()


def normalize_slug(path: Path) -> str:
    return path.stem.replace(" ", "_")


def parse_source_file(csv_path: Path) -> tuple[dict[str, str], list[dict[str, str]]]:
    metadata: dict[str, str] = {}
    header_index: int | None = None

    with csv_path.open("r", encoding="utf-8", newline="") as handle:
        raw_lines = handle.readlines()

    for index, line in enumerate(raw_lines):
        stripped = line.strip()
        if stripped == ",".join(HEADER):
            header_index = index
            break

        if stripped.startswith("# "):
            content = stripped[2:]
            if ":" in content:
                key, value = content.split(":", 1)
                metadata[key.strip().lower().replace(" ", "_")] = value.strip()

    if header_index is None:
        raise ValueError(f"CSV header not found in {csv_path}")

    rows_text = "".join(raw_lines[header_index:])
    reader = csv.DictReader(io.StringIO(rows_text))
    rows = [dict(row) for row in reader]
    return metadata, rows


def build_ayah(row: dict[str, str]) -> str:
    translation = row["translation"].strip()
    translation = FOOTNOTE_MARKER_PATTERN.sub("", translation)
    translation = re.sub(r"\s{2,}", " ", translation)
    return translation.strip()


def validate_rows(rows: list[dict[str, str]]) -> None:
    previous_id = 0
    seen_pairs: set[tuple[int, int]] = set()

    for row in rows:
        global_id = int(row["id"])
        surah = int(row["sura"])
        ayah = int(row["aya"])

        if global_id != previous_id + 1:
            raise ValueError(f"Unexpected id sequence near id={global_id}")
        previous_id = global_id

        pair = (surah, ayah)
        if pair in seen_pairs:
            raise ValueError(f"Duplicate surah/ayah pair found: {surah}:{ayah}")
        seen_pairs.add(pair)


def build_surah_documents(
    metadata: dict[str, str], rows: list[dict[str, str]], source_csv: Path
) -> tuple[dict[int, dict[str, Any]], dict[str, Any]]:
    validate_rows(rows)

    grouped_rows: dict[int, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped_rows[int(row["sura"])].append(row)

    surah_docs: dict[int, dict[str, Any]] = {}
    for surah_number, surah_rows in sorted(grouped_rows.items()):
        ayahs = [build_ayah(row) for row in surah_rows]

        for expected_ayah, ayah_doc in enumerate(ayahs, start=1):
            actual_ayah = int(surah_rows[expected_ayah - 1]["aya"])
            if actual_ayah != expected_ayah:
                raise ValueError(
                    f"Unexpected ayah sequence in surah {surah_number}: "
                    f"expected {expected_ayah}, got {actual_ayah}"
                )

        surah_docs[surah_number] = {
            "surah": surah_number,
            "verses": {
                str(index): ayah
                for index, ayah in enumerate(ayahs, start=1)
            },
        }

    manifest = {
        "source_file": str(source_csv.as_posix()),
        "format_version": 1,
        "translation": {
            "id": metadata.get("translation_id"),
            "language": metadata.get("language"),
            "source": metadata.get("source"),
            "url": metadata.get("url"),
            "last_update": metadata.get("last_update"),
            "check_for_updates": metadata.get("check_for_updates"),
        },
        "counts": {
            "surahs": len(surah_docs),
            "ayahs": len(rows),
        },
        "surahs": [
            {
                "surah": surah_number,
                "ayah_count": len(surah_docs[surah_number]["verses"]),
                "path": f"surah_{surah_number}.json",
            }
            for surah_number in sorted(surah_docs)
        ],
    }
    return surah_docs, manifest


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def main() -> None:
    args = parse_args()
    input_csv = Path(args.input_csv).resolve()
    output_root = Path(args.output_root).resolve()

    if not input_csv.exists():
        raise FileNotFoundError(f"Input file not found: {input_csv}")

    metadata, rows = parse_source_file(input_csv)
    surah_docs, manifest = build_surah_documents(metadata, rows, input_csv)

    dataset_root = output_root / normalize_slug(input_csv)
    write_json(dataset_root / "manifest.json", manifest)

    for surah_number, payload in surah_docs.items():
        write_json(dataset_root / f"surah_{surah_number}.json", payload)

    print(f"Input: {input_csv}")
    print(f"Output: {dataset_root}")
    print(f"Surahs written: {manifest['counts']['surahs']}")
    print(f"Ayahs written: {manifest['counts']['ayahs']}")


if __name__ == "__main__":
    main()
