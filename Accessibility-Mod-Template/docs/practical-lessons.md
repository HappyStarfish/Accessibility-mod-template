# Practical Lessons for Accessibility Mod Development

These lessons come from production accessibility mods tested by blind players. They cover mistakes that compile fine but cause real problems. Every item here was discovered the hard way — through broken builds, confused testers, or silent failures that took hours to diagnose.

---

## 1. Screen Reader Mistakes

### Tolk_IsSpeaking() Is Broken

`Tolk_IsSpeaking()` returns `false` for NVDA, JAWS, System Access, Window-Eyes, and SuperNova. It only works with SAPI and ZoomText. This means the vast majority of blind users will never get correct results from this function.

Never use it for logic (e.g., waiting for speech to finish before sending the next message). Use time-based estimation instead: estimate duration from text length (e.g., `charCount * 80ms + 300ms`, capped at 5 seconds), then track elapsed time.

### Missing DLL Handling

Always wrap `Tolk_Load()` in a try-catch for `DllNotFoundException`. If the DLL is missing, set an `_available` flag to `false` and continue without speech. Never crash because a screen reader DLL is missing — the mod should still function, just silently.

```csharp
try
{
    Tolk_Load();
    _available = true;
}
catch (DllNotFoundException)
{
    _available = false;
    // Continue without speech — mod still works
}
```

### SSML Without XML Escaping

Game text may contain `&`, `<`, or `>` characters. These break SSML parsing silently — the screen reader receives malformed XML and says nothing. Always escape text before embedding it in `<speak>` tags:

```csharp
string safe = text
    .Replace("&", "&amp;")
    .Replace("<", "&lt;")
    .Replace(">", "&gt;")
    .Replace("\"", "&quot;")
    .Replace("'", "&apos;");
string ssml = $"<speak>{safe}</speak>";
```

### Announcement Spam

Multiple handlers firing the same information produces duplicate announcements. A player entering a zone might hear "Entered cave, Entered cave, Entered cave" because three systems all detected the same event.

Solution: implement a 250ms deduplication window. Store the last announced text and timestamp. If the same text is requested within the window, skip it. Also use appropriate priorities — Normal for ambient info, Next for interactions, Now only for emergencies.

### speakSsml Doesn't Fill Speech History

NVDA users can review recent speech output with NVDA+arrow keys. Messages sent via `speakSsml` do NOT appear in this history. This means a player who missed an announcement cannot review it.

Use `speakText` for everything except Now-priority emergency messages (damage warnings, death). For Now-priority: use `speakSsml` with `priority=2` for the interrupt-and-resume behavior, but accept that it won't be in history.

---

## 2. Harmony Patching Mistakes

### Parameter Names Must Match

Harmony 2.x matches prefix/postfix parameters by NAME, not just by type. If the original method has a parameter called `int damage`, your prefix must also name it `damage`. A mismatch produces an "IL Compile Error" at runtime with no helpful message — just a stack trace pointing at the patch application.

```csharp
// Original method: void TakeDamage(int damage, bool ignoreArmor)

// WRONG — compiles but crashes at runtime
static void Prefix(int amount, bool ignore) { }

// CORRECT — parameter names match the original
static void Prefix(int damage, bool ignoreArmor) { }
```

### typeof() In Attributes Loads Too Early

`[HarmonyPatch(typeof(GameClass))]` evaluates at assembly load time. If `GameClass` hasn't been loaded by the game yet, the mod crashes before any of your code runs. This is common with classes that only exist in certain scenes.

Solution: don't use `typeof()` in attributes. Apply patches manually when you know the target class is loaded (e.g., in a scene load callback):

```csharp
void OnSceneLoaded()
{
    var targetMethod = AccessTools.Method("Namespace.GameClass:MethodName");
    var prefix = new HarmonyMethod(typeof(MyPatch), nameof(MyPatch.Prefix));
    harmony.Patch(targetMethod, prefix: prefix);
}
```

### Overloaded Methods

