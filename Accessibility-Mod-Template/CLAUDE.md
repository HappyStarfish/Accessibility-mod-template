# Accessibility Mod Template

## User

- Blind, uses screen reader
- Programming experience: Asked during setup (Little/None or A Lot) - communicate accordingly
- User provides direction, Claude Code writes code independently and explains
- For uncertainties: Ask briefly, then act
- Screen reader-friendly output: NO tables with `|`, use lists instead

## Project Start

For greetings ("Hello", "New project", "Let's go"):
Read `docs/setup-guide.md` and conduct the setup interview.

## Environment

- **OS:** Windows (Bash/Git Bash)
- **Game directory:** [FILL IN DURING SETUP]
- **Architecture:** [32-BIT OR 64-BIT]

## Coding Rules

- **Handler classes:** `[Feature]Handler`
- **Private fields:** `_camelCase`
- **Logs/Comments:** English
- **Build:** `dotnet build [ModName].csproj`

## Coding Principles

- **Playability, not simplification** - Make game playable as sighted players play it; only suggest cheats when unavoidable
- **Modular** - Separate input handling, UI extraction, announcements, game state
- **Maintainable** - Consistent patterns, easily extensible
- **Efficient** - Cache objects, avoid unnecessary processing
- **Robust** - Use utility classes, handle edge cases, announce state changes
- **Respect game controls** - Never override game keys, handle rapid key presses

Patterns: `docs/ACCESSIBILITY_MODDING_GUIDE.md`

## Before Implementation

**ALWAYS:**
1. Search `decompiled/` for actual class/method names - NEVER guess
2. Check `docs/game-api.md` for keys, methods, patterns
3. Use only "Safe Keys for Mod" (see game-api.md → "Game Key Bindings")

## References

- `docs/setup-guide.md` - Project setup interview
- `docs/ACCESSIBILITY_MODDING_GUIDE.md` - Code patterns and architecture
- `docs/localization-guide.md` - Text and announcement localization
- `docs/menu-accessibility-checklist.md` - Menu implementation checklist
- `docs/game-api.md` - Keys, methods, documented patterns
- `templates/` - Code templates
- `scripts/` - PowerShell helper scripts
