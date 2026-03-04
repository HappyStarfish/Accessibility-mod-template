# Référence technique

Aperçu compact : MelonLoader, BepInEx, Harmony et Tolk.

---

## Bases de MelonLoader

### Références du projet (csproj)

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

### Attribut MelonInfo

```csharp
[assembly: MelonInfo(typeof(MyNamespace.Main), "ModName", "1.0.0", "Author")]
[assembly: MelonGame("Developer", "GameName")]
```

### Cycle de vie

```csharp
public class Main : MelonMod
{
    public override void OnInitializeMelon() { }  // Une fois au chargement
    public override void OnUpdate() { }            // Chaque frame
    public override void OnSceneWasLoaded(int buildIndex, string sceneName) { }
    public override void OnApplicationQuit() { }   // A la fermeture
}
```

### CRITIQUE : Accéder au code du jeu

**Tout accès aux classes du jeu avant que le jeu soit entièrement chargé peut provoquer un crash.**

Cela concerne :
- Les singletons de gestion du jeu (ex. `GameManager.i`, `AudioManager.instance`)
- `typeof(GameClass)` - même dans les attributs Harmony !
- Toute référence aux classes du jeu dans les champs ou les méthodes précoces

**Autorisé selon le moment :**

- Chargement de l'assembly : Uniquement vos propres classes et les types Unity
- OnInitializeMelon : Uniquement votre propre initialisation, AUCUN accès au jeu
- OnSceneWasLoaded : Tout est autorisé

**Quand le jeu est-il prêt ?**

Uniquement dans/après `OnSceneWasLoaded()`. Test fiable : Vérifier un élément d'interface fiable :

```csharp
if (GameObject.Find("MainUI") == null)
    return; // Le jeu n'est pas encore prêt
```

**Erreur 1 : typeof() dans les attributs Harmony**

```csharp
// FAUX - typeof() est évalué au chargement de l'assembly
[HarmonyPatch(typeof(GameClass))]
public static class MyPatch { }
```

```csharp
// CORRECT - Appliquer les patches manuellement dans OnSceneWasLoaded
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

**Erreur 2 : Accès au singleton trop tôt**

```csharp
// FAUX - Le singleton peut bloquer ou crasher
public override void OnUpdate()
{
    var manager = GameManager.i;
}
```

```csharp
// CORRECT - Vérifier d'abord, puis mettre en cache
private GameManager _cachedManager = null;

private GameManager GetManagerSafe()
{
    if (_cachedManager != null) return _cachedManager;

    if (GameObject.Find("MainUI") == null)
        return null; // Le jeu n'est pas encore prêt

    _cachedManager = GameManager.i;
    return _cachedManager;
}
```

### Journalisation

```csharp
MelonLogger.Msg("Info");
MelonLogger.Warning("Avertissement");
MelonLogger.Error("Erreur");
```

### Saisie clavier

```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Appuyé une fois
if (Input.GetKey(KeyCode.LeftShift)) { }  // Maintenu
```

---

## Bases de BepInEx

### Références du projet (csproj)

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

### Attribut BepInPlugin

```csharp
[BepInPlugin("com.author.modname", "ModName", "1.0.0")]
```

- Premier paramètre : GUID unique (notation de domaine inversé)
- Contrairement à MelonLoader, ces valeurs sont choisies librement (pas issues d'un fichier de log)
- Le GUID doit être unique parmi tous les mods de ce jeu

### Cycle de vie

```csharp
using BepInEx;
using UnityEngine;

[BepInPlugin("com.author.modname", "ModName", "1.0.0")]
public class Main : BaseUnityPlugin
{
    void Awake() { }    // Une fois au chargement (comme OnInitializeMelon)
    void Update() { }   // Chaque frame (comme OnUpdate)
    void OnDestroy() { } // A la fermeture (comme OnApplicationQuit)
}
```

**Différences clés avec MelonLoader :**

- `BaseUnityPlugin` hérite de `MonoBehaviour` — utilise les méthodes du cycle de vie Unity
- Pas d'équivalent intégré à `OnSceneWasLoaded`. Utilisez l'événement `SceneManager.sceneLoaded` à la place :

```csharp
using UnityEngine.SceneManagement;

void Awake()
{
    SceneManager.sceneLoaded += OnSceneLoaded;
}

