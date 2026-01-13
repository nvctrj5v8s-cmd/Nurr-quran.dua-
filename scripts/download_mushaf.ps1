#!/usr/bin/env pwsh
# Mushaf Pages Downloader - Lädt alle 604 Seiten vom Madani Mushaf

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Mushaf Pages Downloader (604 Seiten)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$outputDir = "assets/mushaf_pages"
$totalPages = 604
$downloaded = 0
$skipped = 0
$failed = 0

# Erstelle Verzeichnis
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "✓ Verzeichnis erstellt: $outputDir" -ForegroundColor Green
}

Write-Host "Quelle: Quran.com CDN (Madani Mushaf)" -ForegroundColor Yellow
Write-Host "Ziel: $outputDir" -ForegroundColor Yellow
Write-Host ""

# Download-Funktion mit mehreren Backup-URLs
function Download-Page {
    param($pageNum)
    
    $filename = "{0:D3}.png" -f $pageNum
    $filepath = Join-Path $outputDir $filename
    
    # Skip wenn existiert und > 50KB
    if (Test-Path $filepath) {
        $size = (Get-Item $filepath).Length
        if ($size -gt 50000) {
            return "skipped"
        }
    }
    
    # Verschiedene CDN-URLs probieren
    $urls = @(
        "https://static.qurancdn.com/images/w/$filename",
        "https://cdn.qurancdn.com/images/w/$filename",
        "https://quran.com/images/w/$filename"
    )
    
    foreach ($url in $urls) {
        try {
            $response = Invoke-WebRequest -Uri $url -OutFile $filepath -TimeoutSec 5 -ErrorAction Stop
            
            # Validiere Download
            $size = (Get-Item $filepath).Length
            if ($size -gt 10000) {
                return "success"
            } else {
                Remove-Item $filepath -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Nächste URL probieren
            continue
        }
    }
    
    return "failed"
}

Write-Host "Starte Download..." -ForegroundColor Green
Write-Host ""

# Download Loop
for ($page = 1; $page -le $totalPages; $page++) {
    $result = Download-Page $page
    
    switch ($result) {
        "success" {
            Write-Host "✓ Seite $page" -ForegroundColor Green -NoNewline
            $downloaded++
        }
        "skipped" {
            Write-Host "○ Seite $page (existiert)" -ForegroundColor DarkGray -NoNewline
            $skipped++
        }
        "failed" {
            Write-Host "✗ Seite $page" -ForegroundColor Red -NoNewline
            $failed++
        }
    }
    
    # Fortschrittsanzeige alle 20 Seiten
    if ($page % 20 -eq 0) {
        $percent = [math]::Round(($page / $totalPages) * 100, 1)
        Write-Host ""
        Write-Host "   → Fortschritt: $percent% ($page/$totalPages)" -ForegroundColor Cyan
    } else {
        Write-Host " " -NoNewline
    }
    
    # Kleine Pause um Server nicht zu überlasten
    Start-Sleep -Milliseconds 50
}

Write-Host ""
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Download abgeschlossen!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Neu heruntergeladen: $downloaded Seiten" -ForegroundColor Green
Write-Host "○ Bereits vorhanden:   $skipped Seiten" -ForegroundColor DarkGray
if ($failed -gt 0) {
    Write-Host "✗ Fehlgeschlagen:      $failed Seiten" -ForegroundColor Red
}
Write-Host ""

$total = $downloaded + $skipped
if ($total -eq $totalPages) {
    Write-Host "🎉 Alle $totalPages Seiten verfügbar!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Jetzt kannst du die App starten:" -ForegroundColor Cyan
    Write-Host "  flutter run" -ForegroundColor Yellow
} elseif ($failed -gt 0) {
    Write-Host "⚠️  $failed Seiten fehlen noch" -ForegroundColor Yellow
    Write-Host "Führe das Script nochmal aus für Retry" -ForegroundColor Yellow
}

Write-Host ""
