"""
Konvertiert das deutsche Quran-PDF in einzelne JPEG-Bilder.
Seiten 28-1263 → 001.jpg bis 1236.jpg in assets/german_pages/
"""
import os
import fitz  # PyMuPDF

PDF_PATH = r"C:\Users\moham\quran\assets\assets\de_Translation_of_the_holy_kuran_in_deutsch.pdf"
OUTPUT_DIR = r"C:\Users\moham\quran\assets\german_pages"
START_PAGE = 28   # erste Seite (1-basiert)
DPI = 120

os.makedirs(OUTPUT_DIR, exist_ok=True)

doc = fitz.open(PDF_PATH)
total_pdf_pages = len(doc)
end_page = total_pdf_pages  # bis zur letzten Seite

pages_to_convert = end_page - START_PAGE + 1
print(f"PDF: {total_pdf_pages} Seiten total")
print(f"Konvertiere Seiten {START_PAGE}-{end_page} ({pages_to_convert} Seiten)")
print(f"Ausgabe: {OUTPUT_DIR}")
print(f"DPI: {DPI}\n")

matrix = fitz.Matrix(DPI / 72, DPI / 72)

for i, pdf_page_num in enumerate(range(START_PAGE - 1, end_page), start=1):
    page = doc[pdf_page_num]
    pix = page.get_pixmap(matrix=matrix, colorspace=fitz.csRGB)
    
    filename = f"{i:04d}.jpg"
    filepath = os.path.join(OUTPUT_DIR, filename)
    pix.save(filepath, jpg_quality=80)
    
    if i % 50 == 0 or i == pages_to_convert:
        print(f"✅ {i}/{pages_to_convert} - {filename}")

doc.close()
print(f"\n🎉 Fertig! {pages_to_convert} Bilder in {OUTPUT_DIR}")
print(f"Total pages: {pages_to_convert}")
