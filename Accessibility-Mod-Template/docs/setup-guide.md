# Setup Guide for New Accessibility Mod Projects

This guide is only needed for the initial project setup.

---

## Setup Interview

When the user first interacts with Claude in this directory (e.g., "Hello", "New project", "Let's go"), conduct this interview.

**Ask these questions ONE AT A TIME. Wait for the answer after EACH question.**

### Step 1: Experience Level

Question: How much experience do you have with programming and modding? (Little/None or A Lot)

- Remember the answer for the rest of the interview
- If "Little/None": Explain concepts contextually in the following steps (see "For Beginners" notes)
- If "A Lot": Brief, technical communication without detailed explanations

### Step 2: Game Name

Question: What is the name of the game you want to make accessible?

### Step 3: Installation Path

Question: Where is the game installed? (e.g., `C:\Program Files (x86)\Steam\steamapps\common\GameName`)

### Step 4: Offer Automatic Check

After the game path is known, offer:

Question: Should I automatically check the game directory? I can detect: Game engine, architecture (32/64-bit), whether MelonLoader is installed, and if yes, read the log information.

**If yes:**

Perform these checks and collect the results:

1. **Detect game engine:**
   - Check if `UnityPlayer.dll` exists → Unity game
   - Check if `[GameName]_Data\Managed` directory exists → Unity game
   - Check for `.pak` files or `UnrealEngine`/`UE4` in filenames → Unreal Engine
   - If not Unity: Issue warning that MelonLoader only works with Unity

2. **Detect architecture:**
   - `MonoBleedingEdge` directory present → 64-bit
   - `Mono` directory (without "BleedingEdge") → 32-bit
   - Files with "x64" in name → 64-bit

3. **MelonLoader status:**
   - Check if `MelonLoader` directory exists
   - If yes: Check if `MelonLoader\Latest.log` exists

4. **Read MelonLoader log (if present):**
   - Extract Game Name and Developer
   - Extract Runtime Type (e.g. net35 or net6)
   - Extract Unity Version

5. **Check Tolk DLLs:**
   - For 64-bit: Check if `Tolk.dll` and `nvdaControllerClient64.dll` are in game directory
   - For 32-bit: Check if `Tolk.dll` and `nvdaControllerClient32.dll` are in game directory

**Summarize results:**

Show a summary of what was detected:
- Game engine: Unity (or other)
- Architecture: 64-bit / 32-bit
- MelonLoader: Installed / Not installed
- If MelonLoader installed: Game Name, Developer, Runtime Type from log
- Tolk DLLs: Present / Missing

Question: Is this correct? (Wait for confirmation)

**Only explain what's missing:**

After confirmation, list ONLY the missing/problematic points with concrete instructions:

- If not a Unity game: Explain that MelonLoader only works with Unity, alternative research needed
- If MelonLoader is missing: Provide installation instructions (see below)
- If Tolk DLLs are missing: Provide download instructions (see below)
- If MelonLoader log is missing: Ask user to start the game once

Skip everything that is already present!

**If no (manual check preferred):**

Continue with manual steps 4a-4c.

---

### Manual Steps (only if automatic check was declined)

#### Step 4a: Game Engine (manual)

Question: Do you know which game engine the game uses?

- Hints for identifying Unity: `UnityPlayer.dll` in game directory or a `[GameName]_Data\Managed` directory
- Hints for Unreal Engine: `UnrealEngine` or `UE4` in filenames, `.pak` files
- If unclear: User can look in game directory or you help with identification

**If NOT a Unity game:**

- MelonLoader ONLY works with Unity games
- Research alternative mod loaders depending on engine (e.g., BepInEx for some Unity versions, Unreal Mod Loader for UE)
- Further process may differ - adapt instructions accordingly
- For beginners: Explain that different games use different "engines", and each engine needs different tools for modding

#### Step 4b: Architecture (manual)

Question: Do you know if the game is 32-bit or 64-bit?

Hints for finding out:
- `MonoBleedingEdge` directory = usually 64-bit
- `Mono` directory = usually 32-bit
- Files with "x64" in name = 64-bit

**IMPORTANT:** The architecture determines which Tolk DLLs are needed!

#### Step 4c: MelonLoader (manual)

