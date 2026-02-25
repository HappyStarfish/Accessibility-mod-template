# Technische Referenz

Kompakte Übersicht: MelonLoader, BepInEx, Harmony und Tolk.

---

## MelonLoader Grundlagen

### Projekt-Referenzen (csproj)

```xml
<Reference Include="MelonLoader">
    <HintPath>[Spielordner]\MelonLoader\net6\MelonLoader.dll</HintPath>
</Reference>
<Reference Include="UnityEngine.CoreModule">
    <HintPath>[Spielordner]\MelonLoader\Managed\UnityEngine.CoreModule.dll</HintPath>
</Reference>
<Reference Include="Assembly-CSharp">
    <HintPath>[Spielordner]\[Spiel]_Data\Managed\Assembly-CSharp.dll</HintPath>
</Reference>
```

### MelonInfo Attribut

```csharp
[assembly: MelonInfo(typeof(MyNamespace.Main), "ModName", "1.0.0", "Autor")]
[assembly: MelonGame("Entwickler", "Spielname")]
```

### Lebenszyklus

```csharp
public class Main : MelonMod
{
    public override void OnInitializeMelon() { }  // Einmalig beim Laden
    public override void OnUpdate() { }            // Jeden Frame
    public override void OnSceneWasLoaded(int buildIndex, string sceneName) { }
    public override void OnApplicationQuit() { }   // Beim Beenden
}
```

### KRITISCH: Zugriff auf Spielcode

**Jeder Zugriff auf Spielklassen vor dem vollständigen Laden des Spiels kann crashen.**

Das betrifft:
- Spielmanager-Singletons (z.B. `GameManager.i`, `AudioManager.instance`)
- `typeof(SpielKlasse)` - auch in Harmony-Attributen!
- Jede Referenz auf Spielklassen in Feldern oder frühen Methoden

**Erlaubt nach Zeitpunkt:**

- Assembly-Load: Nur eigene Klassen und Unity-Typen
- OnInitializeMelon: Nur eigene Initialisierung, KEINE Spielzugriffe
- OnSceneWasLoaded: Alles erlaubt

**Wann ist das Spiel bereit?**

Erst in/nach `OnSceneWasLoaded()`. Sicherer Test: Ein zuverlässiges UI-Element prüfen:

```csharp
if (GameObject.Find("HauptUI") == null)
    return; // Spiel noch nicht bereit
```

**Fehler 1: typeof() in Harmony-Attributen**

```csharp
// FALSCH - typeof() wird beim Assembly-Load ausgewertet
[HarmonyPatch(typeof(SpielKlasse))]
public static class MeinPatch { }
```

```csharp
// RICHTIG - Patches manuell in OnSceneWasLoaded anwenden
public override void OnSceneWasLoaded(int buildIndex, string sceneName)
{
    if (!_patchesApplied && GameObject.Find("HauptUI") != null)
    {
        var targetType = typeof(SpielKlasse);
        _harmony.Patch(AccessTools.Method(targetType, "MethodName"), ...);
        _patchesApplied = true;
    }
}
```

**Fehler 2: Singleton-Zugriff zu früh**

```csharp
// FALSCH - Singleton kann blockieren oder crashen
public override void OnUpdate()
{
    var manager = GameManager.i;
}
```

```csharp
// RICHTIG - Erst prüfen, dann cachen
private GameManager _cachedManager = null;

private GameManager GetManagerSafe()
{
    if (_cachedManager != null) return _cachedManager;

    if (GameObject.Find("HauptUI") == null)
        return null; // Spiel noch nicht bereit

    _cachedManager = GameManager.i;
    return _cachedManager;
}
```

### Logging

```csharp
MelonLogger.Msg("Info");
MelonLogger.Warning("Warnung");
MelonLogger.Error("Fehler");
```

### Tasteneingaben

```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Einmalig gedrückt
if (Input.GetKey(KeyCode.LeftShift)) { }  // Gehalten
```

---

## BepInEx Grundlagen

### Projekt-Referenzen (csproj)

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

### BepInPlugin Attribut

```csharp
[BepInPlugin("com.autor.modname", "ModName", "1.0.0")]
```

- Erster Parameter: Eindeutige GUID (umgekehrte Domain-Notation)
- Im Gegensatz zu MelonLoader werden diese Werte frei gewählt (nicht aus einer Log-Datei)
- Die GUID muss einzigartig unter allen Mods für dieses Spiel sein

