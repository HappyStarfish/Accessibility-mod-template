# Setup-Anleitung für neue Accessibility-Mod-Projekte

Diese Anleitung wird nur beim ersten Projektstart benötigt.

---

## Setup-Interview

Wenn der Benutzer zum ersten Mal mit Claude in diesem Ordner spricht (z.B. "Hallo", "Neues Projekt", "Los geht's"), führe dieses Interview durch.

**Stelle diese Fragen EINZELN. Warte nach JEDER Frage auf die Antwort.**

### Schritt 1: Erfahrungslevel

Frage: Wie viel Erfahrung hast du mit Programmieren und Modding? (Wenig/Keine oder Viel)

- Merke dir die Antwort für den Rest des Interviews
- Bei "Wenig/Keine": Erkläre Konzepte kontextabhängig bei den folgenden Schritten (siehe Hinweise "Für Anfänger")
- Bei "Viel": Knappe, technische Kommunikation ohne ausführliche Erklärungen

### Schritt 2: Spielname

Frage: Wie heißt das Spiel, das du barrierefrei machen möchtest?

### Schritt 3: Installationspfad

Frage: Wo ist das Spiel installiert? (z.B. `C:\Program Files (x86)\Steam\steamapps\common\Spielname`)

### Schritt 4: Automatische Prüfung anbieten

Nachdem der Spielpfad bekannt ist, biete an:

Frage: Soll ich den Spielordner automatisch prüfen? Ich kann folgendes erkennen: Game-Engine, Architektur (32/64-Bit), ob MelonLoader installiert ist, und falls ja die Log-Informationen auslesen.

**Falls ja:**

Führe diese Prüfungen durch und sammle die Ergebnisse:

1. **Game-Engine erkennen:**
   - Prüfe ob `UnityPlayer.dll` existiert → Unity-Spiel
   - Prüfe ob `[Spielname]_Data\Managed` Ordner existiert → Unity-Spiel
   - Prüfe auf `.pak` Dateien oder `UnrealEngine`/`UE4` in Dateinamen → Unreal Engine
   - Falls kein Unity: Warnung ausgeben dass MelonLoader nur mit Unity funktioniert

2. **Architektur erkennen:**
   - `MonoBleedingEdge` Ordner vorhanden → 64-Bit
   - `Mono` Ordner (ohne "BleedingEdge") → 32-Bit
   - Dateien mit "x64" im Namen → 64-Bit

3. **MelonLoader-Status:**
   - Prüfe ob `MelonLoader` Ordner existiert
   - Falls ja: Prüfe ob `MelonLoader\Latest.log` existiert

4. **MelonLoader-Log auslesen (falls vorhanden):**
   - Game Name und Developer extrahieren
   - Runtime Type (net35 oder net6) extrahieren
   - Unity Version extrahieren

5. **Tolk-DLLs prüfen:**
   - Bei 64-Bit: Prüfe ob `Tolk.dll` und `nvdaControllerClient64.dll` im Spielordner
   - Bei 32-Bit: Prüfe ob `Tolk.dll` und `nvdaControllerClient32.dll` im Spielordner

**Ergebnisse zusammenfassen:**

Zeige eine Zusammenfassung dessen was erkannt wurde:
- Game-Engine: Unity (oder andere)
- Architektur: 64-Bit / 32-Bit
- MelonLoader: Installiert / Nicht installiert
- Falls MelonLoader installiert: Game Name, Developer, Runtime Type aus Log
- Tolk-DLLs: Vorhanden / Fehlen

Frage: Stimmt das so? (Bestätigung abwarten)

**Nur Fehlendes erklären:**

Nach der Bestätigung, liste NUR die fehlenden/problematischen Punkte auf mit konkreter Anleitung:

- Falls kein Unity-Spiel: Erkläre dass MelonLoader nur mit Unity funktioniert, Alternative recherchieren nötig
- Falls MelonLoader fehlt: Gib die Installationsanleitung (siehe unten)
- Falls Tolk-DLLs fehlen: Gib die Download-Anleitung (siehe unten)
- Falls MelonLoader-Log fehlt: Bitte Benutzer das Spiel einmal zu starten

