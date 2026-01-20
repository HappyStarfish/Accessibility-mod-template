# Access Mod Template

A structured Claude Code template for creating accessibility mods that make games playable with screen readers.

---

# Welcome!

So you've seen some impressive examples of people creating entire complex mods with the help of AI, and you've been wondering if you could do the same?

I definitely wanted to find out, and as I haven't found a comprehensive guide yet, I've decided to create my own as I explored this topic myself. Which then turned into the idea to make a whole template, allowing people to dive right into mod development without hours of preparation.

## Important Disclaimer

This is very much work in progress. I have not finished any actual mod using this template yet—just started way too many in order to make sure that the basics are covered. Once you're in the middle of the process though, Claude Code knows extremely well how to proceed.

Be aware: It takes some patience, and you might not get along with just the cheapest paid Claude subscription.

So let's get you started...

## Prerequisites and Preparations

### What You'll Need

As mentioned, unfortunately you'll need at least a Claude Pro subscription and a credit card as payment method.

After signup, tell Claude that you're interested in coding, and it will probably suggest automatically to install Claude Code on your computer.

### Setting Up Your Environment

**Important:** Open your command line as an administrator.

Additionally, you'll need to install Git Bash, a command line tool which Claude Code uses for handling certain requests. To check if Git Bash is already installed, run:
```
git --version
```

### Choosing Your Game

It seems to be the easiest (or at least the most popular) choice to mod games which are running on the Unity engine because there are great modding tools available for this. Maybe start with something small. Though it's OK if you don't.

We all have those games which we've been enthusiastic about for years on end and now we finally want to actually play them. In fact, the more enthusiastic you are about your game of choice, the more likely it is that you'll actually stay on track throughout weeks or maybe months of endless back and forth with the AI, fixing loads of mysterious bugs.

### Starting Your Project

1. Unpack the Access Mod Template folder from this directory anywhere on your computer
2. Rename it to the game you want to modify
3. Open your newly created folder (without a file or subfolder being selected)
4. Open Windows PowerShell via the context menu (T or Alt+T usually works)
5. Type "claude" and go through the login process

**Tip:** Only during this login process, the command line output might not be very readable with your screen reader. Use OCR or sighted assistance if needed, and don't worry—as soon as it's set up, it runs very smoothly, reading out all contents automatically (at least with NVDA). Depending on your keyboard layout, you can either use some keys on your numpad or NVDA+Arrow Up to browse through the recent output.

**Note:** If any of you uses JAWS, could you please let me know how and to what extent the command line navigation works? Then I can add that info here.

### Running the Setup

1. Restart the command line (i.e. close the window, open the command line again via the context menu in the same folder, and type "claude")
2. Simply type something like "hello" or "new project"
3. The setup process will guide you through lots of steps to get you started with the foundation of your mod development

## Tips and Tricks

Just a short version for now, I'll add more later:

### 1. Communicate Naturally

Talk to Claude Code in a dynamic, natural way. It's surprising how flexible it is, and it can figure out pretty much any creative solution you ask it about. You can always ask it to clarify things.

### 2. Manage Your Token Usage

It will quickly become important to be careful with your usage. Within a conversation, Claude Code will keep rereading everything that's been said every single time you send a new message. That's generally helpful because you want the AI to remember what you're doing, but if possible, start a new conversation whenever one topic or little feature is completed.

### 3. Maintain Documentation

Add and maintain documentation in MD files to make Claude remember things across conversations. The template setup will start doing this already. The most important file is `CLAUDE.md`—everything that's really important should go there. However, it will be read every single time you interact with Claude, so make sure it stays short and compact.

---

Have fun, and do let me know how it goes! Either here or on the Audiogames forum.

The rest of this documentation is just technical stuff for GitHub.


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
