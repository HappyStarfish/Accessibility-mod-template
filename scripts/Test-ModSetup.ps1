<#
.SYNOPSIS
    Validiert die Mod-Projekteinrichtung.

.DESCRIPTION
    Prueft ob alle notwendigen Dateien und Konfigurationen vorhanden sind:
    - MelonLoader Installation
    - Tolk-DLLs
    - Projektdatei (csproj)
    - Referenzen
    - MelonGame-Attribut

    Gibt klare Fehlermeldungen und Loesungsvorschlaege aus.

.PARAMETER GamePath
    Pfad zum Spielordner (wo die .exe liegt).

.PARAMETER ProjectPath
    Pfad zum Mod-Projektordner. Standard: Aktuelles Verzeichnis.

.PARAMETER Architecture
    Architektur des Spiels: "x64" oder "x86".
    Wird fuer Tolk-DLL-Pruefung benoetigt.

.EXAMPLE
    .\Test-ModSetup.ps1 -GamePath "C:\Spiele\MeinSpiel" -Architecture x64

.EXAMPLE
    .\Test-ModSetup.ps1 -GamePath "C:\Spiele\MeinSpiel" -ProjectPath "C:\Projekte\MeinMod" -Architecture x86
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$GamePath,

    [string]$ProjectPath = (Get-Location).Path,

    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64"
)

# Zaehler fuer Ergebnisse
$script:errorCount = 0
$script:warningCount = 0
$script:successCount = 0

function Write-Check {
    param(
        [string]$Name,
        [string]$Status,  # "OK", "FEHLER", "WARNUNG"
        [string]$Details = ""
    )

    switch ($Status) {
        "OK" {
            Write-Host "OK: $Name"
            $script:successCount++
        }
        "FEHLER" {
            Write-Host "FEHLER: $Name"
            $script:errorCount++
        }
        "WARNUNG" {
            Write-Host "WARNUNG: $Name"
            $script:warningCount++
        }
    }

    if ($Details) {
        Write-Host "   $Details"
    }
}

function Write-Solution {
    param([string]$Text)
    Write-Host "   Loesung: $Text"
}

Write-Host ""
Write-Host "Mod-Setup Validierung"
Write-Host "====================="
Write-Host ""
Write-Host "Spielordner: $GamePath"
Write-Host "Projektordner: $ProjectPath"
Write-Host "Architektur: $Architecture"
Write-Host ""
Write-Host "Pruefe..."
Write-Host "---------"
Write-Host ""

# ===================
# 1. SPIELORDNER
# ===================

Write-Host "1. Spielordner"
Write-Host ""

# Spielordner existiert?
if (Test-Path $GamePath) {
    Write-Check "Spielordner existiert" "OK"
} else {
    Write-Check "Spielordner existiert" "FEHLER" "Pfad nicht gefunden: $GamePath"
    Write-Solution "Pruefe den Pfad auf Tippfehler"
    Write-Host ""
    Write-Host "Abbruch - Spielordner muss existieren."
    exit 1
}

# Spiel-EXE finden
$exeFiles = Get-ChildItem -Path $GamePath -Filter "*.exe" -File | Where-Object { $_.Name -notmatch "UnityCrashHandler|UnityPlayer" }
if ($exeFiles.Count -gt 0) {
    Write-Check "Spiel-EXE gefunden" "OK" $exeFiles[0].Name
} else {
    Write-Check "Spiel-EXE gefunden" "WARNUNG" "Keine EXE im Spielordner gefunden"
}

Write-Host ""

# ===================
# 2. MELONLOADER
# ===================

Write-Host "2. MelonLoader"
Write-Host ""

$melonLoaderPath = Join-Path $GamePath "MelonLoader"

if (Test-Path $melonLoaderPath) {
    Write-Check "MelonLoader-Ordner existiert" "OK"

    # MelonLoader.dll pruefen
    $melonDll = Join-Path $melonLoaderPath "net6\MelonLoader.dll"
    $melonDll35 = Join-Path $melonLoaderPath "net35\MelonLoader.dll"

    if ((Test-Path $melonDll) -or (Test-Path $melonDll35)) {
        Write-Check "MelonLoader.dll vorhanden" "OK"
    } else {
        Write-Check "MelonLoader.dll vorhanden" "FEHLER" "DLL nicht in net6/ oder net35/ gefunden"
        Write-Solution "MelonLoader neu installieren"
    }

    # Log pruefen
    $logPath = Join-Path $melonLoaderPath "Latest.log"
    if (Test-Path $logPath) {
        Write-Check "Latest.log vorhanden" "OK"
        Write-Host "   Tipp: Fuehre Get-MelonLoaderInfo.ps1 aus um die Werte zu extrahieren"
    } else {
        Write-Check "Latest.log vorhanden" "WARNUNG" "Log nicht gefunden"
        Write-Solution "Starte das Spiel einmal mit MelonLoader"
    }

} else {
    Write-Check "MelonLoader-Ordner existiert" "FEHLER" "Ordner nicht gefunden"
    Write-Solution "MelonLoader installieren von https://github.com/LavaGang/MelonLoader.Installer/releases"
}