Question: Is MelonLoader already installed?

If no, explain:
- Download: https://github.com/LavaGang/MelonLoader.Installer/releases
- After installation there should be a `MelonLoader` directory in the game directory
- Start game once to create directory structure

For beginners: MelonLoader is a "mod loader" - a program that loads our mod code into the game. It also comes with "Harmony", a library for hooking into game functions. We don't need to download Harmony separately.

---

### Step 5: Tolk (if reported as missing during automatic check)

If Tolk DLLs are missing, explain:
- Download: https://github.com/ndarilek/tolk/releases
- For 64-bit: `Tolk.dll` + `nvdaControllerClient64.dll` from the x64 directory
- For 32-bit: `Tolk.dll` + `nvdaControllerClient32.dll` from the x86 directory
- Copy these DLLs to the game directory (where the .exe is located)

For beginners: Tolk is a library that can communicate with various screen readers (NVDA, JAWS, etc.). Our mod uses Tolk to send text to your screen reader.

### Step 6: .NET SDK

Question: Do you have the .NET SDK already installed?

If no, explain:
- Download: https://dotnet.microsoft.com/download
- Recommended: .NET 8 SDK or newer
- Check with: `dotnet --version` in PowerShell

For beginners: The .NET SDK is a development tool from Microsoft. We need it to compile our C# code into a DLL file that MelonLoader can then load.

### Step 7: Decompilation

Question: Do you have a decompiler tool (dnSpy or ILSpy) installed?

If no, explain options:

**ILSpy (recommended):**
- Download: https://github.com/icsharpcode/ILSpy/releases
- **Advantage:** Can be controlled via command line, allowing Claude Code to automate decompilation
- Command-line usage: `ilspycmd -p -o decompiled "[Game]_Data\Managed\Assembly-CSharp.dll"`
- This makes the entire decompilation process automatable - Claude Code can do it for you

**dnSpy (alternative):**
- Download: https://github.com/dnSpy/dnSpy/releases
- GUI-based tool with manual workflow
- Use it to decompile `Assembly-CSharp.dll` from `[Game]_Data\Managed\`
- The decompiled code should be copied to `decompiled/` in this project directory

**Screen reader instructions for dnSpy:**
1. Open DnSpy.exe
2. Use Ctrl+O to select the DLL (e.g., Assembly-CSharp.dll)
3. In the "File" menu, select "Export to Project"
4. Press Tab once - lands on an unlabeled button for target directory selection
5. There, select the target directory (best to create a "decompiled" subdirectory in this project directory beforehand, so Claude Code can easily find the source code)
6. After confirming the directory selection, press Tab repeatedly until you reach the "Export" button
7. The export takes about half a minute
8. Then close dnSpy

For beginners: Games are written in a programming language and then "compiled" (translated into machine code). Decompiling reverses this - we get readable code. We need this to understand how the game works and where to hook in our accessibility features.

### Step 8: Multilingual Support

Question: Should the mod be multilingual (automatic language detection based on game language)?

If yes:
- The game's language system must be analyzed during decompilation
- Search for: `Language`, `Localization`, `I18n`, `currentLanguage`, `getAlias()`
- See `localization-guide.md` for complete instructions
- Use `templates/Loc.cs.template` as starting point

If no:
- Mod will be monolingual (in the user's language)

### Step 9: Set Up Project Directory

After the interview:
- **Determine mod name:** `[GameName]Access` - abbreviate if 3+ words (e.g., "PetIdleAccess", "DsaAccess" for "Das Schwarze Auge")
- Create `project_status.md` with collected information (game name, paths, architecture, experience level)
- Create `docs/game-api.md` as placeholder for game discoveries
- Enter the concrete paths in CLAUDE.md under "Environment"

---

## User Checklist (to read aloud)

After the interview, read this checklist:

- Game architecture known (32-bit or 64-bit)
- MelonLoader installed and tested (game starts with MelonLoader console)
- Tolk DLLs in game directory (matching the architecture!)
- Decompiler tool ready
- Assembly-CSharp.dll decompiled and code copied to `decompiled/` directory

**Tip:** The validation script checks all points automatically:
```powershell
.\scripts\Test-ModSetup.ps1 -GamePath "C:\Path\to\Game" -Architecture x64
```

---

## Next Steps

After completing setup, proceed in this order:

0. **Read ACCESSIBILITY_MODDING_GUIDE.md** - Read `docs/ACCESSIBILITY_MODDING_GUIDE.md` completely, especially the "Source Code Research Before Implementation" section. This guide defines the patterns and rules for the entire project.
1. **Source code analysis** (Phase 1 below) - Understand game systems
2. **Search/analyze tutorial** (Section 1.9) - Understand mechanics, often high priority
3. **Create feature plan** (Phase 1.5) - Most important features in detail, rest roughly
4. **Fill game-api.md** - Document findings from the analysis

---

## CRITICAL: Before First Build - Check Log!

**These values MUST be read from the MelonLoader log, NEVER guess!**

### Automatically with Script (recommended)

```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Path\to\Game"
```

The script extracts all values and displays the finished MelonGame attribute.

### Manually (if script not available)

**Step 1:** Start game once with MelonLoader (creates the log).

**Step 2:** Log path: `[GameDirectory]\MelonLoader\Latest.log`

Search for these lines and note the EXACT values:

```
Game Name: [COPY EXACTLY]
Game Developer: [COPY EXACTLY]
Runtime Type: [net35 or net6]
```

### Step 3: Enter Values in Code/Project

**MelonGame Attribute (Main.cs):**
```csharp
[assembly: MelonGame("DEVELOPER_FROM_LOG", "GAME_NAME_FROM_LOG")]
```
- Capitalization MUST match exactly
- Spaces MUST match exactly
- With wrong name, the mod will load but NOT initialize!

**TargetFramework (csproj):**
- If log says `Runtime Type: net35` → use `<TargetFramework>net472</TargetFramework>`
- If log says `Runtime Type: net6` → use `<TargetFramework>net6.0</TargetFramework>`
- Reference MelonLoader DLLs from the matching subdirectory (net35/ or net6/)

**WARNING:** Do NOT use `netstandard2.0` for net35 games!
netstandard2.0 is only an API specification, not a runtime. Mono has compatibility issues with it - the mod will load but not initialize (no error message, just silence).

**Exclude decompiled directory (csproj):**
The csproj MUST contain these lines, otherwise the decompiled files will be compiled (hundreds of errors!):
```xml
<ItemGroup>
  <Compile Remove="decompiled\**" />
  <Compile Remove="templates\**" />
