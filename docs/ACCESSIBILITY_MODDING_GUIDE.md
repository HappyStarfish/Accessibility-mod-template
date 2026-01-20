# Accessibility Modding Guide for Screen Reader Users

A guide for creating game accessibility mods that enable blind players to play using screen readers (NVDA, JAWS, etc.).

## Core Accessibility Goals

### Core Principle: Playability, Not Simplification

**The goal is to make the game playable for blind players in the same way sighted players experience it.** Accessibility means equal access to the gameplay - not a simplified version.

- **No cheats without asking:** Only suggest cheats or simplifications when there is absolutely no other way to make a game mechanic accessible.
- **Never add automatically:** Never implement cheats or shortcuts without explicitly asking first.
- **Full game experience:** All game mechanics, challenges, and decisions should be preserved.

### Technical Goals

- Well-structured text output (no tables, no graphics)
- Linear, readable format for screen readers
- Use a screen reader communication library (e.g., Tolk for NVDA/JAWS on Windows)
- Full keyboard navigation support

## Screen Reader Communication Principles

### What to Announce
- Context changes (screen transitions, mode changes, phase changes)
- Currently focused elements
- Game state updates (health, resources, turn information)
- Available actions and their results
- Error states and confirmations

### How to Announce
- Output plain text optimized for screen readers
- Keep announcements concise but informative
- Provide detailed information in navigable blocks (arrow key navigation)
- Allow users to repeat the last announcement (e.g., Ctrl+R)
- Announce automatically on important events, but avoid spam

### Announcement Patterns

Use consistent formats for different announcement types:

**Menu/List Navigation:**
```
[MenuName], [Position] of [Total]: [ElementName]
Example: "Inventory, 3 of 12: Health Potion"
```

**Status Changes:**
```
[What] [Direction] [Value] (optional: [Context])
Example: "Health dropped to 45 of 100"
```

**Action Confirmation:**
```
[Action] [Object] (optional: [Result])
Example: "Used Health Potion, health full"
```

**Errors/Warnings:**
```
[Warning/Error]: [Reason]
Example: "Cannot do that: Inventory full"
```

## Output Formatting for Screen Readers

### Avoid
- Tables (pipe | symbols are read aloud character by character)
- ASCII art or graphical representations
- Relying on spatial positioning to convey meaning
- Multiple columns of information

### Prefer
- Headings and bullet lists for structure
- Linear, one item per line presentation
- Group related info under clear labels
- Consistent ordering of information

### Example Format
Instead of tables, format information like this:

**Item Name**
- Property: Value
- Property: Value
- Property: Value

**Another Item**
- Property: Value
- Property: Value

## Keyboard Navigation Design

### Reserved Keys (Do NOT Override)
- Tab - Standard UI navigation
- Enter - Confirm/activate
- Escape - Cancel/back

### Recommended Key Patterns
- Single letters for quick zone/area access (e.g., C for cards, G for graveyard)
- Shift+Letter for opponent/alternate views of the same zone
- Arrow keys for navigation within a focused area
- F1 for help, F2 for context information
- Space for primary action/confirm
- Function keys for global actions

### Context-Aware Keys
- Keys can have different functions based on game state
- Always announce what the current context allows
- Provide audio feedback for mode/context changes

## Code Architecture Recommendations

### Quellcode-Recherche vor der Implementierung

**KRITISCH: Niemals raten, immer verifizieren!**

Bevor du einen neuen Handler schreibst, eine Spielmechanik ansprichst oder UI-Elemente referenzierst, MUSST du den dekompilierten Quellcode im `decompiled/` Ordner durchsuchen. Das Erraten von Klassennamen, Methodennamen oder Spielmechaniken führt unweigerlich zu Fehlern.

#### Warum ist das so wichtig?

- Spiele verwenden oft unerwartete Namenskonventionen (z.B. `CardZone` statt `Hand`, `UIManager` statt `GameUI`)
- Interne Mechaniken funktionieren selten so, wie man es von außen vermutet
- Falsche Annahmen führen zu Code, der kompiliert aber nicht funktioniert - schwer zu debuggen
- Reflection auf nicht-existente Felder schlägt still fehl
- Ein falscher Klassenname bedeutet: Zeit verschwendet, Frust beim Benutzer

#### Was muss VOR jeder Implementierung geprüft werden?

**Bei neuen Handlern:**
- Wie heißt die UI-Klasse/das Panel genau? (`decompiled/` durchsuchen)
- Welche Methoden hat sie? (IsOpen, Show, Hide, etc.)
- Wie ist die Hierarchie aufgebaut? (Parent-Child-Beziehungen)
- Welche Events/Callbacks existieren?

