#!/usr/bin/env python3
"""
Mushaf Test-Seite Generator
Erstellt Demo-Bilder für assets/mushaf_pages/
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_demo_pages(num_pages=5):
    """Erstelle Demo-Seiten für Testing"""
    
    output_dir = "assets/mushaf_pages"
    os.makedirs(output_dir, exist_ok=True)
    
    # Seiten-Größe (Portrait)
    width, height = 1080, 1620  # Ähnlich A4 im Portrait
    
    for page in range(1, num_pages + 1):
        # Erstelle leeres Bild mit beiger Farbe (wie altes Papier)
        img = Image.new('RGB', (width, height), color=(245, 239, 224))
        draw = ImageDraw.Draw(img)
        
        # Rahmen
        margin = 50
        draw.rectangle(
            [(margin, margin), (width-margin, height-margin)],
            outline=(139, 90, 43),
            width=3
        )
        
        # Seitenzahl oben
        try:
            # Versuche eine größere Font zu laden
            font_large = ImageFont.truetype("arial.ttf", 80)
            font_small = ImageFont.truetype("arial.ttf", 40)
        except:
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        # Seitenzahl
        page_text = f"صفحة {page}"
        bbox = draw.textbbox((0, 0), page_text, font=font_large)
        text_width = bbox[2] - bbox[0]
        draw.text(
            ((width - text_width) // 2, 100),
            page_text,
            fill=(0, 0, 0),
            font=font_large
        )
        
        # Placeholder Text
        demo_text = f"DEMO SEITE {page}/604"
        bbox = draw.textbbox((0, 0), demo_text, font=font_small)
        text_width = bbox[2] - bbox[0]
        draw.text(
            ((width - text_width) // 2, height // 2),
            demo_text,
            fill=(100, 100, 100),
            font=font_small
        )
        
        # Speichere als PNG
        filename = f"{page:03d}.png"
        filepath = os.path.join(output_dir, filename)
        img.save(filepath, quality=95)
        print(f"✓ Erstellt: {filepath}")
    
    print(f"\n✅ {num_pages} Demo-Seiten erstellt in {output_dir}/")
    print("\nJetzt kannst du die App starten und zum Mushaf-Button gehen!")

if __name__ == "__main__":
    create_demo_pages(5)  # Erstelle 5 Test-Seiten
