--[[
    Silly Cats Manages Hitboxes v2.2
    An open source magnitude hitbox module created by Eric_pokemon.
    Last edited: 05/17/23
    
    More information and documentation can be found here: 
    https://devforum.roblox.com/t/2013747
    
    Feel free to leave feedback and criticism on the post. 
    You're free to fork this too.
    
    PS: THIS IS NOT BACKWARDS COMPATIBLE. VARIABLES AND PROPERTIES LOCATION AND NAME HAS BEEN CHANGED FOR THE SAKE OF READABILITY.
    v1.0 and v1.1 scripts will not work. Future versions will be compatible with v2.
]]

-- localalized because apperently that make stuff go fast
local clock = os.clock
local tableFind, tableInsert, tableRemove = table.find, table.insert, table.remove
local dead = Enum.HumanoidStateType.Dead
local instanceNew, vectorOne, brickColor, ball = Instance.new, Vector3.one, BrickColor.new, Enum.PartType.Ball

export type SillyHitbox = {
	Part: BasePart,
	Range: number,
	EndTime: number,
	IsImmune: {Model?},
	Hit: RBXScriptSignal,

	Visual: Part?
}

-- Modules
local Janitor = require(script.Janitor)
local GoodSignal = require(script.GoodSignal)

-- Services
local Players = game:GetService("Players")
local Heartbeat = game:GetService("RunService").Heartbeat

