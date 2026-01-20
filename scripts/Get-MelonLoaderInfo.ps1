<#
.SYNOPSIS
    Liest wichtige Werte aus dem MelonLoader-Log aus.

.DESCRIPTION
    Parst die MelonLoader Latest.log Datei und extrahiert:
    - Game Name (fuer MelonGame-Attribut)
    - Game Developer (fuer MelonGame-Attribut)
    - Runtime Type (fuer TargetFramework)
    - Unity Version

    Die Werte werden screenreader-freundlich ausgegeben.

.PARAMETER LogPath
    Pfad zur Latest.log Datei.
    Standard: Sucht im aktuellen Verzeichnis nach MelonLoader\Latest.log

.PARAMETER GamePath
    Pfad zum Spielordner. Wird verwendet um den Log-Pfad zu finden.

.EXAMPLE
    .\Get-MelonLoaderInfo.ps1 -GamePath "C:\Program Files (x86)\Steam\steamapps\common\MeinSpiel"

.EXAMPLE
    .\Get-MelonLoaderInfo.ps1 -LogPath "C:\Spiele\MeinSpiel\MelonLoader\Latest.log"
#>

param(
    [string]$LogPath,
    [string]$GamePath
)

# Log-Pfad ermitteln
if (-not $LogPath) {
    if ($GamePath) {
        $LogPath = Join-Path $GamePath "MelonLoader\Latest.log"
    } else {
        # Versuche im aktuellen Verzeichnis
        $LogPath = "MelonLoader\Latest.log"
    }
}

Write-Host ""
Write-Host "MelonLoader Log-Parser"
Write-Host "======================"
Write-Host ""

# Pruefen ob Log existiert
if (-not (Test-Path $LogPath)) {
    Write-Host "FEHLER: Log-Datei nicht gefunden!"
    Write-Host "Gesuchter Pfad: $LogPath"
    Write-Host ""
    Write-Host "Moegliche Ursachen:"
    Write-Host "- MelonLoader ist nicht installiert"
    Write-Host "- Das Spiel wurde noch nie mit MelonLoader gestartet"
    Write-Host "- Der Pfad ist falsch"
    Write-Host ""
    Write-Host "Loesung: Starte das Spiel einmal mit MelonLoader, dann fuehre dieses Skript erneut aus."
    exit 1
}

Write-Host "Log gefunden: $LogPath"
Write-Host ""

# Log einlesen
$logContent = Get-Content $LogPath -Raw

# Werte extrahieren
$results = @{
    GameName = $null
    Developer = $null
    RuntimeType = $null
    UnityVersion = $null
    MelonLoaderVersion = $null
}

# Game Name suchen
if ($logContent -match "Game Name:\s*(.+?)[\r\n]") {
    $results.GameName = $matches[1].Trim()
}

# Game Developer suchen
if ($logContent -match "Game Developer:\s*(.+?)[\r\n]") {
    $results.Developer = $matches[1].Trim()
}

# Runtime Type suchen (net35 oder net6)
if ($logContent -match "Runtime Type:\s*(.+?)[\r\n]") {
    $results.RuntimeType = $matches[1].Trim()
}

# Unity Version suchen
if ($logContent -match "Game Engine:\s*Unity\s*v?([\d\.]+)") {
    $results.UnityVersion = $matches[1].Trim()
}

# MelonLoader Version suchen
if ($logContent -match "MelonLoader\s+v([\d\.]+)") {
    $results.MelonLoaderVersion = $matches[1].Trim()
}

# Ergebnisse ausgeben
Write-Host "Gefundene Werte:"
Write-Host "----------------"
Write-Host ""

if ($results.GameName) {
    Write-Host "Spielname: $($results.GameName)"
} else {
    Write-Host "Spielname: NICHT GEFUNDEN"
}

if ($results.Developer) {
    Write-Host "Entwickler: $($results.Developer)"
} else {
    Write-Host "Entwickler: NICHT GEFUNDEN"
}

if ($results.RuntimeType) {
    Write-Host "Runtime Type: $($results.RuntimeType)"
} else {
    Write-Host "Runtime Type: NICHT GEFUNDEN"
}

if ($results.UnityVersion) {
    Write-Host "Unity Version: $($results.UnityVersion)"
}

if ($results.MelonLoaderVersion) {
    Write-Host "MelonLoader Version: $($results.MelonLoaderVersion)"
}

Write-Host ""
Write-Host "Fuer dein Projekt:"
Write-Host "------------------"
Write-Host ""

# MelonGame-Attribut
if ($results.Developer -and $results.GameName) {
    Write-Host "MelonGame-Attribut (in Main.cs):"
    Write-Host "[assembly: MelonGame(`"$($results.Developer)`", `"$($results.GameName)`")]"
} else {
    Write-Host "WARNUNG: MelonGame-Attribut kann nicht generiert werden - Werte fehlen!"
}

Write-Host ""

# TargetFramework
if ($results.RuntimeType) {
    $framework = switch ($results.RuntimeType.ToLower()) {
        "net35" { "net472" }
        "net6" { "net6.0" }
        default { "UNBEKANNT - manuell pruefen!" }
    }

    $runtimeFolder = switch ($results.RuntimeType.ToLower()) {
        "net35" { "net35" }
        "net6" { "net6" }
        default { "UNBEKANNT" }
    }

    Write-Host "TargetFramework (in csproj):"
    Write-Host "<TargetFramework>$framework</TargetFramework>"
    Write-Host ""
    Write-Host "MelonLoader-DLLs aus Ordner: MelonLoader\$runtimeFolder\"

    if ($results.RuntimeType.ToLower() -eq "net35") {
        Write-Host ""
        Write-Host "WICHTIG: Verwende net472, NICHT netstandard2.0!"
        Write-Host "netstandard2.0 fuehrt zu stillem Fehlschlagen des Mods."
    }
} else {
    Write-Host "WARNUNG: TargetFramework kann nicht bestimmt werden - Runtime Type fehlt!"
}

Write-Host ""
Write-Host "Fertig."
