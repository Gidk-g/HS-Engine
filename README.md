# HS Engine

This is the repository of Friday Night Funkin': HS Engine.

# Build instructions

First you need to install Haxe and HaxeFlixel.
1. [Install Haxe 4.2.5](https://haxe.org/download/version/4.2.5/) (Download 4.2.5 instead of 4.1.5, seriously stop using Haxe 4.1.5, it misses a lot of stuffs)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe.

Second, you need to install the additional libraries, a fully updated list will be in `Project.xml` in the project root. Here's the list of libraries that you need to install:
```
flixel
flixel-addons
flixel-ui
```
Type `haxelib install [library]` for each of those libs, so like: `haxelib install flixel`.

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git hscript-improved https://github.com/FNF-CNE-Devs/hscript-improved.git` to install Hscript Improved.
4. Run `haxelib git hxCodec https://github.com/polybiusproxy/hxCodec` to install hxCodec.
5. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.

You should have everything ready for compiling the engine! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed out cameras.
- Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.
