# HS Engine

This is the repository of Friday Night Funkin': HS Engine.
</br>
(ModAPI coming out soon :0)

## Credits

### HS Engine Developers
| Credits Icon | Username | Involvement |
| ------------ | -------- | ----------- |
| <img src="docs/img/haxel.png" width="64" height="64"/> | [HaxelDev](https://github.com/HaxelDev) | Main-Programmer of HS Engine
| <img src="docs/img/teotm4.png" width="64" height="64"/> | [teotm](https://github.com/teotm) | Ex-Programmer of HS Engine
| <img src="docs/img/kot.png" width="64" height="64"/> | [Codding Cat](https://github.com/CoddingCatPL) | Ex-Programmer of HS Engine

### HS Engine Owner
| Credits Icon | Username | Involvement |
| ------------ | -------- | ----------- |
| <img src="docs/img/gidk.png" width="64" height="64"/> | [Gidk](https://www.youtube.com/watch?v=al74RjD4Ans) | HS engine owner (he resigned to be a programmer for this engine because he went to buy some milk lol)

### Special Thanks
| Credits Icon | Username | Involvement |
| ------------ | -------- | ----------- |
| <img src="docs/img/shadowmario.png" width="64" height="64"/> | [Shadow Mario](https://twitter.com/Shadow_Mario_) | Some Stolen Stuff
| <img src="docs/img/CoreDev.png" width="64" height="64"/> | [CoreCat](https://github.com/Core5570RYT) | Some Stolen Stuff

### Friday Night Funkin'
| Credits Icon | Username | Involvement |
| ------------ | -------- | ----------- |
| <img src="docs/img/ninjamuffin99.png" width="64" height="64"/> | [ninja_muffin99](https://twitter.com/ninja_muffin99) | Programmer of Friday Night Funkin'
| <img src="docs/img/phantomarcade.png" width="64" height="64"/> | [PhantomArcade3K](https://twitter.com/PhantomArcade3K) | Artist of Friday Night Funkin'
| <img src="docs/img/evilsk8r.png" width="64" height="64"/> | [evilsk8r](https://twitter.com/evilsk8r) | Artist of Friday Night Funkin'
| <img src="docs/img/kawaisprite.png" width="64" height="64"/> | [Kawai Sprite](https://twitter.com/kawaisprite) | Composer of Friday Night Funkin'

## Build instructions

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
