#!/usr/bin/env python3
from pypdf import PdfReader
from pdf2image import convert_from_path
import os
from pathlib import Path

# Pfade
pdf_path = r'C:\Users\moham\quran\assets\assets\The_Holy_Quran_English.pdf'
output_dir = r'C:\Users\moham\quran\assets\mushaf_pages_en'

# Zielverzeichnis erstellen
os.makedirs(output_dir, exist_ok=True)

# Versuche mit pypdf zu lesen (zum Zählen)
print(f"Lade PDF: {pdf_path}")
try:
    reader = PdfReader(pdf_path)
    total_pages = len(reader.pages)
    print(f"Gesamtseiten: {total_pages}")
except Exception as e:
    print(f"Fehler mit pypdf: {e}")
    print("Versuche pdf2image...")

# Seiten zum Ausschließen (1-basiert)
exclude_ranges = [
    (1, 13),      # Seiten 1-13
    (953, 964),   # Seiten 953-964
    (970, 978),   # Seiten 970-978
]

# In 0-basierte Indizes konvertieren
exclude_indices = set()
for start, end in exclude_ranges:
    for i in range(start - 1, end):
        exclude_indices.add(i)

print(f"Ausgeschlossene Seiten: {sorted([i+1 for i in sorted(exclude_indices)])}")

# Konvertiere mit pdf2image
print("\nKonvertiere mit pdf2image...")
try:
    images = convert_from_path(pdf_path, dpi=200)
    print(f"Bilder konvertiert: {len(images)}")
    
    output_counter = 1
    for idx, image in enumerate(images):
        page_num = idx + 1
        
        # Überspringe ausgeschlossene Seiten
        if idx in exclude_indices:
            print(f"Überspringe Seite {page_num}")
            continue
        
        # Speichere Bild
        output_filename = f"{output_counter:03d}.png"
        output_path = os.path.join(output_dir, output_filename)
        image.save(output_path, 'PNG')
        
        print(f"Seite {page_num:4d} → {output_filename}")
        output_counter += 1
    
    print(f"\nFertig! {output_counter - 1} Seiten gespeichert in {output_dir}")

except Exception as e:
    print(f"Fehler: {e}")
    print("Bitte installiere: pip install pdf2image")
    print("Und stelle sicher, dass poppler installiert ist (für Windows: scoop install poppler)")
