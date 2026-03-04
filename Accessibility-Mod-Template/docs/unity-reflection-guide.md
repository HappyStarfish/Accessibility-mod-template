# Unity Reflection Guide for Modding

This guide describes patterns and best practices for accessing private fields in Unity games via Reflection - a central topic in accessibility mod development.

## The Problem

Unity developers frequently use this pattern:

```csharp
[SerializeField]
private TextMeshProUGUI title;
```

**Why do developers do this?**
- The field is visible and editable in the Unity Editor
- The field remains private in code (good encapsulation)
- Prevents accidental access from other classes

**Why is this problematic for mods?**
- No public getter available
- Data can only be read via Reflection
- UI paths (transform.Find) often DON'T work, since the field is directly attached to the Component

## Commonly Affected Areas

### UI Components (most frequent)

Almost all UI classes have important data in private fields:
- Title/description text fields
- Button references
- Icon/sprite references
- Active/selected state

Look for patterns like:
- `private TextMeshProUGUI title`
- `private Text m_Label`
- `private Button m_Button`
- `private Image icon`

### Manager Classes

Singleton managers often have private state:
- `m_CurrentlyOpen` - currently open overlay/menu
- `m_IsGamepadInUse` - input mode
- `m_CurrentDialogue` - active dialog

### Game Logic

Game objects often hide their state:
- Current phase/state enums
- Internal collections (lists of items, units, etc.)
- Cached references

## Naming Conventions

Most Unity projects follow one of two patterns:

1. **m_PascalCase** (more common in older projects):
   - m_ActiveTab
   - m_CurrentlyOpen
   - m_IsGamepadInUse

2. **camelCase** (more common in newer projects):
   - title
   - description
   - button

**Tip:** When decompiling, always check both variants!

## The Solution: ReflectionHelper

Create a central helper class (see `templates/shared/ReflectionHelper.cs.template`):

```csharp
// Read a class field (e.g., TextMeshProUGUI)
var tmp = ReflectionHelper.GetPrivateField<TextMeshProUGUI>(component, "title");
string text = tmp?.text;

// Read a value type (e.g., int, bool, enum)
int tabIndex = ReflectionHelper.GetPrivateFieldValue<int>(controller, "m_ActiveTab", 0);

// Shortcut for text fields
string title = ReflectionHelper.GetTextFromPrivateField(uiCard, "title");

// Set a field
ReflectionHelper.SetPrivateField(manager, "m_IsGamepadInUse", true);
```

## Best Practices

### 1. Always check decompiled code first

**Wrong:** Assuming data is accessible via UI paths
```csharp
// Often DOESN'T work!
var title = transform.Find("Card/Title")?.GetComponent<TextMeshProUGUI>();
```

**Right:** First look at the class in decompiled code
```csharp
// From decompiled/SomeUIClass.cs:
// [SerializeField] private TextMeshProUGUI title;

var title = ReflectionHelper.GetTextFromPrivateField(uiComponent, "title");
```

### 2. Cache Reflection when possible

For frequent access, cache FieldInfo:

```csharp
// Once during init
private FieldInfo _activeTabField;

public void Initialize()
{
    _activeTabField = typeof(UITabController).GetField(
        "m_ActiveTab",
        BindingFlags.NonPublic | BindingFlags.Instance);
}

// Then fast access
int tab = (int)_activeTabField.GetValue(controller);
```

### 3. Fallback strategies

Sometimes field names change between game versions:

```csharp
string title = ReflectionHelper.GetTextFromPrivateField(card, "title");
if (string.IsNullOrEmpty(title))
{
    title = ReflectionHelper.GetTextFromPrivateField(card, "m_Title");
}
if (string.IsNullOrEmpty(title))
{
    // UI path as last fallback
    title = card.transform.Find("Title")?.GetComponent<TextMeshProUGUI>()?.text;
}
```

### 4. Error handling

Reflection can fail - always handle errors:

```csharp
try
{
    var field = obj.GetType().GetField(fieldName, BindingFlags.NonPublic | BindingFlags.Instance);
    return field?.GetValue(obj) as T;
}
catch (Exception ex)
{
    DebugLog.Warn("Context", $"Reflection failed: {ex.Message}");
    return null;
}
```

## Checklist for New Handlers

When creating a new handler:

1. Identify the relevant game classes
2. Open the decompiled .cs files
3. Search for `[SerializeField] private` fields
4. Note the field names (m_Name or camelCase?)
5. Use ReflectionHelper instead of transform.Find()
6. Test with different game states

## Harmony Patches as Alternative

Sometimes a Harmony patch is better than Reflection:

```csharp
[HarmonyPatch(typeof(SomeUIClass), "Init")]
public static class SomeUIClassPatch
{
    public static void Postfix(SomeUIClass __instance, ItemData item)
    {
        // Here we have direct access to the item parameter
        string title = item.GetTitle();
    }
}
```

**Advantages:**
- No Reflection needed
- Access to method parameters
- Called automatically

**Disadvantages:**
- More complex to debug
- Can conflict with other mods
- Some methods are hard to patch (virtual/override)

## When to Use Which Approach

**Use ReflectionHelper for:**
- One-time access to private data
- Reading UI text that doesn't change often
- Accessing manager state

**Use cached FieldInfo for:**
- Frequently accessed fields (every frame)
- Performance-critical code

**Use Harmony Postfix for:**
- Intercepting data when a method is called
- When you need method parameters
- Reacting to game events

**Use SetPrivateField for:**
- Forcing game state (e.g., gamepad mode)
- Testing/debugging
- Rare cases where you need to modify internal state

## Document Your Findings

In `docs/game-api.md`, create a section for UI access patterns:

```markdown
## UI Text Access

### MenuButton
- Field: `title` (camelCase)
- Type: TextMeshProUGUI
- Access: `ReflectionHelper.GetTextFromPrivateField(button, "title")`

### InventorySlot
- Field: `m_ItemName` (m_PascalCase)
- Type: Text
- Access: `ReflectionHelper.GetTextFromPrivateField(slot, "m_ItemName")`
```

This documentation saves time when implementing new features - you don't need to re-analyze each UI class.

## References

- `templates/shared/ReflectionHelper.cs.template` - Template for the helper class
- `decompiled/` - Decompiled game code for reference
- `docs/ACCESSIBILITY_MODDING_GUIDE.md` - General modding patterns