**Bei Spielmechaniken:**
- Wie heißen die relevanten Klassen? (z.B. `InventoryManager`, `PlayerInventory`, `ItemStorage`?)
- Welche Properties/Felder sind öffentlich zugänglich?
- Gibt es Singleton-Instanzen? Wie greift man darauf zu?
- Welche Methoden ändern den Zustand?

**Bei UI-Elementen:**
- Exakte Namen der GameObjects/Panels
- Komponententypen (Text, TextMeshProUGUI, Button, etc.)
- Verschachtelung und Pfade in der Hierarchie

**Bei Tasteneingaben:**
- Wie verarbeitet das Spiel Input? (Unity Input, InputSystem, Custom?)
- Welche Tasten sind bereits belegt?
- Gibt es InputBlocker oder Fokus-Systeme?

#### Typische Suchmuster im dekompilierten Code

```
Grep-Pattern für UI-Screens:
- "class.*Menu" oder "class.*Screen" oder "class.*Panel"
- "public static.*Instance" (für Singletons)
- "void Show" oder "void Open" oder "void Display"

Grep-Pattern für Spielmechaniken:
- "class.*Manager" oder "class.*Controller"
- "public.*List<" oder "public.*Dictionary<" (für Sammlungen)
- "static.*Current" oder "static.*Active" (für aktiven Zustand)

Grep-Pattern für spezifische Features:
- Suche nach dem englischen Begriff der Mechanik
- Suche nach UI-Text, der im Spiel sichtbar ist
- Suche nach Variablennamen, die logisch erscheinen
```

#### Checkliste vor der Implementierung

Bevor du Code schreibst, stelle sicher:

- [ ] Relevante Klassen im `decompiled/` Ordner gefunden
- [ ] Exakte Klassennamen notiert (Groß-/Kleinschreibung!)
- [ ] Zugriffsmethode verstanden (Singleton? FindObjectOfType? Referenz?)
- [ ] Öffentliche API der Klasse bekannt (Methoden, Properties)
- [ ] Erkenntnisse in `docs/game-api.md` dokumentiert

#### Beispiel: Falsches vs. Richtiges Vorgehen

**FALSCH (Raten):**
```csharp
// "Das Inventar heißt bestimmt InventoryPanel..."
var inventory = GameObject.Find("InventoryPanel");
// Funktioniert nicht - heißt in Wirklichkeit "UI_Inventory_Main"
```

**RICHTIG (Recherchieren):**
```
1. Grep im decompiled/ Ordner: "Inventory"
2. Finde: class UI_Inventory_Main : MonoBehaviour
3. Prüfe: Hat static Instance Property? Ja!
4. Code: var inventory = UI_Inventory_Main.Instance;
```

#### Wann erneut recherchieren?

- Bei JEDEM neuen Handler
- Bei JEDER neuen Spielmechanik
- Wenn Code unerwartet nicht funktioniert
- Wenn Reflection fehlschlägt
- Nach Spiel-Updates (Namen können sich ändern)

### Core Principles
- **Modular** - Separate concerns: input handling, UI extraction, announcement, game state
- **Maintainable** - Clear structure, consistent patterns, easy to extend and debug
- **Efficient** - Avoid unnecessary processing, cache where appropriate, minimize performance impact on the game

### Essential Utility Classes to Build
- **UITextExtractor** - Extract readable text from UI elements
- **ElementActivator** - Programmatically activate/click UI elements
- **ElementDetector** - Identify element types (cards, buttons, etc.)
- **AnnouncementManager** - Queue and deliver screen reader output
- **KeyboardHandler** - Central input processing with context awareness

### Code Standards
- Avoid redundancy - reuse code, don't duplicate logic
- Consistent naming conventions throughout the project
- **IMMER `decompiled/` durchsuchen vor der Implementierung** (siehe Abschnitt oben)
- Always use your utility classes instead of duplicating logic
- Handle edge cases gracefully (missing elements, unexpected states)

### Handler Architecture

**Keep your main file small.** Create separate handler classes for each screen/feature.

**Each handler should have:**
- `IsOpen()` - Static method to check if this UI is active
- `Update()` - Called every frame, tracks state changes
- `OnOpen()` / `OnClose()` - Called when UI opens/closes
- `Navigate(direction)` - Handle arrow key navigation
- `AnnounceStatus()` - Announce current state (for F-key shortcuts)

**Handler registration in main:**
```csharp
// 1. Declare field
private InventoryHandler _inventoryHandler;

// 2. Initialize
_inventoryHandler = new InventoryHandler();

// 3. Update each frame
_inventoryHandler.Update();

// 4. F-key dispatch
if (Input.GetKeyDown(KeyCode.F2))
    _inventoryHandler.AnnounceStatus();
```

**Rule of thumb:** One handler per screen/feature. Split when a handler exceeds 200-300 lines.

