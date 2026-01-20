"""
PDF zu Bilder Konverter mit Fortschrittsanzeige
Konvertiert jede Seite einer PDF in ein PNG-Bild
"""
import os
from pathlib import Path
from pdf2image import convert_from_path
from tqdm import tqdm

# Pfade
pdf_path = r"C:\Users\moham\Desktop\Holy Quran Arabic King Fahd Complex For Printing.pdf"
output_dir = Path(__file__).parent.parent / "assets" / "mushaf_pages"
poppler_path = r"C:\poppler\poppler-24.08.0\Library\bin"

print(f"📖 PDF: {pdf_path}")
print(f"💾 Ausgabe: {output_dir}")
print(f"⚙️  Poppler: {poppler_path}")
print()

# Erstelle Ausgabe-Ordner
output_dir.mkdir(parents=True, exist_ok=True)

try:
    # Konvertiere alle Seiten mit Fortschrittsbalken
    print("🔄 Konvertiere Seiten...")
    
    images = convert_from_path(
        pdf_path,
        dpi=150,  # Qualität (150 ist gut, 300 wäre höher aber langsamer)
        poppler_path=poppler_path,
        fmt='png',
        thread_count=4  # Nutze 4 CPU Cores parallel
    )
    
    total_pages = len(images)
    print(f"📄 {total_pages} Seiten gefunden")
    print()
    
    # Speichere jede Seite mit Fortschrittsbalken
    for i, image in enumerate(tqdm(images, desc="💾 Speichere", unit="Seite")):
        page_num = str(i + 1).zfill(3)  # 001, 002, 003...
        output_path = output_dir / f"{page_num}.png"
        image.save(output_path, 'PNG', optimize=True)
    
    print()
    print(f"✅ FERTIG! {total_pages} Bilder erstellt in: {output_dir}")
    
except Exception as e:
    print(f"❌ FEHLER: {e}")
    print()
    print("💡 Stelle sicher dass:")
    print("   1. Die PDF-Datei existiert")
    print("   2. Poppler installiert ist")
    print("   3. Genug Speicherplatz vorhanden ist")
