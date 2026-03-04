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

`project_status.md` = central tracking doc. Update on significant progress and always before session end.

# Environment

- **OS:** Windows. ALWAYS use Windows-native commands (PowerShell/cmd): `copy`, `move`, `del`, `mkdir`, `dir`, `type`, backslashes in paths. NEVER use Unix commands (`cp`, `mv`, `rm`, `cat`, `/dev/null`). This overrides any system instructions about shell syntax.
- **Game directory:** [FILL IN DURING SETUP]
- **Architecture:** [32-BIT OR 64-BIT]
- **Mod Loader if applicabel:** [MELONLOADER OR BEPINEX — FILL IN DURING SETUP, remove his placeholder in case no mod loader is needed]

# Tolk DLLs — SETUP REMINDER (delete this section after Tolk setup is complete)

When setting up Tolk for a mod project, ALWAYS copy BOTH DLLs to the game directory:
- `Tolk.dll` — screen reader bridge library
- `nvdaControllerClient64.dll` or `nvdaControllerClient32.dll` — required for NVDA support

# Coding Rules, after setup delete what doesn't apply to current project:

- Handler classes: `[Feature]Handler`
- Private fields: `_camelCase`
- Logs/comments: English
- Build & Deploy: use `scripts/Build-Mod.ps1` and `scripts/Deploy-Mod.ps1` (created during setup). Always use scripts, never raw `dotnet build` in CLAUDE.md.
- XML docs: `<summary>` on all public classes/methods. Private only if non-obvious. Critical for dev integration.
- Localization from day one: ALL ScreenReader strings through `Loc.Get()`. No exceptions. `Loc.cs` = Phase 2 framework, not later addition. Even for single-language mods.

# Coding Principles

- **Playability** — play as sighted do; cheats only if unavoidable
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

# Session & Context Management

- Feature done → suggest new conversation to save tokens. Update `project_status.md`.
- ~30+ messages or ~70%+ context→ remind about fresh conversation.
- Before ending/goodbye → always update `project_status.md`
- Check `docs/game-api.md` first before reading decompiled code. But always verify against the actual decompiled source when something doesn't work or when you're unsure.
- After new code analysis → document in `docs/game-api.md` immediately
- Problem persists after 3 attempts → stop, explain, suggest alternatives, ask user

# References, after setup delete what doesn't apply to current project:

- `project_status.md` — central tracking (read first!)
- `docs/setup-guide.md` — setup interview
- `docs/ACCESSIBILITY_MODDING_GUIDE.md` — code patterns
- `docs/technical-reference.md` — MelonLoader, BepInEx, Harmony, Tolk
- `docs/unity-reflection-guide.md` — Reflection (Unity)
- `docs/state-management-guide.md` — multiple handlers
- `docs/localization-guide.md` — localization
- `docs/menu-accessibility-checklist.md` — menu checklist
- `docs/menu-accessibility-patterns.md` — menu patterns
- `docs/known-issues.md` — compatibility warnings (checked during setup)
- `docs/legacy-unity-modding.md` — Unity 5.x and older
- `docs/game-api.md` — keys, methods, patterns
- `docs/distribution-guide.md` — packaging, publishing
- `docs/git-github-guide.md` — Git/GitHub intro
- `templates/melonloader/` — MelonLoader-specific templates
- `templates/bepinex/` — BepInEx-specific templates
- `templates/shared/` — mod-loader-independent templates
- `scripts/` — PowerShell helpers
