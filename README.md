# Welcome!

So you've seen some impressive examples of people creating entire complex mods with the help of AI, and you've been wondering if you could do the same?

I definitely wanted to find out, and I haven't found a comprehensive guide, so I've decided to create my own while I learned myself how to do this. Which then turned into the idea to make a whole template which allows people to dive right into mod development without hours of preparation.

## Important Disclaimer

This is very much work in progress. I have not finished any actual mod using this template yet—just started way too many in order to make sure that the basics are covered. Once you're in the middle of the process though, Claude Code knows extremely well how to proceed.

Be aware: It takes some patience, and you might not get along with just the cheapest paid Claude subscription.

So let's get you started...

## Prerequisites and Preparations

### What You'll Need

As mentioned, unfortunately you'll need at least a Claude Pro subscription and a credit or debit card as payment method.

After signup, tell Claude that you're interested in coding, and it will probably suggest automatically to install Claude Code on your computer.

### Setting Up Your Environment

**Important:** Open your command line as an administrator.
After installing Claude Code, you might need to set t up so that it works within your command line. Just follow the instructions on the Claude website, and when in doubt ask Claude itself, apparently it knows its own documentary.

Additionally, you'll need to install Git Bash, a command line tool which Claude Code uses for handling certain requests. To check if Git Bash is already installed, run:
```
git --version
```

### Choosing Your first Game

It seems to be the easiest (or at least the most popular) choice to mod games which are running on the Unity engine because there are great modding tools available for this. Maybe start with something small. Though it's OK if you don't.

We all have those games which we've been enthusiastic about for years on end and now we finally want to actually play them. In fact, the more enthusiastic you are about your game of choice, the more likely it is that you'll actually stay on track throughout weeks or maybe months of endless back and forth with the AI, fixing loads of mysterious bugs on the way.

### Starting Your Project

1. Unpack the Accessibility-Mod-Template folder from this directory anywhere on your computer
2. Rename it to the game you want to modify
3. Open your newly created folder (without a file or subfolder being selected)
4. Open Windows PowerShell via the context menu (T or Alt+T usually works)
5. Type "claude" and go through the login process

**Tip:** Only during this login process, the command line output might not be very readable with your screen reader. Use OCR or sighted assistance if needed, and don't worry—as soon as it's set up, it runs very smoothly, reading out all contents automatically (at least with NVDA). Depending on your keyboard layout, you can either use some keys on your numpad or NVDA+Arrow Up to browse through the recent output.

**Note:** If any of you uses JAWS, could you please let me know how and to what extent the command line navigation works? Then I can add that info here.

### Getting started

1. Restart the command line (i.e. close the window, open the command line again via the context menu in the same folder, and type "claude")
2. Simply type something like "hello" or "new project"
3. The setup process will guide you through all the steps to get you started with the foundation of your mod development

## Important: Decompiled Game Code

This template requires you to decompile game files in order to understand the game's APIs and build your mod. Please be aware of the following:

- **Never distribute decompiled code.** Do not push it to Git repositories, do not include it in mod downloads, and do not share it publicly in any form.
- The `decompiled/` folder is already listed in `.gitignore`. Do not remove that entry — it is there to protect you from accidentally publishing copyrighted game code.
- When documenting findings in `game-api.md`, only record what you need: method signatures, parameter names, enums, and brief behavioral notes. Do not copy entire method bodies or large sections of decompiled source.
- Before modding a game, check the game's or publisher's modding policy. Some explicitly allow modding, others do not.
- In the EU and potencially other places, decompilation for interoperability purposes (such as accessibility mods) is permitted under certain conditions. However, the legal situation varies by region and is not fully settled.
- This template does not constitute legal advice. If you are unsure about the legality of your project, do proper research before starting. Don't do anything we wouldn't do! ;)

## What the general work flow will look like

