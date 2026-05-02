MENU ACCESSIBILITY PATTERNS
===========================

Detailed patterns for implementing menu accessibility.
Use alongside: `menu-accessibility-checklist.md`


MENU ITEM TYPES
===============

Different UI controls require different handling:

Button
------
- Activation: Trigger click/activate method
- Announcement: Just the label
- Example: "New Game"

Slider
------
- Activation: Left/Right to decrease/increase
- Announcement: Label + "Slider" + current value + hint
- Example: "Master Volume, Slider, 75 percent, left right to adjust"
- Increment: Use game's increment value, or ~5-10% of range

Toggle / Checkbox
-----------------
- Activation: Enter/Space to flip state
- Announcement: Label + "Checkbox" + state
- Example: "Enable Tutorials, Checkbox, checked"
- After toggle: Announce new state ("checked" / "unchecked")

Dropdown / Selection
--------------------
- Activation: Left/Right to cycle through options
- Announcement: Label + "Dropdown" + current selection
- Example: "Language, Dropdown, English"
- After change: Announce new selection

Tab
---
- Activation: Enter to select tab, then navigate tab content
- Announcement: Label + "Tab"
- Example: "Audio, Tab"
- Use Backspace to go back from content to tab list


LABEL RESOLUTION
================

When UI elements lack readable labels, use this fallback hierarchy:

1. Game's Localization System
   - If text starts with localization marker (e.g., `%`, `#`, `@`)
   - Pass through game's localizer/translator

2. Parent Component
   - Check parent's Title, Label, or Text property
   - Often the wrapper has the label, not the control itself

3. Tooltip Text
   - Extract readable text from tooltip
   - May need parsing (e.g., "Category:Key" format)

4. Known Name Mapping
   - Map common internal names to readable labels:
     - "SelectAll" -> "Select All"
     - "EndTurn" -> "End Turn"
     - "BtnOK" -> "OK"
   - Store in a dictionary, keep it localized

5. Clean GameObject Name
   - Remove prefixes/suffixes (btn_, _button, etc.)
   - Add spaces before capitals (NewGame -> New Game)
   - Last resort, may not be localized

