$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($env:GODOT_BIN)) {
    Write-Host "ERROR: GODOT_BIN no esta definida." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $env:GODOT_BIN)) {
    Write-Host "ERROR: GODOT_BIN apunta a una ruta inexistente: $env:GODOT_BIN" -ForegroundColor Red
    exit 1
}

$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
$failures = 0

Write-Host "== 1/4 Import =="
& $env:GODOT_BIN --headless --path . --import
if ($LASTEXITCODE -ne 0) {
    Write-Host "FALLO: import (exit $LASTEXITCODE)" -ForegroundColor Red
    $failures++
}

Write-Host ""
Write-Host "== 2/4 Check-only =="
$scripts = @(Get-ChildItem -Path $root -Recurse -Filter *.gd |
    Where-Object { $_.FullName -notmatch '[\\/]addons[\\/]' })
if ($scripts.Count -eq 0) {
    Write-Host "  (sin scripts de proyecto)"
}
foreach ($file in $scripts) {
    $rel = "res://" + ($file.FullName.Substring($root.Length + 1) -replace '\\', '/')
    Write-Host "  $rel"
    & $env:GODOT_BIN --headless --path . --check-only --script $rel
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FALLO: $rel (exit $LASTEXITCODE)" -ForegroundColor Red
        $failures++
    }
}

Write-Host ""
Write-Host "== 3/4 Escena principal =="
$mainScene = Select-String -Path (Join-Path $root "project.godot") -Pattern '^run/main_scene="(.+)"' |
    ForEach-Object { $_.Matches[0].Groups[1].Value }
if ([string]::IsNullOrWhiteSpace($mainScene)) {
    Write-Host "  SKIP: no hay run/main_scene definida en project.godot" -ForegroundColor Yellow
} else {
    Write-Host "  $mainScene"
    & $env:GODOT_BIN --headless --path . --quit-after 60
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FALLO: escena principal (exit $LASTEXITCODE)" -ForegroundColor Red
        $failures++
    }
}

Write-Host ""
Write-Host "== 4/4 gdUnit4 =="
$gdunitLog = Join-Path $env:TEMP "espora_gdunit_verify.log"
& $env:GODOT_BIN --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests *> $gdunitLog
$gdunitExit = $LASTEXITCODE
if (Test-Path $gdunitLog) {
    Get-Content $gdunitLog | ForEach-Object { Write-Host $_ }
}
$gdunitText = ""
if (Test-Path $gdunitLog) {
    $gdunitText = Get-Content $gdunitLog -Raw
}

if ($gdunitText -match "No test cases found") {
    Write-Host "FALLO: gdUnit4 no encontro ningun test" -ForegroundColor Red
    $failures++
} else {
    $summaryMatches = [regex]::Matches($gdunitText, '(\d+) test cases \| (\d+) errors \| (\d+) failures \| (\d+) flaky \| (\d+) skipped')
    if ($summaryMatches.Count -eq 0) {
        Write-Host "FALLO: no se pudo leer el resumen de gdUnit4" -ForegroundColor Red
        $failures++
    } else {
        $summary = $summaryMatches[$summaryMatches.Count - 1]
        $totalTests = [int]$summary.Groups[1].Value
        $testErrors = [int]$summary.Groups[2].Value
        $testFailures = [int]$summary.Groups[3].Value
        $testSkipped = [int]$summary.Groups[5].Value
        $testPassed = $totalTests - $testErrors - $testFailures - $testSkipped
        Write-Host ("  Tests: {0} | pasaron: {1} | errores: {2} | fallos: {3} | omitidos: {4}" -f `
            $totalTests, $testPassed, $testErrors, $testFailures, $testSkipped)
        if ($totalTests -eq 0) {
            Write-Host "FALLO: gdUnit4 corrio 0 tests" -ForegroundColor Red
            $failures++
        }
        if ($testErrors -gt 0 -or $testFailures -gt 0) {
            Write-Host "FALLO: hay errores o fallos en los tests" -ForegroundColor Red
            $failures++
        }
    }
}

if ($gdunitExit -ne 0) {
    Write-Host "FALLO: gdUnit4 (exit $gdunitExit)" -ForegroundColor Red
    $failures++
}

Pop-Location
Write-Host ""
if ($failures -gt 0) {
    Write-Host "RESULTADO: $failures paso(s) con fallo" -ForegroundColor Red
    exit 1
}
Write-Host "RESULTADO: OK" -ForegroundColor Green