### Lebenszyklus

```csharp
using BepInEx;
using UnityEngine;

[BepInPlugin("com.autor.modname", "ModName", "1.0.0")]
public class Main : BaseUnityPlugin
{
    void Awake() { }     // Einmalig beim Laden (wie OnInitializeMelon)
    void Update() { }    // Jeden Frame (wie OnUpdate)
    void OnDestroy() { } // Beim Beenden (wie OnApplicationQuit)
}
```

**Hauptunterschiede zu MelonLoader:**

- `BaseUnityPlugin` erbt von `MonoBehaviour` — nutzt Unity-Lifecycle-Methoden
- Kein `OnSceneWasLoaded`-Äquivalent eingebaut. Stattdessen `SceneManager.sceneLoaded`-Event nutzen:

```csharp
using UnityEngine.SceneManagement;

void Awake()
{
    SceneManager.sceneLoaded += OnSceneLoaded;
}

private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
{
    Logger.LogInfo($"Scene geladen: {scene.name}");
}
```

### KRITISCH: Zugriff auf Spielcode (BepInEx)

Die gleichen Timing-Regeln gelten wie bei MelonLoader:

- **Awake()**: Nur eigene Initialisierung, KEINE Spielklassen-Zugriffe
- **Nach Scene-Load**: Alles erlaubt

```csharp
private bool _gameReady = false;

void Update()
{
    if (!_gameReady)
    {
        // Auf Spiel-Singletons prüfen — ans Spiel anpassen!
        // if (GameManager.instance != null)
        //     _gameReady = true;
        // else
        //     return;
        return;
    }

    // Spiellogik hier
}
```

### Logging

```csharp
Logger.LogInfo("Info");       // Instanz-Logger (innerhalb der Plugin-Klasse)
Logger.LogWarning("Warnung");
Logger.LogError("Fehler");
```

### Tasteneingaben

Gleich wie MelonLoader — beide nutzen Unitys Input-System:

```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Einmalig gedrückt
if (Input.GetKey(KeyCode.LeftShift)) { }  // Gehalten
```

### Mod-Ausgabeordner

Gebaute DLL kommt in `BepInEx/plugins/` (nicht `Mods/` wie bei MelonLoader).

---

## Harmony Patching

Harmony ist in MelonLoader und BepInEx enthalten - kein extra Import nötig.

### Setup in Main

**MelonLoader:**
```csharp
private HarmonyLib.Harmony _harmony;

public override void OnInitializeMelon()
{
    _harmony = new HarmonyLib.Harmony("com.autor.modname");
    _harmony.PatchAll();
}
```

**BepInEx:**
```csharp
// Harmony wird von BepInEx bereitgestellt. Einfach PatchAll in Awake aufrufen:
void Awake()
{
    var harmony = new HarmonyLib.Harmony("com.autor.modname");
    harmony.PatchAll();
}
```

### Postfix (nach Originalmethode)

```csharp
[HarmonyPatch(typeof(InventoryUI), "Show")]
public class InventoryShowPatch
{
    [HarmonyPostfix]
    public static void Postfix()
    {
        ScreenReader.Say("Inventar geöffnet");
    }
}
```

### Postfix mit Rückgabewert

```csharp
[HarmonyPatch(typeof(Player), "GetHealth")]
public class HealthPatch
{
    [HarmonyPostfix]
    public static void Postfix(ref int __result)
    {
        MelonLogger.Msg($"Gesundheit: {__result}");
    }
}
```

### Prefix (vor Originalmethode)

```csharp
[HarmonyPatch(typeof(Player), "TakeDamage")]
public class DamagePatch
{
    [HarmonyPrefix]
    public static void Prefix(int damage)
    {
        ScreenReader.Say($"Schaden: {damage}");
    }

    // Return false um Original zu überspringen:
    // public static bool Prefix() { return false; }
}
```

### Spezielle Parameter

- `__instance` - Die Objektinstanz
- `__result` - Rückgabewert (nur Postfix)
- `___fieldName` - Private Felder (3 Unterstriche!)

---

## Tolk (Screenreader)

### Benötigte DLLs im Spielordner

**BEIDE Dateien müssen im Spielordner liegen (wo die .exe ist):**
- `Tolk.dll` — die Screenreader-Bridge
- `nvdaControllerClient64.dll` (64-Bit-Spiele) oder `nvdaControllerClient32.dll` (32-Bit-Spiele) — erforderlich für NVDA

