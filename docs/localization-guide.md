# Localization Guide for Accessibility Mods

This guide describes how to implement multi-language localization for accessibility mods. The method was successfully tested in the Pet Idle Accessibility Mod and can be adapted for different game engines.

---

## Core Principles

### 1. Automatic Language Detection
The mod automatically detects the game language and adapts. No manual switching needed.

### 2. Fallback Chain
When a translation is missing:
- Try current language
- If not available: English
- If also not available: Key itself (for debugging)

### 3. Central Localization Class
All translations in one place. No searching through different files.

### 4. Simple API
Only two methods in daily use:
- `Loc.Get("key")` - Retrieve string
- `Loc.Get("key", param1, param2)` - String with placeholders

---

## Architecture

### File Structure

- Loc.cs - Central localization class
- Handler classes use `Loc.Get()` for all announcements

### Class Structure (Loc.cs)

```csharp
public static class Loc
{
    private static bool _initialized = false;
    private static string _currentLang = "en";  // Fallback

    // One dictionary per language
    private static readonly Dictionary<string, string> _german = new();
    private static readonly Dictionary<string, string> _english = new();
    private static readonly Dictionary<string, string> _spanish = new();
    private static readonly Dictionary<string, string> _russian = new();
    // More languages as needed...

    public static void Initialize() { ... }
    public static void RefreshLanguage() { ... }
    public static string Get(string key) { ... }
    public static string Get(string key, params object[] args) { ... }
    private static Dictionary<string, string> GetCurrentDictionary() { ... }
    private static void Add(string key, string de, string en, string es, string ru) { ... }
    private static void InitializeStrings() { ... }
}
```

---

## Step-by-Step Implementation

### Step 1: Find the Game's Language System

**Goal:** Find out how the game stores the current language.

**Typical search patterns in decompiled code:**
- `Language`, `Localization`, `I18n`, `L10n`
- `currentLanguage`, `CurrentLocale`, `SelectedLanguage`
- `SystemLanguage` (Unity-specific)
- `GetLanguage()`, `GetLocale()`, `getAlias()`

**Examples per engine:**

Unity:
```csharp
// Often found:
Language.currentLanguage  // SystemLanguage enum
Language.getAlias()       // Returns "de", "en", "es" etc.
PlayerPrefs.GetString("language")
```

Godot:
```gdscript
# Often found:
TranslationServer.get_locale()  # Returns "de", "en_US" etc.
OS.get_locale()
```

Unreal/C++:
```cpp
// Often found:
FInternationalization::Get().GetCurrentCulture()
UKismetInternationalizationLibrary::GetCurrentLanguage()
```

**Document what you find!** Note:
- Which class/method provides the language
- Which format (2-letter code, enum, full name)
- Where the setting is stored

### Step 2: Create Localization Class

**Template for basic structure:**

