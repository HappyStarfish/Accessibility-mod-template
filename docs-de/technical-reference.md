# Technische Referenz

Kompakte Übersicht: MelonLoader, Harmony und Tolk.

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

## Harmony Patching

Harmony ist in MelonLoader enthalten - kein extra Import nötig.

### Setup in Main

```csharp
private HarmonyLib.Harmony _harmony;

public override void OnInitializeMelon()
{
    _harmony = new HarmonyLib.Harmony("com.autor.modname");
    _harmony.PatchAll();
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