Überspringe alles was bereits vorhanden ist!

**Falls nein (manuelle Prüfung gewünscht):**

Fahre mit den manuellen Schritten 4a-4c fort.

---

### Manuelle Schritte (nur falls automatische Prüfung abgelehnt)

#### Schritt 4a: Game-Engine (manuell)

Frage: Weißt du welche Game-Engine das Spiel verwendet?

- Hinweise zum Erkennen von Unity: `UnityPlayer.dll` im Spielordner oder ein `[Spielname]_Data\Managed` Ordner
- Hinweise für Unreal Engine: `UnrealEngine` oder `UE4` in Dateinamen, `.pak` Dateien
- Falls unklar: Benutzer kann im Spielordner nachschauen oder du hilfst beim Identifizieren

**Falls KEIN Unity-Spiel:**

- MelonLoader funktioniert NUR mit Unity-Spielen
- Alternative Mod-Loader je nach Engine recherchieren (z.B. BepInEx für manche Unity-Versionen, Unreal Mod Loader für UE)
- Der weitere Prozess kann abweichen - passe die Anleitung entsprechend an
- Für Anfänger: Erkläre dass verschiedene Spiele verschiedene "Motoren" (Engines) nutzen, und jede Engine braucht andere Werkzeuge zum Modden

#### Schritt 4b: Architektur (manuell)

Frage: Weißt du ob das Spiel 32-Bit oder 64-Bit ist?

Hinweise zum Herausfinden:
- `MonoBleedingEdge` Ordner = meist 64-Bit
- `Mono` Ordner = meist 32-Bit
- Dateien mit "x64" im Namen = 64-Bit

**WICHTIG:** Die Architektur bestimmt welche Tolk-DLLs benötigt werden!

#### Schritt 4c: MelonLoader (manuell)

Frage: Ist MelonLoader bereits installiert?

Falls nein, erkläre:
- Download: https://github.com/LavaGang/MelonLoader.Installer/releases
- Nach Installation sollte ein `MelonLoader` Ordner im Spielverzeichnis sein
- Spiel einmal starten um Ordnerstruktur zu erstellen

Für Anfänger: MelonLoader ist ein "Mod-Loader" - ein Programm das unseren Mod-Code ins Spiel lädt. Es bringt auch "Harmony" mit, eine Bibliothek zum Einhaken in Spielfunktionen. Deshalb müssen wir Harmony nicht extra herunterladen.

---

### Schritt 5: Tolk (falls bei automatischer Prüfung als fehlend gemeldet)

Falls Tolk-DLLs fehlen, erkläre:
- Download: https://github.com/ndarilek/tolk/releases
- Für 64-Bit: `Tolk.dll` + `nvdaControllerClient64.dll` aus dem x64-Ordner
- Für 32-Bit: `Tolk.dll` + `nvdaControllerClient32.dll` aus dem x86-Ordner
- Diese DLLs in den Spielordner kopieren (wo die .exe liegt)

Für Anfänger: Tolk ist eine Bibliothek die mit verschiedenen Screenreadern (NVDA, JAWS, etc.) kommunizieren kann. Unser Mod nutzt Tolk um Text an deinen Screenreader zu senden.

### Schritt 6: .NET SDK

Frage: Hast du das .NET SDK bereits installiert?

Falls nein, erkläre:
- Download: https://dotnet.microsoft.com/download
- Empfohlen: .NET 8 SDK oder neuer
- Prüfen mit: `dotnet --version` in PowerShell

Für Anfänger: Das .NET SDK ist ein Entwicklungswerkzeug von Microsoft. Wir brauchen es um unseren C#-Code in eine DLL-Datei zu kompilieren, die MelonLoader dann laden kann.

### Schritt 7: Dekompilierung

Frage: Hast du ein Dekompilier-Tool (dnSpy oder ILSpy) installiert?