private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
{
    Logger.LogInfo($"Scène chargée : {scene.name}");
}
```

### CRITIQUE : Accéder au code du jeu (BepInEx)

Les mêmes règles de timing s'appliquent qu'avec MelonLoader :

- **Awake()** : Uniquement votre propre initialisation, AUCUN accès aux classes du jeu
- **Après le chargement de la scène** : Tout est autorisé

```csharp
private bool _gameReady = false;

void Update()
{
    if (!_gameReady)
    {
        // Vérifier les singletons du jeu — adaptez à votre jeu !
        // if (GameManager.instance != null)
        //     _gameReady = true;
        // else
        //     return;
        return;
    }

    // Logique du jeu ici
}
```

### Journalisation

```csharp
Logger.LogInfo("Info");      // Logger d'instance (dans la classe du plugin)
Logger.LogWarning("Avertissement");
Logger.LogError("Erreur");
```

### Saisie clavier

Identique à MelonLoader — les deux utilisent le système Input de Unity :

```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Appuyé une fois
if (Input.GetKey(KeyCode.LeftShift)) { }  // Maintenu
```

### Répertoire de sortie du mod

La DLL compilée va dans `BepInEx/plugins/` (pas `Mods/` comme avec MelonLoader).

---

## Bases de OWML (Outer Wilds Mod Loader)

OWML est un chargeur de mods spécialisé pour les jeux utilisant le framework OWML. Contrairement à MelonLoader/BepInEx, il fournit sa propre classe de base `ModBehaviour` et son API `ModHelper`.

### Références du projet (csproj)

```xml
<Reference Include="OWML.Common">
    <HintPath>[GameDirectory]\OWML\OWML.Common.dll</HintPath>
</Reference>
<Reference Include="OWML.ModHelper">
    <HintPath>[GameDirectory]\OWML\OWML.ModHelper.dll</HintPath>
</Reference>
<Reference Include="Assembly-CSharp">
    <HintPath>[GameDirectory]\[Game]_Data\Managed\Assembly-CSharp.dll</HintPath>
</Reference>
<Reference Include="0Harmony">
    <HintPath>[GameDirectory]\OWML\0Harmony.dll</HintPath>
</Reference>
```

### Fichier manifeste

OWML utilise `manifest.json` au lieu des attributs d'assembly :

```json
{
    "filename": "ModName.dll",
    "author": "AuthorName",
    "name": "ModName",
    "uniqueName": "AuthorName.ModName",
    "version": "1.0.0",
    "owmlVersion": "2.15.0",
    "dependencies": []
}
```

### Cycle de vie

```csharp
using OWML.ModHelper;

public class Main : ModBehaviour
{
    public void Start()   // Une fois au chargement du mod. ModHelper est disponible ici.
    {
        ModHelper.Console.WriteLine("Mod chargé !");
    }

    public void Update()  // Chaque frame
    {
    }

    public void OnDestroy() // A la fermeture
    {
    }
}
```

### CRITIQUE : ModHelper est NULL dans Awake()

Contrairement à MelonLoader/BepInEx, OWML injecte `ModHelper` entre `Awake()` et `Start()`. Tout accès à `ModHelper` dans `Awake()` lancera une `NullReferenceException`.

**Initialisez toujours dans `Start()`, jamais dans `Awake()`.**

### Configuration de Harmony

OWML inclut `0Harmony.dll` — référencez-le directement dans le csproj :

```csharp
using HarmonyLib;

public void Start()
{
    var harmony = new Harmony("com.author.modname");
    harmony.PatchAll();
}
```

**Important :** La méthode intégrée `ModHelper.HarmonyHelper.AddPrefix/AddPostfix` de OWML peut échouer sur les méthodes surchargées. Préférez utiliser `0Harmony.dll` directement avec `harmony.Patch()` et `AccessTools.Method()` pour un patching fiable.

### Nommage des paramètres Harmony

**Harmony 2.x fait correspondre les paramètres de prefix/postfix par NOM, pas seulement par type.** Si la méthode originale a un paramètre nommé `damage`, votre paramètre de patch doit aussi s'appeler `damage`. Une discordance de nom provoque une "IL Compile Error" à l'exécution.

### Journalisation

```csharp
ModHelper.Console.WriteLine("Info");
ModHelper.Console.WriteLine("Avertissement", MessageType.Warning);
ModHelper.Console.WriteLine("Erreur", MessageType.Error);
```

### Répertoire de sortie du mod

La DLL compilée va dans `OWML/Mods/[uniqueName]/` avec le `manifest.json`.

---

## Patching Harmony

Harmony est inclus dans MelonLoader, BepInEx et OWML - aucun import supplémentaire nécessaire.

### Configuration dans Main

**MelonLoader :**
```csharp
private HarmonyLib.Harmony _harmony;

