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

3. **Mod-Loader-Status:**
   - Prüfe ob `MelonLoader`-Ordner existiert → MelonLoader installiert
   - Prüfe ob `BepInEx`-Ordner existiert → BepInEx installiert
   - Keiner vorhanden → Muss installiert werden

4. **Mod-Loader-Log auslesen (falls vorhanden):**
   - **MelonLoader** (`MelonLoader/Latest.log`): Game Name, Developer, Runtime Type (net35/net6), Unity Version extrahieren
   - **BepInEx** (`BepInEx/LogOutput.log`): Erfolgreiche Initialisierung prüfen, Unity Version, Fehler

4b. **Falls kein Mod-Loader installiert — Community-Konsens recherchieren:**
   - Websuche: "[Spielname] mods"
   - Websuche: "[Spielname] MelonLoader OR BepInEx"
   - Nexus Mods, Thunderstore oder spielspezifische Mod-Seiten prüfen
   - Notieren welchen Mod-Loader andere Mods für dieses Spiel nutzen
   - Falls keine Mods gefunden: Notieren — Mod-Loader-Wahl wird auf Heuristiken basieren (siehe Schritt 4e)

5. **Tolk-DLLs prüfen:**
   - Bei 64-Bit: Prüfe ob `Tolk.dll` und `nvdaControllerClient64.dll` im Spielordner
   - Bei 32-Bit: Prüfe ob `Tolk.dll` und `nvdaControllerClient32.dll` im Spielordner

**Ergebnisse zusammenfassen:**

Zeige eine Zusammenfassung dessen was erkannt wurde:
- Game-Engine: Unity (oder andere)
- Architektur: 64-Bit / 32-Bit
- Mod-Loader: MelonLoader / BepInEx / Keiner installiert (+ Community-Empfehlung falls recherchiert)
- Mod-Loader-Log-Infos: Game Name, Developer, Runtime, Unity Version (falls vorhanden)
- Tolk-DLLs: Vorhanden / Fehlen

Frage: Stimmt das so? (Bestätigung abwarten)

**Nur Fehlendes erklären:**

Nach der Bestätigung, liste NUR die fehlenden/problematischen Punkte auf mit konkreter Anleitung:

- Falls kein Unity-Spiel: Erkläre dass MelonLoader/BepInEx nur mit Unity funktionieren, Alternative recherchieren nötig
- Falls kein Mod-Loader installiert: Weiter mit Schritt 4e (Mod-Loader-Auswahl)
- Falls Tolk-DLLs fehlen: Gib die Download-Anleitung (siehe unten)
- Falls Mod-Loader-Log fehlt: Bitte Benutzer das Spiel einmal zu starten

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

**Nicht sofort aufgeben!** Aber ehrlich einschätzen, was realistisch ist. Die Machbarkeit hängt stark von der Engine ab und davon, ob eine aktive Modding-Community für dieses Spiel existiert.

**Zuerst immer diese allgemeinen Prüfungen:**

1. **Offizielle Mod-Unterstützung suchen:**
   - Hat das Spiel Steam Workshop, ein SDK oder einen Mods-Ordner?
   - Hat der Entwickler Modding-Tools veröffentlicht?

2. **Community-Modding-Ressourcen suchen:**
   - Websuche: "[Spielname] modding guide"
   - Websuche: "[Spielname] mod loader"
   - Nexus Mods, Thunderstore, ModDB, spielspezifische Foren prüfen

3. **Programmiersprache des Spiels prüfen:**
   - C# / .NET / Mono → Sehr gut moddbar (siehe .NET-Spiele unten)
   - Java → Mit Java-spezifischen Tools moddbar
   - Lua-Skripte im Spielordner → Durch Bearbeiten der Skripte moddbar
   - Python-Skripte im Spielordner → Durch Bearbeiten der Skripte moddbar
   - Nur C++ → Schwierig (siehe Abschnitte unten)

Für Anfänger: Verschiedene Spiele nutzen verschiedene "Motoren" (Engines). Jede Engine braucht andere Werkzeuge zum Modden. Spiele in C# oder mit Skriptsprachen (Lua, Python) sind generell viel leichter zu modden als reine C++-Spiele.

**Dann je nach erkannter Engine vorgehen:**

---

##### Unreal Engine (UE4 / UE5)

**HINWEIS: Die Informationen in diesem Abschnitt basieren auf Recherche, nicht auf bewährter Accessibility-Modding-Erfahrung. Es existiert noch kein etabliertes Muster für Screenreader-Accessibility-Mods in Unreal-Spielen. Nutze dies als Ausgangspunkt für Recherche, nicht als garantierten Workflow.**

