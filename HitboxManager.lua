local visual = false --change this to true if you want to see the hitbox

local janitor = require(script.Janitor)
local goodSignal = require(script.GoodSignal)

local heartbeat = game:GetService("RunService").Heartbeat

local HitboxManager = {
	managing = {},
	characters = {}
}
workspace.DescendantAdded:Connect(function(new)
	if new.ClassName == "Humanoid" then
		table.insert(HitboxManager.characters,new.Parent)
	end
end)

local _janitor = janitor.new()
local checkConnection

function visualize(hitbox)
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

function checkHumanoid(hitbox)
	for _,character in ipairs(HitboxManager.characters) do
		if (hitbox.part.Position - character.HumanoidRootPart.Position).Magnitude <= hitbox.range then
			if not table.find(hitbox.hit,character) then
				table.insert(hitbox.hit,character)
				hitbox.Hit:Fire(character.Humanoid)
			end
		end
	end
end

function hitboxChecker()
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
	for i,v in pairs(self.managing) do
		if v == hitbox then
			hitbox.Hit:DisconnectAll()

			if visual then
				hitbox.Visual:Destroy()
			end

			local hasJanitor = self._janitor
			if hasJanitor then
				hasJanitor:Destroy()
			end

			self.managing[i] = nil
			break
		end
	end
end

return HitboxManager
