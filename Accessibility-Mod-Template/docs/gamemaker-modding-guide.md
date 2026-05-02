# GameMaker Modding Guide for Accessibility

A comprehensive guide to adding screen reader accessibility to GameMaker games. This guide is based on proven experience — every pattern here has been tested in a real project.

---

## 1. Overview — How GameMaker Modding Differs from Unity

GameMaker modding is fundamentally different from Unity modding:

- **No mod loader.** There is no MelonLoader or BepInEx equivalent. Instead, you modify the game's `data.win` file directly using UndertaleModTool (UTMT).
- **No C#.** Game logic is written in GML (GameMaker Language). Your patch script is C# (a .csx Roslyn script), but the code it injects is GML.
- **No runtime injection.** Changes are baked into `data.win` at patch time, not injected at runtime. The patched game runs exactly like the original — it doesn't know it was modified.
- **No Harmony.** Instead of hooking methods at runtime, you append or replace GML code in specific code entries (object events, scripts).
- **No DLL references.** GameMaker uses an extension system to call external DLLs. You register functions with specific signatures (return double, accept double/string).
- **The TolkWrapper problem.** GameMaker passes `char*` (UTF-8) to DLL functions, but Tolk expects `wchar_t*` (UTF-16). You need a small C wrapper DLL to bridge this gap. See section 3.

### What stays the same

- The accessibility philosophy: play as sighted players do, no cheats
- Modular approach: separate concerns (menus, dialogue, status)
- Screen reader output via Tolk
- Localization awareness from day one
- Backup strategy: always keep the original data.win

---

## 2. Toolchain

### UndertaleModTool (UTMT)

The primary tool for GameMaker modding. Available in two forms:

- **UTMT GUI** — Visual editor for data.win. Useful for browsing objects, code entries, strings, and sprites. Not accessible with a screen reader for most operations.
- **UTMT CLI** (`UTMT_CLI.exe`) — Command-line interface. Runs .csx scripts against data.win. This is what you use for automated patching.

**Installation:**

```
# Via winget (recommended)
winget install krzys-h.UndertaleModTool

# Or download from GitHub releases:
# https://github.com/UnderminersTeam/UndertaleModTool/releases
```

**CLI usage:**

```
# Apply a patch script and save the result
UTMT_CLI.exe load data.win -s accessibility_patch.csx -o data_patched.win

# Export all GML code (for analysis)
UTMT_CLI.exe load data.win -s Scripts/Resource Exporters/ExportAllCode.csx

# Export all strings (for text analysis)
UTMT_CLI.exe load data.win -s Scripts/Resource Exporters/ExportAllStrings.csx
```

### data.win

The single file containing all game data: code, sprites, sounds, strings, objects, rooms, everything. GameMaker compiles the entire project into this one file.

- Location: game's root directory (next to the .exe)
- **Always back up before patching.** A bad patch can corrupt the file.
- Some games use `game.unx` (Linux) or `game.ios` (iOS) instead.

### Zig (for compiling TolkWrapper)

Zig includes a C compiler (`zig cc`) that can easily cross-compile for 32-bit or 64-bit Windows without needing Visual Studio.

```
winget install zig.zig
```

---

## 3. The TolkWrapper Problem

### Why you can't call Tolk directly from GameMaker

GameMaker's DLL extension system has a limitation: string parameters are passed as `char*` (UTF-8 encoded). Tolk's API expects `wchar_t*` (UTF-16 encoded). If you register Tolk's functions directly as GameMaker extensions, non-ASCII characters (Chinese, Japanese, accented letters, Cyrillic, etc.) will corrupt or crash the game.

This is a GameMaker-specific problem. Unity mods don't have it because C# strings are natively UTF-16.

### The solution: TolkWrapper.dll