**Erkennung:** `.pak`-Dateien, `UE4` oder `UE5` in Dateinamen, `Engine/Binaries`-Ordnerstruktur.

**Was existiert:**
- **UE4SS** (RE-UE4SS) ist das Community-Standard-Modding-Framework für Unreal-Spiele. Injiziert sich ins Spiel und bietet eine Lua-Skripting-Schicht und C++-Mod-API. Vergleichbar mit MelonLoader/BepInEx, aber für Unreal.
- UE4SS kann reflektierte Spielfunktionen hooken (ähnliches Konzept wie Harmony, aber nur für Funktionen die als UFUNCTION im Reflection-System der Engine markiert sind — nicht beliebige C++-Funktionen).
- Lua-Mods können Spielobjekt-Eigenschaften lesen/schreiben, Funktionsausführung hooken und auf Spiel-Events reagieren.
- C++-Mods als DLLs könnten theoretisch Tolk für Screenreader-Ausgabe aufrufen.

**Analyse-Tools:**
- UE4SS generiert SDK/Header-Dumps mit Klassennamen, Properties und Funktionssignaturen — das nächste Äquivalent zur Unity-Dekompilierung, gibt aber nur API-Struktur, keinen Implementierungscode.
- FModel extrahiert und durchsucht Spiel-Assets aus .pak-Dateien.
- KismetKompiler kann Blueprint-Bytecode dekompilieren (für Blueprint-lastige Spiele).

**Accessibility-Barrieren für blinde Modder:**
- FModel und der UE4SS Live Property Viewer sind visuelle GUI-Tools — **nicht mit Screenreader bedienbar**.
- Die SDK/Header-Dump-Ausgabe ist textbasiert und mit CLI-Tools durchsuchbar — dieser Teil ist zugänglich.
- Es gibt **keine existierenden Screenreader-Accessibility-Mods** für Unreal-Spiele als Vorbild. Das wäre Neuland.
- Spielcode-Analyse ist schwieriger als bei Unity, weil man nur API-Signaturen bekommt, keinen vollen Quellcode.