The `[HarmonyPatch]` attribute cannot distinguish between overloaded methods (same name, different parameters). It picks one arbitrarily, and it's usually the wrong one.

Solution: use manual patching with explicit parameter types:

```csharp
var method = AccessTools.Method(
    typeof(TargetClass),
    "MethodName",
    new Type[] { typeof(int), typeof(bool) }  // specify exact overload
);
harmony.Patch(method, prefix: myPrefix);
```

### Private Method Patching

Some methods are private and won't be found by the `[HarmonyPatch]` attribute. The attribute silently does nothing — no error, no patch, just missing functionality.

Solution: use reflection to get the `MethodInfo`, then call `harmony.Patch()` manually:

```csharp
var method = AccessTools.Method(typeof(TargetClass), "PrivateMethodName");
if (method != null)
{
    harmony.Patch(method, postfix: new HarmonyMethod(typeof(MyPatch), nameof(Postfix)));
}
else
{
    Logger.Log("WARNING: PrivateMethodName not found — API may have changed");
}
```

---

## 3. Caching Mistakes

### Caching Values Instead of References

A blind player trusts what the screen reader says. If you cache a health value and return it when the live read fails, the player hears "Health: 80%" while they're actually at 20%. They have no way to notice the discrepancy.

- BAD: cache a health value and return it when live read fails
- GOOD: cache the reference to the health component, always read the value live

When a live read fails: log it, announce "not available", return null. Never return stale data as if it were current.

```csharp
// BAD — stale data with no indication
private float _cachedHealth;
public float GetHealth() => _healthComponent?.currentHealth ?? _cachedHealth;

// GOOD — fail visibly
private HealthComponent _healthRef;
public float? GetHealth()
{
    if (_healthRef == null) return null;  // caller handles "not available"
    return _healthRef.currentHealth;      // always live
}
```

### Stale Cache After State Changes

A handler deactivates (player enters a menu, changes scene, etc.) but cached data remains. When the handler reactivates, old data is announced before fresh data arrives. The player hears information from 5 minutes ago.

Solution: clear all cached data on deactivate. Force a full refresh on reactivate. Never assume cached data is still valid after any state transition.

### Using Wrong Cache Key

In any caching system with composite keys, every part of the key must match between store and retrieve operations. For example, in 3D pathfinding with a grid cache, the key must include a height bucket — not just (x, z). If you store with one height bucket and retrieve with another, you get `KeyNotFoundException` or return data for a completely different location.

Always ensure the key you use to STORE matches the key you use to RETRIEVE. When in doubt, add a unit test that stores and retrieves with the same parameters.

---

## 4. Audio Guidance Mistakes

### Audio Source At Player Position

If the AudioSource is positioned at the player, the sound is mono — it comes from everywhere equally. A blind player gets no directional information from it.

Solution: position the AudioSource toward the target. For example, place it 10 meters ahead in the direction of the target. Use `spatialBlend = 1.0f` for full 3D spatialization:

```csharp
Vector3 direction = (target.position - player.position).normalized;
audioSource.transform.position = player.position + direction * 10f;
audioSource.spatialBlend = 1.0f;  // fully 3D
```

### Pitch vs Yaw Alignment

Players walk by turning left and right (yaw), not by looking up and down (pitch). If your alignment calculation includes the vertical component, the beep cadence changes when the player looks up at a target on a cliff — even though they're walking in the right direction.

Project out the vertical component before computing the dot product:

```csharp
Vector3 toTarget = target.position - player.position;
toTarget.y = 0;  // remove vertical component
Vector3 playerForward = player.forward;
playerForward.y = 0;
float alignment = Vector3.Dot(toTarget.normalized, playerForward.normalized);
```

### Camera vs Body Position

Many games separate the camera (eyes) from the body (feet). Using the wrong one produces incorrect results:

