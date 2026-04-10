#!/usr/bin/env python3
import fitz
import os

pdf_path = r'C:\Users\moham\quran\assets\assets\The_Holy_Quran_English.pdf'
output_dir = r'C:\Users\moham\quran\assets\mushaf_pages_en'

os.makedirs(output_dir, exist_ok=True)

# Versuche mit verschiedenen Methoden
try:
    print("Versuche fitz.open mit Optionen...")
    # Öffne mit erzwungener Verarbeitung
    doc = fitz.open(pdf_path, filetype="pdf")
    print(f"Gesamtseiten: {len(doc.pages)}")
except fitz.FileDataError as e:
    print(f"FileDataError: {e}")
    print("Versuche mit ignore_errors...")
    # Öffne mit Fehler-Ignorierung
    doc = fitz.open()
    try:
        import ctypes
        # Lade die PDF mit weniger strikten Checks
        result = fitz.mupdf._pdf_open_document(pdf_path.encode(), b"")
        if result:
            print("PDF erfolgreich mit direkter mupdf API geöffnet")
    except:
        print("Direkter mupdf Zugriff nicht möglich")
        
        # Versuche mit subprocess und ghostscript
        print("Versuche mit gs (ghostscript)...")
        import subprocess
        try:
            # Versuche PDF zu konvertieren mit gs
            output_pattern = os.path.join(output_dir, '%03d.png')
            cmd = [
                'gs',
                '-q',
                '-dQUIET',
                '-dSAFER',
                '-dBATCH',
                '-dNOPAUSE',
                '-dNOPROMPT',
                '-dMaxBitmap=500000000',
                '-dAlignToPixels=0',
                '-dGridFitTT=2',
                '-sDEVICE=pngalpha',
                '-dTextAlphaBits=4',
                '-dGraphicsAlphaBits=4',
                f'-r200x200',
                f'-sOutputFile={output_pattern}',
                pdf_path,
            ]
            print(f"Führe aus: {' '.join(cmd)}")
            subprocess.run(cmd, check=True)
            print("PDF mit ghostscript konvertiert")
        except FileNotFoundError:
            print("ghostscript nicht gefunden. Bitte installiere mit: choco install ghostscript")
        except subprocess.CalledProcessError as e:
            print(f"ghostscript Fehler: {e}")
