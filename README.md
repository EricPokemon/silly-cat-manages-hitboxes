# silly cat manages hitboxes
![image](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/7f27964d7018b45a0ebbb012216e81cd.png)
# [SOURCE CODE](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/HitboxManager.lua)
## Introduction
Hello! this is a Roblox hitbox manager that uses magnitude to detect humanoid characters. I recently just made this as in October 7 2022, so there may be some bugs but please bear with me. This module uses [Janitor](https://github.com/howmanysmall/Janitor) and stravant's [Good Signal](https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063). The reason I made this module is because I couldn't find any magnitude hitbox modules, so here it is!
## What features does it include?
This is a DoD (data oriented design) based module and is very optimized, performant, fast (yes I'm aware that I said the same thing in 3 different ways), accurate, and easy to use. It also scans every humanoid character with a humanoid root part. If you wish to change how it behaves then you must change some stuff in the source code. Also a way to visualize the hitboxes
## What are the limitaions of this hitbox manager?
- Hit only hits a humanoid target once.
- There's no :Start or :Stop options for this module, therefore once you create a new hitbox it'll start running and once you destroy said hitbox it's gone.
## Where can I install this module?
[Through the roblox marketplace](https://www.roblox.com/library/11204552320/silly-cat-manages-hitbox), [downloading it](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/silly%20cat%20manages%20hitboxes.rbxm), through the [example place](https://www.roblox.com/games/11205345452/silly-cat-manages-hitboxes-Example-Place) or through implementing all the modules that was mentioned including this one.

# API
### *[Dictonary](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries) HitboxManager:New(hitboxPart:[BasePart](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries](https://create.roblox.com/docs/reference/engine/classes/BasePart)), range:[number](https://create.roblox.com/docs/scripting/luau/numbers), duration:[number](https://create.roblox.com/docs/scripting/luau/numbers), character:[Models](https://create.roblox.com/docs/building-and-visuals/studio-modeling/model-objects)))*
Creates a new hitbox.
- hitboxPart: is where the magnitude hitbox will project and scan around
- range: is the range of the magnitude
- duration: how long the hitbox last in seconds
- character: which character is immune to the hitbox. The hitbox won't scan this character. This is ***OPTIONAL***
Returns the dictonary of the hitbox where you can send it in HitboxManager:Destroy(your hitbox dict here) to prematurely stop the hitbox.

### *[Void](https://create.roblox.com/docs/scripting/luau/nil) HitboxManager:Destroy(hitbox that was created using HitboxManager:New)*
Prematurely stops the hitbox and destroying it. Therefore cleaning up signals and gets garbaged collected next frame. Also [voiding](https://create.roblox.com/docs/scripting/luau/nil) itself.

## Example place: [Sword!!!](https://www.roblox.com/games/11205345452/silly-cat-manages-hitboxes-Example-Place)
#### [Donations is much appericated](https://www.roblox.com/catalog/10528629289/Donate-to-the-developers)