- Use **camera position** for angle/direction calculations (that's where the player "looks from")
- Use **body position** for distance calculations (that's where the player physically is)

Getting this wrong produces subtle bugs: angles that are slightly off, distances that are wrong by the player's height, or pitch calculations that point at the ground instead of at the target.

---

## 5. Movement and Input Mistakes

### Injecting Movement In Wrong Coordinate Space

Many games use body-relative movement: `transform.TransformDirection(Vector3.forward)` uses the body's facing direction, not the camera's. If you inject forward movement, it goes where the body faces, not where the camera looks.

Before injecting any movement, understand the game's movement system:

- Does movement follow the body or the camera?
- Is movement absolute (world space) or relative (local space)?
- Does the game separate walk input from look input?

Get this wrong and the player walks sideways, or into walls, or in the opposite direction from where they think they're going.

### Jump Injection Requires Multiple Frames

Many games check jump input over several frames for charge mechanics (hold to jump higher). A single-frame jump injection may not register at all, or may produce a minimal jump that doesn't clear obstacles.

Solution: inject jump input for 3-4 frames minimum. If the game has charge-based jumping, you may need to inject for the full charge duration:

```csharp
private int _jumpFramesRemaining = 0;

public void TriggerJump()
{
    _jumpFramesRemaining = 4;  // inject for 4 frames
}

void Update()
{
    if (_jumpFramesRemaining > 0)
    {
        InjectJumpInput();
        _jumpFramesRemaining--;
    }
}
```

### Not Respecting Game Input Blocking

Games often block input during cutscenes, menus, dialogue, or scene transitions. If your mod injects movement without checking for input blocking, the player walks during cutscenes or triggers actions at wrong times.

Always check if input is currently blocked before injecting any movement or action. Look for methods like `IsInputBlocked()`, `IsInMenu()`, `IsInCutscene()`, or equivalent flags in the game's input system.

---

## 6. General Development Lessons

### Never Crash -- Always Fallback

Every external dependency can fail. Plan for it:

- Screen reader unavailable: continue without speech, set a flag
- Pathfinding finds no path: announce "no path found", stop auto-walk
- Target destroyed mid-navigation: clear target, announce, stop guidance
- Reflection target missing (API changed): log warning, disable that feature

Every external call — Tolk, NVDA Controller Client, reflection on game internals — should be wrapped so that failure is handled gracefully. A crash means the player loses all mod functionality. A fallback means they lose one feature.

### Problem Persists After 3 Attempts -- Stop

If something doesn't work after 3 tries, don't brute-force it. This applies everywhere:

- Pathfinding rescans: 4 failed rescans = stop auto-walk, announce "path blocked"
- Connection retries: 3 failures = disable feature, log error
- Reflection lookups: if the field isn't there after checking alternatives, the API changed

Step back, explain the problem, try a different approach. Brute-forcing a broken path just wastes the player's time while they hear "recalculating... recalculating... recalculating..."

### Test With Screen Off

The best test for an accessibility mod: turn off your monitor and try to play. Can you complete a task using only audio and screen reader output?

Check for these problems:

- Is there enough information to know what's happening?
- Is there too much information (announcement overload)?
- Are announcements clear and unambiguous?
- Can you navigate without seeing the screen?
- Do you know when something goes wrong?

If you can't complete a task with the screen off, neither can a blind player.

### Log Everything In Debug Mode

Create a debug mode toggle (e.g., F12 key). When enabled, log:

- All screen reader announcements (with priority level)
- State changes (handler activated/deactivated, target changed)
- Pathfinding results (path found/not found, node count, time)
- Input injections (jump triggered, movement started/stopped)
- Errors and fallbacks (reflection failed, DLL missing)

Ensure zero overhead when disabled — check the debug flag before doing any string formatting or concatenation:

```csharp
// GOOD — no overhead when disabled
if (DebugMode)
    Logger.Log($"Path found: {nodeCount} nodes in {elapsed}ms");

// BAD — string formatting happens even when disabled
Logger.LogIfDebug($"Path found: {nodeCount} nodes in {elapsed}ms");
```

This is essential for diagnosing issues reported by users who can't send you a screenshot.