```csharp
using System.Collections.Generic;

namespace [YourModName]
{
    /// <summary>
    /// Central localization for the accessibility mod.
    /// Automatically detects game language.
    /// </summary>
    public static class Loc
    {
        #region Fields

        private static bool _initialized = false;
        private static string _currentLang = "en";

        // Dictionaries for each supported language
        private static readonly Dictionary<string, string> _german = new();
        private static readonly Dictionary<string, string> _english = new();
        // Add more as needed

        #endregion

        #region Public Methods

        /// <summary>
        /// Initializes localization. Call once at mod startup.
        /// </summary>
        public static void Initialize()
        {
            InitializeStrings();
            RefreshLanguage();
            _initialized = true;
        }

        /// <summary>
        /// Updates language based on game setting.
        /// Call when player changes language.
        /// </summary>
        public static void RefreshLanguage()
        {
            // === ADAPT THIS FOR YOUR GAME ===
            string gameLang = GetGameLanguage();

            // Only supported languages, otherwise English
            switch (gameLang)
            {
                case "de":
                    _currentLang = "de";
                    break;
                // Add more languages here...
                default:
                    _currentLang = "en";
                    break;
            }
        }

        /// <summary>
        /// Gets a localized string.
        /// </summary>
        public static string Get(string key)
        {
            if (!_initialized) Initialize();

            var dict = GetCurrentDictionary();

            // Try current language
            if (dict.TryGetValue(key, out string value))
                return value;

            // Fallback: English
            if (_english.TryGetValue(key, out string engValue))
                return engValue;

            // Last fallback: Key itself (helps with debugging)
            return key;
        }

        /// <summary>
        /// Gets a localized string with placeholders.
        /// Uses {0}, {1}, {2} etc. as placeholders.
        /// </summary>
        public static string Get(string key, params object[] args)
        {
            string template = Get(key);
            try
            {
                return string.Format(template, args);
            }
            catch
            {
                return template; // On format error: Template without replacement
            }
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// === ADAPT THIS METHOD FOR YOUR GAME ===
        /// Reads the current game language.
        /// </summary>
        private static string GetGameLanguage()
        {
            // UNITY EXAMPLE:
            // return Language.getAlias();

            // UNITY WITH PLAYERPREFS:
            // return PlayerPrefs.GetString("language", "en");

            // GODOT EXAMPLE (via interop):
            // return TranslationServer.GetLocale().Substring(0, 2);

            // FALLBACK:
            return "en";
        }

        private static Dictionary<string, string> GetCurrentDictionary()
        {
            switch (_currentLang)
            {
                case "de": return _german;
                // Add more languages here...
                default: return _english;
            }
        }

        /// <summary>
        /// Helper method: Adds a string in all languages.
        /// </summary>
        private static void Add(string key, string german, string english)
        {
            _german[key] = german;
            _english[key] = english;
        }

        /// <summary>
        /// Define all translations here.
        /// </summary>
        private static void InitializeStrings()
        {
            // === TRANSLATIONS HERE ===

            // General
            Add("mod_loaded",
                "[ModName] geladen. F1 für Hilfe.",
                "[ModName] loaded. F1 for help.");

            Add("help_title",
                "Hilfe:",
                "Help:");

            // With placeholders: {0}, {1}, etc.
            Add("item_count",
                "{0} Gegenstände",
                "{0} items");

            Add("level_info",
                "Level {0}, {1} Erfahrung",
                "Level {0}, {1} experience");
        }

        #endregion
    }
}
```

### Step 3: Integrate into Mod

**At mod startup (Main.cs or equivalent):**

```csharp
public override void OnInitializeMelon()
{
    // Initialize early, but AFTER the game is loaded
}

// For Unity/MelonLoader: When game is ready
private void OnGameReady()
{
    Loc.Initialize();
    ScreenReader.Announce(Loc.Get("mod_loaded"));
}
```

**On language change (e.g., in SettingsHandler):**

```csharp
private void OnLanguageChanged()
{
    // Game language was changed
    Loc.RefreshLanguage();

    // Optional: Confirmation in new language
    // (or old language, depending on preference)
}
```

### Step 4: Convert Handlers

**Before (hardcoded):**
```csharp
ScreenReader.Announce("Inventory opened. 5 items.");
```

**After (localized):**
```csharp
ScreenReader.Announce(Loc.Get("inventory_opened", itemCount));
```

**Don't forget GetHelpText():**
```csharp
public string GetHelpText()
{
    return Loc.Get("inventory_help");
}
```

---

## Organizing Translations

### Naming Convention for Keys

Use consistent prefixes:
```
[handler]_[action/element]

Examples:
inventory_opened
inventory_item_selected
inventory_empty
shop_not_enough_coins
shop_purchased
settings_music_on
settings_music_off
wheel_spin_result
tutorial_skip
```

### Group by Categories

In `InitializeStrings()` sort by categories:

```csharp
private static void InitializeStrings()
{
    // ===== GENERAL =====
    Add("mod_loaded", ...);
    Add("help_title", ...);

    // ===== INVENTORY =====
    Add("inventory_opened", ...);
    Add("inventory_empty", ...);

    // ===== SHOP =====
    Add("shop_opened", ...);
    Add("shop_not_enough", ...);

    // ===== SETTINGS =====
    Add("settings_music_on", ...);
    // etc.
}
```