-- Settings
local AutoAddPlayers: boolean? = true
local VisualHitboxes: boolean? = false
local RangeCheck: number = 5 --[[ basically multiplies with the hitbox range and duration. 
And only checks that area of magntiude. Increase if your game has a lot of movement. I recommend keeping it at 5 
if you don't really have that much movement.]]

-- Variables
local CleanUpLoop = Janitor.new()
local CheckConnection: RBXScriptConnection?
local Managing = {} -- {active hitboxes}
local Characters = {} -- {Characters}

-- Module Variables
local HitboxManager = {} -- {Module functions}

-- Auxiliary
local function VisualizeHitbox(Hitbox: SillyHitbox)
    --[[
        Description: This function will visualize the hitboxes if setting VisualHitboxes is true.
        Arguments: Hitbox (custom dictionary type.)
        Returns: Void
    ]]

	if VisualHitboxes then
		local NewVisual = instanceNew("Part")
		NewVisual.Parent = workspace
		NewVisual.CFrame = Hitbox.Part.CFrame
		NewVisual.Size = vectorOne * Hitbox.Range * 2
		NewVisual.CanCollide = false
		NewVisual.Massless = true
		NewVisual.BrickColor = brickColor("Bright red")
		NewVisual.Transparency = .7
		NewVisual.Shape = ball

		local weld = instanceNew("WeldConstraint")
		weld.Parent = NewVisual
		weld.Part0 = NewVisual
		weld.Part1 = Hitbox.Part

		Hitbox.Visual = NewVisual
	end
end

local CurrentClock

local function HitboxChecker()
    --[[
        Description: Runs pre-heartbeat. Checks if characters are in a hitbox.
        Will fire the .Hit signal when there's a character in a hitbox. 
        Arguments: Void
        Returns: Void
    ]]

	if #Managing == 0 then
		CheckConnection:Disconnect()
		CheckConnection = nil
		return
	end

	CurrentClock = clock()

	for _,Hitbox in Managing do
		if CurrentClock >= Hitbox.EndTime or not Hitbox.Part or (#Hitbox.Check == 0 and not Hitbox.Tick) then 
			HitboxManager.Destroy(Hitbox)
			continue
		end

		if Hitbox.Tick and CurrentClock >= Hitbox.Tick then
			Hitbox.Tick = CurrentClock + Hitbox.ChangeTick

			for _, Character in Hitbox.OldCheck do
				tableInsert(Hitbox.Check, Character)
			end
		end

		for Number, Character in Hitbox.Check do
			-- will ignore this character if the character has already been hit, not in range or is dead 
			if (Hitbox.Part.Position - Character.HumanoidRootPart.Position).Magnitude > Hitbox.Range then
				continue
			end

			tableRemove(Hitbox.Check, Number)
			Hitbox.Hit:Fire(Character.Humanoid)
		end
	end
end



-- Module functions
function HitboxManager.AddCharacter(Character: Model): ()
    --[[
        Description: Allows a character with a humanoid to be affected by any active hitbox.
        Arguments: Character (Model containing both a humanoid and a humanoidRootPart.)
        Returns: Void
    ]]

	if tableFind(Characters,Character) then warn("Character has already been added. Won't be readding.") return end

	local Humanoid = Character:FindFirstChild("Humanoid") or warn("Character won't be detected to hitboxes because 'Humanoid' doesn't exist.")
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or warn("Character won't be detected to hitboxes because 'HumanoidRootPart' doesn't exist.") 

	tableInsert(Characters,Character)

	-- Signals
	local DieSignal
	local DestroyingSignal

	DieSignal = Humanoid.Died:Once(function()
		DieSignal:Disconnect()
		DieSignal = nil
		DestroyingSignal:Disconnect()
		DestroyingSignal = nil

		tableRemove(Characters,tableFind(Characters,Character))
	end)

	DestroyingSignal = Character.Destroying:Once(function()
		DieSignal:Disconnect()
		DieSignal = nil
		DestroyingSignal:Disconnect()
		DestroyingSignal = nil

		tableRemove(Characters,tableFind(Characters,Character))
	end)
end



function HitboxManager.new(Part: BasePart, Range: number, Duration: number, Immune: ({any}|Model)?): SillyHitbox
    --[[
        Description: Creates a new hitbox. This will return a new active hitbox.
        Arguments: Hitbox (custom dictonary type.)
        Returns: Dictonary (The custom hitbox type)
    ]]

	if type(Immune) ~= "table" then
		Immune = {Immune}
	end

	local NewHitbox: SillyHitbox = {
		Part = Part,
		Range = Range,
		EndTime = clock() + Duration,
		Hit = GoodSignal.new(),

		-- stuff that won't be viewed by the user
		OldCheck = {},
		Check = {},
		_Janitor = Janitor.new(),
	}

	tableInsert(Managing,NewHitbox)
	NewHitbox._Janitor:Add(NewHitbox.Hit,"DisconnectAll")
	NewHitbox._Janitor:LinkToInstance(Part)

	for _,Character in Characters do -- makes the hitbox only checks a certain range, saving resources.

		if (NewHitbox.Part.Position - Character.HumanoidRootPart.Position).Magnitude > NewHitbox.Range * (Duration + RangeCheck) or tableFind(Immune, Character) then
			continue
		end

		tableInsert(NewHitbox.OldCheck, Character)
		tableInsert(NewHitbox.Check, Character)
	end

	if not CheckConnection then
		CheckConnection = CleanUpLoop:Add(Heartbeat:Connect(HitboxChecker),"Disconnect")
	end

	VisualizeHitbox(NewHitbox)

	return NewHitbox
end

function HitboxManager.CreateTick(Hitbox: SillyHitbox, TickTime: number): ()
	--[[
		Description: This function will make a hitbox a tick attack for something like a barrage. 
		TickTime means how often a hitbox will reset the projection in seconds.
		Arguments: Hitbox (custom dictionary type.), TickTime(number)
		Returns: Void
	]]

	Hitbox.Tick = clock() + TickTime 
	Hitbox.ChangeTick = TickTime
end

function HitboxManager.Destroy(Hitbox: SillyHitbox): ()
    --[[
        Description: This function will destroy the hitbox. Voiding the hitbox and its properties.
        This can be called to prematurely stop an active hitbox.
        Arguments: Hitbox (custom dictionary type.)
        Returns: Void
    ]]

	local FindHitbox = tableFind(Managing,Hitbox)

	if FindHitbox then
		Hitbox.Hit:DisconnectAll()

		if VisualHitboxes then
			Hitbox.Visual:Destroy()
		end

		local hasJanitor = Hitbox._Janitor
		if hasJanitor then
			hasJanitor:Destroy()
		end

		tableRemove(Managing,FindHitbox)

		Hitbox = nil
		FindHitbox = nil
	end
end



-- Runs settings
if AutoAddPlayers then
	for _, Player in Players:GetPlayers() do -- players whom loaded before keep this
		HitboxManager.AddCharacter(Player.Character)
	end

	AutoAddPlayers = Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAppearanceLoaded:Connect(function(Character)
			HitboxManager.AddCharacter(Character)
		end)
	end)
end

return HitboxManager
