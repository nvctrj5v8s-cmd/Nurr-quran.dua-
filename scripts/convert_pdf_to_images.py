"""
PDF zu Bilder Konverter für Mushaf
Konvertiert Holy Quran PDF in einzelne PNG Seiten
"""
import os
from pdf2image import convert_from_path
from PIL import Image

# Pfade
PDF_PATH = r"C:\Users\moham\Desktop\Holy Quran Arabic King Fahd Complex For Printing.pdf"
OUTPUT_DIR = r"C:\Users\moham\quran\assets\mushaf_pages"

# Stelle sicher dass Output-Ordner existiert
os.makedirs(OUTPUT_DIR, exist_ok=True)

print(f"📖 Konvertiere PDF: {PDF_PATH}")
print(f"💾 Ausgabe nach: {OUTPUT_DIR}")
print("⏳ Das kann einige Minuten dauern...\n")

try:
    # Konvertiere PDF zu Bildern
    # DPI=150 für gute Qualität bei vernünftiger Dateigröße
    print("🔄 Lade PDF und konvertiere Seiten...")
    images = convert_from_path(
        PDF_PATH,
        dpi=150,  # Auflösung
        fmt='png',  # Format
        thread_count=4  # Parallel verarbeiten
    )
    
    total_pages = len(images)
    print(f"✅ {total_pages} Seiten gefunden\n")
    
    # Speichere jede Seite
    for i, image in enumerate(images, start=1):
        # Dateiname: 001.png, 002.png, etc.
        filename = f"{i:03d}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)
        
        # Optional: Bild optimieren (reduziere Dateigröße)
        # image = image.convert('RGB')  # Wenn Probleme mit Transparenz
        
        image.save(filepath, 'PNG', optimize=True)
        
        # Progress
        if i % 10 == 0 or i == total_pages:
            print(f"✅ Seite {i}/{total_pages} gespeichert")
    
    print(f"\n🎉 Fertig! {total_pages} Bilder erstellt in:")
    print(f"   {OUTPUT_DIR}")
    
except FileNotFoundError:
    print("❌ FEHLER: PDF nicht gefunden!")
    print(f"   Überprüfe ob die Datei existiert: {PDF_PATH}")
    
except Exception as e:
    print(f"❌ FEHLER beim Konvertieren: {e}")
    print("\n💡 Hinweis: Für PDF-Konvertierung brauchen wir auch poppler-utils")
    print("   Download: https://github.com/oschwartz10612/poppler-windows/releases/")
    print("   Entpacke und füge den 'bin' Ordner zum PATH hinzu")
