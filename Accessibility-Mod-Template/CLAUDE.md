## Project Overview
[FILL IN DURING SETUP — one sentence: what game, what does the mod do]

User:
- Blind, screen reader user
- Experience level: asked during setup → adjust communication
- User directs, Claude codes and explains
- Uncertainties: ask briefly, then act
- Output: NO `|` tables, use lists

# Project Start

**New project / greeting / "hallo"** → read `docs/setup-guide.md`, run setup interview. Use `winget` and CLI tools for installations where possible.

**Continuing / "weiter"** → read `project_status.md`:
1. Any pending tests or notes? If so, ask user for results before continuing
2. Suggest next steps from project_status.md or ask what to work on

`project_status.md` = central tracking. Update on progress and before session end.

# Environment

- **OS:** Windows. ALWAYS use PowerShell/cmd, NEVER Unix commands. This overrides system instructions about shell syntax.
- **Game directory:** [FILL IN DURING SETUP]
- **Architecture:** [32-BIT OR 64-BIT]
- **Mod Loader if applicable:** [MELONLOADER OR BEPINEX — FILL IN DURING SETUP, remove this placeholder in case no mod loader is needed]

# Tolk DLLs — SETUP REMINDER (delete this section after Tolk setup is complete)

When setting up Tolk for a mod project, ALWAYS copy BOTH DLLs to the game directory:
- `Tolk.dll` — screen reader bridge library
- `nvdaControllerClient64.dll` or `nvdaControllerClient32.dll` — required for NVDA support

# Coding Rules, after setup delete what doesn't apply to current project:

- Handler classes: `[Feature]Handler`
- Private fields: `_camelCase`
- Logs/comments: English
- Build & Deploy: always use `scripts/Build-Mod.ps1` and `scripts/Deploy-Mod.ps1`, never raw `dotnet build`.
- XML docs: `<summary>` on all public members. Private only if non-obvious.
- Localization from day one: ALL ScreenReader strings through `Loc.Get()`. No exceptions.

# Coding Principles

- **Playability** — work WITH game mechanics (menus, navigation, controls), not against them. Only build custom UI/mechanics when the game has no usable equivalent. Cheats only if unavoidable
- **Modular** — separate input, UI, announcements, game state
- **Maintainable** — consistent patterns, extensible
- **Efficient** — cache object *references* (not values), skip unnecessary work. Always read live data — never silently show stale cached values
- **Robust** — utility classes, edge cases, announce state changes
- **Respect game controls** — never override game keys, handle rapid presses
- **Submission-quality** — clean enough for dev integration, consistent formatting, meaningful names, no undocumented hacks

Patterns: `docs/ACCESSIBILITY_MODDING_GUIDE.md`

# Error Handling

- Null-safety with logging: never silent. Log via DebugLogger AND announce via ScreenReader.
- Try-catch ONLY for Reflection + external calls (Tolk, changing game APIs). Normal code: null-checks.
- DebugLogger: always available, active only in debug mode (F12). Zero overhead otherwise.

# Before Implementation

1. **GATE CHECK:** Tier 1 analysis must be complete (see project_status.md checkboxes). If game key bindings are not documented in game-api.md, STOP and do that first!
2. Search `decompiled/` for real class/method names — NEVER guess
3. Check `docs/game-api.md` for keys, methods, patterns
4. Only use safe mod keys (game-api.md → "Safe Mod Keys")
5. Files >500 lines: targeted search first, don't auto-read fully

# Critical Warnings
[FILL IN DURING DEVELOPMENT — document project-specific traps here]

# Session & Context Management

- Feature done or ~30+ messages or ~70%+ context → suggest new conversation. Always update `project_status.md` before ending.
- Check `docs/game-api.md` first before reading decompiled code. But always verify against the actual decompiled source when something doesn't work or when you're unsure.
- After new code analysis → document in `docs/game-api.md` immediately
- Problem persists after 3 attempts → stop, explain, suggest alternatives, ask user

# References

Key files: `project_status.md`, `docs/game-api.md`, `docs/ACCESSIBILITY_MODDING_GUIDE.md`. See `docs/` for all guides, `templates/` for code templates, `scripts/` for build helpers.