Falls nein, erkläre:
- dnSpy Download: https://github.com/dnSpy/dnSpy/releases
- Damit muss `Assembly-CSharp.dll` aus `[Spiel]_Data\Managed\` dekompiliert werden
- Der dekompilierte Code sollte in `decompiled/` in diesem Projektordner kopiert werden

**Screenreader-Anleitung für DnSpy:**
1. DnSpy.exe öffnen
2. Mit Strg+O die DLL auswählen (z.B. Assembly-CSharp.dll)
3. Im Menü "Datei" den Punkt "Exportieren in Projekt" wählen
4. Einmal Tab drücken - landet auf einem unbeschrifteten Schalter für die Zielordner-Auswahl
5. Dort den Zielordner auswählen (am besten vorher schon einen "decompiled" Unterordner in diesem Projektordner erstellen, damit Claude Code den Quellcode leicht finden kann)
6. Nach der Bestätigung der Ordnerauswahl oft Tab drücken bis zum Schalter "Exportieren"
7. Der Export dauert etwa eine halbe Minute
8. Danach DnSpy schließen

Für Anfänger: Spiele werden in einer Programmiersprache geschrieben und dann "kompiliert" (in Maschinencode übersetzt). Dekompilieren macht das rückgängig - wir bekommen lesbaren Code. Das brauchen wir um zu verstehen wie das Spiel funktioniert und wo wir unsere Accessibility-Funktionen einhängen können.

### Schritt 8: Mehrsprachigkeit

Frage: Soll der Mod mehrsprachig sein (automatische Spracherkennung basierend auf Spielsprache)?

Falls ja:
- Das Sprachsystem des Spiels muss beim Dekompilieren analysiert werden
- Suche nach: `Language`, `Localization`, `I18n`, `currentLanguage`, `getAlias()`
- Siehe `localization-guide.md` für vollständige Anleitung
- Nutze `templates/Loc.cs.template` als Ausgangspunkt

Falls nein:
- Mod wird einsprachig (in der Sprache des Benutzers)

### Schritt 9: Projektordner einrichten

Nach dem Interview:
- **Mod-Name festlegen:** `[Spielname]Access` - bei 3+ Wörtern abkürzen (z.B. "PetIdleAccess", "DsaAccess" für "Das Schwarze Auge")
- Erstelle `project_status.md` mit den gesammelten Infos (Spielname, Pfade, Architektur, Erfahrungslevel)
- Erstelle `docs/game-api.md` als Platzhalter für Spiel-Erkenntnisse
- Trage die konkreten Pfade in CLAUDE.md unter "Umgebung" ein

---

## Checkliste für Benutzer (zum Vorlesen)

Nach dem Interview, lies diese Checkliste vor:

- Spielarchitektur bekannt (32-Bit oder 64-Bit)
- MelonLoader installiert und getestet (Spiel startet mit MelonLoader-Konsole)
- Tolk-DLLs im Spielordner (passend zur Architektur!)
- Dekompilier-Tool bereit
- Assembly-CSharp.dll dekompiliert und Code in `decompiled/` Ordner kopiert

**Tipp:** Das Validierungsskript prüft alle Punkte automatisch:
```powershell
.\scripts\Test-ModSetup.ps1 -GamePath "C:\Pfad\zum\Spiel" -Architecture x64
```

---

## Nächste Schritte

Nach Abschluss des Setups in dieser Reihenfolge vorgehen:

0. **ACCESSIBILITY_MODDING_GUIDE.md lesen** - Lies `docs/ACCESSIBILITY_MODDING_GUIDE.md` komplett durch, insbesondere den Abschnitt "Quellcode-Recherche vor der Implementierung". Dieser Guide definiert die Patterns und Regeln für das gesamte Projekt.
1. **Quellcode-Analyse** (Phase 1 weiter unten) - Spielsysteme verstehen
2. **Tutorial suchen/analysieren** (Abschnitt 1.9) - Mechaniken verstehen, oft hohe Priorität
3. **Feature-Plan erstellen** (Phase 1.5) - Wichtigste Features ausführlich, Rest grob
4. **game-api.md befüllen** - Erkenntnisse aus der Analyse dokumentieren

---

## KRITISCH: Vor dem ersten Build - Log prüfen!

**Diese Werte MÜSSEN aus dem MelonLoader-Log gelesen werden, NIEMALS raten!**

### Automatisch mit Skript (empfohlen)

```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Pfad\zum\Spiel"
```

Das Skript extrahiert alle Werte und zeigt das fertige MelonGame-Attribut an.

### Manuell (falls Skript nicht verfügbar)

**Schritt 1:** Spiel einmal mit MelonLoader starten (erstellt das Log).

**Schritt 2:** Log-Pfad: `[Spielordner]\MelonLoader\Latest.log`

Suche nach diesen Zeilen und notiere die EXAKTEN Werte:

```
Game Name: [EXAKT ÜBERNEHMEN]
Game Developer: [EXAKT ÜBERNEHMEN]
Runtime Type: [net35 oder net6]
```

### Schritt 3: Werte in Code/Projekt eintragen

**MelonGame-Attribut (Main.cs):**
```csharp
[assembly: MelonGame("DEVELOPER_AUS_LOG", "GAME_NAME_AUS_LOG")]
```
- Groß/Kleinschreibung MUSS exakt stimmen
- Leerzeichen MÜSSEN exakt stimmen
- Bei falschem Namen wird der Mod geladen aber NICHT initialisiert!

**TargetFramework (csproj):**
- Wenn Log sagt `Runtime Type: net35` → verwende `<TargetFramework>net472</TargetFramework>`
- Wenn Log sagt `Runtime Type: net6` → verwende `<TargetFramework>net6.0</TargetFramework>`
- MelonLoader-DLLs aus dem passenden Unterordner referenzieren (net35/ oder net6/)

**ACHTUNG:** NICHT `netstandard2.0` für net35-Spiele verwenden!
netstandard2.0 ist nur eine API-Spezifikation, keine Runtime. Mono hat Kompatibilitätsprobleme damit - der Mod wird geladen aber nicht initialisiert (keine Fehlermeldung, einfach Stille).

**decompiled-Ordner ausschließen (csproj):**
Das csproj MUSS diese Zeilen enthalten, sonst werden die dekompilierten Dateien mitcompiliert (hunderte Fehler!):
```xml
<ItemGroup>
  <Compile Remove="decompiled\**" />
  <Compile Remove="templates\**" />