public override void OnInitializeMelon()
{
    _harmony = new HarmonyLib.Harmony("com.author.modname");
    _harmony.PatchAll();
}
```

**BepInEx :**
```csharp
// Harmony est automatiquement créé par BepInEx. Appelez simplement PatchAll dans Awake :
void Awake()
{
    var harmony = new HarmonyLib.Harmony("com.author.modname");
    harmony.PatchAll();
}
```

### Postfix (après la méthode originale)

```csharp
[HarmonyPatch(typeof(InventoryUI), "Show")]
public class InventoryShowPatch
{
    [HarmonyPostfix]
    public static void Postfix()
    {
        ScreenReader.Say("Inventaire ouvert");
    }
}
```

### Postfix avec valeur de retour

```csharp
[HarmonyPatch(typeof(Player), "GetHealth")]
public class HealthPatch
{
    [HarmonyPostfix]
    public static void Postfix(ref int __result)
    {
        MelonLogger.Msg($"Santé : {__result}");
    }
}
```

### Prefix (avant la méthode originale)

```csharp
[HarmonyPatch(typeof(Player), "TakeDamage")]
public class DamagePatch
{
    [HarmonyPrefix]
    public static void Prefix(int damage)
    {
        ScreenReader.Say($"Dégâts : {damage}");
    }

    // Retourner false pour ignorer la méthode originale :
    // public static bool Prefix() { return false; }
}
```

### Paramètres spéciaux

- `__instance` - L'instance de l'objet
- `__result` - Valeur de retour (Postfix uniquement)
- `___fieldName` - Champs privés (3 underscores !)

---

## Tolk (lecteur d'écran)

### DLL requises dans le répertoire du jeu

**Les DEUX fichiers doivent être présents dans le dossier du jeu (là où se trouve le .exe) :**
- `Tolk.dll` — le pont vers le lecteur d'écran
- `nvdaControllerClient64.dll` (jeux 64 bits) ou `nvdaControllerClient32.dll` (jeux 32 bits) — requis pour NVDA

Sans nvdaControllerClient, les utilisateurs NVDA n'ont aucune sortie. JAWS fonctionne via COM (pas de DLL supplémentaire).

Téléchargement : https://github.com/ndarilek/tolk/releases

### Imports DLL

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

### Wrapper simple

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

### Utilisation

**MelonLoader :**
```csharp
public override void OnInitializeMelon()
{
    ScreenReader.Initialize();
    ScreenReader.Say("Mod chargé");
}

public override void OnApplicationQuit()
{
    ScreenReader.Shutdown();
}
```

**BepInEx :**
```csharp
void Awake()
{
    ScreenReader.Initialize();
    ScreenReader.Say("Mod chargé");
}

void OnDestroy()
{
    ScreenReader.Shutdown();
}
```

---

## Référence rapide Unity

### Trouver des GameObjects

```csharp
var obj = GameObject.Find("Name");  // Lent !
var all = GameObject.FindObjectsOfType<Button>();
```

### Composants

```csharp
var text = obj.GetComponent<Text>();
var text = obj.GetComponentInChildren<Text>();
var allTexts = obj.GetComponentsInChildren<Text>();
```

### Hiérarchie

```csharp
var child = parent.transform.Find("ChildName");
foreach (Transform child in parent.transform) { }
```

### État actif

```csharp
bool isActive = obj.activeInHierarchy;
obj.SetActive(true);
```

---

## Patterns d'accessibilité courants

### Annoncer l'ouverture/fermeture d'une interface

```csharp
[HarmonyPatch(typeof(MenuUI), "Show")]
public class MenuShowPatch
{
    [HarmonyPostfix]
    public static void Postfix() => ScreenReader.Say("Menu ouvert");
}

