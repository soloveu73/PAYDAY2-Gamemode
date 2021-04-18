AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Spawnable = true
ENT.Type = "point"

if CLIENT then return end

local delay = 0.02
local stealth = 0.5

local bone_table = {
2,
6,
10,
11,
15,
16,
19,
20,
23,
24,
}
function ENT:TraceBoneCount(ent)
local count,vec = 0
for i,v in pairs(bone_table) do
    vec = ent:GetBonePosition(v)
    local tr = util.TraceLine( {
        start = self:GetPos()+self:GetAngles():Forward()*5,
        endpos = vec,
        filter = {self,ent},
        mask=MASK_ALL
    } )
    if not tr.Hit then
        count = count + 1
    end
end
return count
end

local function camera_think()
local tab = ents.FindByClass('camera')
	while true do
		if table.IsEmpty(tab) then tab = ents.FindByClass('camera') end
		if table.IsEmpty(tab) then timer.Stop('camera_think') coroutine.yield() end
		for i, ent in pairs( tab ) do
			ent:think()
		end
	coroutine.yield()
	end
end
local co
timer.Create('camera_think',delay,0,function()
	if not co or not coroutine.resume( co ) then
		co = coroutine.create(camera_think)
		coroutine.resume( co )
	end
	
	-- end
		-- ply:SetNWFloat("stealth_pd2", math.max(ply:GetNWFloat("stealth_pd2")-stealth*delay/4, 0))
end )
timer.Stop('camera_think')

function ENT:Initialize()
timer.Start('camera_think')

self.NextFrame = 0
self.Active = true
self.Alarm = true
self.inconetableent = {}

local model = ents.Create('prop_dynamic')
model:SetModel('models/props/cs_assault/camera.mdl')
model:SetPos(self:GetPos())
model:SetAngles(self:GetAngles())
model:Spawn()
model:SetParent(self)
end

function ENT:think()
if not self.Active then return end
if self.NextFrame <= CurTime() then
self.NextFrame = CurTime() + delay
	local cone = ents.FindInCone(self:GetPos(), self:GetAngles():Forward(), 300, math.cos(math.rad(45)))
	for i, ent in pairs(cone) do
		if ent:IsPlayer() then
			if ent:Alive() and self:TraceBoneCount(ent) > 0 then
				if not self.inconetableent[ent] then 
					self.inconetableent[ent]=CurTime() 
				end
			end
		end
	end
	for k,v in pairs(self.inconetableent) do
		if not IsValid(k) then print(true) table.RemoveByValue(self.inconetableent,v) end
		if not table.HasValue(cone,k) then table.RemoveByValue(self.inconetableent,v) end
		k:ChatPrint(tostring(CurTime()-v>1/stealth))
		print(CurTime()-v)
		if CurTime()-v>1/stealth then
			self.Alarm = true
		end
	end
end
end