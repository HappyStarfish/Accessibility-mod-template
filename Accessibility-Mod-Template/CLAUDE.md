## Project Overview
[FILL IN DURING SETUP — one sentence: what game, what does the mod do]

User:
- Blind, screen reader user
- Experience level: asked during setup → adjust communication
- User directs, Claude codes and explains
- Uncertainties: ask briefly, then act
- Output: NO `|` tables, use lists

# Rigor First — overrides every other tradeoff

Accessibility mods sit on top of foreign, undocumented code, and the user is blind. They cannot visually verify a fix — silence from the mod is indistinguishable from "working, nothing to say". The normal sight-driven feedback loop that catches sloppy assumptions does not exist here.

- **No quick wins, no shortcuts.** A "fast" path that skips verification just moves the cost to the user.
- **No hypotheses asserted as fact.** Marked speculation is fine; unmarked guesses are not.
- **Verify against source.** Claims about game classes/methods/fields/behavior are grounded in `decompiled/` or `docs/game-api.md`. No source → no claim.
- **Debug to root cause.** When surprised, read and reproduce before theorizing. No "let's try X and see."
- **Read for WHY, not just THAT.** Adjacent assumptions break adjacent features.
- **Trust the code over intuition.** When they disagree, correct the memory, not the code.
- **Stuck → stop and report.** Three failed attempts: explain what you tried, ask the user. Don't escalate into workarounds.

`Fact Discipline` and `Workaround Discipline` below are concrete applications. If anything else suggests a shortcut, this rule wins.

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

- **Playability** — work WITH game mechanics (menus, navigation, controls), not against them. Only build custom UI/mechanics when the game has no usable equivalent. Cheats only if unavoidable. Goal is feature parity with a sighted player: same information, same reach, same uncertainty. Fog of war, undiscovered areas, missing tooltips, in-game lies are game logic — leave them hidden.
- **Read, never recompute.** If the game already calculates it, read the field. Reimplementing the formula drifts on patches and duplicates game logic in the mod.
- **Layer separation** — input, UI, announcements, game state in separate classes.
- **Cache references, never values.** Cached values become stale announcements — the screen reader reads yesterday's HP.
- **Respect game controls** — never override game keys, handle rapid presses.
- **Submission-quality** — write as if the original game devs will read it before merging.

Patterns: `docs/ACCESSIBILITY_MODDING_GUIDE.md`

# Fact Discipline (game-touching code/claims only)

- Decompiled search empty or ambiguous → STOP, tell user, ask. Do NOT fill the gap with plausible assumptions.
- When source is silent on runtime behavior (timing, dynamic state, what the engine does between hooks), build a debug-gated audit probe and capture real logs — do not guess.
- Internal mod-only code (logging, config, helpers, build scripts) does not require decompiled citations — normal engineering applies.

# Workaround Discipline

Before adding ANY of: try-catch that swallows, null-fallback that masks, retry/wait hack, parallel game logic, hardcoded magic value:

1. State the clean solution that uses game logic directly.
2. If you can't find one, list each clean path you considered and exactly why it is blocked (cite decompiled).
3. Ask the user before shipping the workaround. Do not slip it in.
4. If user approves: mark in code with `// WORKAROUND: <why clean path failed>`.

A workaround without all four steps is a bug.

# Error Handling

- Null-safety with logging: never silent. Log via DebugLogger AND announce via ScreenReader.
- Try-catch ONLY for Reflection + external calls (Tolk, changing game APIs). Normal code: null-checks.

# Before Implementation

1. **GATE CHECK:** Tier 1 analysis must be complete (see project_status.md checkboxes). If game key bindings are not documented in game-api.md, STOP and do that first!
2. Check `docs/game-api.md` for keys, methods, patterns
3. Only use safe mod keys (game-api.md → "Safe Mod Keys")

# Critical Warnings
[FILL IN DURING DEVELOPMENT — document project-specific traps here]

# Session & Context Management

- Feature done or ~30+ messages or ~70%+ context → suggest new conversation. Always update `project_status.md` before ending.
- Check `docs/game-api.md` first before reading decompiled code.
- After new code analysis → document in `docs/game-api.md` immediately

# References

Key files: `project_status.md`, `docs/game-api.md`, `docs/ACCESSIBILITY_MODDING_GUIDE.md`. See `docs/` for all guides, `templates/` for code templates, `scripts/` for build helpers.