A small C DLL that:
1. Receives `char*` strings from GameMaker
2. Converts them to `wchar_t*` using `MultiByteToWideChar(CP_UTF8, ...)`
3. Forwards the call to Tolk
4. Returns the result as a `double` (GameMaker's only numeric type)

See `templates/gamemaker/TolkWrapper.c.template` for the complete source code.

### Compiling TolkWrapper

**With Zig (recommended — no Visual Studio needed):**

```
# 32-bit game (check options.ini → Usex64=False, or PE32 exe)
zig cc -target x86-windows -shared -o TolkWrapper.dll TolkWrapper.c

# 64-bit game (check options.ini → Usex64=True, or PE32+ exe)
zig cc -target x86_64-windows -shared -o TolkWrapper.dll TolkWrapper.c
```

**With MSVC (Visual Studio Developer Command Prompt):**

```
cl /LD /Fe:TolkWrapper.dll TolkWrapper.c
```

Tolk.dll is loaded dynamically via `LoadLibrary`/`GetProcAddress` at runtime, so you do NOT need Tolk's import library at compile time.

### Required DLLs in the game directory

All of these must be in the same directory as the game's .exe:

- `TolkWrapper.dll` — your compiled wrapper
- `Tolk.dll` — the screen reader bridge library
- `nvdaControllerClient32.dll` or `nvdaControllerClient64.dll` — required for NVDA (match game architecture)

Without the nvdaControllerClient DLL, NVDA users get no output. JAWS works via COM (no extra DLL needed).

---

## 4. Patch Script Patterns

The .csx patch script is a C# Roslyn script that UTMT executes against the loaded data.win. It uses the UndertaleModLib API to modify game data.

### Required imports

```csharp
using System;
using System.Linq;
using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Compiler;

EnsureDataLoaded();
```

### Extension registration

To call TolkWrapper functions from GML, you must register them as a GameMaker extension:

```csharp
var ext = new UndertaleExtension()
{
    Name = Data.Strings.MakeString("TolkWrapper"),
    FolderName = Data.Strings.MakeString(""),
    ClassName = Data.Strings.MakeString("")
};

var extFile = new UndertaleExtensionFile()
{
    Filename = Data.Strings.MakeString("TolkWrapper.dll"),
    CleanupScript = Data.Strings.MakeString(""),
    InitScript = Data.Strings.MakeString(""),
    Kind = UndertaleExtensionKind.Dll
};

uint nextId = Data.ExtensionFindLastId();

// tw_load() → Double, no args
extFile.Functions.DefineExtensionFunction(Data.Functions, Data.Strings,
    nextId++, 1, "tw_load", UndertaleExtensionVarType.Double, "tw_load");

// tw_output(string, double) → Double
extFile.Functions.DefineExtensionFunction(Data.Functions, Data.Strings,
    nextId++, 1, "tw_output", UndertaleExtensionVarType.Double, "tw_output",
    UndertaleExtensionVarType.String, UndertaleExtensionVarType.Double);

// tw_speak(string, double) → Double
extFile.Functions.DefineExtensionFunction(Data.Functions, Data.Strings,
    nextId++, 1, "tw_speak", UndertaleExtensionVarType.Double, "tw_speak",
    UndertaleExtensionVarType.String, UndertaleExtensionVarType.Double);

// tw_silence() → Double, no args
extFile.Functions.DefineExtensionFunction(Data.Functions, Data.Strings,
    nextId++, 1, "tw_silence", UndertaleExtensionVarType.Double, "tw_silence");

ext.Files.Add(extFile);
Data.Extensions.Add(ext);
```

Key points:
- `ExtensionFindLastId()` returns the next safe ID — never hardcode IDs
- `DefineExtensionFunction` params: (Functions, Strings, id, kind=1 for DLL, gmlName, returnType, externalName, ...argTypes)
- GameMaker only supports `Double` and `String` as extension arg/return types

### CodeImportGroup — QueueAppend vs QueueFindReplace

`CodeImportGroup` batches GML code modifications and applies them all at once with `Import()`.

**QueueAppend (recommended):**

Adds GML code to the END of an existing code entry. Safe and reliable — it always works as long as the code entry name is correct.

```csharp
var importGroup = new CodeImportGroup(Data);

importGroup.QueueAppend("gml_Object_obj_SETUP_Create_0", @"
tw_load();
global.a11y_enabled = 1;
");

importGroup.Import();  // Apply all queued changes
```

**QueueFindReplace (use with caution):**

Replaces a specific string within a code entry. Useful when you need to inject code at a precise location (e.g., right after a variable is set). But it's fragile:

- The match string must EXACTLY match the decompiled GML output, including whitespace
- Different UTMT versions may decompile the same bytecode differently
- If the match fails, it fails **silently** — no error, no warning, your code just isn't injected
- Roslyn-based execution (GUI patcher) may produce different decompiled output than CLI

```csharp
importGroup.QueueFindReplace("gml_GlobalScript_some_function",
    @"show_debug_message(text);",
    @"show_debug_message(text);
if (global.a11y_enabled) {
    tw_output(text, 0);
}");
```

**Rule of thumb:** Use QueueAppend whenever possible. Only use QueueFindReplace when you absolutely need code injected at a specific point in the middle of a function.

### GML string escaping in C#

Inside `@"..."` C# verbatim strings, GML strings need doubled quotes:

```csharp
importGroup.QueueAppend("gml_Object_obj_init_Create_0", @"
global.a11y_last_text = """";          // GML: global.a11y_last_text = ""
var _msg = ""Hello, world!"";          // GML: var _msg = "Hello, world!"
");
```

---

## 5. GML Accessibility Patterns

### The a11y_enabled guard

Always wrap accessibility code in a check so users can disable it:

```gml
if (global.a11y_enabled) {
    tw_output("Menu item: " + _item_text, 1);
}
```

### Safe global check with variable_global_exists

If your code might run before the init block (e.g., in a room that loads before the setup object), use `variable_global_exists`:

```gml
if (variable_global_exists("a11y_enabled") && global.a11y_enabled) {
    tw_output(_text, 1);
}
```

### Duplicate prevention

Prevent the same text from being announced repeatedly (e.g., every frame in a Step event):

```gml
if (global.a11y_enabled) {
    var _text = menu_items[menu_index];
    if (_text != global.a11y_last_text) {
        global.a11y_last_text = _text;
        tw_output(_text, 1);
    }
}
```

### tw_output vs tw_speak

- `tw_output(text, interrupt)` — sends to both speech AND braille display. Use this by default.
- `tw_speak(text, interrupt)` — speech only, no braille. Use for transient/rapid announcements where braille would be distracting.
- `interrupt` parameter: `1` = interrupt current speech, `0` = queue after current speech.

### Menu navigation pattern

```gml
// In the menu object's Step event (appended via QueueAppend)
if (global.a11y_enabled) {
    // Detect when selection changes
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)) {
        var _item = menu_items[menu_index];
        var _pos = string(menu_index + 1) + " of " + string(array_length(menu_items));
        tw_output(_item + ", " + _pos, 1);
    }
    // Announce on confirm
    if (keyboard_check_pressed(vk_enter)) {
        tw_output("Selected: " + menu_items[menu_index], 1);
    }
}
```

### Dialogue hooking pattern

```gml
// Appended to the dialogue display function or object
if (global.a11y_enabled) {
    var _text = [current dialogue text variable];
    if (_text != "" && _text != global.a11y_last_text) {
        global.a11y_last_text = _text;
        // Include speaker name if available
        var _announce = _text;
        if ([speaker_name variable] != "") {
            _announce = [speaker_name] + ": " + _text;
        }
        tw_output(_announce, 0);
    }
}
```

### Stripping markup from text

Many GameMaker games use markup tags in text (e.g., `[color=red]`, `[shake]`). Strip these before announcing:

```gml
var _clean = _text;
var _bp = string_pos("[", _clean);
while (_bp > 0) {
    var _ep = string_pos("]", _clean);
    if (_ep > _bp) {
        _clean = string_delete(_clean, _bp, _ep - _bp + 1);
    } else {
        break;
    }
    _bp = string_pos("[", _clean);
}
tw_output(_clean, 1);
```

### Localization

If the game supports multiple languages, build announcement strings using the game's own localization system rather than hardcoding English:

```gml
// If the game uses a language variable like global.lang
// Look up text from the game's own string tables
var _label = [game's localization lookup for "Health"];
tw_output(_label + ": " + string(hp), 1);
```

---

## 6. Code Export & Analysis

### Exporting GML code

Use UTMT's built-in export scripts to dump all GML code to text files:

```
UTMT_CLI.exe load data.win -s "Scripts/Resource Exporters/ExportAllCode.csx"
```

This creates one `.gml` file per code entry in a `CodeEntries/` directory. Code entry names follow the pattern:

- `gml_Object_[objectName]_[eventType]_[subtype]` — object events
- `gml_GlobalScript_[scriptName]` — script functions
- `gml_Script_[scriptName]` — script functions (older format)
- `gml_RoomCC_[roomName]_[instanceId]_[eventType]` — room creation code

### Exporting strings

```
UTMT_CLI.exe load data.win -s "Scripts/Resource Exporters/ExportAllStrings.csx"
```

Useful for finding all text in the game — menu labels, dialogue, UI strings. Search the output for keywords to find which code entries use specific text.

### Analysis workflow

1. Export all code and strings
2. Search code entries for key patterns:
   - `keyboard_check` / `keyboard_check_pressed` — input handling, key bindings
   - `menu` / `cursor` / `sel` / `index` — menu navigation
   - `draw_text` / `draw_set_font` — text display
   - `room_goto` — room transitions
   - `global.` — global state variables
   - `ds_grid` / `ds_list` / `ds_map` — data structures
3. Identify the init/setup object (runs first, initializes globals)
4. Identify menu objects and their navigation variables
5. Identify dialogue/text display systems
6. Document everything in `docs/game-api.md`

### Finding objects and events

Object events map to code entries by name:

- Create event → `gml_Object_[name]_Create_0`
- Step event → `gml_Object_[name]_Step_0`
- Draw event → `gml_Object_[name]_Draw_0`
- Key Press → `gml_Object_[name]_KeyPress_[keycode]`
- Alarm → `gml_Object_[name]_Alarm_[number]`
- Other events → `gml_Object_[name]_Other_[subtype]`

---

## 7. Applying Patches

### UTMT CLI workflow

```
# 1. Back up the original
copy data.win data.win.backup

# 2. Apply the patch
UTMT_CLI.exe load data.win -s accessibility_patch.csx -o data.win

# 3. Test the game
# Launch the game normally — the patched data.win is used automatically
```

**Important:** The `-o` flag specifies the output file. You can overwrite the original (`-o data.win`) or save to a new file (`-o data_patched.win`). For development, overwriting is convenient. For distribution, keep the original untouched.

### Backup strategy

- Always keep `data.win.backup` (the unmodified original)
- Before each patch attempt during development, restore from backup first
- Include backup/restore instructions in your release README

### Path issues

- **Paths with special characters** (`!`, `#`, `&`, spaces) can break UTMT CLI, especially when run from Git Bash where `!` triggers history expansion
- **Workaround:** Copy data.win to a clean path (e.g., `C:\modwork\data.win`) for development
- Use PowerShell or cmd instead of Git Bash for UTMT CLI commands

---

## 8. Optional: GUI Patcher

For end-user distribution, you can build a standalone GUI patcher that applies the .csx script without requiring users to install UTMT.

### Recommended: UTMT CLI subprocess

The patcher is a thin GUI shell (WinForms/console) that calls `UndertaleModCli.exe` as a subprocess. This is the proven-working approach — the CLI handles all data.win loading, script execution, and saving.

How it works:
1. Back up data.win (pure file copy)
2. Launch: `UndertaleModCli.exe load <data.win> -s <script.csx> -o <data.win>`
3. Stream stdout/stderr to the UI in real-time
4. Check exit code: 0 = success, non-zero = error
5. Copy support files (Tolk DLLs, etc.) to the game directory

Benefits:
- Zero heavy dependencies — no Roslyn, no UndertaleModLib reference needed
- Script behavior is identical to CLI (no decompilation differences)
- `PublishSingleFile` and `PublishTrimmed` work fine
- QueueFindReplace works reliably (no Roslyn context mismatch)

Distribution layout:
```
patcher.exe                    (small app, can be single-file)
accessibility_patch.csx        (patch script)
support DLLs                   (Tolk, screen reader bridges, etc.)
utmt\                          (UTMT CLI distribution)
  UndertaleModCli.exe
  UndertaleModLib.dll
  ... (all CLI files)
```

### Not recommended: Roslyn in-process execution

An older approach loads data.win via UndertaleModLib and executes the .csx script via Roslyn scripting, all in-process. This has several known issues:

- **QueueFindReplace silently fails.** The decompiled GML output can differ between UTMT CLI and Roslyn-hosted execution, causing match strings to not match. Patches appear to succeed but code is not injected.
- **PublishSingleFile breaks Roslyn metadata.** Roslyn needs assembly metadata on disk. SingleFile packaging embeds assemblies, making them invisible to Roslyn.
- **PublishTrimmed breaks UndertaleModLib.** UndertaleModLib uses reflection heavily. The trimmer removes code it considers unused.
- **Underanalyzer assembly resolution.** UndertaleModLib loads Underanalyzer at runtime, requiring manual assembly resolution.

If you must use Roslyn (e.g., offline-only requirement with no CLI), set these in your .csproj:
```xml
<PublishTrimmed>false</PublishTrimmed>
<PublishSingleFile>false</PublishSingleFile>
<SelfContained>true</SelfContained>
```

---

## 9. Distribution

### Release package structure

```
GameName-A11Y-v1.0.0.zip
├── TolkWrapper.dll              (compiled wrapper)
├── Tolk.dll                     (screen reader bridge)
├── nvdaControllerClient32.dll   (or 64-bit version)
├── accessibility_patch.csx      (the patch script)
├── data.win.backup              (NOT included — user makes their own)
├── README.txt                   (installation instructions)
└── LICENSE.txt                  (your license)
```

**Optional additions:**
- `patcher.exe` + dependencies — GUI patcher for one-click patching
- Additional screen reader DLLs for regional screen readers (e.g., Chinese screen readers)
- `evidence_details.json` or other data files the patch references

### End-user README template

```
[ModName] - Accessibility Patch for [GameName]
Version: 1.0.0
Author: [Your Name]

WHAT THIS PATCH DOES
====================
Makes [GameName] playable with a screen reader (NVDA, JAWS).
- Screen reader announcements for menus, dialogue, and game events
- Keyboard navigation where needed
- [List key features]

REQUIREMENTS
============
- [GameName] (Steam version tested, others may work)
- UndertaleModTool CLI (https://github.com/UndertaleMod/UndertaleModTool/releases)
  OR use the included patcher (if provided)
- A screen reader (NVDA recommended, JAWS also works)

INSTALLATION
============
1. Back up your data.win file (in the game folder)!
   Copy data.win to data.win.backup
2. Copy ALL DLL files from this ZIP into your game folder:
   - TolkWrapper.dll, Tolk.dll, nvdaControllerClient32.dll
3. Apply the patch (pick one method):
   a) UTMT CLI: UTMT_CLI.exe load data.win -s accessibility_patch.csx -o data.win
   b) Patcher: Run patcher.exe and select your game folder
4. Launch the game — you should hear the screen reader announce the first screen

TO UNINSTALL
============
Copy data.win.backup back to data.win (overwrite the patched version).

CONTROLS
========
F1 - Help (lists all accessibility key bindings)
[List your key bindings here]

TROUBLESHOOTING
===============
- No speech: Check that TolkWrapper.dll, Tolk.dll, and nvdaControllerClient DLL
  are all in the game folder
- Patch fails: Make sure you're using the original data.win, not an already-patched one
- Wrong architecture: If game is 64-bit, use nvdaControllerClient64.dll instead
```

### No mod loader needed

Unlike Unity mods, GameMaker accessibility patches don't require users to install a mod loader. The patch modifies data.win directly. This makes installation simpler for end users — just copy DLLs and apply the patch.

---

## 10. Common Pitfalls — Lessons Learned

### QueueFindReplace silent failure

`QueueFindReplace` does not throw an error if the match string isn't found. Your patch will appear to succeed, but the code won't be injected. Always verify patched code by exporting after patching, or add `ScriptMessage()` calls to confirm each step.

### Extension function IDs

Never hardcode extension function IDs. Always use `Data.ExtensionFindLastId()` to get the next available ID. IDs vary between data.win files and even between UTMT versions.

### GML variable scope

Variables declared with `var` in GML are local to the current scope. Global variables must use `global.` prefix. If you append code to an event, your `var` declarations won't conflict with the original code, but `global.` variables are shared.

### Architecture mismatch

The TolkWrapper DLL, Tolk.dll, and nvdaControllerClient DLL must ALL match the game's architecture (32-bit or 64-bit). A 32-bit game cannot load 64-bit DLLs and vice versa. Check the game's `options.ini` for `Usex64=True/False`.

### data.win corruption

If a patch fails partway through (e.g., a code entry name is wrong), the output file may be corrupted. Always patch from a clean backup, never from an already-patched file.

### Decompiler differences

UTMT's GML decompiler output can vary between versions. If you upgrade UTMT, your QueueFindReplace match strings may stop working. This is another reason to prefer QueueAppend.

### VM vs YYC

GameMaker games can be compiled in VM mode (bytecode, decompilable) or YYC mode (native C++, not decompilable). UTMT only works with VM-mode games. If the game directory has no `data.win`, it may be YYC-compiled and not moddable with this approach.

### Testing workflow

1. Restore data.win from backup
2. Apply patch
3. Launch game, test the feature
4. If it doesn't work, check the exported code to verify your changes were applied
5. Iterate

### Handling game updates

When the game updates, the developer ships a new data.win. Your patch must be re-applied to the new file. If the game's code changed, your QueueFindReplace strings may need updating. QueueAppend is more resilient to game updates since it doesn't depend on exact code matching.

---

## References

- `templates/gamemaker/` — GameMaker-specific templates
- `templates/gamemaker/TolkWrapper.c.template` — TolkWrapper source code
- `templates/gamemaker/accessibility_patch.csx.template` — Skeleton patch script
- `templates/gamemaker/game-api.md.template` — Game API documentation template
- `templates/gamemaker/project_status.md.template` — Project tracking template
- `docs/known-issues.md` — Known issues including GameMaker + UTMT section
- `docs/distribution-guide.md` — Packaging and publishing (includes GameMaker section)
- UndertaleModTool: https://github.com/UnderminersTeam/UndertaleModTool
- Tolk: https://github.com/ndarilek/tolk