### Placeholder Convention

Always use `{0}`, `{1}`, `{2}` (C# string.Format syntax):
```csharp
Add("coins_info",
    "{0} Münzen, {1} Diamanten",
    "{0} coins, {1} diamonds");

// Call:
Loc.Get("coins_info", coinCount, diamondCount);
```

---

## Adding Languages

### 1. Add Dictionary
```csharp
private static readonly Dictionary<string, string> _french = new();
```

### 2. Register in GetCurrentDictionary()
```csharp
case "fr": return _french;
```

### 3. Register in RefreshLanguage()
```csharp
case "fr":
    _currentLang = "fr";
    break;
```

### 4. Extend Add Method
```csharp
private static void Add(string key, string de, string en, string fr)
{
    _german[key] = de;
    _english[key] = en;
    _french[key] = fr;
}
```

### 5. Add All Translations
Extend every `Add()` call with the new language.

---

## Engine-Specific Adaptations

### Unity (MelonLoader, BepInEx)

**Read language:**
```csharp
// Option 1: Via game's own class
string lang = Language.getAlias();

// Option 2: Via PlayerPrefs
string lang = PlayerPrefs.GetString("language", "en");

// Option 3: System language
SystemLanguage sysLang = Application.systemLanguage;
```

**When to initialize:**
- After `SceneManager.sceneLoaded` event
- Or when `MainScreen.instance != null`

### Godot (GDExtension, C#)

**Read language:**
```csharp
string locale = TranslationServer.GetLocale();
string lang = locale.Substring(0, 2); // "en_US" -> "en"
```

**When to initialize:**
- In `_Ready()` of main node

### Unreal Engine (C++)

**Read language:**
```cpp
FString Culture = FInternationalization::Get().GetCurrentCulture()->GetName();
// Returns e.g. "de-DE"
```

**When to initialize:**
- After `PostInitializeComponents()`

---

## Best Practices

### Do's

- Localize all announcements, no exceptions
- Short, concise texts (screen reader friendly)
- Consistent terminology per language
- Use placeholders for variable values
- Test early if language is detected

### Don'ts

- Don't build sentences from individual parts (grammar varies!)
- No machine translation without verification
- Don't forget hardcoded strings after localization
- No overly long texts (block screen readers)

### Bad Example (Building Sentences):
```csharp
// BAD - Grammar doesn't work in all languages!
string text = Loc.Get("you_have") + " " + count + " " + Loc.Get("items");
// German: "Du hast 5 Gegenstände" - OK
// Japanese: "5 Gegenstände du hast" - WRONG
```

### Good Example:
```csharp
// GOOD - Full sentence as template
string text = Loc.Get("item_count", count);
// Key contains: "Du hast {0} Gegenstände" / "You have {0} items" / etc.
```

---

## Checklist for New Projects

- [ ] Game's language system found and documented
- [ ] Loc.cs created with GetGameLanguage() adapted
- [ ] At least German and English implemented
- [ ] Loc.Initialize() is called at mod startup
- [ ] Loc.RefreshLanguage() is called on language change
- [ ] All handlers use Loc.Get() instead of hardcoded strings
- [ ] GetHelpText() localized in all handlers
- [ ] Tested with both languages
- [ ] Language switching during gameplay tested

---

## Example: Complete Handler

```csharp
public class InventoryHandler
{
    public string GetHelpText()
    {
        return Loc.Get("inventory_help");
    }

    public void AnnounceInventory()
    {
        if (inventory == null)
        {
            ScreenReader.Announce(Loc.Get("inventory_not_available"));
            return;
        }

        int count = inventory.items.Count;

        if (count == 0)
        {
            ScreenReader.Announce(Loc.Get("inventory_empty"));
        }
        else
        {
            ScreenReader.Announce(Loc.Get("inventory_count", count));
        }
    }

    public void AnnounceItem(Item item)
    {
        if (item == null)
        {
            ScreenReader.Announce(Loc.Get("no_item_selected"));
            return;
        }

        ScreenReader.Announce(
            Loc.Get("item_info", item.name, item.quantity, item.description)
        );
    }
}
```
