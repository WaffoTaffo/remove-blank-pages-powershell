$ErrorActionPreference = "Stop"

if ($args.Count -ne 3) {
    Write-Host "This script requires exactly three arguments. Use it as follows: $PSCommandPath 'input with blank pages.pdf' 'output without blank pages.pdf' 'output with only blank pages.pdf'. Aborting."
    Read-Host "Press Enter to continue..."
    exit 1
}

if (-not (Get-Command "gswin64c.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires Ghostscript, but it's not installed. Aborting."
    Read-Host "Press Enter to continue..."
    exit 1
}

if (-not (Get-Command "pdftk" -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires pdftk, but it's not installed. Aborting."
    Read-Host "Press Enter to continue..."
    exit 1
}

$numPages = 0

$pdftkOutput = pdftk.exe $args[0] dump_data | Select-String -Pattern "^NumberOfPages"
if ($pdftkOutput) {
    $numPages = ($pdftkOutput -split ':')[1].Trim()
}

$emptyPages = @()
$iterable = 1

$gswinOutput = & gswin64c.exe -o - -sDEVICE=inkcov $args[0] 2>&1 | Out-String
$nonEmptyLines = $gswinOutput -split '\r?\n' | Where-Object { $_ -match '\S' } | Where-Object { $_ -notmatch 'GPL Ghostscript' } | Where-Object { $_ -notmatch 'Copyright' } | Where-Object { $_ -notmatch 'This software' } | Where-Object { $_ -notmatch 'see the' } | Where-Object { $_ -notmatch 'Processing' } | ForEach-Object {
    $lineParts = ($_ -split '\s+')
    if ($lineParts.Count -ge 5) {
        $cyanCoverage = [double]$lineParts[1]
        $magentaCoverage = [double]$lineParts[2]
        $yellowCoverage = [double]$lineParts[3]
        $blackCoverage = [double]$lineParts[4]

        Write-Host $iterable $cyanCoverage $magentaCoverage $yellowCoverage $blackCoverage
    
        if ($cyanCoverage -lt 0.01 -and $magentaCoverage -lt 0.01 -and $yellowCoverage -lt 0.01 -and $blackCoverage -lt 0.0002) {
            $emptyPages += $iterable
        }
        $iterable += 1
    }
}

$nonEmptyPages = 1..$numPages | Where-Object { $_ -notin $emptyPages }

Write-Host "This PDF has $numPages pages"
Write-Host "These pages are empty: $($emptyPages -join ' ')"
Read-Host "Press Enter to continue..."

& pdftk.exe $args[0] cat $nonEmptyPages output $args[1]
& pdftk.exe $args[0] cat $emptyPages output $args[2]

Read-Host "Press Enter to exit..."
