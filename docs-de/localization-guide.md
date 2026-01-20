# Lokalisierung für Accessibility-Mods - Anleitung

Diese Anleitung beschreibt, wie du eine Mehrsprachen-Lokalisierung für Accessibility-Mods implementierst. Die Methode wurde erfolgreich im Pet Idle Accessibility Mod getestet und kann für verschiedene Spiel-Engines angepasst werden.

---

## Grundprinzipien

### 1. Automatische Spracherkennung
Der Mod erkennt die Spielsprache automatisch und passt sich an. Kein manuelles Umschalten nötig.

### 2. Fallback-Kette
Wenn eine Übersetzung fehlt:
- Versuche aktuelle Sprache
- Falls nicht vorhanden: Englisch
- Falls auch nicht vorhanden: Key selbst (für Debugging)

### 3. Zentrale Lokalisierungsklasse
Alle Übersetzungen an einem Ort. Kein Suchen in verschiedenen Dateien.

### 4. Einfache API
Nur zwei Methoden im Alltag:
- `Loc.Get("key")` - String abrufen
- `Loc.Get("key", param1, param2)` - String mit Platzhaltern

---

## Architektur

### Dateistruktur

- Loc.cs - Zentrale Lokalisierungsklasse
- Handler-Klassen nutzen `Loc.Get()` für alle Ansagen

### Klassenaufbau (Loc.cs)

```csharp
public static class Loc
{
    private static bool _initialized = false;
    private static string _currentLang = "en";  // Fallback

    // Ein Dictionary pro Sprache
    private static readonly Dictionary<string, string> _german = new();
    private static readonly Dictionary<string, string> _english = new();
    private static readonly Dictionary<string, string> _spanish = new();
    private static readonly Dictionary<string, string> _russian = new();
    // Weitere Sprachen nach Bedarf...

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

## Implementierung Schritt für Schritt

### Schritt 1: Sprachsystem des Spiels finden

**Ziel:** Herausfinden, wie das Spiel die aktuelle Sprache speichert.

**Typische Suchmuster im dekompilierten Code:**
- `Language`, `Localization`, `I18n`, `L10n`
- `currentLanguage`, `CurrentLocale`, `SelectedLanguage`
- `SystemLanguage` (Unity-spezifisch)
- `GetLanguage()`, `GetLocale()`, `getAlias()`

**Beispiele pro Engine:**

Unity:
```csharp
// Oft gefunden:
Language.currentLanguage  // SystemLanguage enum
Language.getAlias()       // Gibt "de", "en", "es" etc. zurück
PlayerPrefs.GetString("language")
```

Godot:
```gdscript
# Oft gefunden:
TranslationServer.get_locale()  # Gibt "de", "en_US" etc. zurück
OS.get_locale()
```

Unreal/C++:
```cpp
// Oft gefunden:
FInternationalization::Get().GetCurrentCulture()
UKismetInternationalizationLibrary::GetCurrentLanguage()
```

**Dokumentiere was du findest!** Notiere:
- Welche Klasse/Methode die Sprache liefert
- Welches Format (2-Buchstaben-Code, Enum, voller Name)
- Wo die Einstellung gespeichert wird

### Schritt 2: Lokalisierungsklasse erstellen

**Template für die Grundstruktur:**

```csharp
using System.Collections.Generic;

namespace [DeinModName]
{
    /// <summary>
    /// Zentrale Lokalisierung für den Accessibility-Mod.
    /// Erkennt Spielsprache automatisch.
    /// </summary>
    public static class Loc
    {
        #region Fields

        private static bool _initialized = false;
        private static string _currentLang = "en";

        // Dictionaries für jede unterstützte Sprache
        private static readonly Dictionary<string, string> _german = new();
        private static readonly Dictionary<string, string> _english = new();
        // Weitere nach Bedarf hinzufügen

        #endregion

        #region Public Methods

        /// <summary>
        /// Initialisiert die Lokalisierung. Einmal beim Mod-Start aufrufen.
        /// </summary>
        public static void Initialize()
        {
            InitializeStrings();
            RefreshLanguage();
            _initialized = true;
        }

