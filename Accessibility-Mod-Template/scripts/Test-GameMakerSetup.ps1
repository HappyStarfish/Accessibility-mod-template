<#
.SYNOPSIS
    Validates a GameMaker accessibility mod project setup.

.DESCRIPTION
    Checks whether all necessary files and tools are in place:
    - data.win exists and backup exists
    - UndertaleModTool CLI installed
    - TolkWrapper.dll, Tolk.dll, nvdaControllerClient DLL present
    - Patch .csx script exists
    - Exported code entries available for analysis

    Gives clear error messages and suggested fixes.

.PARAMETER GamePath
    Path to the game directory (where data.win and the .exe are).

.PARAMETER ProjectPath
    Path to the mod project directory. Default: current directory.

.PARAMETER Architecture
    Game architecture: "x64" or "x86".
    Needed for Tolk DLL check.

.EXAMPLE
    .\Test-GameMakerSetup.ps1 -GamePath "C:\Games\MyGame" -Architecture x86

.EXAMPLE
    .\Test-GameMakerSetup.ps1 -GamePath "C:\Games\MyGame" -ProjectPath "C:\Projects\MyMod" -Architecture x64
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$GamePath,

    [string]$ProjectPath = (Get-Location).Path,

    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x86"
)

$script:errorCount = 0
$script:warningCount = 0
$script:successCount = 0

function Write-Check {
    param(
        [string]$Name,
        [string]$Status,  # "OK", "ERROR", "WARNING"
        [string]$Details = ""
    )

    switch ($Status) {
        "OK" {
            Write-Host "OK: $Name"
            $script:successCount++
        }
        "ERROR" {
            Write-Host "ERROR: $Name"
            $script:errorCount++
        }
        "WARNING" {
            Write-Host "WARNING: $Name"
            $script:warningCount++
        }
    }

    if ($Details) {
        Write-Host "   $Details"
    }
}

function Write-Solution {
    param([string]$Text)
    Write-Host "   Fix: $Text"
}

Write-Host ""
Write-Host "GameMaker Mod Setup Validation"
Write-Host "=============================="
Write-Host ""
Write-Host "Game directory: $GamePath"
Write-Host "Project directory: $ProjectPath"
Write-Host "Architecture: $Architecture"
Write-Host ""
Write-Host "Checking..."
Write-Host "----------"
Write-Host ""

# ===================
# 1. GAME DIRECTORY
# ===================

Write-Host "1. Game Directory"
Write-Host ""

if (Test-Path $GamePath) {
    Write-Check "Game directory exists" "OK"
} else {
    Write-Check "Game directory exists" "ERROR" "Path not found: $GamePath"
    Write-Solution "Check the path for typos"
    Write-Host ""
    Write-Host "Aborting - game directory must exist."
    exit 1
}

# data.win
$dataWin = Join-Path $GamePath "data.win"
if (Test-Path $dataWin) {
    $size = (Get-Item $dataWin).Length / 1MB
    Write-Check "data.win found" "OK" ("{0:N1} MB" -f $size)
} else {
    Write-Check "data.win found" "ERROR" "data.win not in game directory"
    Write-Solution "Check if the game uses a different data file (game.unx, game.ios) or is YYC-compiled (not moddable with UTMT)"
}

# data.win backup
$dataBackup = Join-Path $GamePath "data.win.backup"
if (Test-Path $dataBackup) {
    Write-Check "data.win backup exists" "OK"
} else {
    Write-Check "data.win backup exists" "WARNING" "No backup found"
    Write-Solution "Copy data.win to data.win.backup before patching!"
}

# Game exe
$exeFiles = Get-ChildItem -Path $GamePath -Filter "*.exe" -File -ErrorAction SilentlyContinue
if ($exeFiles.Count -gt 0) {
    Write-Check "Game executable found" "OK" $exeFiles[0].Name
} else {
    Write-Check "Game executable found" "WARNING" "No .exe found in game directory"
}

Write-Host ""

# ===================
# 2. UTMT CLI
# ===================

Write-Host "2. UndertaleModTool CLI"
Write-Host ""

$utmtCmd = Get-Command "UTMT_CLI.exe" -ErrorAction SilentlyContinue
if ($utmtCmd) {
    Write-Check "UTMT CLI in PATH" "OK" $utmtCmd.Source
} else {
    # Check common locations
    $utmtLocal = Join-Path $ProjectPath "tools\UTMT_CLI\UTMT_CLI.exe"
    if (Test-Path $utmtLocal) {
        Write-Check "UTMT CLI found locally" "OK" $utmtLocal
    } else {
        Write-Check "UTMT CLI available" "ERROR" "Not found in PATH or tools\UTMT_CLI\"
        Write-Solution "Install via: winget install UndertaleMod.UndertaleModTool"
    }
}

Write-Host ""

# ===================
# 3. TOLK / TOLKWRAPPER
# ===================

Write-Host "3. Screen Reader DLLs"
Write-Host ""

