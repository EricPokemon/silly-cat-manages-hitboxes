--[[
    Silly Cats Manages Hitboxes v2.1
    An open source magnitude hitbox module created by Eric_pokemon.
    Last edited: 04/15/23
    
    More information and documentation can be found here: 
    https://devforum.roblox.com/t/2013747
    
    Feel free to leave feedback and criticism on the post. 
    You're free to fork this too.
    
    PS: THIS IS NOT BACKWARDS COMPATIBLE. VARIABLES AND PROPERTIES LOCATION AND NAME HAS BEEN CHANGED FOR THE SAKE OF READABILITY.
    v1.0 and v1.1 scripts will not work. Future versions will be compatible with v2.
]]


export type SillyHitbox = {
	Part: BasePart,
	Range: number,
	EndTime: number,
	IsImmune: {Model?},
	Hit: RBXScriptSignal,
	_Janitor: never,

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
local VisualHitboxes: boolean? = true

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
		local NewVisual = Instance.new("Part")
		NewVisual.Parent = workspace
		NewVisual.CFrame = Hitbox.Part.CFrame
		NewVisual.Size = Vector3.new(Hitbox.Range*2,Hitbox.Range*2,Hitbox.Range*2)
		NewVisual.CanCollide = false
		NewVisual.Massless = true
		NewVisual.BrickColor = BrickColor.new("Bright red")
		NewVisual.Transparency = .7
		NewVisual.Shape = Enum.PartType.Ball

		local weld = Instance.new("WeldConstraint")
		weld.Parent = NewVisual
		weld.Part0 = NewVisual
		weld.Part1 = Hitbox.Part

		Hitbox.Visual = NewVisual
	end
end



local function isCharacterDead(Character: Model)
	return not Character
		or not Character.Parent
		or Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead
		or not Character.Humanoid 
		or Character.Humanoid.Health <= 0
end



local function CheckHumanoids(Hitbox: SillyHitbox)
    --[[
        Description: Check if any characters are in the hitbox. They will not be hit again unless the table hitbox.hit got rid of 
        the character. Some more information could be found in the 'HitboxChecker' function.
        Arguments: Hitbox (custom dictionary type.)
        Returns: Void
    ]]

	for _,Character in ipairs(Characters) do
		-- will ignore this character if the character has already been hit, not in range or is dead 
		if isCharacterDead(Character) or (Hitbox.Part.Position - Character.HumanoidRootPart.Position).Magnitude > Hitbox.Range or table.find(Hitbox.IsImmune, Character) then
			continue
		end

		table.insert(Hitbox.IsImmune,Character)
		Hitbox.Hit:Fire(Character.Humanoid)
	end
end



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

	for _,Hitbox in ipairs(Managing) do
		if os.clock() >= Hitbox.EndTime or not Hitbox.Part then 
			HitboxManager.Destroy(Hitbox)
			continue
		end
		CheckHumanoids(Hitbox)
	end
end



-- Module functions
function HitboxManager.AddCharacter(Character: Model): ()
    --[[
        Description: Allows a character with a humanoid to be affected by any active hitbox.
        Arguments: Character (Model containing both a humanoid and a humanoidRootPart.)
        Returns: Void
    ]]

	if table.find(Characters,Character) then warn("Character has already been added. Won't be readding.") return end

	local Humanoid = Character:FindFirstChild("Humanoid") or warn("Character won't be detected to hitboxes because 'Humanoid' doesn't exist.")
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or warn("Character won't be detected to hitboxes because 'HumanoidRootPart' doesn't exist.") 

	table.insert(Characters,Character)

	-- Signals
	local DieSignal
	local DestroyingSignal

	DieSignal = Humanoid.Died:Once(function()
		DieSignal:Disconnect()
		DieSignal = nil
		DestroyingSignal:Disconnect()
		DestroyingSignal = nil

		table.remove(Characters,table.find(Characters,Character))
	end)

	DestroyingSignal = Character.Destroying:Once(function()
		DieSignal:Disconnect()
		DieSignal = nil
		DestroyingSignal:Disconnect()
		DestroyingSignal = nil

		table.remove(Characters,table.find(Characters,Character))
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
		EndTime = os.clock() + Duration,
		IsImmune = Immune,
		Hit = GoodSignal.new(),
		_Janitor = Janitor.new()
	}

	table.insert(Managing,NewHitbox)
	NewHitbox._Janitor:Add(NewHitbox.Hit,"DisconnectAll")
	NewHitbox._Janitor:LinkToInstance(Part)

	if not CheckConnection then
		CheckConnection = CleanUpLoop:Add(Heartbeat:Connect(HitboxChecker),"Disconnect")
	end

	VisualizeHitbox(NewHitbox)

	return NewHitbox
end



function HitboxManager.Destroy(Hitbox: SillyHitbox): ()
    --[[
        Description: This function will destroy the hitbox. Voiding the hitbox and its properties.
        This can be called to prematurely stop an active hitbox.
        Arguments: Hitbox (custom dictionary type.)
        Returns: Void
    ]]

	local FindHitbox = table.find(Managing,Hitbox)

	if FindHitbox then
		Hitbox.Hit:DisconnectAll()

		if VisualHitboxes then
			Hitbox.Visual:Destroy()
		end

		local hasJanitor = Hitbox._Janitor
		if hasJanitor then
			hasJanitor:Destroy()
		end

		table.remove(Managing,FindHitbox)

		Hitbox = nil
		FindHitbox = nil
	end
end



-- Runs settings
if AutoAddPlayers then
	for _, Player in ipairs(Players:GetPlayers()) do -- players whom loaded before keep this
		HitboxManager.AddCharacter(Player.Character)
	end

	AutoAddPlayers = Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAppearanceLoaded:Connect(function(Character)
			HitboxManager.AddCharacter(Character)
		end)
	end)
end

return HitboxManager
