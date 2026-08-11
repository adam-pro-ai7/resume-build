# Rebuilds Adam_Resume_AUG26.pdf from resume.html
# Usage:  powershell -ExecutionPolicy Bypass -File "d:\Adam Pro Works\resume-build\build.ps1"

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chrome)) { $chrome = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" }

$src = "d:\Adam Pro Works\resume-build\resume.html"
$out = "d:\Adam Pro Works\resume-build\Adam_Resume_AUG26.pdf"

# A stale/locked Chrome profile makes --print-to-pdf silently produce nothing,
# so use a throwaway profile per run and clean it up afterwards.
$ud  = Join-Path $env:TEMP ("resume-build-" + [guid]::NewGuid().ToString('N').Substring(0,8))

if (Test-Path $out) { Remove-Item $out -Force }

$url = "file:///" + $src.Replace('\', '/').Replace(' ', '%20')

$chromeArgs = @(
    "--headless=new"
    "--disable-gpu"
    "--no-sandbox"
    "--user-data-dir=$ud"
    "--no-pdf-header-footer"
    "--virtual-time-budget=5000"
    "--print-to-pdf=$out"
    $url
)

& $chrome $chromeArgs | Out-Null

try { Remove-Item $ud -Recurse -Force -ErrorAction Stop } catch {}

if (Test-Path $out) {
    $bytes = [System.IO.File]::ReadAllBytes($out)
    $raw   = [System.Text.Encoding]::GetEncoding(28591).GetString($bytes)
    $pages = ([regex]::Matches($raw, '/Type\s*/Page[^s]')).Count
    Write-Host ("Built : " + $out)
    Write-Host ("Pages : " + $pages + "    Size: " + [math]::Round($bytes.Length / 1kb, 1) + " KB")
} else {
    Write-Host "BUILD FAILED - no PDF produced"
}
