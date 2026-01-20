# Accessibility Mod Template

## Benutzer

- Blind, nutzt Screenreader
- Programmiererfahrung: Wird beim Setup abgefragt (Wenig/Keine oder Viel) - entsprechend kommunizieren
- Benutzer gibt Richtung vor, Claude Code schreibt Code selbstständig und erklärt
- Bei Unklarheiten: Frage kurz nach, dann handle
- Ausgaben screenreader-freundlich: KEINE Tabellen mit `|`, stattdessen Aufzählungen

## Projektstart

Bei Begrüßungen ("Hallo", "Neues Projekt", "Los geht's"):
Lies `docs/setup-guide.md` und führe das Setup-Interview durch.

## Umgebung

- **OS:** Windows (Bash/Git Bash)
- **Spielordner:** [BEIM SETUP AUSFÜLLEN]
- **Architektur:** [32-BIT ODER 64-BIT]

## Kodier-Regeln

- **Handler-Klassen:** `[Feature]Handler`
- **Private Felder:** `_camelCase`
- **Logs/Kommentare:** Englisch
- **Build:** `dotnet build [ModName].csproj`

## Coding-Prinzipien

- **Spielbarkeit, nicht Vereinfachung** - Spiel wie für Sehende spielbar machen; Cheats nur vorschlagen wenn unvermeidbar
- **Modular** - Input-Handling, UI-Extraktion, Ansagen und Spielzustand trennen
- **Wartbar** - Konsistente Patterns, einfach erweiterbar
- **Effizient** - Objekte cachen, unnötige Verarbeitung vermeiden
- **Robust** - Utility-Klassen nutzen, Edge Cases abfangen, Zustandsänderungen ansagen
- **Spielsteuerung respektieren** - Niemals Spieltasten überschreiben, schnelle Tastendrücke abfangen

Patterns: `docs/ACCESSIBILITY_MODDING_GUIDE.md`

## Vor der Implementierung

**IMMER:**
1. `decompiled/` nach echten Klassen-/Methodennamen durchsuchen - NIEMALS raten
2. `docs/game-api.md` für Tasten, Methoden, Patterns prüfen
3. Nur "Sichere Tasten für den Mod" verwenden (siehe game-api.md → "Spiel-Tastenbelegungen")

## Referenzen

- `docs/setup-guide.md` - Projekt-Setup-Interview
- `docs/ACCESSIBILITY_MODDING_GUIDE.md` - Code-Patterns und Architektur
- `docs/localization-guide.md` - Text- und Ansagen-Lokalisierung
- `docs/menu-accessibility-checklist.md` - Menü-Implementierungs-Checkliste
- `docs/game-api.md` - Tasten, Methoden, dokumentierte Patterns
- `templates/` - Code-Vorlagen
- `scripts/` - PowerShell-Hilfsskripte