[HarmonyPatch(typeof(MenuUI), "Hide")]
public class MenuHidePatch
{
    [HarmonyPostfix]
    public static void Postfix() => ScreenReader.Say("Menu fermé");
}
```

### Navigation dans les menus

```csharp
public void AnnounceItem(int index, int total, string name)
{
    ScreenReader.Say($"{index} sur {total} : {name}");
}
```

### Changement d'état

```csharp
public void AnnounceHealth(int current, int max)
{
    ScreenReader.Say($"Santé : {current} sur {max}");
}
```

### Éviter les doublons

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

## Multi-plateforme : Linux et macOS

Si le jeu fonctionne sous Linux ou macOS, le mod peut être porté. Voici ce qui fonctionne tel quel, ce qui doit être modifié, et comment procéder.

### Ce qui fonctionne sans modification

- **Tout le code du mod** (handlers, Loc, DebugLogger, Main) est du C# pur — fonctionne sur n'importe quelle plateforme
- **Le patching Harmony** fonctionne partout où Mono/.NET s'exécute
- **Unity** est multi-plateforme, donc les mécanismes internes du jeu se comportent de la même façon

### Chargeur de mods

- **BepInEx** : Dispose de versions officielles pour Linux et fonctionne sur macOS. Le meilleur choix pour les mods multi-plateformes.
- **MelonLoader** : Le support Linux existe mais est moins mature que celui de BepInEx. Le support macOS est limité.
- Si le multi-plateforme est un objectif, préférez BepInEx.

### Le défi principal : l'intégration du lecteur d'écran

**Tolk est exclusivement Windows.** Il utilise des DLL spécifiques à Windows (nvdaControllerClient, API JAWS, SAPI). Sur les autres plateformes, d'autres APIs de lecteur d'écran existent :

- **Linux** : speech-dispatcher (libspeechd / commande `spd-say`), AT-SPI
- **macOS** : VoiceOver via l'API NSAccessibility, ou la commande `say`

### Comment implémenter un support multi-plateforme du lecteur d'écran

Remplacez les appels directs à Tolk dans `ScreenReader.cs` par une abstraction adaptée à la plateforme :

```csharp
public static void Initialize()
{
    if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        _backend = new TolkBackend();       // Intégration Tolk existante
    else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        _backend = new SpeechDBackend();     // speech-dispatcher
    else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        _backend = new MacSayBackend();      // Commande say de macOS
}
```

**Backend Linux simple (appel au processus spd-say) :**

```csharp
public class SpeechDBackend : IScreenReaderBackend
{
    public bool IsAvailable()
    {
        // Vérifier si spd-say existe
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

**Backend macOS simple (commande say) :**

```csharp
public class MacSayBackend : IScreenReaderBackend
{
    public bool IsAvailable() => true; // say est toujours disponible sur macOS

    public void Say(string text, bool interrupt)
    {
        if (interrupt) Silence();
        Process.Start("say", $"\"{text}\"");
    }

    public void Silence()
    {
        // Tuer tout processus say en cours
        try { Process.Start("killall", "say"); } catch { }
    }
}
```

**Interface partagée :**

```csharp
public interface IScreenReaderBackend
{
    bool IsAvailable();
    void Say(string text, bool interrupt);
    void Silence();
}
```

### Limitations de l'approche simple

- **Les appels de processus ont une légère latence** (~50-100ms) comparé aux appels DLL directs de Tolk
- **Pas de file d'attente** — `spd-say` et `say` ne gèrent pas nativement la file d'attente (nécessiterait une file d'attente personnalisée)
- **`say` sur macOS utilise la voix de VoiceOver mais PAS le lecteur d'écran VoiceOver** — les utilisateurs aveugles de macOS qui utilisent VoiceOver risquent d'entendre une double sortie audio

### Alternatives robustes (plus d'effort)

- **Linux** : P/Invoke directement vers `libspeechd.so` pour speech-dispatcher — similaire au fonctionnement de Tolk sous Windows, sans surcharge de processus
- **macOS** : Utiliser les APIs NSAccessibility via P/Invoke ou un helper natif — s'intègre correctement avec VoiceOver
- **Bibliothèque multi-plateforme** : [Tolk-rs](https://github.com/mush42/tolk-rs) (Rust) ou [accessible-output](https://github.com/accessibleapps/accessible_output2) (Python) existent comme références, mais aucune bibliothèque C# multi-plateforme maintenue pour les lecteurs d'écran n'existe encore

### Estimation de l'effort

- Couche d'abstraction du lecteur d'écran : Faible (refactoring du ScreenReader.cs existant)
- Backend Linux simple (spd-say) : Faible
- Backend macOS simple (say) : Faible
- Backend Linux robuste (libspeechd) : Moyen
- Backend macOS robuste (NSAccessibility) : Moyen
- Tout le reste du template : Aucune modification nécessaire
