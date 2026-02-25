# Technical Reference

Compact overview: MelonLoader, BepInEx, Harmony, and Tolk.

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

## BepInEx Basics

### Project References (csproj)

```xml
<Reference Include="BepInEx">
    <HintPath>[GameDirectory]\BepInEx\core\BepInEx.dll</HintPath>
</Reference>
<Reference Include="0Harmony">
    <HintPath>[GameDirectory]\BepInEx\core\0Harmony.dll</HintPath>
</Reference>
<Reference Include="UnityEngine">
    <HintPath>[GameDirectory]\[Game]_Data\Managed\UnityEngine.dll</HintPath>
</Reference>
<Reference Include="UnityEngine.CoreModule">
    <HintPath>[GameDirectory]\[Game]_Data\Managed\UnityEngine.CoreModule.dll</HintPath>
</Reference>
<Reference Include="Assembly-CSharp">
    <HintPath>[GameDirectory]\[Game]_Data\Managed\Assembly-CSharp.dll</HintPath>
</Reference>
```

### BepInPlugin Attribute

```csharp
[BepInPlugin("com.author.modname", "ModName", "1.0.0")]
```

- First parameter: Unique GUID (reverse domain notation)
- Unlike MelonLoader, these values are freely chosen (not from a log file)
- The GUID must be unique across all mods for this game

### Lifecycle

```csharp
using BepInEx;
using UnityEngine;

[BepInPlugin("com.author.modname", "ModName", "1.0.0")]
public class Main : BaseUnityPlugin
{
    void Awake() { }    // Once on load (like OnInitializeMelon)
    void Update() { }   // Every frame (like OnUpdate)
    void OnDestroy() { } // On exit (like OnApplicationQuit)
}
```

**Key differences from MelonLoader:**

- `BaseUnityPlugin` inherits from `MonoBehaviour` — uses Unity lifecycle methods
- No `OnSceneWasLoaded` equivalent built-in. Use `SceneManager.sceneLoaded` event instead:

```csharp
using UnityEngine.SceneManagement;

void Awake()
{
    SceneManager.sceneLoaded += OnSceneLoaded;
}

private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
{
    Logger.LogInfo($"Scene loaded: {scene.name}");
}
```

### CRITICAL: Accessing Game Code (BepInEx)

The same timing rules apply as with MelonLoader:

- **Awake()**: Only own initialization, NO game class access
- **After scene load**: Everything allowed

```csharp
private bool _gameReady = false;

void Update()
{
    if (!_gameReady)
    {
        // Check for game singletons — adjust to your game!
        // if (GameManager.instance != null)
        //     _gameReady = true;
        // else
        //     return;
        return;
    }

    // Game logic here
}
```

### Logging

```csharp
Logger.LogInfo("Info");      // Instance logger (within plugin class)
Logger.LogWarning("Warning");
Logger.LogError("Error");
```

### Key Input

Same as MelonLoader — both use Unity's Input system:

```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Pressed once
if (Input.GetKey(KeyCode.LeftShift)) { }  // Held
```

### Mod Output Directory

Built DLL goes into `BepInEx/plugins/` (not `Mods/` like MelonLoader).

---

## Harmony Patching

Harmony is included in both MelonLoader and BepInEx - no extra import needed.

### Setup in Main

**MelonLoader:**
```csharp
private HarmonyLib.Harmony _harmony;

public override void OnInitializeMelon()
{
    _harmony = new HarmonyLib.Harmony("com.author.modname");
    _harmony.PatchAll();
}
```