        /// <summary>
        /// Aktualisiert die Sprache basierend auf Spieleinstellung.
        /// Aufrufen wenn Spieler Sprache ändert.
        /// </summary>
        public static void RefreshLanguage()
        {
            // === HIER ANPASSEN FÜR DEIN SPIEL ===
            string gameLang = GetGameLanguage();

            // Nur unterstützte Sprachen, sonst Englisch
            switch (gameLang)
            {
                case "de":
                    _currentLang = "de";
                    break;
                // Weitere Sprachen hier...
                default:
                    _currentLang = "en";
                    break;
            }
        }

        /// <summary>
        /// Holt einen lokalisierten String.
        /// </summary>
        public static string Get(string key)
        {
            if (!_initialized) Initialize();

            var dict = GetCurrentDictionary();

            // Versuche aktuelle Sprache
            if (dict.TryGetValue(key, out string value))
                return value;

            // Fallback: Englisch
            if (_english.TryGetValue(key, out string engValue))
                return engValue;

            // Letzter Fallback: Key selbst (hilft beim Debugging)
            return key;
        }

        /// <summary>
        /// Holt einen lokalisierten String mit Platzhaltern.
        /// Nutzt {0}, {1}, {2} etc. als Platzhalter.
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
                return template; // Bei Format-Fehler: Template ohne Ersetzung
            }
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// === DIESE METHODE FÜR DEIN SPIEL ANPASSEN ===
        /// Liest die aktuelle Spielsprache aus.
        /// </summary>
        private static string GetGameLanguage()
        {
            // UNITY BEISPIEL:
            // return Language.getAlias();

            // UNITY MIT PLAYERPREFS:
            // return PlayerPrefs.GetString("language", "en");

            // GODOT BEISPIEL (über Interop):
            // return TranslationServer.GetLocale().Substring(0, 2);

            // FALLBACK:
            return "en";
        }

        private static Dictionary<string, string> GetCurrentDictionary()
        {
            switch (_currentLang)
            {
                case "de": return _german;
                // Weitere Sprachen hier...
                default: return _english;
            }
        }

        /// <summary>
        /// Hilfsmethode: Fügt einen String in alle Sprachen ein.
        /// </summary>
        private static void Add(string key, string german, string english)
        {
            _german[key] = german;
            _english[key] = english;
        }

