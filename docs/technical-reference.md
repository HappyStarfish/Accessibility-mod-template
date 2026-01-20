# Technical Reference

Compact overview: MelonLoader, Harmony, and Tolk.

---

## MelonLoader Basics

### Project References (csproj)

```xml
<Reference Include="MelonLoader">
    <HintPath>[GameDirectory]\MelonLoader\net6\MelonLoader.dll</HintPath>
</Reference>
<Reference Include="UnityEngine.CoreModule">
    <HintPath>[GameDirectory]\MelonLoader\Managed\UnityEngine.CoreModule.dll</HintPath>
</Reference>
<Reference Include="Assembly-CSharp">
    <HintPath>[GameDirectory]\[Game]_Data\Managed\Assembly-CSharp.dll</HintPath>
</Reference>
```

### MelonInfo Attribute

```csharp
[assembly: MelonInfo(typeof(MyNamespace.Main), "ModName", "1.0.0", "Author")]
[assembly: MelonGame("Developer", "GameName")]
```

### Lifecycle

```csharp
public class Main : MelonMod
{
    public override void OnInitializeMelon() { }  // Once on load
    public override void OnUpdate() { }            // Every frame
    public override void OnSceneWasLoaded(int buildIndex, string sceneName) { }
    public override void OnApplicationQuit() { }   // On exit
}
```

### CRITICAL: Accessing Game Code

**Any access to game classes before the game is fully loaded can crash.**

This affects:
- Game manager singletons (e.g., `GameManager.i`, `AudioManager.instance`)
- `typeof(GameClass)` - even in Harmony attributes!
- Any reference to game classes in fields or early methods

**Allowed by timing:**

- Assembly load: Only own classes and Unity types
- OnInitializeMelon: Only own initialization, NO game access
- OnSceneWasLoaded: Everything allowed

**When is the game ready?**

Only in/after `OnSceneWasLoaded()`. Safe test: Check a reliable UI element:

```csharp
if (GameObject.Find("MainUI") == null)
    return; // Game not ready yet
```

**Error 1: typeof() in Harmony attributes**

```csharp
// WRONG - typeof() is evaluated at assembly load
[HarmonyPatch(typeof(GameClass))]
public static class MyPatch { }
```

```csharp
// CORRECT - Apply patches manually in OnSceneWasLoaded
public override void OnSceneWasLoaded(int buildIndex, string sceneName)
{
    if (!_patchesApplied && GameObject.Find("MainUI") != null)
    {
        var targetType = typeof(GameClass);
        _harmony.Patch(AccessTools.Method(targetType, "MethodName"), ...);
        _patchesApplied = true;
    }
}
```

**Error 2: Singleton access too early**

```csharp
// WRONG - Singleton can block or crash
public override void OnUpdate()
{
    var manager = GameManager.i;
}
```

```csharp
// CORRECT - Check first, then cache
private GameManager _cachedManager = null;

private GameManager GetManagerSafe()
{
    if (_cachedManager != null) return _cachedManager;

    if (GameObject.Find("MainUI") == null)
        return null; // Game not ready yet

    _cachedManager = GameManager.i;
    return _cachedManager;
}
```

### Logging

```csharp
MelonLogger.Msg("Info");
MelonLogger.Warning("Warning");
MelonLogger.Error("Error");
```

### Key Input

```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Pressed once
if (Input.GetKey(KeyCode.LeftShift)) { }  // Held
```

---

## Harmony Patching

Harmony is included in MelonLoader - no extra import needed.

### Setup in Main

```csharp
private HarmonyLib.Harmony _harmony;

public override void OnInitializeMelon()
{
    _harmony = new HarmonyLib.Harmony("com.author.modname");
    _harmony.PatchAll();
}
```

### Postfix (after original method)

```csharp
[HarmonyPatch(typeof(InventoryUI), "Show")]
public class InventoryShowPatch
{
    [HarmonyPostfix]
    public static void Postfix()
    {
        ScreenReader.Say("Inventory opened");
    }
}
```

### Postfix with return value

```csharp
[HarmonyPatch(typeof(Player), "GetHealth")]
public class HealthPatch
{
    [HarmonyPostfix]
    public static void Postfix(ref int __result)
    {
        MelonLogger.Msg($"Health: {__result}");
    }
}
```

### Prefix (before original method)

```csharp
[HarmonyPatch(typeof(Player), "TakeDamage")]
public class DamagePatch
{
    [HarmonyPrefix]
    public static void Prefix(int damage)
    {
        ScreenReader.Say($"Damage: {damage}");
    }

    // Return false to skip original:
    // public static bool Prefix() { return false; }
}
```

### Special Parameters

- `__instance` - The object instance
- `__result` - Return value (Postfix only)
- `___fieldName` - Private fields (3 underscores!)

---

## Tolk (Screen Reader)

### DLL Imports

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

### Simple Wrapper

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

### Usage

```csharp
public override void OnInitializeMelon()
{
    ScreenReader.Initialize();
    ScreenReader.Say("Mod loaded");
}

public override void OnApplicationQuit()
{
    ScreenReader.Shutdown();
}
```

---

## Unity Quick Reference

### Finding GameObjects

```csharp
var obj = GameObject.Find("Name");  // Slow!
var all = GameObject.FindObjectsOfType<Button>();
```

### Components

```csharp
var text = obj.GetComponent<Text>();
var text = obj.GetComponentInChildren<Text>();
var allTexts = obj.GetComponentsInChildren<Text>();
```

### Hierarchy

```csharp
var child = parent.transform.Find("ChildName");
foreach (Transform child in parent.transform) { }
```

### Active State

```csharp
bool isActive = obj.activeInHierarchy;
obj.SetActive(true);
```

---

## Common Accessibility Patterns

### Announce UI opened/closed

```csharp
[HarmonyPatch(typeof(MenuUI), "Show")]
public class MenuShowPatch
{
    [HarmonyPostfix]
    public static void Postfix() => ScreenReader.Say("Menu opened");
}

[HarmonyPatch(typeof(MenuUI), "Hide")]
public class MenuHidePatch
{
    [HarmonyPostfix]
    public static void Postfix() => ScreenReader.Say("Menu closed");
}
```

### Menu Navigation

```csharp
public void AnnounceItem(int index, int total, string name)
{
    ScreenReader.Say($"{index} of {total}: {name}");
}
```

### Status Change

```csharp
public void AnnounceHealth(int current, int max)
{
    ScreenReader.Say($"Health: {current} of {max}");
}
```

### Avoid Duplicates

```csharp
private string _lastAnnounced;

public void Say(string text)
{
    if (text == _lastAnnounced) return;
    _lastAnnounced = text;
    ScreenReader.Say(text);
}
```
