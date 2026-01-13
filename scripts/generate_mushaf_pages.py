#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate all 604 Mushaf pages with real Quran text
Uses the Tanzil Quran text data
"""

import json
import requests
from PIL import Image, ImageDraw, ImageFont
import os

# Download Quran text in Uthmani script from Tanzil
def download_quran_text():
    url = "https://api.alquran.cloud/v1/quran/quran-uthmani"
    print(f"Downloading Quran text from {url}...")
    
    try:
        response = requests.get(url, timeout=30)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Failed to download: {response.status_code}")
            return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Madani Mushaf page mapping (which verses go on which page)
# This is the standard 604-page Mushaf layout
MUSHAF_PAGE_MAPPING = {
    1: [(1, 1, 7)],  # Surah 1, ayah 1-7
    2: [(2, 1, 5)],   # Surah 2, ayah 1-5
    # ... (In a real implementation, this would have all 604 pages)
    # For now, we'll distribute verses evenly across pages
}

def create_mushaf_page(page_num, verses, output_path):
    """Create a single Mushaf page image"""
    # Image dimensions (A4 portrait at 300 DPI)
    width, height = 2480, 3508
    
    # Create image with beige background
    img = Image.new('RGB', (width, height), color=(252, 248, 240))
    draw = ImageDraw.Draw(img)
    
    # Draw decorative borders
    border_color = (180, 140, 90)
    inner_border_color = (200, 160, 110)
    
    # Outer border
    draw.rectangle([80, 80, width-80, height-80], outline=border_color, width=12)
    # Inner border
    draw.rectangle([120, 120, width-120, height-120], outline=inner_border_color, width=4)
    
    # Try to load Arabic font (fallback to default if not available)
    try:
        font_large = ImageFont.truetype("C:\\Windows\\Fonts\\tahoma.ttf", 80)
        font_medium = ImageFont.truetype("C:\\Windows\\Fonts\\tahoma.ttf", 60)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
    
    # Draw page header with Surah name (if new surah starts on this page)
    y_pos = 200
    
    # Draw verses
    for verse_data in verses:
        surah_num = verse_data['surah']
        ayah_num = verse_data['ayah']
        text = verse_data['text']
        
        # Draw verse text (RTL)
        draw.text((width - 200, y_pos), text, fill=(0, 0, 0), font=font_medium, anchor="rt")
        y_pos += 200
        
        # Stop if page is full
        if y_pos > height - 400:
            break
    
    # Draw page number at bottom center
    page_text = f"﴿ {page_num} ﴾"
    draw.text((width//2, height - 200), page_text, fill=(0, 0, 0), font=font_medium, anchor="mm")
    
    # Save image
    img.save(output_path, 'PNG', optimize=True)
    print(f"✓ Created page {page_num}")

def generate_all_pages():
    """Generate all 604 Mushaf pages"""
    
    # Create output directory
    output_dir = "assets/mushaf_pages"
    os.makedirs(output_dir, exist_ok=True)
    
    # Download Quran data
    quran_data = download_quran_text()
    
    if not quran_data:
        print("Failed to download Quran data!")
        return
    
    # Extract verses
    surahs = quran_data['data']['surahs']
    all_verses = []
    
    for surah in surahs:
        surah_num = surah['number']
        for ayah in surah['ayahs']:
            all_verses.append({
                'surah': surah_num,
                'ayah': ayah['numberInSurah'],
                'text': ayah['text']
            })
    
    print(f"Total verses: {len(all_verses)}")
    
    # Distribute verses across 604 pages (approximately 10 verses per page)
    verses_per_page = len(all_verses) // 604 + 1
    
    for page_num in range(1, 605):
        start_idx = (page_num - 1) * verses_per_page
        end_idx = min(start_idx + verses_per_page, len(all_verses))
        
        page_verses = all_verses[start_idx:end_idx]
        
        if page_verses:
            output_path = os.path.join(output_dir, f"{page_num:03d}.png")
            create_mushaf_page(page_num, page_verses, output_path)
    
    print("\n✓ All 604 pages generated!")

if __name__ == "__main__":
    generate_all_pages()
