# Advanced Screen Reader Integration Guide

This guide goes beyond basic Tolk usage. It covers the complete Tolk API, direct NVDA integration, speech priority systems, and production-tested patterns for reliable screen reader communication.

**Prerequisites:** Read `technical-reference.md` first for basic Tolk setup.

---

## Complete Tolk API (13 Functions)

The basic template uses 6 Tolk functions. Here is the full API with all 13:

```csharp
using System;
using System.Runtime.InteropServices;

// === Core lifecycle ===
[DllImport("Tolk.dll")]
private static extern void Tolk_Load();

[DllImport("Tolk.dll")]
private static extern void Tolk_Unload();

[DllImport("Tolk.dll")]
private static extern bool Tolk_IsLoaded();

// === Speech output ===
[DllImport("Tolk.dll", CharSet = CharSet.Unicode)]
private static extern bool Tolk_Output(string text, bool interrupt);
// Output to both speech AND braille. Most common function.

[DllImport("Tolk.dll", CharSet = CharSet.Unicode)]
private static extern bool Tolk_Speak(string text, bool interrupt);
// Speech only (no braille). Use when braille output is not desired.

[DllImport("Tolk.dll", CharSet = CharSet.Unicode)]
private static extern bool Tolk_Braille(string text);
// Braille only (no speech). Rarely needed.

[DllImport("Tolk.dll")]
private static extern bool Tolk_Silence();
// Stop current speech immediately.

// === Detection ===
[DllImport("Tolk.dll")]
private static extern bool Tolk_HasSpeech();

[DllImport("Tolk.dll", CharSet = CharSet.Unicode)]
private static extern bool Tolk_HasBraille();

[DllImport("Tolk.dll", CharSet = CharSet.Unicode)]
private static extern IntPtr Tolk_DetectScreenReader();
// Returns screen reader name as IntPtr. Use Marshal.PtrToStringUni() to read.

[DllImport("Tolk.dll")]
private static extern bool Tolk_IsSpeaking();
// ⚠️ BROKEN — see warning below

// === SAPI fallback ===
[DllImport("Tolk.dll")]
private static extern void Tolk_TrySAPI(bool trySAPI);
// If true, Tolk falls back to Windows SAPI when no screen reader is detected.

[DllImport("Tolk.dll")]
private static extern void Tolk_PreferSAPI(bool preferSAPI);
// If true, Tolk uses SAPI even when a screen reader is detected.
```

### Critical Bug: `Tolk_IsSpeaking()`

**`Tolk_IsSpeaking()` always returns `false` for NVDA, JAWS, System Access, Window-Eyes, and SuperNova.** Only SAPI and ZoomText return correct values.

This means you **cannot** use `Tolk_IsSpeaking()` to:
- Wait for speech to finish before speaking the next message
- Build a queue based on speech completion
- Detect if the user has heard the full announcement

**Workaround:** Use time-based estimation (see Temporal Protection below).

---

## Required DLLs

**BOTH files must be in the game folder (where the .exe is):**
- `Tolk.dll` — the screen reader bridge
- `nvdaControllerClient64.dll` (64-bit) or `nvdaControllerClient32.dll` (32-bit) — required for NVDA

Without `nvdaControllerClient*.dll`, NVDA users get **no output at all**. JAWS works via COM (no extra DLL needed).

The `nvdaControllerClient*.dll` shipped with older Tolk releases may be outdated. For advanced features (speakSsml), copy the version from your NVDA installation directory.

Download Tolk: https://github.com/ndarilek/tolk/releases

---

## NVDA Controller Client: Direct API

For NVDA users, you can bypass Tolk entirely and talk to NVDA directly. This unlocks speech priorities and SSML support.

### API Functions

```csharp
// === Core functions (all NVDA versions) ===
[DllImport("nvdaControllerClient64.dll", CharSet = CharSet.Unicode)]
private static extern int nvdaController_speakText(string text);

[DllImport("nvdaControllerClient64.dll")]
private static extern int nvdaController_cancelSpeech();

[DllImport("nvdaControllerClient64.dll", CharSet = CharSet.Unicode)]
private static extern int nvdaController_brailleMessage(string text);

[DllImport("nvdaControllerClient64.dll")]
private static extern int nvdaController_testIfRunning();

[DllImport("nvdaControllerClient64.dll")]
private static extern int nvdaController_getProcessId();

// === Advanced functions (NVDA 2024.1+ only) ===
[DllImport("nvdaControllerClient64.dll", CharSet = CharSet.Unicode)]
private static extern int nvdaController_speakSsml(
    string ssml, int symbolLevel, int priority, bool asynchronous);

// Returns 1717 (RPC_S_UNKNOWN_IF) on NVDA versions before 2024.1
```

All functions return `int`: 0 = success, non-zero = Windows error code.

### Speech Priorities (speakSsml)

