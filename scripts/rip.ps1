# Rip a Unity build to an editable project with AssetRipper 2.0.0 (headless web server)
# Usage: .\rip.ps1 -GameData "C:\...\A1_Data" -Out "C:\...\GH_Rip"

param(
    [Parameter(Mandatory=$true)][string]$GameData,
    [Parameter(Mandatory=$true)][string]$Out,
    [string]$RipperDir = "$env:TEMP\AssetRipper",
    [int]$Port = 8123
)

$ErrorActionPreference = 'Stop'
$exe = Join-Path $RipperDir "AssetRipper.GUI.Free.exe"

if (-not (Test-Path $exe)) {
    Write-Host "Downloading AssetRipper 2.0.0..."
    New-Item -ItemType Directory -Force -Path $RipperDir | Out-Null
    $zip = Join-Path $RipperDir "ar.zip"
    Invoke-WebRequest "https://github.com/AssetRipper/AssetRipper/releases/download/2.0.0/AssetRipper_win_x64.zip" -OutFile $zip -UseBasicParsing
    # Expand-Archive can fail on locked binaries; prefer 7z
    & "C:\Program Files\7-Zip\7z.exe" x $zip -o"$RipperDir" -y -bso0 -bsp0
}

if (-not (Test-Path $GameData)) { throw "Game data dir not found: $GameData" }
New-Item -ItemType Directory -Force -Path $Out | Out-Null

Write-Host "Starting AssetRipper on port $Port..."
Start-Process -FilePath $exe -ArgumentList "--headless","--port","$Port" -WindowStyle Hidden
Start-Sleep -Seconds 12

# Field name is lowercase 'path'
Write-Host "Loading $GameData ..."
Invoke-WebRequest "http://localhost:$Port/LoadFolder" -Method Post `
    -Body @{ path = $GameData } -UseBasicParsing -MaximumRedirection 0 `
    -ErrorAction SilentlyContinue | Out-Null

# Load completes when CPU stops climbing; poll for stability
$lastCpu = -1; $stable = 0
while ($stable -lt 3) {
    Start-Sleep -Seconds 15
    $p = Get-Process AssetRipper* -ErrorAction SilentlyContinue
    if (-not $p) { throw "AssetRipper exited during load" }
    if ([math]::Abs($p.CPU - $lastCpu) -lt 1) { $stable++ } else { $stable = 0 }
    $lastCpu = $p.CPU
    Write-Host ("  load: CPU={0:N0}s RAM={1:N0}MB" -f $p.CPU, ($p.WorkingSet64/1MB))
}

Write-Host "Exporting Unity project to $Out ..."
# NOTE: this POST does not return until export finishes; a client timeout is harmless
# (export continues server-side). We poll the output directory instead.
try {
    Invoke-WebRequest "http://localhost:$Port/Export/UnityProject" -Method Post `
        -Body @{ path = $Out; CreateSubfolder = "false" } -UseBasicParsing `
        -MaximumRedirection 0 -TimeoutSec 30 -ErrorAction SilentlyContinue | Out-Null
} catch { }

$lastSize = -1; $stable = 0
while ($stable -lt 4) {
    Start-Sleep -Seconds 30
    $size = (Get-ChildItem $Out -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object Length -Sum).Sum
    if ($size -eq $lastSize) { $stable++ } else { $stable = 0 }
    $lastSize = $size
    Write-Host ("  export: {0:N0} MB" -f ($size/1MB))
}

# AssetRipper writes into ExportedProject/ regardless of CreateSubfolder
$proj = Join-Path $Out "ExportedProject"
if (Test-Path $proj) { $Out = $proj }

$m = Get-ChildItem $Out -Recurse -File | Measure-Object Length -Sum
"Done: {0:N0} files, {1:N2} GiB -> {2}" -f $m.Count, ($m.Sum/1GB), $Out

$scripts = Join-Path $Out "Assets\Scripts"
if (Test-Path $scripts) {
    Get-ChildItem $scripts -Directory | ForEach-Object {
        "  {0}: {1} files" -f $_.Name, (Get-ChildItem $_.FullName -Recurse -File).Count
    }
}
Get-Content (Join-Path $Out "ProjectSettings\ProjectVersion.txt") -ErrorAction SilentlyContinue