# TolkWrapper.dll
$tolkWrapper = Join-Path $GamePath "TolkWrapper.dll"
if (Test-Path $tolkWrapper) {
    Write-Check "TolkWrapper.dll present" "OK"
} else {
    Write-Check "TolkWrapper.dll present" "ERROR" "TolkWrapper.dll not in game directory"
    Write-Solution "Compile from TolkWrapper.c (see templates/gamemaker/TolkWrapper.c.template)"
}

# Tolk.dll
$tolkDll = Join-Path $GamePath "Tolk.dll"
if (Test-Path $tolkDll) {
    Write-Check "Tolk.dll present" "OK"
} else {
    Write-Check "Tolk.dll present" "ERROR" "Tolk.dll not in game directory"
    Write-Solution "Download from https://github.com/ndarilek/tolk/releases"
}

# NVDA Controller Client
$nvdaDll = if ($Architecture -eq "x64") {
    Join-Path $GamePath "nvdaControllerClient64.dll"
} else {
    Join-Path $GamePath "nvdaControllerClient32.dll"
}

$nvdaDllName = Split-Path $nvdaDll -Leaf

if (Test-Path $nvdaDll) {
    Write-Check "$nvdaDllName present" "OK"
} else {
    Write-Check "$nvdaDllName present" "ERROR" "NVDA DLL not found"

    # Check if wrong architecture version is present
    $wrongDll = if ($Architecture -eq "x64") {
        Join-Path $GamePath "nvdaControllerClient32.dll"
    } else {
        Join-Path $GamePath "nvdaControllerClient64.dll"
    }

    if (Test-Path $wrongDll) {
        $wrongName = Split-Path $wrongDll -Leaf
        Write-Host "   NOTE: $wrongName is present - wrong architecture!"
        Write-Solution "Use the $Architecture version from the Tolk download"
    } else {
        Write-Solution "Copy nvdaControllerClient DLL from the Tolk download into the game directory"
    }
}

Write-Host ""

# ===================
# 4. PATCH SCRIPT
# ===================

Write-Host "4. Patch Script"
Write-Host ""

$csxFiles = Get-ChildItem -Path $ProjectPath -Filter "*.csx" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch "^(Export|Import|diagnostic|verify)" }

if ($csxFiles.Count -gt 0) {
    Write-Check "Patch script found" "OK" $csxFiles[0].Name
} else {
    # Check in patch/ subdirectory
    $patchDir = Join-Path $ProjectPath "patch"
    if (Test-Path $patchDir) {
        $csxFiles = Get-ChildItem -Path $patchDir -Filter "*.csx" -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notmatch "^(Export|Import|diagnostic|verify)" }
        if ($csxFiles.Count -gt 0) {
            Write-Check "Patch script found" "OK" "patch\$($csxFiles[0].Name)"
        } else {
            Write-Check "Patch script found" "WARNING" "No patch .csx found"
            Write-Solution "Create from template: templates/gamemaker/accessibility_patch.csx.template"
        }
    } else {
        Write-Check "Patch script found" "WARNING" "No patch .csx found"
        Write-Solution "Create from template: templates/gamemaker/accessibility_patch.csx.template"
    }
}

Write-Host ""

# ===================
# 5. EXPORTED CODE
# ===================

Write-Host "5. Exported Code (for analysis)"
Write-Host ""

# Check common export locations
$codeEntriesPath = Join-Path $ProjectPath "CodeEntries"
$analysisPath = Join-Path $ProjectPath "analysis\CodeEntries"

if (Test-Path $codeEntriesPath) {
    $gmlFiles = Get-ChildItem -Path $codeEntriesPath -Filter "*.gml" -Recurse -ErrorAction SilentlyContinue
    if ($gmlFiles.Count -gt 0) {
        Write-Check "Exported GML code" "OK" "$($gmlFiles.Count) code entries in CodeEntries\"
    } else {
        Write-Check "Exported GML code" "WARNING" "CodeEntries\ exists but no .gml files"
    }
} elseif (Test-Path $analysisPath) {
    $gmlFiles = Get-ChildItem -Path $analysisPath -Filter "*.gml" -Recurse -ErrorAction SilentlyContinue
    if ($gmlFiles.Count -gt 0) {
        Write-Check "Exported GML code" "OK" "$($gmlFiles.Count) code entries in analysis\CodeEntries\"
    } else {
        Write-Check "Exported GML code" "WARNING" "analysis\CodeEntries\ exists but no .gml files"
    }
} else {
    Write-Check "Exported GML code" "WARNING" "No exported code found"
    Write-Solution "Export with: UTMT_CLI.exe load data.win -s ExportAllCode.csx"
}

Write-Host ""

# ===================
# SUMMARY
# ===================

Write-Host "Summary"
Write-Host "======="
Write-Host ""
Write-Host "Passed: $script:successCount"
Write-Host "Warnings: $script:warningCount"
Write-Host "Errors: $script:errorCount"
Write-Host ""

if ($script:errorCount -eq 0 -and $script:warningCount -eq 0) {
    Write-Host "Everything looks good! Ready to develop and apply patches."
} elseif ($script:errorCount -eq 0) {
    Write-Host "Setup is usable but there are warnings to address."
} else {
    Write-Host "There are errors that must be fixed before patching."
}

Write-Host ""
