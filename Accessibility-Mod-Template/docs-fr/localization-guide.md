# Guide de localisation pour les mods d'accessibilité

Ce guide décrit comment implémenter la localisation multilingue pour les mods d'accessibilité. La méthode a été testée avec succès dans le Pet Idle Accessibility Mod et peut être adaptée pour différents moteurs de jeu.

---

## Principes fondamentaux

### 1. Détection automatique de la langue
Le mod détecte automatiquement la langue du jeu et s'adapte. Aucun changement manuel nécessaire.

### 2. Chaîne de repli
Quand une traduction est manquante :
- Essayer la langue courante
- Si non disponible : anglais
- Si également non disponible : la clé elle-même (pour le débogage)

### 3. Classe de localisation centralisée
Toutes les traductions au même endroit. Pas besoin de chercher dans différents fichiers.

### 4. API simple
Seulement deux méthodes au quotidien :
- `Loc.Get("key")` - Récupérer une chaîne
- `Loc.Get("key", param1, param2)` - Chaîne avec paramètres

---

## Architecture

### Structure des fichiers

- Loc.cs - Classe de localisation centralisée
- Les classes handler utilisent `Loc.Get()` pour toutes les annonces

### Structure de la classe (Loc.cs)

```csharp
public static class Loc
{
    private static bool _initialized = false;
    private static string _currentLang = "en";  // Repli

    // Un dictionnaire par langue
    private static readonly Dictionary<string, string> _german = new();
    private static readonly Dictionary<string, string> _english = new();
    private static readonly Dictionary<string, string> _spanish = new();
    private static readonly Dictionary<string, string> _russian = new();
    // D'autres langues selon les besoins...

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

## Implémentation pas à pas

### Étape 1 : Trouver le système de langue du jeu

**Objectif :** Découvrir comment le jeu stocke la langue courante.

**Patterns de recherche typiques dans le code décompilé :**
- `Language`, `Localization`, `I18n`, `L10n`
- `currentLanguage`, `CurrentLocale`, `SelectedLanguage`
- `SystemLanguage` (spécifique à Unity)
- `GetLanguage()`, `GetLocale()`, `getAlias()`

**Exemples par moteur :**

Unity :
```csharp
// Souvent trouvé :
Language.currentLanguage  // Enum SystemLanguage
Language.getAlias()       // Retourne "de", "en", "es" etc.
PlayerPrefs.GetString("language")
```

Godot :
```gdscript
# Souvent trouvé :
TranslationServer.get_locale()  # Retourne "de", "en_US" etc.
OS.get_locale()
```

Unreal/C++ :
```cpp
// Souvent trouvé :
FInternationalization::Get().GetCurrentCulture()
UKismetInternationalizationLibrary::GetCurrentLanguage()
```

**Documentez ce que vous trouvez !** Notez :
- Quelle classe/méthode fournit la langue
- Quel format (code à 2 lettres, enum, nom complet)
- Où le paramètre est stocké

### Étape 2 : Créer la classe de localisation

**Template pour la structure de base :**

```csharp
using System.Collections.Generic;

namespace [YourModName]
{
    /// <summary>
    /// Localisation centralisée pour le mod d'accessibilité.
    /// Détecte automatiquement la langue du jeu.
    /// </summary>
    public static class Loc
    {
        #region Fields

        private static bool _initialized = false;
        private static string _currentLang = "en";

        // Dictionnaires pour chaque langue supportée
        private static readonly Dictionary<string, string> _german = new();
        private static readonly Dictionary<string, string> _english = new();
        // Ajoutez-en d'autres selon les besoins

        #endregion

        #region Public Methods

        /// <summary>
        /// Initialise la localisation. Appeler une fois au démarrage du mod.
        /// </summary>
        public static void Initialize()
        {
            InitializeStrings();
            RefreshLanguage();
            _initialized = true;
        }

        /// <summary>
        /// Met à jour la langue selon le paramètre du jeu.
        /// Appeler quand le joueur change de langue.
        /// </summary>
        public static void RefreshLanguage()
        {
            // === ADAPTEZ CECI POUR VOTRE JEU ===
            string gameLang = GetGameLanguage();

            // Uniquement les langues supportées, sinon anglais
            switch (gameLang)
            {
                case "de":
                    _currentLang = "de";
                    break;
                // Ajoutez d'autres langues ici...
                default:
                    _currentLang = "en";
                    break;
            }
        }