**BepInEx:**
```csharp
// Harmony is auto-created by BepInEx. Just call PatchAll in Awake:
void Awake()
{
    var harmony = new HarmonyLib.Harmony("com.author.modname");
    harmony.PatchAll();
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

### Required DLLs in Game Directory

**BOTH files must be present in the game folder (where the .exe is):**
- `Tolk.dll` — the screen reader bridge
- `nvdaControllerClient64.dll` (64-bit games) or `nvdaControllerClient32.dll` (32-bit games) — required for NVDA

Without nvdaControllerClient, NVDA users get no output. JAWS works via COM (no extra DLL).

Download: https://github.com/ndarilek/tolk/releases

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

**MelonLoader:**
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

**BepInEx:**
```csharp
void Awake()
{
    ScreenReader.Initialize();
    ScreenReader.Say("Mod loaded");
}

void OnDestroy()
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

---

## Cross-Platform: Linux and macOS

If the game runs on Linux or macOS, the mod can be ported. Here is what works, what needs changes, and how to approach it.

### What works without changes

- **All mod code** (Handlers, Loc, DebugLogger, Main) is pure C# — runs on any platform
- **Harmony patching** works everywhere Mono/.NET runs
- **Unity** is cross-platform, so game internals behave the same

### Mod Loader

- **BepInEx**: Has official Linux builds and works on macOS. Best choice for cross-platform mods.
- **MelonLoader**: Linux support exists but is less mature than BepInEx. macOS support is limited.
- If cross-platform is a goal, prefer BepInEx.

### The main challenge: Screen reader integration

**Tolk is Windows-only.** It uses Windows-specific DLLs (nvdaControllerClient, JAWS API, SAPI). On other platforms, different screen reader APIs exist:

- **Linux**: speech-dispatcher (libspeechd / `spd-say` command), AT-SPI
- **macOS**: VoiceOver via NSAccessibility API, or the `say` command

### How to implement cross-platform screen reader support

Replace the direct Tolk calls in `ScreenReader.cs` with a platform-aware abstraction:

```csharp
public static void Initialize()
{
    if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        _backend = new TolkBackend();       // Existing Tolk integration
    else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        _backend = new SpeechDBackend();     // speech-dispatcher
    else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        _backend = new MacSayBackend();      // macOS say command
}
```

**Simple Linux backend (using spd-say process call):**

```csharp
public class SpeechDBackend : IScreenReaderBackend
{
    public bool IsAvailable()
    {
        // Check if spd-say exists
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

**Simple macOS backend (using say command):**

```csharp
public class MacSayBackend : IScreenReaderBackend
{
    public bool IsAvailable() => true; // say is always available on macOS

    public void Say(string text, bool interrupt)
    {
        if (interrupt) Silence();
        Process.Start("say", $"\"{text}\"");
    }

    public void Silence()
    {
        // Kill any running say process
        try { Process.Start("killall", "say"); } catch { }
    }
}
```

**Shared interface:**

```csharp
public interface IScreenReaderBackend
{
    bool IsAvailable();
    void Say(string text, bool interrupt);
    void Silence();
}
```

### Limitations of the simple approach

- **Process calls have slight latency** (~50-100ms) compared to Tolk's direct DLL calls
- **No queueing** — `spd-say` and `say` don't queue natively (would need custom queue)
- **`say` on macOS uses VoiceOver's voice but NOT the VoiceOver screen reader** — blind macOS users who use VoiceOver may hear double output

### Robust alternatives (more effort)

- **Linux**: P/Invoke directly to `libspeechd.so` for speech-dispatcher — similar to how Tolk works on Windows, no process overhead
- **macOS**: Use NSAccessibility APIs via P/Invoke or a native helper — integrates with VoiceOver properly
- **Cross-platform library**: [Tolk-rs](https://github.com/mush42/tolk-rs) (Rust) or [accessible-output](https://github.com/accessibleapps/accessible_output2) (Python) exist as references, but no maintained cross-platform C# screen reader library exists yet

### Effort estimate

- ScreenReader abstraction layer: Small (refactor existing ScreenReader.cs)
- Simple Linux backend (spd-say): Small
- Simple macOS backend (say): Small
- Robust Linux backend (libspeechd): Medium
- Robust macOS backend (NSAccessibility): Medium
- Everything else in the template: No changes needed
