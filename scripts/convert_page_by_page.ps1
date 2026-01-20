# Konvertiere PDF Seite für Seite mit Fortschrittsanzeige
$pdfPath = "C:\Users\moham\Desktop\Holy Quran Arabic King Fahd Complex For Printing.pdf"
$outputDir = "C:\Users\moham\quran\assets\mushaf_pages"

Write-Host "📖 PDF zu PNG Konverter" -ForegroundColor Cyan
Write-Host ""

# Zähle Seiten in der PDF
Write-Host "🔍 Zähle PDF-Seiten..." -ForegroundColor Yellow
$pageCount = (magick identify -format "%n\n" "$pdfPath" | Select-Object -First 1)
Write-Host "📄 $pageCount Seiten gefunden" -ForegroundColor Green
Write-Host ""

# Erstelle Ausgabe-Ordner
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "🔄 Starte Konvertierung..." -ForegroundColor Green
$startTime = Get-Date

for ($i = 0; $i -lt $pageCount; $i++) {
    $pageNum = ($i + 1).ToString("000")
    $outputFile = "$outputDir\$pageNum.png"
    
    # Fortschritt anzeigen
    $percent = [math]::Round(($i / $pageCount) * 100, 1)
    Write-Progress -Activity "Konvertiere PDF" -Status "Seite $($i+1)/$pageCount ($percent%)" -PercentComplete $percent
    
    # Konvertiere einzelne Seite
    magick "$pdfPath[$i]" -density 150 -quality 90 $outputFile 2>$null
    
    if ($i % 50 -eq 0 -and $i -gt 0) {
        $elapsed = (Get-Date) - $startTime
        $avgPerPage = $elapsed.TotalSeconds / $i
        $remaining = ($pageCount - $i) * $avgPerPage
        Write-Host "⏱️  Seite $i/$pageCount - Geschätzt noch $([math]::Round($remaining/60, 1)) Min" -ForegroundColor Cyan
    }
}

Write-Progress -Activity "Konvertiere PDF" -Completed

$duration = (Get-Date) - $startTime
$minutes = [math]::Floor($duration.TotalMinutes)
$seconds = $duration.Seconds

Write-Host ""
Write-Host "✅ FERTIG in $minutes Min $seconds Sek!" -ForegroundColor Green

# Zähle erstellte Bilder
$count = (Get-ChildItem "$outputDir\*.png" | Measure-Object).Count
Write-Host "📊 $count Bilder erstellt" -ForegroundColor Cyan