Ohne nvdaControllerClient bekommen NVDA-Nutzer keine Ausgabe. JAWS funktioniert über COM (keine extra DLL).

Download: https://github.com/ndarilek/tolk/releases

### DLL-Imports

```csharp
using System.Runtime.InteropServices;

[DllImport("Tolk.dll")]
private static extern void Tolk_Load();

[DllImport("Tolk.dll")]
private static extern void Tolk_Unload();

[DllImport("Tolk.dll")]
private static extern bool Tolk_IsLoaded();

[DllImport("Tolk.dll")]
private static extern bool Tolk_HasSpeech();

[DllImport("Tolk.dll", CharSet = CharSet.Unicode)]
private static extern bool Tolk_Output(string text, bool interrupt);

[DllImport("Tolk.dll")]
private static extern bool Tolk_Silence();
```

### Einfacher Wrapper

```csharp
public static class ScreenReader
{
    private static bool _available;

    public static void Initialize()
    {
        try
        {
            Tolk_Load();
            _available = Tolk_IsLoaded() && Tolk_HasSpeech();
        }
        catch
        {
            _available = false;
        }
    }

    public static void Say(string text, bool interrupt = true)
    {
        if (_available && !string.IsNullOrEmpty(text))
            Tolk_Output(text, interrupt);
    }

    public static void Stop()
    {
        if (_available) Tolk_Silence();
    }

    public static void Shutdown()
    {
        try { Tolk_Unload(); } catch { }
    }
}
```

### Verwendung

**MelonLoader:**
```csharp
public override void OnInitializeMelon()
{
    ScreenReader.Initialize();
    ScreenReader.Say("Mod geladen");
}

public override void OnApplicationQuit()
{
    ScreenReader.Shutdown();
}
```

**BepInEx:**
```csharp
void Awake()
{
    ScreenReader.Initialize();
    ScreenReader.Say("Mod geladen");
}

void OnDestroy()
{
    ScreenReader.Shutdown();
}
```

---

## Unity Kurzreferenz

### GameObjects finden

```csharp
var obj = GameObject.Find("Name");  // Langsam!
var all = GameObject.FindObjectsOfType<Button>();
```

### Komponenten

```csharp
var text = obj.GetComponent<Text>();
var text = obj.GetComponentInChildren<Text>();
var allTexts = obj.GetComponentsInChildren<Text>();
```

### Hierarchie

```csharp
var child = parent.transform.Find("ChildName");
foreach (Transform child in parent.transform) { }
```

### Aktiv-Status

```csharp
bool isActive = obj.activeInHierarchy;
obj.SetActive(true);
```

---

## Häufige Accessibility-Patterns

### UI geöffnet/geschlossen ansagen

```csharp
[HarmonyPatch(typeof(MenuUI), "Show")]
public class MenuShowPatch
{
    [HarmonyPostfix]
    public static void Postfix() => ScreenReader.Say("Menü geöffnet");
}

[HarmonyPatch(typeof(MenuUI), "Hide")]
public class MenuHidePatch
{
    [HarmonyPostfix]
    public static void Postfix() => ScreenReader.Say("Menü geschlossen");
}
```

### Menü-Navigation

```csharp
public void AnnounceItem(int index, int total, string name)
{
    ScreenReader.Say($"{index} von {total}: {name}");
}
```

### Statusänderung

```csharp
public void AnnounceHealth(int current, int max)
{
    ScreenReader.Say($"Leben: {current} von {max}");
}
```

### Duplikate vermeiden

```csharp
private string _lastAnnounced;

public void Say(string text)
{
    if (text == _lastAnnounced) return;
    _lastAnnounced = text;
    ScreenReader.Say(text);
}
```

---

## Cross-Platform: Linux und macOS

Wenn das Spiel auf Linux oder macOS läuft, kann der Mod portiert werden. Hier ist was funktioniert, was geändert werden muss, und wie man vorgeht.

### Was ohne Änderung funktioniert

- **Der gesamte Mod-Code** (Handler, Loc, DebugLogger, Main) ist reines C# — läuft auf jeder Plattform
- **Harmony-Patching** funktioniert überall wo Mono/.NET läuft
- **Unity** ist plattformübergreifend, Spiel-Interna verhalten sich gleich

