# Extract the base game only (excludes optional costume content + installer)
# Usage: .\extract-base.ps1 -Archive "C:\path\to\GuiltyHell_A1.7z" [-Out "C:\path\to\out"]

param(
    [Parameter(Mandatory=$true)][string]$Archive,
    [string]$Out = ".\GuiltyHell_Base",
    [string]$SevenZip = "C:\Program Files\7-Zip\7z.exe"
)

if (-not (Test-Path $SevenZip)) { throw "7-Zip not found at $SevenZip" }
if (-not (Test-Path $Archive)) { throw "Archive not found: $Archive" }

# NOTE: use -xr! (recursive by name). The -x!*wildcard* form silently matches nothing here.
& $SevenZip x $Archive -o"$Out" `
    "-xr!additional_contents" `
    "-xr!GunslingerCostumePatch.exe" `
    -y -bso0 -bsp0

if ($LASTEXITCODE -ne 0) { throw "7z failed with exit code $LASTEXITCODE" }

$m = Get-ChildItem $Out -Recurse -File | Measure-Object Length -Sum
"Extracted: {0} files, {1:N2} GiB -> {2}" -f $m.Count, ($m.Sum / 1GB), $Out