Example (Unity/C#):
```csharp
private string ResolveLabel(GameObject obj)
{
    // 1. Check localization component
    var locText = obj.GetComponent<LocalizedText>();
    if (locText != null && !string.IsNullOrEmpty(locText.Key))
        return Localizer.Get(locText.Key);

    // 2. Check parent's title
    var parent = obj.GetComponentInParent<OptionBase>();
    if (parent != null && !string.IsNullOrEmpty(parent.Title))
        return parent.Title;

    // 3. Check tooltip
    var tooltip = obj.GetComponent<TooltipTrigger>();
    if (tooltip != null)
        return ExtractTooltipLabel(tooltip);

    // 4. Known name mapping
    if (KnownNames.TryGetValue(obj.name, out string label))
        return label;

    // 5. Clean name
    return CleanGameObjectName(obj.name);
}
```


ITEM COLLECTION
===============

What to Collect
---------------
- Buttons with actual click handlers (not decorative)
- Sliders with value change handlers
- Toggles/Checkboxes with state change handlers
- Dropdowns with selection handlers
- Tab buttons

What to Skip
------------
- Controls without activation/change handlers
- Controls with Visible = false or inactive GameObjects
- Controls where parent panel is hidden
- Internal containers (names containing "Area", "Panel", "Container", "Group")
- Purely decorative elements (backgrounds, separators)

Sorting
-------
Sort collected items by visual position for intuitive navigation:

1. Priority items first (if defined)
   - e.g., "New Game" before "Exit"

2. Then by Y position (top to bottom)
   - Higher Y values first (Unity) or lower Y first (depends on coordinate system)

3. For horizontal layouts (tabs): by X position (left to right)

Example:
```csharp
items.Sort((a, b) =>
{
    // Priority items first
    int prioA = GetPriority(a);
    int prioB = GetPriority(b);
    if (prioA != prioB) return prioB - prioA;

    // Then by Y position (top to bottom)
    return (int)(b.Position.y - a.Position.y);
});
```


NAVIGATION PATTERNS
===================

Wraparound
----------
When reaching the end of a list, wrap to the beginning (and vice versa).
Announce "First item" or "Last item" when wrapping occurs.

```csharp
private void Navigate(int direction)
{
    int newIndex = _currentIndex + direction;

    if (newIndex < 0)
    {
        newIndex = _items.Count - 1;
        ScreenReader.Say(Loc.Get("LastItem")); // "Last item"
    }
    else if (newIndex >= _items.Count)
    {
        newIndex = 0;
        ScreenReader.Say(Loc.Get("FirstItem")); // "First item"
    }

    _currentIndex = newIndex;
    AnnounceCurrentItem();
}
```

Key Capture
-----------
Ensure navigation keys don't fall through to the game:

```csharp
// Unity example with Harmony
[HarmonyPatch(typeof(InputManager), "Update")]
class InputPatch
{
    static bool Prefix()
    {
        if (MenuHandler.Instance.IsActive && MenuHandler.Instance.HandleInput())
            return false; // Block game input
        return true; // Let game handle it
    }
}
```

Two-Level Navigation (Tabs)
---------------------------
For tabbed menus, maintain navigation state:

```csharp
enum NavigationLevel { Tabs, Content }
private NavigationLevel _level = NavigationLevel.Tabs;

private void HandleInput()
{
    if (_level == NavigationLevel.Tabs)
    {
        // Up/Down navigates tabs
        // Enter selects tab and switches to Content level
    }
    else // Content
    {
        // Up/Down navigates content items
        // Backspace returns to Tabs level
    }
}
```


SPECIAL CASES
=============

Modal Dialogs
-------------
Modal dialogs (popups, confirmations) take priority:
- Detect when modal opens (check game's modal manager)
- Collect items from modal only, ignore background
- When modal closes, refresh items from parent screen
- Announce modal opening ("Confirmation dialog")

Dynamic Content
---------------
When content changes while menu is open:
- Detect changes via polling or event hooks
- Refresh item collection
- Try to preserve selection if item still exists
- If current item removed, select nearest valid item

Empty States
------------
When a menu/list has no items:
- Announce "No items available" or context-specific message
- Don't leave user in silence
- Still allow closing/back navigation


ANNOUNCEMENT TIMING
===================

When to Announce
----------------
- Screen/menu opened: Screen name
- Navigation: Current item (with type and value for non-buttons)
- Activation: Result ("Enabled", "Changed to English", "75 percent")
- Wraparound: "First item" / "Last item"
- Empty state: "No items available"
- Errors: "Cannot activate" (if relevant)

Speech Interruption
-------------------
New announcements should interrupt previous ones:
```csharp
ScreenReader.Stop();  // Interrupt
ScreenReader.Say(text);
```

Queued Information
------------------
For additional info after main announcement, use a short delay:
```csharp
ScreenReader.Say(mainText);
// Queue hint after brief pause
StartCoroutine(SayDelayed(hintText, 0.5f));
```


DEBUGGING
=========

Use a separate debug mode, NOT logging in the main code.

Toggle with a key (e.g., F12):
- Log input events
- Log screen/modal changes
- Log collected items with their labels
- Output to separate log file

Example:
```csharp
public static class MenuDebug
{
    public static bool Enabled { get; private set; }
    private static string _logPath;

    public static void Toggle()
    {
        Enabled = !Enabled;
        ScreenReader.Say(Enabled ? "Debug mode on" : "Debug mode off");
    }

    public static void Log(string message)
    {
        if (!Enabled) return;
        File.AppendAllText(_logPath, $"[{DateTime.Now:HH:mm:ss}] {message}\n");
    }
}

// Usage in MenuHandler:
MenuDebug.Log($"Collected {items.Count} items");
MenuDebug.Log($"Current item: {_items[_currentIndex].Label}");
```


RELATED DOCUMENTATION
=====================
- `menu-accessibility-checklist.md` - Quick checklist before implementation
- `state-management-guide.md` - Handler architecture, multiple handlers
- `ACCESSIBILITY_MODDING_GUIDE.md` - General accessibility patterns
- `unity-reflection-guide.md` - Accessing private fields for UI inspection