# Mods-Ordner
$modsPath = Join-Path $GamePath "Mods"
if (Test-Path $modsPath) {
    Write-Check "Mods-Ordner existiert" "OK"
} else {
    Write-Check "Mods-Ordner existiert" "WARNUNG" "Wird beim ersten Start erstellt"
}

Write-Host ""

# ===================
# 3. TOLK
# ===================

Write-Host "3. Tolk (Screenreader)"
Write-Host ""

$tolkDll = Join-Path $GamePath "Tolk.dll"
if (Test-Path $tolkDll) {
    Write-Check "Tolk.dll vorhanden" "OK"
} else {
    Write-Check "Tolk.dll vorhanden" "FEHLER" "Tolk.dll nicht im Spielordner"
    Write-Solution "Tolk.dll von https://github.com/ndarilek/tolk/releases herunterladen und in den Spielordner kopieren"
}

# NVDA Controller Client
$nvdaDll = if ($Architecture -eq "x64") {
    Join-Path $GamePath "nvdaControllerClient64.dll"
} else {
    Join-Path $GamePath "nvdaControllerClient32.dll"
}

$nvdaDllName = Split-Path $nvdaDll -Leaf

if (Test-Path $nvdaDll) {
    Write-Check "$nvdaDllName vorhanden" "OK"
} else {
    Write-Check "$nvdaDllName vorhanden" "FEHLER" "NVDA-DLL nicht gefunden"

    # Pruefen ob die falsche Version vorhanden ist
    $wrongDll = if ($Architecture -eq "x64") {
        Join-Path $GamePath "nvdaControllerClient32.dll"
    } else {
        Join-Path $GamePath "nvdaControllerClient64.dll"
    }

    if (Test-Path $wrongDll) {
        $wrongName = Split-Path $wrongDll -Leaf
        Write-Host "   HINWEIS: $wrongName ist vorhanden - falsche Architektur!"
        Write-Solution "Verwende die $Architecture Version aus dem Tolk-Download"
    } else {
        Write-Solution "nvdaControllerClient-DLL aus dem Tolk-Download in den Spielordner kopieren"
    }
}

Write-Host ""

# ===================
# 4. PROJEKTDATEIEN
# ===================

Write-Host "4. Projektdateien"
Write-Host ""

# csproj finden
$csprojFiles = Get-ChildItem -Path $ProjectPath -Filter "*.csproj" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch "Assembly-CSharp" }

if ($csprojFiles.Count -eq 0) {
    Write-Check "Projektdatei (csproj)" "FEHLER" "Keine csproj gefunden"
    Write-Solution "Erstelle eine csproj aus der Vorlage"
} elseif ($csprojFiles.Count -eq 1) {
    Write-Check "Projektdatei (csproj)" "OK" $csprojFiles[0].Name
    $csprojPath = $csprojFiles[0].FullName
} else {
    $names = ($csprojFiles | ForEach-Object { $_.Name }) -join ", "
    Write-Check "Projektdatei (csproj)" "WARNUNG" "Mehrere gefunden: $names"
    Write-Host "   Beim Build explizit angeben: dotnet build [Name].csproj"
    $csprojPath = $csprojFiles[0].FullName
}

# Main.cs pruefen
$mainCs = Join-Path $ProjectPath "Main.cs"
if (Test-Path $mainCs) {
    Write-Check "Main.cs vorhanden" "OK"

    # MelonGame-Attribut pruefen
    $mainContent = Get-Content $mainCs -Raw
    if ($mainContent -match '\[assembly:\s*MelonGame\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)\s*\]') {
        $dev = $matches[1]
        $game = $matches[2]
        Write-Check "MelonGame-Attribut" "OK" "Developer: $dev, Game: $game"

        # Warnen wenn Platzhalter
        if ($dev -eq "ENTWICKLER" -or $game -eq "SPIELNAME") {
            Write-Check "MelonGame-Werte" "WARNUNG" "Platzhalter noch nicht ersetzt!"
            Write-Solution "Werte aus MelonLoader-Log eintragen (Get-MelonLoaderInfo.ps1)"
        }
    } else {
        Write-Check "MelonGame-Attribut" "FEHLER" "Nicht gefunden oder fehlerhaft"
        Write-Solution "MelonGame-Attribut in Main.cs einfuegen"
    }
} else {
    Write-Check "Main.cs vorhanden" "FEHLER" "Hauptdatei fehlt"
    Write-Solution "Main.cs aus Vorlage erstellen"
}

