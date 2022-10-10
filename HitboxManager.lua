local visual:boolean = true -- change this to false if you don't want to see the visual.

local janitor = require(script.Janitor)
local goodSignal = require(script.GoodSignal)

local players = game:GetService("Players")
local heartbeat = game:GetService("RunService").Heartbeat

local _janitor = janitor.new()
local checkConnection

local HitboxManager = {
	managing = {},
	characters = {}
}

function HitboxManager:AddCharacter(character:Model)
	task.spawn(function()
		if not character:FindFirstChildOfClass("Humanoid") and not character:FindFirstChild("HumanoidRootPart") then
			warn("Character doesn't have a Humanoid and or doesn't have a HumanoidRootPart. Won't add the character")
		elseif table.find(HitboxManager.characters,character) then
			warn("Character is already in the table! Won't re-add the character.")
		else
			table.insert(self.characters,character)
		end
	end)
end


for _, player in pairs(players:GetPlayers()) do -- players whom loaded before keep this
	HitboxManager:AddCharacter(player.Character)
end

--[[
IMPORTANT

remove this connection if you have you have another connection similar to this 
and add the function HitboxManager:AddCharacter(character) in.

To add npcs to the hitbox manager you'll need to put in a :AddCharacter(NPC) so it'll get affected 
by the hitboxes.

local NPCS = path to NPCS folder 
for _,NPC in pairs(workspace.NPCS:GetChildren()) do -- this is how you add npcs who are in a folder.
	hitboxManager:AddCharacter(NPC)
end
]]
players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(character)
		HitboxManager:AddCharacter(character)
	end)
end)
--

local function visualize(hitbox)
	if visual then
		local newVisual = Instance.new("Part")
		newVisual.Parent = workspace
		newVisual.CFrame = hitbox.part.CFrame
		newVisual.Size = Vector3.new(hitbox.range*2,hitbox.range*2,hitbox.range*2)
		newVisual.CanCollide = false
		newVisual.Massless = true
		newVisual.BrickColor = BrickColor.new("Bright red")
		newVisual.Transparency = .7
		newVisual.Shape = Enum.PartType.Ball
		
		local weld = Instance.new("Weld")
		weld.Parent = newVisual
		weld.Part0 = newVisual
		weld.Part1 = hitbox.part
		
		hitbox.Visual = newVisual
	end
end

local function checkHumanoid(hitbox)
	task.spawn(function()
		for _,character in ipairs(HitboxManager.characters) do
			if (hitbox.part.Position - character.HumanoidRootPart.Position).Magnitude <= hitbox.range then
				if not table.find(hitbox.hit,character) then
					table.insert(hitbox.hit,character)
					hitbox.Hit:Fire(character.Humanoid)
				end
			end
			
			--checks if the character is gone or dead.
			if not character or not character.Parent or character.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
				table.remove(HitboxManager.characters,table.find(HitboxManager.characters,character))
			end
		end
	end)
end

local function hitboxChecker()
	if #HitboxManager.managing == 0 then
		checkConnection:Disconnect()
		checkConnection = nil
	end
	for _,hitbox in pairs(HitboxManager.managing) do
		if os.clock() >= hitbox.endTime then 
			HitboxManager:Destroy(hitbox)
		else
			checkHumanoid(hitbox)
		end
	end
end

function HitboxManager:New(part:BasePart, range:number, duration:number, character:Model)
	local newHitbox = {
		part = part,
		range = range,
		endTime = os.clock() + duration,
		hit = {character},
		Hit = goodSignal.new(),
		_janitor = janitor.new()
	}
	table.insert(self.managing,newHitbox)
	newHitbox._janitor:Add(newHitbox.Hit,"DisconnectAll")
	newHitbox._janitor:LinkToInstance(part)
	
	if not checkConnection then
		checkConnection = _janitor:Add(heartbeat:Connect(hitboxChecker),"Disconnect")
	end
	
	visualize(newHitbox)
	
	return newHitbox
end

function HitboxManager:Destroy(hitbox)
	local findHitbox = table.find(self.managing,hitbox)
	if findHitbox then
		hitbox.Hit:DisconnectAll()

		if visual then
			hitbox.Visual:Destroy()
		end

		local hasJanitor = self._janitor
		if hasJanitor then
			hasJanitor:Destroy()
		end

		table.remove(self.managing,findHitbox)
	end

	print(HitboxManager.characters)
end

return HitboxManager