### Performance Tips

Mods should not slow down the game. Follow these patterns:

**Caching:** Don't search for objects every frame.
```csharp
// BAD: Searches every frame
void Update() {
    var panel = GameObject.Find("InventoryPanel"); // Slow!
}

// GOOD: Cache the reference
private GameObject _cachedPanel;
void Update() {
    if (_cachedPanel == null)
        _cachedPanel = GameObject.Find("InventoryPanel");
}
```

**Frame-Limiting:** Don't check expensive operations every frame.
```csharp
private float _lastCheck;
private const float CHECK_INTERVAL = 0.1f; // 10 times per second

void Update() {
    if (Time.time - _lastCheck < CHECK_INTERVAL)
        return;
    _lastCheck = Time.time;

    // Expensive checks here
}
```

**Note:** The examples use Unity API. For other engines, apply the same principles with equivalent APIs.

## Error Handling

### Defensive Programming

**Core rule:** Be null-safe AND log unexpected states.

```csharp
// BAD: Hides errors silently - you'll never know something is null
var text = panel?.GetComponentInChildren<Text>()?.text ?? "Unknown";

// GOOD: Null-safe AND logged
var textComp = panel?.GetComponentInChildren<Text>();
if (textComp == null)
{
    Logger.Warning("Text component not found in panel");
    ScreenReader.Say("Element not readable");
    return;
}
var text = textComp.text;
```

**For Reflection (prone to break on game updates):**
```csharp
// Catch specific exceptions, not everything
try
{
    var value = fieldInfo.GetValue(obj);
}
catch (TargetException ex)
{
    Logger.Warning($"Field access failed - game updated? {ex.Message}");
}
```

### Graceful Degradation

When something fails, don't crash - provide useful feedback:

```csharp
public void AnnounceInventory()
{
    var items = GetItems();
    if (items == null || items.Count == 0)
    {
        Announce("Inventory empty or not available");
        return;
    }
    // Continue normally
}
```

**Why both matter:**
- Without null-checks: Mod crashes on missing UI elements
- Without logging: You'll never know WHY something doesn't work

## Testing Considerations

- Test with actual screen reader software
- Verify announcements are clear and not too verbose
- Ensure keyboard navigation reaches all interactive elements
- Test with the screen off to simulate blind user experience
- Get feedback from blind users when possible

## Dos & Don'ts

### DO
- Use Tolk (or equivalent) for screen reader output
- Keep announcements short and informative
- Cache frequently used game objects
- Add a `GetHelpText()` method to handlers for F1 help
- Test with an active screen reader

### DON'T
- No long announcements that block the screen reader
- No tables or ASCII art in output
- No redundant announcements (same info repeated)
- **NEVER override game keys** - check game keybindings first!
- No expensive search operations in Update loops (cache instead!)

## Common Pitfalls

- Announcing too much information at once
- Not announcing important state changes
- Inconsistent key bindings across different screens
- Overriding keys that screen reader users expect to work normally
- Assuming visual context that isn't announced
- Not handling rapid repeated key presses gracefully

---

## Unity-Specific Reference

*This section is only relevant for Unity games.*

### UI Detection

**Typical Unity UI Hierarchy:**
```
Canvas
└── Panel (e.g., "InventoryPanel")
    ├── Header (Title)
    ├── Content
    │   └── ScrollView
    │       └── Items (List)
    └── Buttons (Actions)
```

**Important Components to Search For:**
- `Text` / `TextMeshProUGUI` - Labels and text display
- `Button` - Clickable elements
- `Toggle` - On/off switches
- `Slider` - Value adjusters
- `InputField` - Text input
- `ScrollRect` - Scrollable lists

**Checking UI State:**
```csharp
// Is panel active?
bool isOpen = panel != null && panel.activeInHierarchy;

// Is button interactable?
bool canClick = button != null && button.interactable;

// Read text safely
string text = textComponent?.text ?? "";
```

### Unity Quick Reference

**Finding GameObjects:**
```csharp
var obj = GameObject.Find("Name");  // Slow - cache result!
var all = GameObject.FindObjectsOfType<Button>();
```

**Getting Components:**
```csharp
var text = obj.GetComponent<Text>();
var text = obj.GetComponentInChildren<Text>();
var allTexts = obj.GetComponentsInChildren<Text>();
```

**Navigating Hierarchy:**
```csharp
var child = parent.transform.Find("ChildName");
foreach (Transform child in parent.transform) { }
```

**Active State:**
```csharp
bool isActive = obj.activeInHierarchy;
obj.SetActive(true);
```

**Input Handling:**
```csharp
if (Input.GetKeyDown(KeyCode.F1)) { }  // Pressed once
if (Input.GetKey(KeyCode.LeftShift)) { }  // Held down
```
