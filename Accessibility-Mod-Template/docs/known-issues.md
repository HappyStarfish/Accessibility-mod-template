# Known Issues & Compatibility Warnings

This file is checked automatically during project setup (Step 4). When the game's engine, Unity version, or mod loader is identified, Claude scans this list and warns the user about any matching issues.

**How to add entries:** Add a new item under the matching category. Include the affected version/component, a short description, and a workaround if one exists.

---

## Unity + MelonLoader

- **Unity 6000.2.2f1**: MelonLoader fails to start. Throws null-reference errors during loader initialization. No workaround known — use BepInEx instead, or wait for a MelonLoader update.
- **Unity 2022.3.62f2**: Crash beim Start während IL2CPP-Initialisierung. BepInEx 6 Bleeding Edge crasht ebenfalls. Kein Fix bekannt. ([GitHub Issue #1063](https://github.com/LavaGang/MelonLoader/issues/1063))
- **Unity 2022.3.58**: UnityDependencies-Download schlägt fehl. **Fix:** MelonLoader auf die neueste Version aktualisieren — die fehlende Version wurde im Dependency-Repo nachgetragen. ([GitHub Issue #936](https://github.com/LavaGang/MelonLoader/issues/936))
- **Unity 5.x**: MelonLoader generally does not support Unity 5. Use BepInEx 5.x instead. See `docs/legacy-unity-modding.md`.
- **Unity 4.x and older**: Neither MelonLoader nor BepInEx work. Only assembly patching is possible. See `docs/legacy-unity-modding.md`.

## Unity + BepInEx

- **Unity 6000+**: BepInEx 5.x does not support Unity 6. BepInEx 6 (bleeding edge) may work but is not stable. Check the BepInEx GitHub for the latest status before proceeding.

## Engine-Specific Issues

### GameMaker + UndertaleModTool

- **QueueFindReplace silent failure:** `QueueFindReplace` does not throw an error when the match string is not found. The patch appears to succeed but the code is not injected. This is especially problematic when the decompiled GML output differs between UTMT versions or between CLI and Roslyn-hosted execution. **Workaround:** Prefer `QueueAppend` wherever possible. When `QueueFindReplace` is necessary, verify the patched output by re-exporting the code after patching.
- **Roslyn in-process patcher causes silent patch failures:** Building a GUI patcher that loads data.win and runs .csx scripts via Roslyn in-process can cause QueueFindReplace to silently fail — the patcher reports success but patches are not applied. This is because Roslyn's script host produces slightly different decompilation behavior than UTMT CLI's native script host. **Fix:** Use UTMT CLI as a subprocess instead of Roslyn. See `docs/gamemaker-modding-guide.md` section 8.
- **PublishTrimmed breaks UndertaleModLib:** Only relevant if using the Roslyn in-process approach (not recommended). UndertaleModLib uses reflection heavily, and the trimmer removes code it considers unused. **Fix:** Set `<PublishTrimmed>false</PublishTrimmed>`, or switch to the CLI subprocess approach.
- **PublishSingleFile breaks Roslyn metadata loading:** Only relevant if using the Roslyn in-process approach (not recommended). SingleFile packaging embeds assemblies inside the exe, making them invisible to Roslyn's metadata resolver. **Fix:** Set `<PublishSingleFile>false</PublishSingleFile>`, or switch to the CLI subprocess approach.
- **Special characters in paths break UTMT CLI:** Paths containing `!`, `#`, `&`, or other special characters can cause UTMT CLI to fail, especially when run from Git Bash (where `!` triggers history expansion). **Workaround:** Copy data.win to a clean path (e.g., `C:\modwork\`) for development. Use PowerShell or cmd instead of Git Bash.
- **char\* encoding limitation:** GameMaker's DLL extension system passes strings as `char*` (UTF-8), but Tolk expects `wchar_t*` (UTF-16). Calling Tolk directly corrupts non-ASCII characters. **Fix:** Use TolkWrapper.dll as a bridge (see `templates/gamemaker/TolkWrapper.c.template` and `docs/gamemaker-modding-guide.md`).
- **YYC-compiled games not moddable:** Games compiled with GameMaker's YYC (native C++) compiler have no `data.win` file and cannot be modded with UTMT. Only VM-mode games are supported.

## Game-Specific Issues

_(Add entries here when a specific game has known modding hurdles that aren't covered by the categories above.)_

---

## How Claude Uses This File

During setup (Step 4), after detecting the engine and version:

1. Read this file
2. Check if any entry matches the detected configuration
3. If a match is found: warn the user immediately, explain the issue, and suggest the documented workaround
4. Log the warning in `project_status.md` so it's not forgotten