</ItemGroup>
```

**Build command - ALWAYS with project file!**
```
dotnet build [ModName].csproj
```
Do NOT just use `dotnet build`! The `decompiled/` directory often contains its own `.csproj` file from the decompiled game. If MSBuild finds multiple project files, it aborts.

### Why is this so important?

1. **Developer name wrong** = Mod loads but OnInitializeMelon() is never called. No error in log, just silence.
2. **Framework wrong** = Mod loads but cannot execute. No error in log, just silence.

**For crashes or silent failures:** Read `technical-reference.md` section "CRITICAL: Accessing Game Code".

---

## Project Start Workflow

### Phase 1: Codebase Analysis (before coding)

Goal: Understand all accessibility-relevant systems BEFORE starting mod development.

#### 1.1 Structure Overview

**Namespace Inventory:**
```
Grep pattern: ^namespace\s+
```
Categorize into: UI/Menus, Gameplay, Audio, Input, Save/Load, Network, Other.

**Find singleton instances:**
```
Grep pattern: static.*instance
Grep pattern: \.instance\.
```
Singletons are the main access points to the game. List all with class name, what they manage, important properties.

#### 1.2 Input System (CRITICAL!)

**Find all key bindings:**
```
Grep pattern: KeyCode\.
Grep pattern: Input\.GetKey
Grep pattern: Input\.GetKeyDown
Grep pattern: Input\.GetKeyUp
```
For EVERY find, document: File/line, which key, what happens, in which context.

**Mouse input:**
```
Grep pattern: Input\.GetMouseButton
Grep pattern: OnClick
Grep pattern: OnPointerClick
Grep pattern: OnPointerEnter
```

**Input controllers:**
```
Grep pattern: class.*Input.*Controller
Grep pattern: class.*InputManager
```

**Result:** Create list of which keys are NOT used by the game → safe mod keys.

#### 1.3 UI System

**UI base classes:**
```
Grep pattern: class.*Form.*:
Grep pattern: class.*Panel.*:
Grep pattern: class.*Window.*:
Grep pattern: class.*Dialog.*:
Grep pattern: class.*Menu.*:
Grep pattern: class.*Screen.*:
Grep pattern: class.*Canvas.*:
```

Find out: Common base class? How are windows opened/closed? Central UI management?

**Text display:**
```
Grep pattern: \.text\s*=
Grep pattern: SetText\(
Grep pattern: TextMeshPro
```

**Tooltips:**
```
Grep pattern: Tooltip
Grep pattern: hover
Grep pattern: description
```

#### 1.4 Game Mechanics

**Player class:**
```
Grep pattern: class.*Player
Grep pattern: class.*Character
Grep pattern: class.*Controller.*:.*MonoBehaviour
```

**Inventory:**
```
Grep pattern: class.*Inventory
Grep pattern: class.*Item
Grep pattern: class.*Slot
```

**Interaction:**
```
Grep pattern: Interact
Grep pattern: OnUse
Grep pattern: IInteractable
```

**Other systems (depending on game):**
- Quest: `class.*Quest`, `class.*Mission`
- Dialog: `class.*Dialog`, `class.*Conversation`, `class.*NPC`
- Combat: `class.*Combat`, `class.*Attack`, `class.*Health`
- Crafting: `class.*Craft`, `class.*Recipe`
- Resources: `class.*Currency`, `Gold`, `Coins`

#### 1.5 Status and Feedback

**Player status:**
```
Grep pattern: Health
Grep pattern: Stamina
Grep pattern: Mana
Grep pattern: Energy
```

**Notifications:**
```
Grep pattern: Notification
Grep pattern: Message
Grep pattern: Toast
Grep pattern: Popup
```

#### 1.6 Event System (for Harmony patches)

**Find events:**
```
Grep pattern: delegate\s+
Grep pattern: event\s+
Grep pattern: Action<
Grep pattern: UnityEvent
Grep pattern: \.Invoke\(
```

**Good patch points:**
```
Grep pattern: OnOpen
Grep pattern: OnClose
Grep pattern: OnShow
Grep pattern: OnHide
Grep pattern: OnSelect
```

#### 1.7 Localization

```
Grep pattern: Locali
Grep pattern: Language
Grep pattern: Translate
Grep pattern: GetString
```

#### 1.8 Document Results

After analysis, `docs/game-api.md` should contain:
1. Overview - Game description, engine version
2. Singleton access points
3. Game key bindings (ALL!)
4. Safe mod keys
5. UI system - Windows/menus with opening methods
6. Game mechanics
7. Status systems
8. Event hooks for Harmony

#### 1.9 Search and Analyze Tutorial

**Why the tutorial is important:**
- Tutorials explain game mechanics step by step - ideal for understanding what needs to be made accessible
- Often simpler structure than the rest of the game - good entry point for mod development
- If the tutorial is accessible, blind players can actually learn the game in the first place
- Tutorial code often reveals which UI elements and interactions exist

**Search in decompiled code:**
```
Grep pattern: Tutorial
Grep pattern: class.*Tutorial
Grep pattern: FirstTime
Grep pattern: Introduction
Grep pattern: HowToPlay
Grep pattern: Onboarding
```

**Search in game directory:**
- For files with "tutorial", "intro", "howto" in name
- Often organized in separate scenes or levels

**Analysis questions:**
1. Is there a tutorial? If yes, how is it started?
2. Which game mechanics are introduced in the tutorial?
3. How are instructions displayed (text, popups, voice output)?
4. Are there interactive elements that need to be made accessible?
5. Can the tutorial be skipped?

**Result:**
- Document tutorial existence and start method in game-api.md
- Put tutorial on feature list (typically high priority)
- Use recognized mechanics as basis for further features

### Phase 1.5: Create Feature Plan

**Create a structured plan before coding:**

Based on codebase analysis and tutorial findings, create a feature list.

**Plan structure:**

Most important features (document in detail):
- What exactly should the feature do?
- Which game classes/methods are used?
- Which keys are needed?
- Dependencies on other features?
- Known challenges?

Example for detailed feature:
```
Feature: Main Menu Navigation
- Goal: All menu items navigable with arrow keys, announce current selection
- Classes: MainMenu, MenuButton (from Analysis 1.3)
- Harmony hook: MainMenu.OnOpen() for initialization
- Keys: Arrow keys (already used by game), Enter (confirm)
- Dependencies: None (first feature)
- Challenge: Menu items have no uniform text property
```

Less important features (document roughly):
- Brief description in 1-2 sentences
- Estimated complexity (simple/medium/complex)
- Dependencies if any

Example for rough feature:
```
Feature: Achievement Announcements
- Brief: Intercept achievement popups and read aloud
- Complexity: Simple
- Depends on: Basic announcement system
```

**Set priorities:**

Question to user: Which feature should we start with?

Guiding principle: Best to start with the things you interact with first in the game. This enables early testing and the player can experience the game from the beginning.

Typical order (adapt contextually!):
1. Main menu - Usually the first contact with the game
2. Basic status announcements - Health, resources, etc.
3. Tutorial (if present) - Introduces game mechanics
4. Core gameplay navigation
5. Inventory and submenus
6. Special features (Crafting, Trading, etc.)
7. Optional features (Achievements, Statistics)

This order is just a suggestion. Depending on the game, it may make sense to prioritize differently:
- Some games start directly in gameplay without main menu
- In some games the tutorial is mandatory and comes before everything else
- Status announcements can also be developed parallel to other features

**Advantages of a well-thought-out plan:**
- Dependencies are recognized early
- Common utility classes can be identified
- Architecture decisions made once instead of ad-hoc
- Better overview of total scope

**Note:** The plan may and will change. Some features prove to be easier or harder than expected.

### Phase 2: Basic Framework

1. Create C# project with MelonLoader references
2. Integrate Tolk for screen reader output
3. Create basic mod that only announces "Mod loaded"
4. Test if basic framework works

### Phase 3: Feature Development

**BEFORE each new feature:**
1. Consult `docs/game-api.md`:
   - Check game key bindings (no conflicts!)
   - Use already documented classes/methods
   - Reuse known patterns
2. Check feature plan entry (dependencies fulfilled?)
3. For menus: Work through `menu-accessibility-checklist.md`

**Why API docs first?**
- Prevents key conflicts with the game
- Avoids duplicate work (don't search for methods again)
- Consistency between features is maintained
- Documented patterns can be directly reused

See `ACCESSIBILITY_MODDING_GUIDE.md` for code patterns.

**Feature order:** Build accessibility features in the order a player encounters them in the game:

1. **Main menu** - First contact with the game, basic navigation
2. **Settings menu** - If accessible from main menu
3. **General status announcements** - Health, money, time, etc.
4. **Tutorial / Starting area** - First game experience
5. **Core gameplay** - The most frequent actions
6. **Inventory / In-game menus** - Pause menu, inventory, map
7. **Special features** - Crafting, trading, dialogs
8. **Endgame / Optional** - Achievements, statistics

---

## Helper Scripts

### Get-MelonLoaderInfo.ps1

Reads the MelonLoader log and extracts all important values:
- Game Name and Developer (for MelonGame attribute)
- Runtime Type (for TargetFramework)
- Unity Version

**Usage:**
```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Path\to\Game"
```

**Output:** Ready-to-copy code snippets.

### Test-ModSetup.ps1

Validates if everything is set up correctly:
- MelonLoader installation
- Tolk DLLs (also checks correct architecture!)
- Project file and references
- MelonGame attribute
- Decompiled directory

**Usage:**
```powershell
.\scripts\Test-ModSetup.ps1 -GamePath "C:\Path\to\Game" -Architecture x64
```

Parameter `-Architecture` can be `x64` or `x86`.

**Output:** List of all checks with OK, WARNING or ERROR, plus solution suggestions.

---

## Important Links

- MelonLoader GitHub: https://github.com/LavaGang/MelonLoader
- MelonLoader Installer: https://github.com/LavaGang/MelonLoader.Installer/releases
- Tolk (Screen reader): https://github.com/ndarilek/tolk/releases
- dnSpy (Decompiler): https://github.com/dnSpy/dnSpy/releases
- .NET SDK: https://dotnet.microsoft.com/download
