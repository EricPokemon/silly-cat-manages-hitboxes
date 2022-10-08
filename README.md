# silly cat manages hitboxes
![silly cat who manages the hitbox](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/7f27964d7018b45a0ebbb012216e81cd.png)
# [SOURCE CODE](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/HitboxManager.lua)
## Introduction
Hello! this is a Roblox hitbox manager that uses magnitude to detect humanoid characters. I recently just made this as in October 7 2022, so there may be some bugs but please bear with me. This module uses [Janitor](https://github.com/howmanysmall/Janitor) and stravant's [Good Signal](https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063). The reason I made this module is because I couldn't find any magnitude hitbox modules, so here it is!
![example gif](https://gyazo.com/66798be6a8712321e0e1f8a9af3fee09)
## What features does it include?
This is a DoD (data oriented design) based module and is very optimized, performant, fast (yes I'm aware that I said the same thing in 3 different ways), accurate, and easy to use. It also scans every humanoid character with a humanoid root part. If you wish to change how it behaves then you must change some stuff in the source code. Also a way to visualize the hitboxes
## What are the limitaions of this hitbox manager?
- Hit only hits a humanoid target once.
- There's no :Start or :Stop options for this module, therefore once you create a new hitbox it'll start running and once you destroy said hitbox it's gone.
## Where can I install this module?
[Through the roblox marketplace](https://www.roblox.com/library/11204552320/silly-cat-manages-hitbox), [downloading it](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/silly%20cat%20manages%20hitboxes.rbxm), through the [example place](https://www.roblox.com/games/11205345452/silly-cat-manages-hitboxes-Example-Place) or through implementing all the modules that was mentioned including this one.

# API
## Functions
### *[Dictonary](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries) HitboxManager:New(hitboxPart:[BasePart](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries](https://create.roblox.com/docs/reference/engine/classes/BasePart)), range:[number](https://create.roblox.com/docs/scripting/luau/numbers), duration:[number](https://create.roblox.com/docs/scripting/luau/numbers), character:[Models](https://create.roblox.com/docs/building-and-visuals/studio-modeling/model-objects)))*
Creates a new hitbox.
- hitboxPart: is where the magnitude hitbox will project and scan around
- range: is the range of the magnitude
- duration: how long the hitbox last in seconds
- character: which character is immune to the hitbox. The hitbox won't scan this character. This is ***OPTIONAL***
Returns the dictonary of the hitbox where you can send it in HitboxManager:Destroy(Hitbox dictonary) to prematurely stop the hitbox.
```lua
local newHitbox = hitboxManager:New(Handle,3,1,Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
```

### *[Void](https://create.roblox.com/docs/scripting/luau/nil) HitboxManager:Destroy(Hitbox dictonary)*
Prematurely stops the hitbox and destroying it. Therefore cleaning up signals and gets garbaged collected next frame. Also [voiding](https://create.roblox.com/docs/scripting/luau/nil) itself.
```lua
local newHitbox = hitboxManager:New(Handle,3,1,Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
task.wait(.5)
hitboxManager:Destroy() --force destroys the hitbox in .5 seconds. This is before the silly cat destroys the hitbox.
```

## Events
### *[RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal) .Hit([Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid))*
Fire when a humanoid character is in range of the hitbox. This will return the humanoid of the humanoid Character.
```lua
local newHitbox = hitboxManager:New(Handle,3,1,Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
newHitbox.Hit:Connect(function(enemyHumanoid) --any humanoid who's in the hitbox radius will take 15 damage.
  enemyHumanoid:TakeDamage(15)
end)
```

## Properties
### *[Table](https://create.roblox.com/docs/scripting/luau/tables) hit*
Humanoid characters that were already hit by the hitbox, therefore immune to the hitbox. You can add multiple humanoid characters into this hitbox to make them immune from the hitbox. Great for removing friendly fire in games.
```lua
local newHitbox = hitboxManager:New(Handle,3,1) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. There's no character's who's immune yet.
newHitbox.hit = {
  Character,
  Character1,
  Character2,
  ect.
}
newHitbox.Hit:Connect(function(enemyHumanoid) --any humanoid who's in the hitbox radius will take 15 damage.
  enemyHumanoid:TakeDamage(15)
end)
--These guys in the .hit list won't take 15 damage if they're in the hitbox!
```

### *[number](https://create.roblox.com/docs/scripting/luau/numbers) range*
The range/size of the hitbox. Thic can be changed anytime while the hitbox is active (before the duration is over or before it gets destroyed). **Do note that visuals doesn't update when the range changes.**
```lua
local newHitbox = hitboxManager:New(Handle,3,1,Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
newHitbox.Hit:Connect(function(enemyHumanoid) --any humanoid who's in the hitbox radius will take 15 damage.
  enemyHumanoid:TakeDamage(15)
end)
newHitbox.range = 15 --changes the range from 3 to 15!!
```

## Example place: [Sword!!!](https://www.roblox.com/games/11205345452/silly-cat-manages-hitboxes-Example-Place)
#### [Donations is much appericated](https://www.roblox.com/catalog/10528629289/Donate-to-the-developers)
