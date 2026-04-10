#!/usr/bin/env python3
import os
from pathlib import Path

pdf_path = r'C:\Users\moham\quran\assets\assets\The_Holy_Quran_English.pdf'

# Versuche, die Verschlüsselung durch Byte-Manipulation zu entfernen
print("Lese PDF-Bytes...")
with open(pdf_path, 'rb') as f:
    pdf_data = f.read()

# Find /Encrypt and try to remove/disable it
if b'/Encrypt' in pdf_data:
    print("Gefunden: /Encrypt Dictionary - versuche zu entfernen...")
    # Ersetze /Encrypt mit /X_Encrypt (deaktiviert, aber nicht entfernt - für Kompatibilität)
    modified_data = pdf_data.replace(b'/Encrypt', b'/X_crypt')
    
    # Speichere modifizierte PDF
    temp_pdf = pdf_path.replace('.pdf', '_decrypted.pdf')
    with open(temp_pdf, 'wb') as f:
        f.write(modified_data)
    print(f"Modifizierte PDF gespeichert: {temp_pdf}")
    
    # Versuche zu öffnen
    try:
        import fitz
        doc = fitz.open(temp_pdf)
        print(f"Erfolgreich geöffnet! Seiten: {len(doc)}")
    except Exception as  e:
        print(f"Fehler beim Öffnen: {e}")
else:
    print("Kein /Encrypt Dictionary gefunden")
