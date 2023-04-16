### scripts using v1.0 and v1.1 is not compatible to v2.0

# **Silly Cat Manages Hitboxes**

[![image](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/7f27964d7018b45a0ebbb012216e81cd.png?raw=true)
also no I didn't draw this I just think it's silly


#### [Source Code](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/HitboxManager.lua)
#### [Example Place](https://www.roblox.com/games/11205345452/silly-cat-manages-hitboxes-Example-Place)
#### [Download](https://github.com/EricPokemon/silly-cat-manages-hitboxes/releases/tag/latest)
#### [Roblox Model](https://www.roblox.com/library/11204552320/silly-cat-manages-hitbox)


## **Introduction**

Hello! I’ve created a roblox hitbox manager that uses magnitude to detect humanoid characters. This was created October 7 2022, Last updated 1/14/2023. This module uses module uses [Janitor](https://github.com/howmanysmall/Janitor) and Stravant's [Good Signal](https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063). The reason I made this module is because I couldn’t find any magnitude hitbox modules and I really wanted to use a magnitude hitbox system, so I decided to make one myself. My intention of this module is to be mainly used in fighting games and to be easy to modify and add onto to suit your needs.

#### A basic sword tool using this module
![example gif](https://github.com/EricPokemon/silly-cat-manages-hitboxes/blob/main/silly%20cat%20hitbox.mp4?raw=true)

## **What features does this include?**
This is what I would like to think is pretty minimal. This module is accurate and is easy to use and understand. It contains a ‘Characters’ table which you could add humanoid characters that you want the hitbox to check if they’re in range, a way to visualize the hitbox, and a way to make the hitbox not scan certain characters. You can toggle the hitbox visuals by editing the module. As well toggle if players are automatically added or not.

## **What are the limitations?**
Only checks characters that are added to the ‘Characters’ table through the .AddCharacter() function. Therefore you must manually add NPCS (players could be automatically added through the module, you can turn this off by going into the settings)

‘Hit’ only hits a character once unless you modify the ‘IsImmune’ property of a hitbox. I’ll also talk about how you could go about implementing a tick-based hitbox if you really want a tick-based hitbox system.

*This module is not set up as object oriented!!*

Performance could tank if you have too many hitboxes or humanoid characters in ‘Characters’. I’ll discuss a possible solution to this. Though I believe you shouldn’t really worry about this as I believe most hitboxes in fighting games usually last around 0.1 - 2 seconds. For having too many characters you could implement an octree. Will talk about this later


# API
<details>

<summary>Click here to open the API!</summary>

**I apologize for the half-baked documentation.** 

## Functions
### [***Void***](https://create.roblox.com/docs/scripting/luau/nil) HitboxManager.AddCharacter(Character: Character Model)

**Adds a character with a humanoid and a root part to the hitbox manager. Will automatically clean up when the character is dead or voided.**

```lua
local NPCS = workspace.NPCS --path to your npcs 
for _,NPC in pairs(workspace.NPCS:GetChildren()) do -- this is how you add npcs who are in a folder.
	hitboxManager.AddCharacter(NPC) --Now the NPC is added it'll now be able to be detected by hitboxes!
end
```
  


### [ ***Hitbox Dictonary***](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries) HitboxManager.new(hitboxPart: [BasePart](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries](https://create.roblox.com/docs/reference/engine/classes/BasePart)), range: [number](https://create.roblox.com/docs/scripting/luau/numbers), duration: [number](https://create.roblox.com/docs/scripting/luau/numbers), immune: [Character Models](https://create.roblox.com/docs/building-and-visuals/studio-modeling/model-objects))
Creates a new hitbox.
- hitboxPart: is where the magnitude hitbox will project and scan around
- range: is the range of the magnitude
- duration: how long the hitbox last in seconds
- immune: **humanoid character(s) that is immune to the hitbox. The hitbox manager won't scan these characters. This can be a table with characters or just a single character that's not in a table. This is **OPTIONAL**
- Return the dictionary of the hitbox where you can send it in HitboxManager.Destroy( dictionary) to prematurely stop the hitbox.



```lua
local newHitbox = hitboxManager.new(Handle, 3, 1, SingleCharacterThatsNotaTable) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
-- OR
local newHitbox = hitboxManager.new(Handle, 3, 1, {Character1, Character2, Character3}) -- Put multiple character that's immune by inserting them in a table.
```

### *[Void](https://create.roblox.com/docs/scripting/luau/nil) HitboxManager.Destroy([ ***Hitbox Dictonary***](https://create.roblox.com/docs/education/coding-5/intro-to-dictionaries) )*
Prematurely stops the hitbox and destroying it. Therefore cleaning up signals and gets garbage the collected next frame. Also [voiding](https://create.roblox.com/docs/scripting/luau/nil) itself.
```lua
local newHitbox = hitboxManager.new(Handle, 3, 1, Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
task.wait(.5)
hitboxManager.Destroy() --force destroys the hitbox in .5 seconds. This is before the silly cat destroys the hitbox.
```


## Events
### *[RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal) .Hit([Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid))*
Fire when a humanoid character is in range of the hitbox. This will return the humanoid of the humanoid Character.
```lua
local newHitbox = hitboxManager.new(Handle, 3, 1, Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
newHitbox.Hit:Connect(function(enemyHumanoid) --any humanoid who's in the hitbox radius will take 15 damage.
  enemyHumanoid:TakeDamage(15)
end)
```

## Properties
### *[Table](https://create.roblox.com/docs/scripting/luau/tables) .IsImmune*
Humanoid characters that were already hit by the hitbox, therefore immune to the hitbox. You can add multiple humanoid characters into this hitbox to make them immune from the hitbox. Great for removing friendly fire in games.
```lua
local newHitbox = hitboxManager.new(Handle, 3, 1) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. There's no character's who's immune yet.
newHitbox.IsImmune = {
  Character,
  Character1,
  Character2,
  ect.
}--These guys in the '.IsImmune' table won't take 15 damage if they're in the hitbox!
newHitbox.Hit:Connect(function(enemyHumanoid) --any humanoid who's in the hitbox radius will take 15 damage.
  enemyHumanoid:TakeDamage(15)
end)
```

### *[number](https://create.roblox.com/docs/scripting/luau/numbers) .Range*
The range/size of the hitbox. Thic can be changed anytime while the hitbox is active (before the duration is over or before it gets destroyed). **Do note that visuals doesn't update when the range changes.**
```lua
local newHitbox = hitboxManager.new(Handle,3,1,Character) --creates a new magnitude hitbox that will scan around Handle with a range of 3 and will last 1 second. Variable Character will be ignored.
newHitbox.Hit:Connect(function(enemyHumanoid) --any humanoid who's in the hitbox radius will take 15 damage.
  enemyHumanoid:TakeDamage(15)
end)
newHitbox.Range = 15 --changes the range from 3 to 15!!
```
</details>


## **Possible solutions to problems**
<details>
<summary> Click here for possible solutions to problems</summary>

* I may implement these ideas and put the files on github in the future. I apologize if you guys were looking for some scripts that you could add on. Sadly you would need to add these yourself unless I decide to implement these myself (I’m updating this module 

 ## **Performance increase:** 

You could make usage with parallel luau and run the :ConnectParallel heartbeat method every time you’ve created a hitbox. So instead of having a heartbeat method which iterates through every hitbox which iterates through every character, you’ll now just have a hitbox iterating through each character. 

This however still has some issues. If you have too many characters then your performance can still tank. My suggestion to solve this is by using an **octree (grid chunk system) to see if a character is worth checking. i.e if a character is 1000 studs away the module wouldn’t check it but if a humanoid is around 0-200 studs away it might actually be worth checking to see if the character gets hit by the hitbox. I’m sure there’s a few modules that can help achieve this octree system. 

To increase performance even further, you could look into converting silly cat into a client side solution. You may be asking “Isn’t that bad because exploiters can just abuse this?” Yes and no. Exploiters wouldn’t be able to really abuse this if you check if the hitbox is really there on the server as well as a magnitude check to see if the character is really near (with a leeway of course so players with higher ping wouldn’t get a false positive). With all of this performance trick, your combat experience will be more consistent, smooth, and much more performant. 

## **Beam type attacks**
Let's say you have an attack that’s a laser beam. If you try to utilize this module to create a hitbox for this, there would only be one hitbox and it would only be in the center of the beam attack. So if any character that’s touching the beam part but not the actual hitbox then the hitbox won’t actually detect them being hit by the hitbox. My suggestion is using attachments (like Raycast Hitbox v4) and create multiple hitboxes based on the attachments and putting all of them in one parent table. As well putting the ‘IsImmune’ property in the new parent table instead of having that property in each hitboxes (we’ll remove the ‘IsImmune’ property in the hitboxes) . Then have the hitbox checker run through if a character is in the hitboxes. If one of the hitbox detects a character then you’ll put that character in the ‘IsImmune’ table which is inside the parent table. Each hitbox that has been created based on the attachment would also check the ‘IsImmune’ property that’s in the parent table. 

## **Tick based attacks**

Let’s say you have a multi-hit attack like a barrage of slashes or punches. First, we have 1 solution for this without touching or making modifications to the module.

This is somewhat a lazy and naive solution but if you really really want to avoid getting your hands dirty and modify and add onto the module is, you could again run a loop but instead of creating a new hitbox.

``` lua

local Characters = {Hi, Roblox, ThisGuy}

newHitbox = HitboxManager.new(Part, Range, Duration, Characters)

newHitbox.Hit:Connect(function(Humanoid)
  Humanoid:TakeDamage(10)
end)

for i=1,30 do
  newHitbox.IsImmune = {Characters} -- give
  task.wait(tick duration)
end

```

Or you could create a new function in the hitbox to make the tick hitbox more accurate and possibly more performate. To make a new function where you add a conditional in the heartbeat connection which would clear the hitbox IsImmune except the characters that you decide that’s the user or is immuned to the hitbox. This is mainly for the sake of readability but your script styling is all preference. (Also it could be slightly faster if you implement it well)

</details>

So this is kinda like the end of this post. I’ll maybe or may not be creating solutions to said problems when I get motivated again and need these solutions (I’ll definitely be implementing an octree for a performance boost soon). V2.1 is just bug fixes and slightly better typing and that’s it. Thanks for reading, criticism is appreciated. 👍