</ItemGroup>
```

**Build-Befehl - IMMER mit Projektdatei!**
```
dotnet build [ModName].csproj
```
NICHT einfach `dotnet build` verwenden! Der `decompiled/`-Ordner enthält oft eine eigene `.csproj`-Datei vom dekompilierten Spiel. Wenn MSBuild mehrere Projektdateien findet, bricht es ab.

### Warum ist das so wichtig?

1. **Entwicklername falsch** = Mod wird geladen aber OnInitializeMelon() wird nie aufgerufen. Kein Fehler im Log, einfach Stille.
2. **Framework falsch** = Mod wird geladen aber kann nicht ausgeführt werden. Kein Fehler im Log, einfach Stille.

**Bei Crashes oder stillem Fehlschlagen:** Lies `technical-reference.md` Abschnitt "KRITISCH: Zugriff auf Spielcode".

---

## Projektstart-Workflow

### Phase 1: Codebase-Analyse (vor dem Coden)

Ziel: Alle für Accessibility relevanten Systeme verstehen, BEVOR mit der Mod-Entwicklung begonnen wird.

#### 1.1 Strukturübersicht

**Namespace-Inventar:**
```
Grep-Pattern: ^namespace\s+
```
Kategorisiere in: UI/Menüs, Gameplay, Audio, Input, Speichern/Laden, Netzwerk, Sonstiges.

**Singleton-Instanzen finden:**
```
Grep-Pattern: static.*instance
Grep-Pattern: \.instance\.
```
Singletons sind die Hauptzugangspunkte zum Spiel. Liste alle auf mit Klassenname, was sie verwalten, wichtige Properties.

#### 1.2 Eingabe-System (KRITISCH!)

**Alle Tastenbelegungen finden:**
```
Grep-Pattern: KeyCode\.
Grep-Pattern: Input\.GetKey
Grep-Pattern: Input\.GetKeyDown
Grep-Pattern: Input\.GetKeyUp
```
Für JEDEN Fund dokumentieren: Datei/Zeile, welche Taste, was passiert, in welchem Kontext.

**Maus-Eingaben:**
```
Grep-Pattern: Input\.GetMouseButton
Grep-Pattern: OnClick
Grep-Pattern: OnPointerClick
Grep-Pattern: OnPointerEnter
```

**Input-Controller:**
```
Grep-Pattern: class.*Input.*Controller
Grep-Pattern: class.*InputManager
```

**Ergebnis:** Liste erstellen welche Tasten NICHT vom Spiel verwendet werden → sichere Mod-Tasten.

#### 1.3 UI-System

**UI-Basisklassen:**
```
Grep-Pattern: class.*Form.*:
Grep-Pattern: class.*Panel.*:
Grep-Pattern: class.*Window.*:
Grep-Pattern: class.*Dialog.*:
Grep-Pattern: class.*Menu.*:
Grep-Pattern: class.*Screen.*:
Grep-Pattern: class.*Canvas.*:
```

Finde heraus: Gemeinsame Basisklasse? Wie werden Fenster geöffnet/geschlossen? Zentrales UI-Management?

**Text-Anzeige:**
```
Grep-Pattern: \.text\s*=
Grep-Pattern: SetText\(
Grep-Pattern: TextMeshPro
```

**Tooltips:**
```
Grep-Pattern: Tooltip
Grep-Pattern: hover
Grep-Pattern: description
```

#### 1.4 Spielmechaniken

**Spieler-Klasse:**
```
Grep-Pattern: class.*Player
Grep-Pattern: class.*Character
Grep-Pattern: class.*Controller.*:.*MonoBehaviour
```

**Inventar:**
```
Grep-Pattern: class.*Inventory
Grep-Pattern: class.*Item
Grep-Pattern: class.*Slot
```

**Interaktion:**
```
Grep-Pattern: Interact
Grep-Pattern: OnUse
Grep-Pattern: IInteractable
```

**Weitere Systeme (je nach Spiel):**
- Quest: `class.*Quest`, `class.*Mission`
- Dialog: `class.*Dialog`, `class.*Conversation`, `class.*NPC`
- Kampf: `class.*Combat`, `class.*Attack`, `class.*Health`
- Crafting: `class.*Craft`, `class.*Recipe`
- Ressourcen: `class.*Currency`, `Gold`, `Coins`

#### 1.5 Status und Feedback

**Spieler-Status:**
```
Grep-Pattern: Health
Grep-Pattern: Stamina
Grep-Pattern: Mana
Grep-Pattern: Energy
```

**Benachrichtigungen:**
```
Grep-Pattern: Notification
Grep-Pattern: Message
Grep-Pattern: Toast
Grep-Pattern: Popup
```

#### 1.6 Event-System (für Harmony-Patches)

**Events finden:**
```
Grep-Pattern: delegate\s+
Grep-Pattern: event\s+
Grep-Pattern: Action<
Grep-Pattern: UnityEvent
Grep-Pattern: \.Invoke\(
```

**Gute Patch-Punkte:**
```
Grep-Pattern: OnOpen
Grep-Pattern: OnClose
Grep-Pattern: OnShow
Grep-Pattern: OnHide
Grep-Pattern: OnSelect
```

#### 1.7 Lokalisierung

```
Grep-Pattern: Locali
Grep-Pattern: Language
Grep-Pattern: Translate
Grep-Pattern: GetString
```

#### 1.8 Ergebnis dokumentieren

Nach der Analyse sollte `docs/game-api.md` enthalten:
1. Übersicht - Spielbeschreibung, Engine-Version
2. Singleton-Zugangspunkte
3. Spiel-Tastenbelegungen (ALLE!)
4. Sichere Mod-Tasten
5. UI-System - Fenster/Menüs mit Öffnungs-Methoden
6. Spielmechaniken
7. Status-Systeme
8. Event-Hooks für Harmony

#### 1.9 Tutorial suchen und analysieren

**Warum das Tutorial wichtig ist:**
- Tutorials erklären Spielmechaniken schrittweise - ideal um zu verstehen, was zugänglich gemacht werden muss
- Oft einfacher strukturiert als der Rest des Spiels - guter Einstiegspunkt für die Mod-Entwicklung
- Wenn das Tutorial zugänglich ist, können blinde Spieler das Spiel überhaupt erst lernen
- Tutorial-Code offenbart oft, welche UI-Elemente und Interaktionen existieren

**Suche im dekompilierten Code:**
```
Grep-Pattern: Tutorial
Grep-Pattern: class.*Tutorial
Grep-Pattern: FirstTime
Grep-Pattern: Introduction
Grep-Pattern: HowToPlay
Grep-Pattern: Onboarding
```

**Suche im Spielordner:**
- Nach Dateien mit "tutorial", "intro", "howto" im Namen
- Oft in separaten Szenen oder Levels organisiert

**Analyse-Fragen:**
1. Gibt es ein Tutorial? Wenn ja, wie wird es gestartet?
2. Welche Spielmechaniken werden im Tutorial eingeführt?
3. Wie werden Anweisungen angezeigt (Text, Popups, Sprachausgabe)?
4. Gibt es interaktive Elemente die zugänglich gemacht werden müssen?
5. Kann das Tutorial übersprungen werden?

**Ergebnis:**
- Tutorial-Existenz und Startmethode in game-api.md dokumentieren
- Tutorial auf die Feature-Liste setzen (typischerweise hohe Priorität)
- Erkannte Mechaniken als Basis für weitere Features nutzen

### Phase 1.5: Feature-Plan erstellen

**Vor dem Coden einen strukturierten Plan erstellen:**

Basierend auf der Codebase-Analyse und Tutorial-Erkenntnisse eine Feature-Liste erstellen.

**Struktur des Plans:**

Wichtigste Features (ausführlich dokumentieren):
- Was genau soll das Feature tun?
- Welche Spielklassen/Methoden werden genutzt?
- Welche Tasten werden benötigt?
- Abhängigkeiten zu anderen Features?
- Bekannte Herausforderungen?

Beispiel für ausführliches Feature:
```
Feature: Hauptmenü-Navigation
- Ziel: Alle Menüpunkte mit Pfeiltasten navigierbar, aktuelle Auswahl ansagen
- Klassen: MainMenu, MenuButton (aus Analyse 1.3)
- Harmony-Hook: MainMenu.OnOpen() für Initialisierung
- Tasten: Pfeiltasten (vom Spiel bereits genutzt), Enter (bestätigen)
- Abhängigkeiten: Keine (erstes Feature)
- Herausforderung: Menüpunkte haben kein einheitliches Text-Property
```

Weniger wichtige Features (grob dokumentieren):
- Kurzbeschreibung in 1-2 Sätzen
- Geschätzte Komplexität (einfach/mittel/komplex)
- Abhängigkeiten falls vorhanden

Beispiel für grobes Feature:
```
Feature: Achievements-Ansage
- Kurz: Achievement-Popups abfangen und vorlesen
- Komplexität: Einfach
- Abhängig von: Basis-Ansagesystem
```

**Priorisierung festlegen:**

Frage an den Benutzer: Mit welchem Feature sollen wir anfangen?

Leitprinzip: Am besten mit den Dingen anfangen, mit denen man im Spiel als erstes interagiert. Das ermöglicht frühes Testen und der Spieler kann das Spiel von Anfang an erleben.

Typische Reihenfolge (kontextabhängig anpassen!):
1. Hauptmenü - Meist der erste Kontakt mit dem Spiel
2. Grundlegende Statusansagen - Leben, Ressourcen, etc.
3. Tutorial (falls vorhanden) - Führt in Spielmechaniken ein
4. Kern-Gameplay-Navigation
5. Inventar und Untermenüs
6. Spezialfeatures (Crafting, Handel, etc.)
7. Optionale Features (Achievements, Statistiken)

Diese Reihenfolge ist nur ein Vorschlag. Je nach Spiel kann es sinnvoll sein, anders zu priorisieren:
- Manche Spiele starten direkt im Gameplay ohne Hauptmenü
- Bei manchen Spielen ist das Tutorial verpflichtend und kommt vor allem anderen
- Statusansagen können auch parallel zu anderen Features entwickelt werden

**Vorteile eines durchdachten Plans:**
- Abhängigkeiten werden früh erkannt
- Gemeinsame Utility-Klassen können identifiziert werden
- Architektur-Entscheidungen einmal treffen statt ad-hoc
- Besserer Überblick über Gesamtumfang

**Hinweis:** Der Plan darf und wird sich ändern. Manche Features erweisen sich als einfacher oder schwieriger als gedacht.

### Phase 2: Grundgerüst

1. C#-Projekt mit MelonLoader-Referenzen erstellen
2. Tolk für Screenreader-Ausgabe einbinden
3. Basis-Mod erstellen der nur "Mod geladen" ansagt
4. Testen ob Grundgerüst funktioniert

### Phase 3: Feature-Entwicklung

**VOR jedem neuen Feature:**
1. `docs/game-api.md` konsultieren:
   - Spiel-Tastenbelegungen prüfen (keine Konflikte!)
   - Bereits dokumentierte Klassen/Methoden nutzen
   - Bekannte Patterns wiederverwenden
2. Feature-Plan-Eintrag prüfen (Abhängigkeiten erfüllt?)
3. Bei Menüs: `menu-accessibility-checklist.md` durcharbeiten

**Warum API-Doku zuerst?**
- Verhindert Tastenkonflikte mit dem Spiel
- Vermeidet doppelte Arbeit (Methoden nicht erneut suchen)
- Konsistenz zwischen Features bleibt erhalten
- Dokumentierte Patterns können direkt wiederverwendet werden

Siehe `ACCESSIBILITY_MODDING_GUIDE.md` für Code-Patterns.

**Reihenfolge der Features:** Baue Access-Features in der Reihenfolge ein, wie ein Spieler im Spiel darauf trifft:

1. **Hauptmenü** - Erster Kontakt mit dem Spiel, Grundnavigation
2. **Einstellungsmenü** - Falls vom Hauptmenü erreichbar
3. **Allgemeine Statusansagen** - Leben, Geld, Zeit etc.
4. **Tutorial / Startgebiet** - Erste Spielerfahrung
5. **Kern-Gameplay** - Die häufigsten Aktionen
6. **Inventar / Menüs im Spiel** - Pausenmenü, Inventar, Karte
7. **Spezielle Features** - Crafting, Handel, Dialoge
8. **Endgame / Optionales** - Achievements, Statistiken

---

## Hilfsskripte

### Get-MelonLoaderInfo.ps1

Liest das MelonLoader-Log und extrahiert alle wichtigen Werte:
- Game Name und Developer (für MelonGame-Attribut)
- Runtime Type (für TargetFramework)
- Unity Version

**Verwendung:**
```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Pfad\zum\Spiel"
```

**Ausgabe:** Fertige Code-Snippets zum Kopieren.

### Test-ModSetup.ps1

Validiert ob alles korrekt eingerichtet ist:
- MelonLoader-Installation
- Tolk-DLLs (prüft auch richtige Architektur!)
- Projektdatei und Referenzen
- MelonGame-Attribut
- Decompiled-Ordner

**Verwendung:**
```powershell
.\scripts\Test-ModSetup.ps1 -GamePath "C:\Pfad\zum\Spiel" -Architecture x64
```

Parameter `-Architecture` kann `x64` oder `x86` sein.

**Ausgabe:** Liste aller Prüfungen mit OK, WARNUNG oder FEHLER, plus Lösungsvorschläge.

---

## Wichtige Links

- MelonLoader GitHub: https://github.com/LavaGang/MelonLoader
- MelonLoader Installer: https://github.com/LavaGang/MelonLoader.Installer/releases
- Tolk (Screenreader): https://github.com/ndarilek/tolk/releases
- dnSpy (Dekompiler): https://github.com/dnSpy/dnSpy/releases
- .NET SDK: https://dotnet.microsoft.com/download