        /// <summary>
        /// Alle Übersetzungen hier definieren.
        /// </summary>
        private static void InitializeStrings()
        {
            // === ÜBERSETZUNGEN HIER ===

            // Allgemein
            Add("mod_loaded",
                "[ModName] geladen. F1 für Hilfe.",
                "[ModName] loaded. F1 for help.");

            Add("help_title",
                "Hilfe:",
                "Help:");

            // Mit Platzhaltern: {0}, {1}, etc.
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

### Schritt 3: In Mod integrieren

**Beim Mod-Start (Main.cs oder äquivalent):**

```csharp
public override void OnInitializeMelon()
{
    // Früh initialisieren, aber NACH dem Spiel geladen ist
}

// Bei Unity/MelonLoader: Wenn Spiel bereit ist
private void OnGameReady()
{
    Loc.Initialize();
    ScreenReader.Announce(Loc.Get("mod_loaded"));
}
```

**Bei Sprachänderung (z.B. in SettingsHandler):**

```csharp
private void OnLanguageChanged()
{
    // Spielsprache wurde geändert
    Loc.RefreshLanguage();

    // Optional: Bestätigung in neuer Sprache
    // (oder alte Sprache, je nach Präferenz)
}
```

### Schritt 4: Handler umstellen

**Vorher (hardcodiert):**
```csharp
ScreenReader.Announce("Inventar geöffnet. 5 Gegenstände.");
```

**Nachher (lokalisiert):**
```csharp
ScreenReader.Announce(Loc.Get("inventory_opened", itemCount));
```

**GetHelpText() nicht vergessen:**
```csharp
public string GetHelpText()
{
    return Loc.Get("inventory_help");
}
```

---

## Übersetzungen organisieren

### Namenskonvention für Keys

Verwende konsistente Präfixe:
```
[handler]_[aktion/element]

Beispiele:
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

### Kategorien gruppieren

In `InitializeStrings()` nach Kategorien sortieren:

```csharp
private static void InitializeStrings()
{
    // ===== ALLGEMEIN =====
    Add("mod_loaded", ...);
    Add("help_title", ...);

    // ===== INVENTAR =====
    Add("inventory_opened", ...);
    Add("inventory_empty", ...);

    // ===== SHOP =====
    Add("shop_opened", ...);
    Add("shop_not_enough", ...);

    // ===== EINSTELLUNGEN =====
    Add("settings_music_on", ...);
    // usw.
}
```

### Platzhalter-Konvention

Immer `{0}`, `{1}`, `{2}` verwenden (C# string.Format Syntax):
```csharp
Add("coins_info",
    "{0} Münzen, {1} Diamanten",
    "{0} coins, {1} diamonds");

// Aufruf:
Loc.Get("coins_info", coinCount, diamondCount);
```

---

## Sprachen hinzufügen

### 1. Dictionary hinzufügen
```csharp
private static readonly Dictionary<string, string> _french = new();
```

### 2. In GetCurrentDictionary() eintragen
```csharp
case "fr": return _french;
```

### 3. In RefreshLanguage() eintragen
```csharp
case "fr":
    _currentLang = "fr";
    break;
```

### 4. Add-Methode erweitern
```csharp
private static void Add(string key, string de, string en, string fr)
{
    _german[key] = de;
    _english[key] = en;
    _french[key] = fr;
}
```

### 5. Alle Übersetzungen ergänzen
Jeden `Add()`-Aufruf um die neue Sprache erweitern.

---

## Engine-spezifische Anpassungen

### Unity (MelonLoader, BepInEx)

**Sprache auslesen:**
```csharp
// Option 1: Über Spiel-eigene Klasse
string lang = Language.getAlias();

// Option 2: Über PlayerPrefs
string lang = PlayerPrefs.GetString("language", "en");

// Option 3: Systemsprache
SystemLanguage sysLang = Application.systemLanguage;
```

**Wann initialisieren:**
- Nach `SceneManager.sceneLoaded` Event
- Oder wenn `MainScreen.instance != null`

### Godot (GDExtension, C#)

**Sprache auslesen:**
```csharp
string locale = TranslationServer.GetLocale();
string lang = locale.Substring(0, 2); // "en_US" -> "en"
```

**Wann initialisieren:**
- In `_Ready()` des Haupt-Nodes

### Unreal Engine (C++)

**Sprache auslesen:**
```cpp
FString Culture = FInternationalization::Get().GetCurrentCulture()->GetName();
// Gibt z.B. "de-DE" zurück
```

**Wann initialisieren:**
- Nach `PostInitializeComponents()`

---

## Best Practices

### Do's

- Alle Ansagen lokalisieren, keine Ausnahmen
- Kurze, prägnante Texte (Screenreader-freundlich)
- Konsistente Terminologie pro Sprache
- Platzhalter für variable Werte nutzen
- Früh testen, ob Sprache erkannt wird

### Don'ts

- Keine Sätze aus Einzelteilen zusammenbauen (Grammatik variiert!)
- Keine maschinelle Übersetzung ohne Prüfung
- Keine hardcodierten Strings nach Lokalisierung vergessen
- Keine zu langen Texte (blockieren Screenreader)

### Schlechtes Beispiel (Satz zusammenbauen):
```csharp
// SCHLECHT - Grammatik funktioniert nicht in allen Sprachen!
string text = Loc.Get("you_have") + " " + count + " " + Loc.Get("items");
// Deutsch: "Du hast 5 Gegenstände" - OK
// Japanisch: "5 Gegenstände du hast" - FALSCH
```

### Gutes Beispiel:
```csharp
// GUT - Ganzer Satz als Template
string text = Loc.Get("item_count", count);
// Key enthält: "Du hast {0} Gegenstände" / "You have {0} items" / etc.
```

---

## Checkliste für neue Projekte

- [ ] Sprachsystem des Spiels gefunden und dokumentiert
- [ ] Loc.cs erstellt mit GetGameLanguage() angepasst
- [ ] Mindestens Deutsch und Englisch implementiert
- [ ] Loc.Initialize() wird beim Mod-Start aufgerufen
- [ ] Loc.RefreshLanguage() wird bei Sprachänderung aufgerufen
- [ ] Alle Handler nutzen Loc.Get() statt hardcodierte Strings
- [ ] GetHelpText() in allen Handlern lokalisiert
- [ ] Mit beiden Sprachen getestet
- [ ] Sprachenwechsel während des Spielens getestet

---

## Beispiel: Vollständiger Handler

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

