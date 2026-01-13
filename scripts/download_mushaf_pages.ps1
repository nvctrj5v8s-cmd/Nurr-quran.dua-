# Mushaf-Seiten Downloader
# Lädt alle 604 Seiten des Madani Mushaf herunter

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Mushaf Seiten Downloader" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$outputDir = "assets/mushaf_pages"

# Erstelle Verzeichnis falls nicht vorhanden
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "Downloadquelle: Madani Mushaf (604 Seiten)" -ForegroundColor Yellow
Write-Host "Speicherort: $outputDir" -ForegroundColor Yellow
Write-Host ""

# Mehrere Quellen für Mushaf-Bilder
$sources = @(
    @{
        Name = "Quran.com CDN"
        BaseUrl = "https://cdn.qurancdn.com/images/w/{0:D3}.png"
    },
    @{
        Name = "Tanzil Backup"
        BaseUrl = "https://raw.githubusercontent.com/cpfair/quran-images/master/page{0:D3}.png"
    },
    @{
        Name = "Alternative Source"
        BaseUrl = "https://everyayah.com/data/images_png/{0:D3}.png"
    }
)

$totalPages = 604
$downloaded = 0
$failed = @()

Write-Host "Starte Download von $totalPages Seiten..." -ForegroundColor Green
Write-Host ""

for ($page = 1; $page -le $totalPages; $page++) {
    $filename = "{0:D3}.png" -f $page
    $filepath = Join-Path $outputDir $filename
    
    # Überspringe bereits vorhandene Dateien
    if (Test-Path $filepath) {
        Write-Host "✓ Seite $page existiert bereits" -ForegroundColor DarkGray
        $downloaded++
        continue
    }
    
    $success = $false
    
    # Versuche verschiedene Quellen
    foreach ($source in $sources) {
        $url = $source.BaseUrl -f $page
        
        try {
            Write-Host "  Lade Seite $page von $($source.Name)..." -NoNewline
            
            Invoke-WebRequest -Uri $url -OutFile $filepath -TimeoutSec 10 -ErrorAction Stop
            
            # Prüfe ob Datei valide ist
            $fileInfo = Get-Item $filepath
            if ($fileInfo.Length -gt 1000) {
                Write-Host " ✓" -ForegroundColor Green
                $downloaded++
                $success = $true
                break
            } else {
                Remove-Item $filepath -Force
                Write-Host " ✗ (zu klein)" -ForegroundColor Red
            }
            
        } catch {
            Write-Host " ✗" -ForegroundColor Red
        }
    }
    
    if (-not $success) {
        $failed += $page
        Write-Host "  ⚠ Seite $page konnte nicht geladen werden" -ForegroundColor Yellow
    }
    
    # Fortschritt
    if ($page % 50 -eq 0) {
        $percent = [math]::Round(($page / $totalPages) * 100)
        Write-Host ""
        Write-Host "Fortschritt: $percent% ($page/$totalPages Seiten)" -ForegroundColor Cyan
        Write-Host ""
    }
    
    # Kleine Pause um Server nicht zu überlasten
    Start-Sleep -Milliseconds 100
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Download abgeschlossen!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Erfolgreich: $downloaded Seiten" -ForegroundColor Green

if ($failed.Count -gt 0) {
    Write-Host "Fehlgeschlagen: $($failed.Count) Seiten" -ForegroundColor Red
    Write-Host "Fehlende Seiten: $($failed -join ', ')" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Tipp: Führe das Script nochmal aus für fehlende Seiten" -ForegroundColor Yellow
} else {
    Write-Host "Alle Seiten erfolgreich heruntergeladen! ✓" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starte jetzt die App mit: flutter run" -ForegroundColor Cyan
