# Accessibility Mod Template

## Benutzer

- Blind, nutzt Screenreader
- Erfahrungslevel: wird beim Setup abgefragt → Kommunikation anpassen
- Benutzer gibt Richtung vor, Claude codet und erklärt
- Bei Unklarheiten: kurz nachfragen, dann handeln
- Ausgabe: KEINE `|`-Tabellen, Aufzählungen nutzen

## Projektstart

Bei Begrüßung: `project_status.md` vorhanden?

**Nein** → `docs/setup-guide.md` lesen, Setup-Interview durchführen.

**Ja** → Rückkehrende Session:
1. `project_status.md` lesen — Phase, Features, Issues, Notizen für nächste Session
2. Kurz zusammenfassen: woran zuletzt gearbeitet wurde, ausstehende Tests oder Notizen
3. Wenn ausstehende Tests existieren, Benutzer nach Ergebnissen fragen bevor weitergemacht wird
4. Nächste Schritte aus project_status.md vorschlagen oder fragen was zu tun ist

`project_status.md` = zentrales Tracking-Dokument. Bei wichtigem Fortschritt und immer vor Session-Ende aktualisieren.

## Umgebung

- **OS:** Windows (Bash/Git Bash)
- **Spielordner:** [BEIM SETUP AUSFÜLLEN]
- **Architektur:** [32-BIT ODER 64-BIT]
- **Mod-Loader:** [MELONLOADER ODER BEPINEX — BEIM SETUP AUSFÜLLEN]

## Tolk-DLLs — SETUP-ERINNERUNG (diesen Abschnitt nach Tolk-Setup löschen)

Beim Einrichten von Tolk für ein Mod-Projekt IMMER BEIDE DLLs in den Spielordner kopieren:
- `Tolk.dll` — die Screenreader-Bridge-Bibliothek
- `nvdaControllerClient64.dll` (64-Bit) oder `nvdaControllerClient32.dll` (32-Bit) — erforderlich für NVDA

Ohne die nvdaControllerClient-DLL bekommen NVDA-Nutzer KEINE Ausgabe! JAWS funktioniert über COM (keine extra DLL), aber NVDA braucht diese Datei. NIE weglassen.

Lokale Kopie: `C:\Users\Sonja\Documents\Modprojekte\Meta\nvdaControllerClient64.dll`

## Kodier-Regeln

- Handler-Klassen: `[Feature]Handler`
- Private Felder: `_camelCase`
- Logs/Kommentare: Englisch
- Build: `dotnet build [ModName].csproj`
- XML-Doku: `<summary>` auf alle öffentlichen Klassen/Methoden. Private nur wenn nicht offensichtlich. Kritisch für Entwickler-Integration.
- Lokalisierung ab Tag eins: ALLE ScreenReader-Strings durch `Loc.Get()`. Keine Ausnahmen. `Loc.cs` = Phase-2-Grundgerüst, nicht spätere Ergänzung. Auch bei einsprachigen Mods.

## Coding-Prinzipien

- **Spielbarkeit** — wie Sehende spielen; Cheats nur wenn unvermeidbar
- **Modular** — Input, UI, Ansagen, Spielzustand trennen
- **Wartbar** — konsistente Patterns, erweiterbar
- **Effizient** — Objekte cachen, unnötige Arbeit vermeiden
- **Robust** — Utility-Klassen, Edge Cases, Zustandsänderungen ansagen
- **Spielsteuerung respektieren** — nie Spieltasten überschreiben, schnelle Tastendrücke handhaben
- **Einreichungs-Qualität** — sauber genug für Entwickler-Integration, konsistente Formatierung, aussagekräftige Namen, keine undokumentierten Hacks

Patterns: `docs/ACCESSIBILITY_MODDING_GUIDE.md`

## Fehlerbehandlung

- Null-sicher mit Logging: nie still fehlschlagen. Über DebugLogger loggen UND per ScreenReader ansagen.
- Try-catch NUR für Reflection + externe Aufrufe (Tolk, sich ändernde Game-APIs). Normaler Code: Null-Checks.
- DebugLogger: immer verfügbar, nur aktiv im Debug-Modus (F12). Kein Overhead sonst.

## Vor der Implementierung

1. `decompiled/` nach echten Klassen-/Methodennamen durchsuchen — NIEMALS raten
2. `docs/game-api.md` für Tasten, Methoden, Patterns prüfen
3. Nur sichere Mod-Tasten nutzen (game-api.md → "Game Key Bindings")
4. Große Dateien (>500 Zeilen): zuerst gezielte Suche (Grep/Glob), nicht automatisch komplett lesen

## Session- & Kontext-Management

- Feature fertig → neue Conversation vorschlagen um Tokens zu sparen. `project_status.md` aktualisieren.
- ~30+ Nachrichten → an frische Conversation erinnern (KI liest alles pro Nachricht neu)
- Vor Ende/Verabschiedung → immer `project_status.md` aktualisieren
- Nie dekompilierten Code erneut lesen, der schon in `docs/game-api.md` dokumentiert ist
- Nach neuer Code-Analyse → sofort in `docs/game-api.md` dokumentieren
- Problem besteht nach 3 Versuchen → stoppen, erklären, Alternativen vorschlagen, Benutzer fragen

## Referenzen

- `project_status.md` — zentrales Tracking (zuerst lesen!)
- `docs/setup-guide.md` — Setup-Interview
- `docs/ACCESSIBILITY_MODDING_GUIDE.md` — Code-Patterns
- `docs/technical-reference.md` — MelonLoader, BepInEx, Harmony, Tolk
- `docs/unity-reflection-guide.md` — Reflection (Unity)
- `docs/state-management-guide.md` — mehrere Handler
- `docs/localization-guide.md` — Lokalisierung
- `docs/menu-accessibility-checklist.md` — Menü-Checkliste
- `docs/menu-accessibility-patterns.md` — Menü-Patterns
- `docs/legacy-unity-modding.md` — Unity 5.x und älter
- `docs/game-api.md` — Tasten, Methoden, Patterns
- `docs/distribution-guide.md` — Paketierung, Veröffentlichung
- `docs/git-github-guide.md` — Git/GitHub Einstieg
- `templates/` — Code-Vorlagen
- `scripts/` — PowerShell-Hilfsskripte