The first time you run the starting setup, Claude Code will prompt you to install several tools e.g. for logging and other technical background stuff. This will take a little while.
Then, after you've answered all the initial questions, e.g. where the game is located and what engine it is based on, Claude will guide you through some additional steps in order to get a first overview of what will need to be done to make the game accessible.
Then the actual work begins: You can decide which features you'll want to build first. I'd recommend to start with a very basic version which just announces something when the game is started, an to then move on to the first things you'll interact with in the game, like the main menu or starting screen.
The AI will write a lot of code and test it (this is just for technical errors, not for actual functionality), then you can start the game, see what the mod does, and tell claude what is not working.
And once the first feature is functional (or functional enough for the moment), you can continue with the next one.

## Tips and Tricks

Just a short version for now, I'll add more later:

### 1. Communicate Naturally

Talk to Claude Code in a dynamic, natural way. It's surprising how flexible it is, and it can figure out pretty much any creative solution you ask it about. (And now, it did not force me to write this!)

### 2. Be curious, creative and persistent

You can and should ask Claude to clarify things you don't get.
The better you understand what it is doing and why, the better suggestions you'll be able to make, no matter your level of coding skills (or lack thereof).
If you aren't sure how to proceed or which choice would be better, ask for advantages, disadvantages and common pitfalls.
Also, if you feel confident enough, do question Claude's decisions, sometimes it's possible to safe yourself time (and tokens) by asking if a new feature can be built using already existing code.

### 3. Use the claude.md file wisely, and repeat crucial instructions in your prompts if necessary

Claude.md is the file within your project folder which contains the most important instructions for the AI. It gets re-read with every single prompt you send. Still, you might want to repeat crucial instructions within your prompts, for example I often tell Claude to thoroughly research how a feature works within the game's source code before creating an accessibility plan for said feature.
You might want to go over your claude.md occasionally to check for two factors, which unfortunately can get in the way of each other and therefore require careful weighing:
1) Does the file contain everything essential for Claude to do its work, including references for more verbose or specific documentation?
2) Is the file as compact as it can possibly be? Each time you send a message, the entire file gets attached. I've seen claude.md files with 600 lines which had to do lists and whatnot in it, that's an unnecessary use of tokens. That said, in case you're on the top tier Claude plan, you might get more benefits than disadvantages from using a larger claude.md.

### 4. What to do when something won't work even after the umteenth attempt

Sometimes it helps to urge Claude to check the existing source code for expected game behaviour. Maybe the dialogue popup you've been working on for hours doesn't actually exist because the game is doing something entirely different. Or maybe the combat handling class is using generic variable terms instead of the ones the game actually uses.

### 5. Manage Your Token Usage

It will quickly become important to be careful with your usage. Within a conversation, Claude Code will keep rereading everything that's been said every single time you send a new message. That's generally helpful because you want the AI to remember what you're doing, but if possible, start a new conversation (i.e. a new Claude Code session) whenever one topic or little feature is completed.

### 6. Maintain Documentation

Add and maintain documentation in MD files to make Claude remember things across conversations. The template setup will start doing this already. The most important file is `CLAUDE.md`, but you might want to add separate files e.g. for your project status and the results of research within the original game's codebase.
It's especially important to have Claude document results into a file when exploring complex game mechanics, Claude might need that info again later on.

---

Have fun, and do let me know how it goes! Either here or on the Audiogames forum.

The rest of this page is just credits and technical stuff for GitHub.


## Project Structure

- `docs/` - Guides, checklists, and API documentation
- `templates/` - Code templates for common features
- `scripts/` - PowerShell helper scripts
- `decompiled/` - Game source code (you add this during setup)
- `CLAUDE.md` - Instructions for Claude Code integration

## Contributing

This template is designed for blind developers and their AI assistants. Contributions that improve clarity, add useful patterns, or expand documentation are welcome.

## Credits

This template was built with invaluable support from **Jean Stiletto** and **Firefly82**. Thank you so much for contributing your accessibility modding experience, brilliant ideas, your enthusiasm, and patient testing!

Your contributions helped me create a template that actually works.
