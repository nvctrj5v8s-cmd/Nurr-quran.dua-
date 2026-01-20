# PDF zu PNG Konverter mit ImageMagick
# Konvertiert jede Seite der PDF in ein separates PNG-Bild

$pdfPath = "C:\Users\moham\Desktop\Holy Quran Arabic King Fahd Complex For Printing.pdf"
$outputDir = "C:\Users\moham\quran\assets\mushaf_pages"

Write-Host "📖 PDF: $pdfPath" -ForegroundColor Cyan
Write-Host "💾 Ausgabe: $outputDir" -ForegroundColor Cyan
Write-Host ""

# Erstelle Ausgabe-Ordner falls nicht vorhanden
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Lösche alte Bilder
Write-Host "🗑️  Lösche alte Bilder..." -ForegroundColor Yellow
Remove-Item "$outputDir\*.png" -Force -ErrorAction SilentlyContinue

Write-Host "🔄 Konvertiere PDF zu PNG (DPI: 150, Qualität: 90%)..." -ForegroundColor Green
Write-Host "⏳ Das dauert einige Minuten, bitte warten..." -ForegroundColor Yellow
Write-Host ""

try {
    # ImageMagick Befehl: Konvertiere alle Seiten zu PNG
    # -density 150: Auflösung (150 DPI ist gut für Bildschirm)
    # -quality 90: PNG Kompression
    # %03d: 001, 002, 003...
    
    $startTime = Get-Date
    
    magick convert -density 150 -quality 90 "$pdfPath" "$outputDir\%03d.png"
    
    $duration = (Get-Date) - $startTime
    $minutes = [math]::Floor($duration.TotalMinutes)
    $seconds = $duration.Seconds
    
    Write-Host ""
    Write-Host "✅ FERTIG in $minutes Min $seconds Sek!" -ForegroundColor Green
    
    # Zähle erstellte Bilder
    $count = (Get-ChildItem "$outputDir\*.png" | Measure-Object).Count
    Write-Host "📊 $count Bilder erstellt" -ForegroundColor Cyan
    
    # Zeige erste 3 Dateien
    Write-Host ""
    Write-Host "📁 Erste Dateien:" -ForegroundColor Cyan
    Get-ChildItem "$outputDir\*.png" | Select-Object -First 3 | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Host "   $($_.Name) - ${sizeMB} MB"
    }
    
} catch {
    Write-Host "❌ FEHLER: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Stelle sicher dass:" -ForegroundColor Yellow
    Write-Host "   1. ImageMagick installiert ist (magick --version)" -ForegroundColor Yellow
    Write-Host "   2. Die PDF-Datei existiert" -ForegroundColor Yellow
    Write-Host "   3. Genug Speicherplatz vorhanden ist (ca. 1-2 GB)" -ForegroundColor Yellow
}