### Mod Loader

- **BepInEx**: Hat offizielle Linux-Builds und funktioniert auf macOS. Beste Wahl für plattformübergreifende Mods.
- **MelonLoader**: Linux-Support existiert, ist aber weniger ausgereift als BepInEx. macOS-Support ist eingeschränkt.
- Wenn Plattformübergreifung ein Ziel ist, BepInEx bevorzugen.

### Die Hauptherausforderung: Screenreader-Integration

**Tolk ist rein Windows.** Es nutzt Windows-spezifische DLLs (nvdaControllerClient, JAWS API, SAPI). Auf anderen Plattformen gibt es andere Screenreader-APIs:

- **Linux**: speech-dispatcher (libspeechd / `spd-say`-Befehl), AT-SPI
- **macOS**: VoiceOver über NSAccessibility API, oder der `say`-Befehl

### Umsetzung: Plattformabhängige Screenreader-Unterstützung

Die direkten Tolk-Aufrufe in `ScreenReader.cs` durch eine plattformabhängige Abstraktion ersetzen:

```csharp
public static void Initialize()
{
    if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        _backend = new TolkBackend();       // Bestehende Tolk-Integration
    else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        _backend = new SpeechDBackend();     // speech-dispatcher
    else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        _backend = new MacSayBackend();      // macOS say-Befehl
}
```

**Einfaches Linux-Backend (spd-say Prozessaufruf):**

```csharp
public class SpeechDBackend : IScreenReaderBackend
{
    public bool IsAvailable()
    {
        try
        {
            var p = Process.Start(new ProcessStartInfo("which", "spd-say")
                { RedirectStandardOutput = true, UseShellExecute = false });
            p.WaitForExit();
            return p.ExitCode == 0;
        }
        catch { return false; }
    }

    public void Say(string text, bool interrupt)
    {
        if (interrupt) Silence();
        Process.Start("spd-say", $"\"{text}\"");
    }

    public void Silence()
    {
        try { Process.Start("spd-say", "--cancel"); } catch { }
    }
}
```

**Einfaches macOS-Backend (say-Befehl):**

```csharp
public class MacSayBackend : IScreenReaderBackend
{
    public bool IsAvailable() => true; // say ist immer auf macOS verfügbar

    public void Say(string text, bool interrupt)
    {
        if (interrupt) Silence();
        Process.Start("say", $"\"{text}\"");
    }

    public void Silence()
    {
        try { Process.Start("killall", "say"); } catch { }
    }
}
```

**Gemeinsames Interface:**

```csharp
public interface IScreenReaderBackend
{
    bool IsAvailable();
    void Say(string text, bool interrupt);
    void Silence();
}
```

### Einschränkungen des einfachen Ansatzes

- **Prozessaufrufe haben leichte Latenz** (~50-100ms) im Vergleich zu Tolks direkten DLL-Aufrufen
- **Kein Queueing** — `spd-say` und `say` reihen nicht nativ ein (bräuchte eigene Queue)
- **`say` auf macOS nutzt VoiceOvers Stimme, aber NICHT den VoiceOver-Screenreader** — blinde macOS-Nutzer die VoiceOver verwenden könnten doppelte Ausgabe hören

### Robustere Alternativen (mehr Aufwand)

- **Linux**: Direkte P/Invoke-Anbindung an `libspeechd.so` für speech-dispatcher — ähnlich wie Tolk auf Windows funktioniert, kein Prozess-Overhead
- **macOS**: NSAccessibility APIs über P/Invoke oder einen nativen Helper nutzen — integriert sich korrekt mit VoiceOver
- **Plattformübergreifende Bibliothek**: [Tolk-rs](https://github.com/mush42/tolk-rs) (Rust) oder [accessible-output](https://github.com/accessibleapps/accessible_output2) (Python) existieren als Referenz, aber es gibt derzeit keine gepflegte plattformübergreifende C#-Screenreader-Bibliothek

### Aufwandsschätzung

- ScreenReader-Abstraktionsschicht: Klein (bestehende ScreenReader.cs umbauen)
- Einfaches Linux-Backend (spd-say): Klein
- Einfaches macOS-Backend (say): Klein
- Robustes Linux-Backend (libspeechd): Mittel
- Robustes macOS-Backend (NSAccessibility): Mittel
- Alles andere im Template: Keine Änderung nötig
