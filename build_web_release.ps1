###############################################################################
# build_web_release.ps1 — Production web build for 4Directions Farmer
#
# Builds the Flutter web app with maximum optimization and pre-compresses
# all large files (JS, WASM, CSS) so servers with static compression can
# serve them without runtime overhead.
#
# Usage:
#   .\build_web_release.ps1          # build + compress
#   .\build_web_release.ps1 -SkipBuild   # compress only (use existing build)
#   .\build_web_release.ps1 -NoBrotli    # gzip only (if brotli unavailable)
#
# After running, deploy the entire build\web folder to your host.
# Server configuration files are in the web\ folder:
#   web\.htaccess    — Apache / cPanel shared hosting
#   web\web.config   — IIS / Azure Static Web Apps
#   web\firebase.json — Firebase Hosting (copy to project root before deploy)
#   netlify.toml     — Netlify (already in project root)
###############################################################################

param(
    [switch]$SkipBuild,
    [switch]$NoBrotli
)

$flutter = 'C:\flutter\bin\flutter.bat'
$webDir  = Join-Path $PSScriptRoot 'build\web'

###############################################################################
# STEP 1 — Build
###############################################################################
if (-not $SkipBuild) {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  Building Flutter web (release + -O4 + tree-shake-icons)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

    Push-Location $PSScriptRoot
    & $flutter build web --release --tree-shake-icons --no-wasm-dry-run -O4
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[ERROR] Flutter build failed (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    Pop-Location
    Write-Host "`n[OK] Flutter build succeeded" -ForegroundColor Green
}

###############################################################################
# STEP 2 — Remove .symbols files (debug-only, no runtime value, ~7 MB)
###############################################################################
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Removing .symbols files (~7 MB debug artifacts)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$symbolFiles = Get-ChildItem $webDir -Recurse -Filter '*.symbols'
$symbolsMB   = [math]::Round(($symbolFiles | Measure-Object Length -Sum).Sum / 1MB, 1)
$symbolFiles | Remove-Item -Force
Write-Host "[OK] Removed $($symbolFiles.Count) .symbols files ($symbolsMB MB saved)" -ForegroundColor Green

###############################################################################
# STEP 3 — Remove NOTICES file (legal text, not served to users; ~1.4 MB)
###############################################################################
$noticesFile = Join-Path $webDir 'assets\NOTICES'
if (Test-Path $noticesFile) {
    $noticesMB = [math]::Round((Get-Item $noticesFile).Length / 1MB, 1)
    Remove-Item $noticesFile -Force
    Write-Host "[OK] Removed NOTICES ($noticesMB MB)" -ForegroundColor Green
}

###############################################################################
# STEP 4 — Pre-compress large files with gzip
###############################################################################
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Pre-compressing files with gzip (.gz)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Extensions worth compressing (WASM and JS compress very well)
$compressExts = @('*.js', '*.wasm', '*.css', '*.html', '*.json', '*.ttf', '*.otf')

$filesToCompress = $compressExts | ForEach-Object {
    Get-ChildItem $webDir -Recurse -Filter $_ -File
} | Sort-Object FullName -Unique

$totalSaved = 0
foreach ($file in $filesToCompress) {
    $gzPath = $file.FullName + '.gz'
    
    # Create .gz file using .NET GZipStream
    $inputStream  = [System.IO.File]::OpenRead($file.FullName)
    $outputStream = [System.IO.File]::Create($gzPath)
    $gzStream     = [System.IO.Compression.GZipStream]::new(
        $outputStream,
        [System.IO.Compression.CompressionLevel]::Optimal
    )
    $inputStream.CopyTo($gzStream)
    $gzStream.Dispose()
    $outputStream.Dispose()
    $inputStream.Dispose()

    $origKB  = [math]::Round($file.Length / 1KB, 0)
    $gzKB    = [math]::Round((Get-Item $gzPath).Length / 1KB, 0)
    $saved   = $file.Length - (Get-Item $gzPath).Length
    $totalSaved += $saved
    $pct     = [math]::Round(100 - ($gzKB / $origKB * 100), 0)
    Write-Host ("  {0,-45} {1,6} KB → {2,5} KB ({3}% saved)" -f $file.Name, $origKB, $gzKB, $pct)
}

Write-Host ("[OK] Gzip: {0} MB total savings across {1} files" -f [math]::Round($totalSaved/1MB,1), $filesToCompress.Count) -ForegroundColor Green

###############################################################################
# STEP 5 — Pre-compress with Brotli (better compression, ~30% smaller than gzip)
# Uses .NET 6+ System.IO.Compression.BrotliStream
###############################################################################
if (-not $NoBrotli) {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  Pre-compressing files with Brotli (.br)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

    $brotliAvailable = $true
    try {
        [System.IO.Compression.BrotliStream] | Out-Null
    } catch {
        $brotliAvailable = $false
        Write-Host "[SKIP] BrotliStream not available on this .NET version. Use -NoBrotli to silence." -ForegroundColor Yellow
    }

    if ($brotliAvailable) {
        $brSaved = 0
        foreach ($file in $filesToCompress) {
            $brPath = $file.FullName + '.br'
            $inputStream  = [System.IO.File]::OpenRead($file.FullName)
            $outputStream = [System.IO.File]::Create($brPath)
            $brStream     = [System.IO.Compression.BrotliStream]::new(
                $outputStream,
                [System.IO.Compression.CompressionLevel]::Optimal
            )
            $inputStream.CopyTo($brStream)
            $brStream.Dispose()
            $outputStream.Dispose()
            $inputStream.Dispose()
            $brSaved += $file.Length - (Get-Item $brPath).Length
        }
        Write-Host ("[OK] Brotli: {0} MB total savings" -f [math]::Round($brSaved/1MB,1)) -ForegroundColor Green
    }
}

###############################################################################
# STEP 6 — Summary
###############################################################################
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Build Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$allFiles    = Get-ChildItem $webDir -Recurse -File
$totalMB     = [math]::Round(($allFiles | Measure-Object Length -Sum).Sum / 1MB, 1)
$jsOnlyMB    = [math]::Round(($allFiles | Where-Object Name -eq 'main.dart.js' | Measure-Object Length -Sum).Sum / 1MB, 2)
$jsGzMB      = [math]::Round(($allFiles | Where-Object Name -eq 'main.dart.js.gz' | Measure-Object Length -Sum).Sum / 1MB, 2)
$jsGzPct     = if ($jsOnlyMB -gt 0) { [math]::Round((1 - $jsGzMB / $jsOnlyMB) * 100, 0) } else { 0 }

Write-Host "  Total build size : $totalMB MB"
Write-Host "  main.dart.js     : $jsOnlyMB MB"
Write-Host "  main.dart.js.gz  : $jsGzMB MB  ($jsGzPct% smaller - what users download with compression)"
Write-Host ""
Write-Host "  Deploy folder    : build\web"
Write-Host ""
Write-Host "  SERVER REQUIREMENTS for compression to work:" -ForegroundColor Yellow
Write-Host "    Apache / cPanel  → build\web\.htaccess is already configured" -ForegroundColor Yellow
Write-Host "    IIS / Azure      → build\web\web.config is already configured" -ForegroundColor Yellow
Write-Host "    Firebase Hosting → run: firebase deploy" -ForegroundColor Yellow
Write-Host "    Netlify          → push repo, netlify.toml handles everything" -ForegroundColor Yellow
    Write-Host "    Nginx            --> add 'gzip_static on; brotli_static on;' to your server block" -ForegroundColor Yellow
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "  Done! Ready to deploy." -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
