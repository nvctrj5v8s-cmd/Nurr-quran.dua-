#!/usr/bin/env python3
import fitz  # PyMuPDF
import os
from pathlib import Path

# Pfade
pdf_path = r'C:\Users\moham\quran\assets\assets\Holy-Quran-English real.pdf'
output_dir = r'C:\Users\moham\quran\assets\mushaf_pages_en'
start_page = 17  # 1-basiert
end_page = 958   # 1-basiert

# Zielverzeichnis erstellen und alte PNGs entfernen
os.makedirs(output_dir, exist_ok=True)
for old_file in Path(output_dir).glob('*.png'):
    old_file.unlink(missing_ok=True)

# PDF laden
print(f"Lade PDF: {pdf_path}")
try:
    # Versuche direkt zu öffnen
    doc = fitz.open(pdf_path)
except fitz.FileDataError:
    # Versuche mit leerem Passwort
    print("PDF ist verschlüsselt, versuche Entschlüsselung...")
    doc = fitz.open(pdf_path)
    if not doc.authenticate(""):
        raise RuntimeError("PDF erfordert Passwort")

total_pages = len(doc)
print(f"Gesamtseiten: {total_pages}")

if start_page < 1 or end_page > total_pages or start_page > end_page:
    raise ValueError(f'Ungueltiger Bereich: {start_page}-{end_page} bei {total_pages} PDF-Seiten')

print(f"\nKonvertiere Seiten {start_page}-{end_page}")

# Seiten konvertieren
output_counter = 1
for page_idx in range(start_page - 1, end_page):
    
    page = doc[page_idx]
    
    # Hochwertige Pixmap mit Zoom erstellen
    mat = fitz.Matrix(2, 2)  # 2x Zoom für bessere Qualität
    pix = page.get_pixmap(matrix=mat, alpha=False)
    
    # Ausgabedatei speichern
    output_filename = f"{output_counter:03d}.png"
    output_path = os.path.join(output_dir, output_filename)
    pix.save(output_path)
    
    print(f"Seite {page_idx + 1:4d} → {output_filename}")
    output_counter += 1

print(f"\nFertig! {output_counter - 1} Seiten gespeichert in {output_dir}")
doc.close()
