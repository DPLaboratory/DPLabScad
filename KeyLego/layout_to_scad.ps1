#  layout_to_scad.ps1
#  ------------------------------------------------------------------
#  Converte il layout della tastiera (JSON esportato da
#  https://editor.keyboard-tools.xyz, formato KLE) nel file
#  keyboard_layout.scad, che LegoPlate.scad include.
#
#  Uso:
#    powershell -File .\layout_to_scad.ps1 [-JsonPath <file.json>]
#
#  Semantica KLE gestita:
#    "stringa"            -> tasto 1x1
#    {"w":n} {"h":n}      -> dimensioni del tasto che segue
#    {"x":n}              -> spazio orizzontale prima del tasto che segue
#    numeri / booleani    -> ignorati
#
#  Output: lista di tasti [x, y, w, h] in unita' (1u), y = indice riga.
#  ------------------------------------------------------------------

param(
    [string]$JsonPath = (Join-Path $PSScriptRoot "keyboard_layout.json"),
    [string]$OutPath  = (Join-Path $PSScriptRoot "keyboard_layout.scad")
)

$ErrorActionPreference = "Stop"
$inv = [System.Globalization.CultureInfo]::InvariantCulture

if (-not (Test-Path $JsonPath)) {
    throw "File layout non trovato: $JsonPath"
}

$data = Get-Content $JsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Fmt([double]$v) {
    $v.ToString("0.###", $inv)
}

# Da un oggetto JSON (PSCustomObject)estrae le proprieta' numeriche
function Get-Prop($obj, $name) {
    $p = $obj.PSObject.Properties[$name]
    if ($null -ne $p -and $p.Value -is [double] -or $p.Value -is [int] -or $p.Value -is [long]) {
        [double]$p.Value
    } else {
        $null
    }
}

$keys = New-Object System.Collections.Generic.List[string]
$rowIndex = 0

foreach ($row in @($data)) {
    $x = 0.0
    $pending = @{}

    foreach ($item in @($row)) {
        if ($item -is [string]) {
            # Proprieta' in attesa: si applicano a questo tasto
            $w  = if ($null -ne $pending["w"]) { [double]$pending["w"] } else { 1.0 }
            $h  = if ($null -ne $pending["h"]) { [double]$pending["h"] } else { 1.0 }
            $xo = if ($null -ne $pending["x"]) { [double]$pending["x"] } else { 0.0 }

            $keys.Add(("[{0},{1},{2},{3}]" -f (Fmt ($x + $xo)), (Fmt $rowIndex), (Fmt $w), (Fmt $h)))

            $x += $w + $xo
            $pending = @{}
        }
        elseif ($item -is [System.Management.Automation.PSCustomObject]) {
            foreach ($name in @("w", "h", "x")) {
                $v = Get-Prop $item $name
                if ($null -ne $v) { $pending[$name] = $v }
            }
        }
        # numeri, booleani, null: ignorati
    }

    $rowIndex += 1
}

$stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss", $inv)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("// AUTO-GENERATO da layout_to_scad.ps1 il $stamp - non modificare a mano")
$lines.Add("// Sorgente: $(Split-Path -Leaf $JsonPath)  ($($keys.Count) tasti, $rowIndex righe)")
$lines.Add("")
$lines.Add("layout_keys = [")
foreach ($k in $keys) { $lines.Add("    $k,") }
$lines.Add("];")
$lines.Add("")

Set-Content -Path $OutPath -Value $lines -Encoding UTF8
Write-Host "Generato $OutPath ($($keys.Count) tasti, $rowIndex righe)"