        /// <summary>
        /// Récupère une chaîne localisée.
        /// </summary>
        public static string Get(string key)
        {
            if (!_initialized) Initialize();

            var dict = GetCurrentDictionary();

            // Essayer la langue courante
            if (dict.TryGetValue(key, out string value))
                return value;

            // Repli : anglais
            if (_english.TryGetValue(key, out string engValue))
                return engValue;

            // Dernier repli : la clé elle-même (aide au débogage)
            return key;
        }

        /// <summary>
        /// Récupère une chaîne localisée avec des paramètres.
        /// Utilise {0}, {1}, {2} etc. comme paramètres.
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
                return template; // En cas d'erreur de format : template sans remplacement
            }
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// === ADAPTEZ CETTE MÉTHODE POUR VOTRE JEU ===
        /// Lit la langue courante du jeu.
        /// </summary>
        private static string GetGameLanguage()
        {
            // EXEMPLE UNITY :
            // return Language.getAlias();

            // UNITY AVEC PLAYERPREFS :
            // return PlayerPrefs.GetString("language", "en");

            // EXEMPLE GODOT (via interop) :
            // return TranslationServer.GetLocale().Substring(0, 2);

            // REPLI :
            return "en";
        }

        private static Dictionary<string, string> GetCurrentDictionary()
        {
            switch (_currentLang)
            {
                case "de": return _german;
                // Ajoutez d'autres langues ici...
                default: return _english;
            }
        }

        /// <summary>
        /// Méthode utilitaire : Ajoute une chaîne dans toutes les langues.
        /// </summary>
        private static void Add(string key, string german, string english)
        {
            _german[key] = german;
            _english[key] = english;
        }