**Realistische Einschätzung:**
- **Machbar wenn:** Das Spiel eine aktive UE4SS-Modding-Community hat mit dokumentierten Hooks und APIs. Andere Mods existieren die zeigen wie man auf die Spieldaten zugreift. Ein sehender Helfer bei der Erstanalyse mit visuellen Tools unterstützen könnte.
- **Nicht machbar wenn:** Keine Modding-Community existiert, das Spiel nicht mit UE4SS funktioniert, oder wichtige Spiellogik in nicht-reflektierten nativen C++-Funktionen liegt.
- **Unser Template ist NICHT direkt anwendbar.** Die Mod-Sprache ist Lua oder C++ (nicht C#), das Patching-System ist anders, und die Projektstruktur ist komplett verschieden. Die Accessibility-Patterns (Handler-Klassen, ScreenReader-Wrapper, Loc-System) könnten konzeptionell adaptiert werden, aber der Code müsste neu geschrieben werden.

**Falls fortgefahren wird:** Zuerst UE4SS-Kompatibilität für dieses spezifische Spiel recherchieren. UE4SS-Discord und -Dokumentation prüfen. Erkenntnisse in `docs/game-api.md` dokumentieren.

---

##### Godot Engine

**HINWEIS: Die Informationen in diesem Abschnitt basieren auf Recherche, nicht auf bewährter Accessibility-Modding-Erfahrung. Nutze dies als Ausgangspunkt, nicht als garantierten Workflow.**

**Erkennung:** `.pck`-Dateien, `libgodot`-Dateien, Godot-Splashscreen.

**Was existiert:**
- **Godot Mod Loader** ist das primäre Modding-Framework — aber er **muss vom Spielentwickler eingebaut sein**. Kann nicht von außen injiziert werden (anders als MelonLoader/BepInEx). Wenn das Spiel ihn nicht enthält, ist Script-Level-Modding sehr eingeschränkt.
- Ohne Mod Loader: Mods funktionieren durch Ersetzen von Spieldateien über PCK-Pakete. Spielskripte dekompilieren, modifizieren, als PCK neu verpacken. Fragil und bricht bei Spiel-Updates.
- **Godot 4.5+** (veröffentlicht September 2025) hat eingebaute AccessKit-Screenreader-Unterstützung. Wenn das Spiel Godot 4.5+ nutzt und Standard-UI-Nodes verwendet, könnte die UI bereits teilweise für Screenreader zugänglich sein — ohne Modding.
- Godot ist vollständig Open Source (MIT-Lizenz), die Engine-Interna sind dokumentiert.

**Analyse-Tools:**
- **gdsdecomp / GDRE Tools** kann GDScript-Bytecode zu lesbarem Quellcode dekompilieren — ähnlich wie dnSpy für .NET. CLI-Tool, sollte mit Screenreader bedienbar sein.
- **GdTool** ist ein CLI-Tool zum Kompilieren/Dekompilieren von GDScript und Verwalten von PCK-Dateien.

**Accessibility-Barrieren für blinde Modder:**
- Ohne eingebauten Mod Loader: nur PCK-Datei-Ersetzung funktioniert, was aufwendig und fragil ist.
- Die Mod-Sprache ist GDScript (nicht C#), erfordert das Erlernen einer neuen Sprache.
- Keine bekannten Accessibility-Mods für Godot-Spiele als Vorbild.

**Realistische Einschätzung:**
- **Bester Fall:** Spiel nutzt Godot 4.5+ (AccessKit möglicherweise eingebaut) UND hat den Godot Mod Loader integriert. Dann sind GDScript-Mods mit TTS-Aufrufen möglich.
- **Mittlerer Fall:** Spiel kann mit gdsdecomp dekompiliert, Skripte modifiziert und neu verpackt werden. Funktioniert aber ist fragil.
- **Schlechtester Fall:** Spiel nutzt Godot 3.x ohne Mod Loader. Auf Skript-Ersetzung beschränkt, keine eingebaute Accessibility-Unterstützung.
- **Unser Template ist NICHT direkt anwendbar** (andere Sprache, andere Mod-Struktur), aber die Accessibility-Patterns (modulare Handler, Lokalisierung, Screenreader-Wrapper) übertragen sich konzeptionell.

---

##### .NET-Spiele (XNA, MonoGame, FNA, andere .NET-Frameworks)

**Erkennung:** Spiel-DLLs können mit dnSpy/ILSpy geöffnet werden und zeigen lesbaren C#-Code. Suche nach `MonoGame.Framework.dll`, `FNA.dll`, `Microsoft.Xna.Framework.dll` oder anderen .NET-Assemblies im Spielordner.

**Gute Nachricht: Diese Spiele sind mit den gleichen Tools wie Unity-Spiele moddbar.**

- **BepInEx** unterstützt explizit .NET-Framework-Spiele jenseits von Unity, einschließlich XNA-, MonoGame- und FNA-Spielen.
- **Harmony**-Patching funktioniert genau wie bei Unity — Runtime-IL-Patching jeder .NET-Methode.
- **dnSpy / ILSpy** dekompilieren den Spielcode zu lesbarem C#, genau wie bei Unity.
- **Tolk**-Integration funktioniert identisch.

**Bewährte Beispiele:**
- Stardew Valley (MonoGame) hat SMAPI, einen dedizierten Mod-Loader mit tausenden Mods
- Celeste (MonoGame) hat den Everest Mod-Loader

**Realistische Einschätzung:**
- **Unser Template ist weitgehend anwendbar.** Die Accessibility-Patterns, Handler-Struktur, ScreenReader-Wrapper und Loc-System funktionieren alle. Die Hauptunterschiede liegen beim Projekt-Setup (andere DLL-Referenzen, kein MelonLoader/Unity-spezifischer Lifecycle) und möglicherweise andere Einstiegspunkte.
- **Machbarkeit ist ähnlich wie bei Unity** — wenn sich die DLLs dekompilieren lassen und BepInEx funktioniert, ist der volle Workflow anwendbar.

**Falls fortgefahren wird:** BepInEx zuerst probieren. Spielcode mit dnSpy analysieren. Main.cs des Templates auf BepInEx's `BaseUnityPlugin`-Pattern anpassen (oder die passende Basisklasse für das spezifische .NET-Framework). Der Rest des Templates (Handler, ScreenReader, Loc) braucht minimale Änderungen.

---

##### Java-Spiele

**HINWEIS: Java-Game-Modding ist gut etabliert (Minecraft ist die größte Modding-Community im Gaming), nutzt aber komplett anderes Tooling als unser C#-basiertes Template.**

**Erkennung:** `.jar`-Dateien, Java Runtime benötigt, `jre`- oder `jdk`-Ordner.

**Was existiert:**
- Java-Bytecode enthält Metadaten (Klassennamen, Methodennamen) ähnlich wie .NET — Dekompilierung liefert lesbaren Code.
- **Minecraft** hat ausgereifte Mod-Loader: Fabric (leichtgewichtig, nutzt Mixin für Bytecode-Injektion) und NeoForge (umfassende APIs). Das Mixin-System ist konzeptionell mit Harmony vergleichbar.
- Andere Java-Spiele haben möglicherweise keine etablierten Mod-Loader, aber Java-Dekompiler (JD-GUI, Fernflower, CFR) und Bytecode-Manipulationsbibliotheken existieren.

**Accessibility-Barrieren:**
- Unser Template (C#, .NET, Tolk) ist nicht anwendbar — Java nutzt ein anderes Ökosystem.
- Tolk hat keine Java-Bindings (bräuchte JNI oder JNA für den Aufruf der nativen DLL).
- Entwicklungsworkflow, Build-Tools und Projektstruktur sind komplett verschieden.

**Realistische Einschätzung:**
- **Machbar für Minecraft** und andere Java-Spiele mit etablierten Mod-Loadern — erfordert aber Java-Entwicklungskenntnisse und spielspezifische Tools.
- **Unser Template ist NICHT anwendbar** was den Code betrifft, aber die Accessibility-Konzepte (modulare Handler, Screenreader-Integration, Lokalisierung) übertragen sich in jede Sprache.

---

##### Spiele mit eingebettetem Lua-Skripting

**Erkennung:** Suche nach `lua51.dll`, `lua52.dll`, `lua53.dll`, `lua54.dll` oder `luajit.dll` im Spielordner. Auch `.lua`- oder `.luac`-Dateien.

**Was existiert:**
- Viele Custom Engines betten Lua als Skripting-Schicht ein. Wenn das Spiel Lua-Skripte aus Dateien lädt, können diese modifiziert oder erweitert werden.
- Spiele mit umfassenden Lua-APIs: World of Warcraft (UI-Addons), Factorio (volle Gameplay-Mods), Don't Starve, Garry's Mod.
- LuaJITs FFI (Foreign Function Interface) kann native DLLs aufrufen — Tolk könnte also von Lua-Mods aus aufgerufen werden.

**Realistische Einschätzung:**
- **Sehr spielspezifisch.** Manche Lua-geskriptete Spiele haben reichhaltige APIs und aktive Communities (Factorio, WoW). Andere nutzen Lua nur für interne Konfiguration ohne Modding-Oberfläche.
- **Wenn Lua-Skripte editierbar und dokumentiert sind:** Kann ein gangbarer Weg sein. Der Mod wird in Lua statt C# geschrieben, und Tolk kann über FFI aufgerufen werden.
- **Wenn nur kompilierter Lua-Bytecode vorliegt (`.luac`-Dateien):** Dekompilierung ist möglich aber weniger zuverlässig als bei GDScript oder .NET.
- **Unser Template ist NICHT direkt anwendbar** (andere Sprache), aber die Patterns übertragen sich.

---

##### Spiele mit eingebettetem Python

**Erkennung:** Suche nach `python*.dll` im Spielordner, oder `.py`- / `.pyc`-Dateien.

**Was existiert:**
- **Ren'Py** (Visual-Novel-Engine): Auf Python aufgebaut, Open Source, einfach zu modden durch Bearbeiten von `.rpy`-Skriptdateien. Hat eine Community.
- Manche Custom Engines betten Python fürs Skripting ein.
- Pythons `ctypes`-Bibliothek kann native DLLs aufrufen — Tolk-Integration ist direkt aus Python möglich.
- `.pyc`-Dateien (kompilierter Python-Bytecode) können mit Tools wie `uncompyle6` oder `decompyle3` dekompiliert werden.

**Realistische Einschätzung:**
- **Ren'Py-Spiele:** Relativ leicht zu modden. Skripte werden oft als lesbare `.rpy`-Dateien ausgeliefert. Accessibility-Mods könnten TTS-Aufrufe hinzufügen.
- **Andere Python-geskriptete Spiele:** Hängt davon ab wie viel der Spiellogik in Python ist und ob Skripte zugänglich sind.
- **Unser Template ist NICHT direkt anwendbar** (andere Sprache), aber die Patterns übertragen sich.

---

##### Reine C++-Spiele (keine Skripting-Schicht)

Wenn das Spiel rein in C++ geschrieben ist, ohne jede Skripting-Schicht (Lua, Python, C#), sei ehrlich:

> **Wichtiger Hinweis:** Reine C++-Spiele sind für Accessibility-Modding extrem schwierig — besonders für blinde Modder. Die Werkzeuge die sehende Reverse Engineers nutzen (Cheat Engine, ReClass, Frida, x64dbg) sind mit Screenreader **nicht bedienbar**. Sie erfordern visuelles Navigieren im Spiel und Abgleichen von Bildschirminhalten mit Speicheradressen.
>
> Selbst wenn jemand Sehendes Speicheradressen finden würde: Die Ergebnisse sind **unzuverlässig**. Adressen ändern sich bei jedem Neustart, bei Updates, bei unterschiedlichen Systemkonfigurationen. Stabile Accessibility-Features auf wechselnden Adressen aufzubauen funktioniert nicht.
>
> **Realistisch ist ein reines C++-Spiel nur moddbar wenn:**
>
> 1. **Eine etablierte Modding-Community existiert** mit dokumentierten Tools und APIs. Wenn andere Mods existieren, können wir deren Ansatz studieren.
> 2. **Das Spiel offizielle Mod-Unterstützung hat** — ein SDK, Plugin-API oder Skripting-Interface das stabilen, benannten Zugriff auf Spieldaten bietet.
> 3. **Das Spiel Daten in zugänglichen Formaten speichert** — lesbare Config-Dateien, Savegames oder APIs.
>
> **Falls nichts davon zutrifft:** Dieses Spiel ist aktuell nicht moddbar für Accessibility durch einen blinden Modder. Das ist kein Können-Problem — es ist eine Werkzeug- und Zugangsbarriere.
>
> Alternativen vorschlagen:
> - Spieleentwickler direkt kontaktieren und Accessibility-Features oder eine API anfragen
> - Prüfen ob es ein Community-Accessibility-Projekt gibt (sehende Freiwillige leiten diese manchmal)
> - Nach einem ähnlichen Spiel suchen das eine moddbare Engine nutzt
> - Prüfen ob der Entwickler open-source-freundlich ist — selbst teilweiser Zugang (Spieldaten, Dokumentation) kann helfen

---

##### Spiele mit offiziellem Modding-SDK

Manche Spiele liefern offizielle Modding-Tools mit, unabhängig von der Engine. Falls die Auto-Prüfung oder Community-Suche ein SDK, einen Mod-Editor oder eine dokumentierte Mod-API gefunden hat:

- **Das ist immer der bevorzugte Weg.** Offizielle Tools sind stabiler und besser dokumentiert als Reverse Engineering.
- Prüfen was das SDK erlaubt: nur Content-/Asset-Mods, oder auch Code-/Logik-Mods?
- Für Accessibility brauchen wir Code-Level-Zugriff (um Screenreader-Aufrufe einzubauen). Reine Asset-SDKs (Level-Editoren, Textur-Tausch) reichen nicht aus.
- Wenn das SDK ein Skripting-Interface bietet (Lua, Python, C#), könnten Accessibility-Mods machbar sein. Einzelfallbewertung.

---

##### Falls kein Modding-Weg gefunden wird

Ehrlich sein — manche Spiele können nicht gemoddet werden:
- Keine etablierte Modding-Community oder Tools für dieses Spiel
- Starker DRM- oder Anti-Cheat-Schutz (blockiert DLL-Injektion und Speicherzugriff)
- Reines C++ ohne Skripting-Schicht oder Modding-API
- Online-only mit serverseitiger Logik
- Sehr obskure oder proprietäre Engines

**Wichtig:** Keine Werkzeuge empfehlen die mit Screenreader nicht bedienbar sind (Cheat Engine, Memory Scanner, visuelle Debugger), ohne diese Einschränkung klar zu benennen. Unzugängliche Tools zu empfehlen verschwendet Zeit und erzeugt Frustration.

**Haftungsausschluss:** Die engine-spezifischen Informationen oben basieren auf Recherche und können unvollständig oder veraltet sein. Modding-Ökosysteme entwickeln sich schnell. Immer die aktuelle Kompatibilität für das spezifische Spiel verifizieren.

#### Schritt 4b: Architektur (manuell)

Frage: Weißt du ob das Spiel 32-Bit oder 64-Bit ist?

Hinweise zum Herausfinden:
- `MonoBleedingEdge` Ordner = meist 64-Bit
- `Mono` Ordner = meist 32-Bit
- Dateien mit "x64" im Namen = 64-Bit

**WICHTIG:** Die Architektur bestimmt welche Tolk-DLLs benötigt werden!

#### Schritt 4c: Mod-Loader (manuell, nur Unity)

Frage: Ist ein Mod-Loader (MelonLoader oder BepInEx) bereits installiert?

Hinweise zum Erkennen:
- `MelonLoader`-Ordner im Spielverzeichnis → MelonLoader ist installiert
- `BepInEx`-Ordner im Spielverzeichnis → BepInEx ist installiert
- Keiner von beiden → Muss installiert werden (siehe Schritt 4e)

Für Anfänger: Ein Mod-Loader ist ein Programm das unseren Mod-Code ins Spiel lädt. Sowohl MelonLoader als auch BepInEx bringen "Harmony" mit, eine Bibliothek zum Einhaken in Spielfunktionen. Deshalb müssen wir Harmony nicht extra herunterladen.

---

### Schritt 4e: Mod-Loader-Auswahl (nur Unity)

**Ziel:** Bestimmen welcher Mod-Loader für dieses Spiel verwendet wird. Das ist entscheidend — mit dem falschen Mod-Loader funktioniert der Mod möglicherweise gar nicht.

**Falls ein Mod-Loader bereits erkannt wurde (Auto-Prüfung oder manuell):**

Nutze den, der installiert ist. Falls beide installiert sind, frage welchen der Benutzer bevorzugt (normalerweise bei dem bleiben, den die Modding-Community des Spiels nutzt).

**Falls kein Mod-Loader installiert ist:**

1. **Community-Konsens recherchieren:**
   - Websuche: "[Spielname] mods"
   - Websuche: "[Spielname] modding guide"
   - Nexus Mods, Thunderstore oder spielspezifische Mod-Seiten prüfen
   - Schauen was andere Mods für dieses Spiel verwenden

2. **Ergebnisse auswerten:**
   - Community nutzt **MelonLoader**: MelonLoader verwenden
   - Community nutzt **BepInEx**: BepInEx verwenden
   - **Beide** werden genutzt: Beide funktionieren — Benutzer fragen oder Mehrheit empfehlen
   - **Keine Mods vorhanden** für das Spiel: Siehe Hinweis unten

3. **Allgemeine Heuristiken (wenn keine Community-Empfehlung existiert):**
   - Il2Cpp-Spiele (kein `[Spiel]_Data\Managed`-Ordner, oder MelonLoader-Log sagt "Il2Cpp"): **MelonLoader** ist generell zuverlässiger
   - Mono-Spiele (klassischer `[Spiel]_Data\Managed`-Ordner mit `Assembly-CSharp.dll`): Beide funktionieren, BepInEx hat mehr Community-Ressourcen
   - Sehr alte Unity-Versionen (5.x): **BepInEx 5.x** zuerst probieren, MelonLoader unterstützt das möglicherweise nicht

**Hauptunterschiede für den Benutzer:**

- **MelonLoader:** Installiert sich über eine Installer-EXE. Mods kommen in den `Mods/`-Ordner. Eigene Logdatei (`MelonLoader/Latest.log`).
- **BepInEx:** Installiert sich durch Entpacken einer ZIP in den Spielordner. Mods (Plugins) kommen in `BepInEx/plugins/`. Eigene Logdatei (`BepInEx/LogOutput.log`).
- **Beide:** Enthalten Harmony fürs Patching. Beide unterstützen Tolk für Screenreader-Ausgabe. Der eigentliche Mod-Code (Handler-Klassen, ScreenReader-Wrapper, Loc-System) ist nahezu identisch.

Für Anfänger: Stell dir Mod-Loader wie verschiedene Marken von Netzteilen vor — sie liefern beide Strom (laden deinen Mod), nur mit leicht unterschiedlichen Steckern (Setup und Struktur). Der wichtige Teil — die eigentlichen Features deines Mods — funktioniert mit beiden gleich.

**Falls gar keine Mods für das Spiel existieren:**

Das ist nicht zwingend ein Blocker, bedeutet aber:
- Niemand hat verifiziert dass ein Mod-Loader mit diesem Spiel funktioniert
- Es kann Anti-Cheat, DRM oder andere Hindernisse geben
- Installation könnte Fehlerbehebung erfordern

Empfehlung: Den Mod-Loader probieren der zur Runtime des Spiels passt (MelonLoader für Il2Cpp, beide für Mono). Falls es nicht funktioniert, den anderen versuchen. Ergebnisse dokumentieren.

**Installationsanleitungen:**

**MelonLoader:**
- Download: https://github.com/LavaGang/MelonLoader.Installer/releases
- Installer starten und auf die EXE des Spiels zeigen
- Nach Installation sollte ein `MelonLoader`-Ordner im Spielverzeichnis sein
- Spiel einmal starten um Ordnerstruktur zu erstellen und Logdatei zu generieren

**BepInEx:**
- Download: https://github.com/BepInEx/BepInEx/releases
- Für Unity-Mono-Spiele: Den passenden Build herunterladen (x64 oder x86, passend zur Spielarchitektur)
- Für Unity-Il2Cpp-Spiele: Den Il2Cpp-Build herunterladen (MelonLoader ist für Il2Cpp aber meist besser)
- ZIP-Inhalt in den Spielordner entpacken (wo die Spiel-EXE liegt)
- Spiel einmal starten um Ordnerstruktur zu erstellen (`BepInEx/plugins/`, `BepInEx/config/`, etc.)

**Nach der Installation:** Weiter mit Schritt 5 (Tolk).

**Den gewählten Mod-Loader** in `project_status.md` festhalten — er beeinflusst die Projektstruktur, Build-Konfiguration und Code-Templates.

---

### Schritt 5: Tolk (falls bei automatischer Prüfung als fehlend gemeldet)

Falls Tolk-DLLs fehlen, erkläre:
- Download: https://github.com/ndarilek/tolk/releases
- **WICHTIG: Es werden BEIDE DLLs benötigt — nicht nur Tolk.dll!**
- Für 64-Bit: `Tolk.dll` + `nvdaControllerClient64.dll` aus dem x64-Ordner
- Für 32-Bit: `Tolk.dll` + `nvdaControllerClient32.dll` aus dem x86-Ordner
- BEIDE DLLs in den Spielordner kopieren (wo die .exe liegt)
- Ohne `nvdaControllerClient*.dll` bekommt NVDA keine Ausgabe! (JAWS funktioniert über COM, braucht keine extra DLL)

Für Anfänger: Tolk ist eine Bibliothek die mit verschiedenen Screenreadern (NVDA, JAWS, etc.) kommunizieren kann. Unser Mod nutzt Tolk um Text an deinen Screenreader zu senden. Tolk.dll ist die Brücke, und nvdaControllerClient*.dll wird speziell benötigt damit NVDA den Text empfangen kann.

### Schritt 6: .NET SDK

Frage: Hast du das .NET SDK bereits installiert?

Prüfen mit: `dotnet --version` in PowerShell.

Falls nein, per WinGet installieren (bevorzugt — Claude Code kann das automatisch ausführen):

```powershell
winget install Microsoft.DotNet.SDK.8
```

Nach der Installation **Terminal neu starten**, damit der `dotnet`-Befehl verfügbar ist.

Falls WinGet nicht verfügbar ist, manueller Download: https://dotnet.microsoft.com/download (empfohlen: .NET 8 SDK oder neuer).

Für Anfänger: Das .NET SDK ist ein Entwicklungswerkzeug von Microsoft. Wir brauchen es um unseren C#-Code in eine DLL-Datei zu kompilieren, die der Mod-Loader (MelonLoader oder BepInEx) dann laden kann.

### Schritt 7: Dekompilierung

Frage: Hast du ein Dekompilier-Tool (dnSpy oder ILSpy) installiert?

Falls nein, erkläre:

**ILSpy (empfohlen):**

Kommandozeilen-Tool per dotnet installieren (bevorzugt — Claude Code kann das automatisch ausführen):

```powershell
dotnet tool install ilspycmd -g
```

Nach der Installation **Terminal neu starten**, damit der `ilspycmd`-Befehl verfügbar ist.

- **Vorteil:** Komplett über die Kommandozeile steuerbar, Claude Code kann die Dekompilierung automatisieren
- Kommandozeilen-Nutzung: `ilspycmd -p -o decompiled "[Spiel]_Data\Managed\Assembly-CSharp.dll"`
- Damit wird der gesamte Dekompilierungsprozess automatisierbar — Claude Code kann das für dich erledigen

Optional auch die GUI-Version per WinGet installieren:

```powershell
winget install icsharpcode.ILSpy
```

Falls weder WinGet noch dotnet tool verfügbar ist, manueller Download: https://github.com/icsharpcode/ILSpy/releases

**dnSpy (Alternative):**
- Download: https://github.com/dnSpy/dnSpy/releases
- Nicht über WinGet verfügbar (eingestelltes Projekt)
- GUI-basiertes Tool mit manuellem Workflow
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
- Mod-Loader installiert und getestet: MelonLoader (Spiel startet mit MelonLoader-Konsole) oder BepInEx (BepInEx-Logdatei erstellt)
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

**Diese Werte MÜSSEN aus dem Mod-Loader-Log gelesen werden, NIEMALS raten!**

### Für MelonLoader

#### Automatisch mit Skript (empfohlen)

```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Pfad\zum\Spiel"
```

Das Skript extrahiert alle Werte und zeigt das fertige MelonGame-Attribut an.

#### Manuell (falls Skript nicht verfügbar)

**Schritt 1:** Spiel einmal mit MelonLoader starten (erstellt das Log).

**Schritt 2:** Log-Pfad: `[Spielordner]\MelonLoader\Latest.log`

Suche nach diesen Zeilen und notiere die EXAKTEN Werte:

```
Game Name: [EXAKT ÜBERNEHMEN]
Game Developer: [EXAKT ÜBERNEHMEN]
Runtime Type: [net35 oder net6]
```

#### Werte in Code/Projekt eintragen (MelonLoader)

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

**Warum ist das so wichtig?**
1. **Entwicklername falsch** = Mod wird geladen aber OnInitializeMelon() wird nie aufgerufen. Kein Fehler im Log, einfach Stille.
2. **Framework falsch** = Mod wird geladen aber kann nicht ausgeführt werden. Kein Fehler im Log, einfach Stille.

**Bei Crashes oder stillem Fehlschlagen:** Lies `technical-reference.md` Abschnitt "KRITISCH: Zugriff auf Spielcode".

### Für BepInEx

#### Log und Konfiguration

**Schritt 1:** Spiel einmal mit BepInEx starten (erstellt Config- und Log-Dateien).

**Schritt 2:** Log-Pfad: `[Spielordner]\BepInEx\LogOutput.log`

Prüfe das Log auf:
- Erfolgreiche BepInEx-Initialisierung
- Unity-Version
- Fehler oder Warnungen

#### Werte in Code/Projekt eintragen (BepInEx)

**BepInPlugin-Attribut (Main.cs):**
```csharp
[BepInPlugin("com.autor.modname", "ModName", "1.0.0")]
```
- Der erste Parameter (GUID) ist eine eindeutige Kennung — verwende umgekehrte Domain-Notation
- Diese Werte müssen NICHT aus dem Log gelesen werden — du wählst sie selbst
- Aber die GUID muss einzigartig unter allen Mods für dieses Spiel sein

**TargetFramework (csproj):**
- Die meisten BepInEx-Mono-Spiele: `<TargetFramework>net472</TargetFramework>` oder `<TargetFramework>net35</TargetFramework>`
- Prüfe was andere BepInEx-Mods für dieses Spiel verwenden, oder prüfe die DLLs in `BepInEx/core/`
- BepInEx-DLLs referenzieren: `BepInEx/core/BepInEx.dll` und relevante Unity-DLLs aus `[Spiel]_Data/Managed/`

**Projekt-Referenzen (csproj) für BepInEx:**
```xml
<Reference Include="BepInEx">
    <HintPath>[Spielordner]\BepInEx\core\BepInEx.dll</HintPath>
</Reference>
<Reference Include="0Harmony">
    <HintPath>[Spielordner]\BepInEx\core\0Harmony.dll</HintPath>
</Reference>
<Reference Include="UnityEngine">
    <HintPath>[Spielordner]\[Spiel]_Data\Managed\UnityEngine.dll</HintPath>
</Reference>
<Reference Include="UnityEngine.CoreModule">
    <HintPath>[Spielordner]\[Spiel]_Data\Managed\UnityEngine.CoreModule.dll</HintPath>
</Reference>
<Reference Include="Assembly-CSharp">
    <HintPath>[Spielordner]\[Spiel]_Data\Managed\Assembly-CSharp.dll</HintPath>
</Reference>
```

**Ausgabeordner:** Die gebaute DLL kommt in `BepInEx/plugins/` (nicht `Mods/`).

### Gemeinsam für beide Mod-Loader

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

1. C#-Projekt mit Mod-Loader-Referenzen erstellen (MelonLoader oder BepInEx — siehe `technical-reference.md` für beide)
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
- Mod-Loader-Installation (MelonLoader oder BepInEx)
- Tolk-DLLs (prüft auch richtige Architektur!)
- Projektdatei und Referenzen
- Mod-Loader-Attribute (MelonGame oder BepInPlugin)
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
- BepInEx GitHub: https://github.com/BepInEx/BepInEx
- BepInEx Releases: https://github.com/BepInEx/BepInEx/releases
- Tolk (Screenreader): https://github.com/ndarilek/tolk/releases
- dnSpy (Dekompiler): https://github.com/dnSpy/dnSpy/releases
- .NET SDK: https://dotnet.microsoft.com/download
