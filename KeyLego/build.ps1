#  build.ps1
#  ------------------------------------------------------------------
#  Rigenera i dati del layout e esporta il modello con OpenSCAD.
#
#  Uso:
#    powershell -File .\build.ps1              # anteprima PNG
#    powershell -File .\build.ps1 -Stl         # anche STL (render F6)
#    powershell -File .\build.ps1 -Json mio_layout.json
#  ------------------------------------------------------------------

param(
    [string]$JsonPath = (Join-Path $PSScriptRoot "keyboard_layout.json"),
    [string]$OpenScad = "C:\Users\debora.presti\Software\OpenSCAD\openscad.com",
    [switch]$Stl
)

$ErrorActionPreference = "Stop"

# 1. Converte il layout JSON in keyboard_layout.scad
#    (uno script .ps1 non imposta $LASTEXITCODE: gli errori si propagano da soli)
& (Join-Path $PSScriptRoot "layout_to_scad.ps1") -JsonPath $JsonPath

# 2. Anteprima PNG
& $OpenScad --autocenter --viewall --imgsize=1200,800 `
    -o (Join-Path $PSScriptRoot "preview.png") (Join-Path $PSScriptRoot "LegoPlate.scad")
if ($LASTEXITCODE -ne 0) { throw "Anteprima fallita" }

# 3. STL su richiesta
if ($Stl) {
    & $OpenScad -o (Join-Path $PSScriptRoot "LegoPlate.stl") (Join-Path $PSScriptRoot "LegoPlate.scad")
    if ($LASTEXITCODE -ne 0) { throw "Export STL fallito" }
    Write-Host "Generato LegoPlate.stl"
}
