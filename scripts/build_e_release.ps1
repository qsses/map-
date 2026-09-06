$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$py = "C:\Users\admin\AppData\Local\Programs\Python\Python310\python.exe"
$target = "E:\6666\MapFanSim_集成版_20260906_修复3"
$zip = "E:\6666\MapFanSim_集成版_20260906_修复3.zip"

Set-Location $root

& $py -m PyInstaller `
    --noconfirm `
    --clean `
    --windowed `
    --name MapFanSim `
    --add-data "data;data" `
    --add-data "input_maps;input_maps" `
    --add-data "output_maps;output_maps" `
    --add-data "download;download" `
    --add-data "update;update" `
    --add-data "backup;backup" `
    --add-data "reports;reports" `
    --add-data "logs;logs" `
    --add-data "rules;rules" `
    --hidden-import paramiko `
    --hidden-import bcrypt `
    --hidden-import cryptography `
    --hidden-import openpyxl `
    --hidden-import xlrd `
    src\MapFanSim.py

$releaseDir = Join-Path $root "release\MapFanSim"
if (Test-Path $releaseDir) {
    Remove-Item -Recurse -Force -LiteralPath $releaseDir
}
New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $root "dist\MapFanSim\*") -Destination $releaseDir

foreach ($dir in @("rules", "input_maps", "tools")) {
    $src = Join-Path $root $dir
    if (Test-Path $src) {
        Copy-Item -Recurse -Force -LiteralPath $src -Destination $releaseDir
    }
}

$dataSrc = Join-Path $root "data"
$dataDst = Join-Path $releaseDir "data"
if (Test-Path $dataSrc) {
    New-Item -ItemType Directory -Force -Path $dataDst | Out-Null
    Get-ChildItem -LiteralPath $dataSrc -File | Where-Object { $_.Name -ne "config.json" -and $_.Name -ne "config.local.json" } | ForEach-Object {
        Copy-Item -Force -LiteralPath $_.FullName -Destination (Join-Path $dataDst $_.Name)
    }
}

foreach ($dir in @("output_maps", "download", "update", "backup", "reports", "logs")) {
    New-Item -ItemType Directory -Force -Path (Join-Path $releaseDir $dir) | Out-Null
}

if (Test-Path $target) {
    Rename-Item -LiteralPath $target -NewName ("MapFanSim_集成版_old_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
}
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $releaseDir "*") -Destination $target

if (Test-Path $zip) {
    Remove-Item -Force $zip
}
Compress-Archive -Path (Join-Path $target "*") -DestinationPath $zip -Force

Write-Host "Built to $target"