        /// <summary>
        /// Définissez toutes les traductions ici.
        /// </summary>
        private static void InitializeStrings()
        {
            // === TRADUCTIONS ICI ===

            // Général
            Add("mod_loaded",
                "[ModName] geladen. F1 für Hilfe.",
                "[ModName] loaded. F1 for help.");

            Add("help_title",
                "Hilfe:",
                "Help:");

            // Avec paramètres : {0}, {1}, etc.
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

### Étape 3 : Intégrer dans le mod

**Au démarrage du mod (Main.cs ou équivalent) :**

```csharp
public override void OnInitializeMelon()
{
    // Initialiser tôt, mais APRÈS que le jeu soit chargé
}

// Pour Unity/MelonLoader : Quand le jeu est prêt
private void OnGameReady()
{
    Loc.Initialize();
    ScreenReader.Say(Loc.Get("mod_loaded"));
}
```

**Au changement de langue (ex. dans SettingsHandler) :**

```csharp
private void OnLanguageChanged()
{
    // La langue du jeu a été changée
    Loc.RefreshLanguage();

    // Optionnel : Confirmation dans la nouvelle langue
    // (ou l'ancienne, selon la préférence)
}
```

### Étape 4 : Convertir les handlers

**Avant (en dur) :**
```csharp
ScreenReader.Say("Inventory opened. 5 items.");
```

**Après (localisé) :**
```csharp
ScreenReader.Say(Loc.Get("inventory_opened", itemCount));
```

**N'oubliez pas GetHelpText() :**
```csharp
public string GetHelpText()
{
    return Loc.Get("inventory_help");
}
```

---

## Organiser les traductions

### Convention de nommage des clés

Utilisez des préfixes cohérents :
```
[handler]_[action/élément]

Exemples :
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

### Regrouper par catégories

Dans `InitializeStrings()`, triez par catégories :

```csharp
private static void InitializeStrings()
{
    // ===== GÉNÉRAL =====
    Add("mod_loaded", ...);
    Add("help_title", ...);

    // ===== INVENTAIRE =====
    Add("inventory_opened", ...);
    Add("inventory_empty", ...);

    // ===== BOUTIQUE =====
    Add("shop_opened", ...);
    Add("shop_not_enough", ...);

    // ===== PARAMÈTRES =====
    Add("settings_music_on", ...);
    // etc.
}
```

### Convention des paramètres

Utilisez toujours `{0}`, `{1}`, `{2}` (syntaxe C# string.Format) :
```csharp
Add("coins_info",
    "{0} Münzen, {1} Diamanten",
    "{0} coins, {1} diamonds");

// Appel :
Loc.Get("coins_info", coinCount, diamondCount);
```

---

## Ajouter des langues

### 1. Ajouter un dictionnaire
```csharp
private static readonly Dictionary<string, string> _french = new();
```

### 2. Enregistrer dans GetCurrentDictionary()
```csharp
case "fr": return _french;
```

### 3. Enregistrer dans RefreshLanguage()
```csharp
case "fr":
    _currentLang = "fr";
    break;
```

### 4. Étendre la méthode Add
```csharp
private static void Add(string key, string de, string en, string fr)
{
    _german[key] = de;
    _english[key] = en;
    _french[key] = fr;
}
```

### 5. Ajouter toutes les traductions
Étendez chaque appel `Add()` avec la nouvelle langue.

---

## Adaptations spécifiques aux moteurs

### Unity (MelonLoader, BepInEx)

**Lire la langue :**
```csharp
// Option 1 : Via la propre classe du jeu
string lang = Language.getAlias();

// Option 2 : Via PlayerPrefs
string lang = PlayerPrefs.GetString("language", "en");

// Option 3 : Langue du système
SystemLanguage sysLang = Application.systemLanguage;
```

**Quand initialiser :**
- Après l'événement `SceneManager.sceneLoaded`
- Ou quand `MainScreen.instance != null`

### Godot (GDExtension, C#)

**Lire la langue :**
```csharp
string locale = TranslationServer.GetLocale();
string lang = locale.Substring(0, 2); // "en_US" -> "en"
```

**Quand initialiser :**
- Dans `_Ready()` du noeud principal

### Unreal Engine (C++)

**Lire la langue :**
```cpp
FString Culture = FInternationalization::Get().GetCurrentCulture()->GetName();
// Retourne par ex. "de-DE"
```

**Quand initialiser :**
- Après `PostInitializeComponents()`

---

## Bonnes pratiques

### A faire

- Localiser toutes les annonces, sans exception
- Textes courts et concis (adaptés aux lecteurs d'écran)
- Terminologie cohérente par langue
- Utiliser des paramètres pour les valeurs variables
- Tester tôt si la langue est détectée

### A ne pas faire

- Ne pas construire des phrases à partir de morceaux individuels (la grammaire varie !)
- Pas de traduction automatique sans vérification
- Ne pas oublier les chaînes en dur après la localisation
- Pas de textes trop longs (bloquent les lecteurs d'écran)

### Mauvais exemple (construction de phrases) :
```csharp
// MAUVAIS - La grammaire ne fonctionne pas dans toutes les langues !
string text = Loc.Get("you_have") + " " + count + " " + Loc.Get("items");
// Allemand : "Du hast 5 Gegenstände" - OK
// Japonais : "5 Gegenstände du hast" - FAUX
```

### Bon exemple :
```csharp
// BON - Phrase complète comme template
string text = Loc.Get("item_count", count);
// La clé contient : "Du hast {0} Gegenstände" / "You have {0} items" / etc.
```

---

## Checklist pour les nouveaux projets

- [ ] Système de langue du jeu trouvé et documenté
- [ ] Loc.cs créé avec GetGameLanguage() adapté
- [ ] Au moins l'allemand et l'anglais implémentés
- [ ] Loc.Initialize() est appelé au démarrage du mod
- [ ] Loc.RefreshLanguage() est appelé au changement de langue
- [ ] Tous les handlers utilisent Loc.Get() au lieu de chaînes en dur
- [ ] GetHelpText() localisé dans tous les handlers
- [ ] Testé avec les deux langues
- [ ] Changement de langue en cours de jeu testé

---

## Exemple : handler complet

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
            ScreenReader.Say(Loc.Get("inventory_not_available"));
            return;
        }

        int count = inventory.items.Count;

        if (count == 0)
        {
            ScreenReader.Say(Loc.Get("inventory_empty"));
        }
        else
        {
            ScreenReader.Say(Loc.Get("inventory_count", count));
        }
    }

    public void AnnounceItem(Item item)
    {
        if (item == null)
        {
            ScreenReader.Say(Loc.Get("no_item_selected"));
            return;
        }

        ScreenReader.Say(
            Loc.Get("item_info", item.name, item.quantity, item.description)
        );
    }
}
```