```csharp
// Priority levels for nvdaController_speakSsml
private const int PriorityNormal = 0;  // Queued in order
private const int PriorityNext = 1;    // Interrupts Normal, queues after other Next
private const int PriorityNow = 2;     // Interrupts everything, resumes after
```

### Symbol Levels

```csharp
private const int SymbolNone = 0;
private const int SymbolSome = 100;
private const int SymbolMost = 200;
private const int SymbolAll = 300;
private const int SymbolChar = 1000;
private const int SymbolUnchanged = -1;  // Keep user's current setting
```

### Important Behaviors

- `speakText` fills NVDA's speech history (reviewable with NVDA+arrows). **Always prefer this.**
- `speakSsml` does **NOT** fill the speech history. Use only when you need priority control.
- `cancelSpeech` stops all current speech immediately.
- For 32-bit games, use `nvdaControllerClient32.dll` instead.

---

## Speech Priority System

### The Problem

A basic interrupt/queue system (Tolk's `bool interrupt`) is too coarse for complex mods. When multiple events happen simultaneously:
- A death announcement should interrupt everything
- A navigation update should interrupt ambient info but not critical alerts
- A proximity hint should wait for more important speech to finish

### Three-Tier Priority Model

```csharp
public enum SpeechPriority
{
    /// <summary>
    /// Lowest priority. Queued — waits for current speech.
    /// Use for: prompts, proximity alerts, menu items, telemetry, hints.
    /// </summary>
    Normal = 0,

    /// <summary>
    /// Default priority. Interrupts Normal speech.
    /// Use for: state changes, navigation, dialogue, user-triggered info.
    /// </summary>
    Next = 1,

    /// <summary>
    /// Highest priority. Interrupts everything.
    /// Use for: death, critical damage, hazard alerts, low resources.
    /// </summary>
    Now = 2
}
```

### Routing Logic

```csharp
public static void Say(string text, SpeechPriority priority = SpeechPriority.Next)
{
    if (string.IsNullOrEmpty(text)) return;
    if (!_available) return;

    // Deduplicate
    if (IsDuplicate(text)) return;

    if (_useNvdaDirect)
        SayViaNvda(text, priority);
    else
        SayViaTolk(text, priority);
}

private static void SayViaTolk(string text, SpeechPriority priority)
{
    // Tolk only supports interrupt (bool), so map priorities:
    // Now → interrupt + silence first
    // Next → interrupt
    // Normal → queue (no interrupt)

    if (priority == SpeechPriority.Now)
    {
        Tolk_Silence();
        Tolk_Output(text, true);
    }
    else if (priority == SpeechPriority.Next)
    {
        Tolk_Output(text, true);
    }
    else // Normal
    {
        Tolk_Output(text, false);
    }
}

private static void SayViaNvda(string text, SpeechPriority priority)
{
    switch (priority)
    {
        case SpeechPriority.Now:
            // Use speakSsml for Now priority (interrupts + resumes)
            string ssml = "<speak>" + EscapeXml(text) + "</speak>";
            nvdaController_speakSsml(ssml, SymbolUnchanged, PriorityNow, true);
            ResetNormalProtection();
            break;

        case SpeechPriority.Next:
            if (IsNormalProtected())
            {
                // Normal speech still playing — don't cancel, just queue
                _lastNormalSentAt = 0; // consume protection
            }
            else
            {
                nvdaController_cancelSpeech();
            }
            nvdaController_speakText(text);
            break;

        case SpeechPriority.Normal:
            StartNormalProtection(text);
            nvdaController_speakText(text);
            break;
    }
}
```

---

## Temporal Protection

### The Problem

When Normal priority speech is playing and Next priority arrives, we want to:
1. Let Normal finish if it's almost done
2. Interrupt if Normal has been playing long enough

But `Tolk_IsSpeaking()` is broken for NVDA, so we can't check.

### Solution: Time-Based Estimation

```csharp
private static int _lastNormalSentAt;
private static int _lastNormalProtectionMs;

private const int MsPerChar = 80;      // Conservative: 80ms per character
private const int BufferMs = 300;       // Extra buffer for screen reader latency
private const int MaxProtectionMs = 5000; // Never protect for more than 5 seconds

private static void StartNormalProtection(string text)
{
    _lastNormalSentAt = Environment.TickCount;
    _lastNormalProtectionMs = Math.Min(
        text.Length * MsPerChar + BufferMs,
        MaxProtectionMs);
}

private static bool IsNormalProtected()
{
    if (_lastNormalSentAt == 0) return false;
    int elapsed = Math.Abs(Environment.TickCount - _lastNormalSentAt);
    return elapsed < _lastNormalProtectionMs;
}

private static void ResetNormalProtection()
{
    _lastNormalSentAt = 0;
}
```

**How it works:**
- When Normal speech is sent, record timestamp + estimated duration
- When Next arrives during the protection window: skip `cancelSpeech()`, just queue via `speakText()`
- When Next arrives after the window: cancel normally
- When Now arrives: reset protection entirely (Now always wins)
- If the reader speaks faster than estimated, `speakText` will play immediately (empty queue)

---

## Hybrid Architecture: Tolk + NVDA Direct

### Detection at Startup

```csharp
private static bool _isNvda;
private static bool _useNvdaDirect;
private static bool _nvdaHasSsml;

public static void Initialize()
{
    try
    {
        Tolk_Load();
        _available = Tolk_IsLoaded() && Tolk_HasSpeech();

        if (!_available) return;

        // Detect which screen reader
        IntPtr srNamePtr = Tolk_DetectScreenReader();
        string srName = srNamePtr != IntPtr.Zero
            ? Marshal.PtrToStringUni(srNamePtr)
            : "Unknown";

        _isNvda = srName != null
            && srName.IndexOf("NVDA", StringComparison.OrdinalIgnoreCase) >= 0;

        if (_isNvda)
        {
            // Probe speakSsml support (requires NVDA 2024.1+)
            try
            {
                int probe = nvdaController_speakSsml(
                    "<speak></speak>", SymbolUnchanged, PriorityNormal, true);
                _nvdaHasSsml = (probe != 1717); // 1717 = RPC_S_UNKNOWN_IF
            }
            catch { _nvdaHasSsml = false; }

            _useNvdaDirect = true;
        }
    }
    catch (DllNotFoundException)
    {
        // Tolk.dll not found
        _available = false;
    }
    catch (Exception ex)
    {
        // Other initialization errors
        _available = false;
    }
}
```

### Runtime Toggle

Allow users to disable NVDA direct mode if it causes issues:

```csharp
public static bool NvdaDirectEnabled
{
    get => _useNvdaDirect;
    set => _useNvdaDirect = _isNvda && value;
}
```

---

## Deduplication

Prevent the same text from being announced twice within a short window:

```csharp
private static string _lastText;
private static int _lastSayTick;
private const int DedupMs = 250;

private static bool IsDuplicate(string text)
{
    int now = Environment.TickCount;
    if (text == _lastText && Math.Abs(now - _lastSayTick) < DedupMs)
        return true;

    _lastText = text;
    _lastSayTick = now;
    return false;
}
```

**Why 250ms?** Fast enough to catch accidental duplicates from multiple handlers firing the same frame, slow enough to allow intentional repeats.

---

## XML Escaping for SSML

When using `speakSsml`, text must be valid XML:

```csharp
private static string EscapeXml(string text)
{
    return text
        .Replace("&", "&amp;")
        .Replace("<", "&lt;")
        .Replace(">", "&gt;")
        .Replace("\"", "&quot;");
}

// Usage:
string ssml = "<speak>" + EscapeXml(playerText) + "</speak>";
nvdaController_speakSsml(ssml, SymbolUnchanged, PriorityNow, true);
```

**Always escape user-facing text.** Game strings may contain `&`, `<`, or `>`.

---

## Force Speak (Bypass Deduplication)

For critical announcements that must always be spoken, even if identical to the last:

```csharp
public static void SayForce(string text, SpeechPriority priority = SpeechPriority.Now)
{
    if (string.IsNullOrEmpty(text)) return;
    if (!_available) return;

    // Reset dedup state
    _lastText = null;
    _lastSayTick = 0;

    Say(text, priority);
}
```

Use for: mod enabled/disabled confirmation, repeated status queries, critical alerts.

---

## Repeat Last Announcement

Let users hear the last announcement again:

```csharp
private static string _lastAnnouncedText;

public static void RepeatLast()
{
    if (!string.IsNullOrEmpty(_lastAnnouncedText))
        SayForce(_lastAnnouncedText, SpeechPriority.Next);
}

// In Say(), after dedup check:
_lastAnnouncedText = text;
```

Bind to a key (e.g., Insert or Delete) for quick access.

---

## Graceful Shutdown

```csharp
public static void Shutdown()
{
    if (!_initialized) return;

    try { Tolk_Unload(); } catch { }

    _initialized = false;
    _available = false;
}
```

Always wrap `Tolk_Unload()` in try-catch. Never crash on shutdown.

---

## Quick Reference: When to Use What

- **Simple mod, any screen reader:** Tolk only (`Tolk_Output` with interrupt bool)
- **Complex mod, any screen reader:** Tolk with 3-tier priority mapping (Now→Silence+interrupt, Next→interrupt, Normal→queue)
- **NVDA-heavy audience:** Hybrid Tolk + NVDA direct for full priority support
- **Deduplication:** Always. 250ms window prevents spam from Update loops
- **Temporal protection:** Only needed with NVDA direct (when using speakText priorities)
- **Force speak:** For toggling features on/off, repeating last, critical alerts