Write-Host ""

# ===================
# 5. CSPROJ INHALT
# ===================

if ($csprojPath -and (Test-Path $csprojPath)) {
    Write-Host "5. Projektkonfiguration (csproj)"
    Write-Host ""

    $csprojContent = Get-Content $csprojPath -Raw

    # TargetFramework pruefen
    if ($csprojContent -match '<TargetFramework>([^<]+)</TargetFramework>') {
        $framework = $matches[1]
        Write-Check "TargetFramework" "OK" $framework

        if ($framework -eq "netstandard2.0") {
            Write-Check "Framework-Kompatibilitaet" "WARNUNG" "netstandard2.0 kann Probleme verursachen!"
            Write-Solution "Fuer net35-Spiele: net472 verwenden. Fuer net6-Spiele: net6.0 verwenden."
        }

        if ($framework -eq "TARGET_FRAMEWORK") {
            Write-Check "Framework-Wert" "FEHLER" "Platzhalter nicht ersetzt!"
            Write-Solution "Wert aus MelonLoader-Log eintragen"
        }
    } else {
        Write-Check "TargetFramework" "FEHLER" "Nicht gefunden"
    }

    # Decompiled-Ausschluss pruefen
    if ($csprojContent -match '<Compile\s+Remove="decompiled\\\*\*"') {
        Write-Check "Decompiled-Ausschluss" "OK"
    } else {
        Write-Check "Decompiled-Ausschluss" "WARNUNG" "decompiled-Ordner wird nicht ausgeschlossen"
        Write-Solution "In csproj einfuegen: <Compile Remove=`"decompiled\**`" />"
    }

    # MelonLoader-Referenz pruefen
    if ($csprojContent -match '<Reference\s+Include="MelonLoader"') {
        Write-Check "MelonLoader-Referenz" "OK"

        # Pfad pruefen
        if ($csprojContent -match 'SPIELORDNER') {
            Write-Check "Referenz-Pfade" "FEHLER" "Platzhalter SPIELORDNER nicht ersetzt!"
            Write-Solution "Alle SPIELORDNER durch den echten Pfad ersetzen"
        }
    } else {
        Write-Check "MelonLoader-Referenz" "FEHLER" "Nicht gefunden"
    }

    # Copy-Target pruefen
    if ($csprojContent -match 'CopyToMods') {
        Write-Check "Auto-Copy zu Mods" "OK"
    } else {
        Write-Check "Auto-Copy zu Mods" "WARNUNG" "DLL wird nicht automatisch kopiert"
        Write-Solution "CopyToMods-Target aus Vorlage uebernehmen"
    }

    Write-Host ""
}

# ===================
# 6. DECOMPILED
# ===================

Write-Host "6. Dekompilierter Code"
Write-Host ""

$decompiledPath = Join-Path $ProjectPath "decompiled"
if (Test-Path $decompiledPath) {
    $csFiles = Get-ChildItem -Path $decompiledPath -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue
    if ($csFiles.Count -gt 0) {
        Write-Check "Dekompilierter Code" "OK" "$($csFiles.Count) CS-Dateien gefunden"
    } else {
        Write-Check "Dekompilierter Code" "WARNUNG" "Ordner existiert aber keine CS-Dateien"
        Write-Solution "Assembly-CSharp.dll mit dnSpy dekompilieren und Code hier ablegen"
    }
} else {
    Write-Check "Decompiled-Ordner" "WARNUNG" "Nicht vorhanden"
    Write-Solution "Ordner 'decompiled' erstellen und dekompilierten Code dort ablegen"
}

Write-Host ""

# ===================
# ZUSAMMENFASSUNG
# ===================

Write-Host "Zusammenfassung"
Write-Host "==============="
Write-Host ""
Write-Host "Erfolgreich: $script:successCount"
Write-Host "Warnungen: $script:warningCount"
Write-Host "Fehler: $script:errorCount"
Write-Host ""

if ($script:errorCount -eq 0 -and $script:warningCount -eq 0) {
    Write-Host "Alles in Ordnung! Das Projekt ist bereit zum Bauen."
    Write-Host "Befehl: dotnet build"
} elseif ($script:errorCount -eq 0) {
    Write-Host "Projekt kann gebaut werden, aber es gibt Warnungen."
    Write-Host "Empfehlung: Warnungen vor dem ersten Build beheben."
} else {
    Write-Host "Es gibt Fehler! Diese muessen vor dem Build behoben werden."
}

Write-Host ""
