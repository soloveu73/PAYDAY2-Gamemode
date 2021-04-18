AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Spawnable = true

function ENT:Initialize()
    self:SetModel("models/payday2/equipments/medicbag.mdl")
    self:SetColor(Color(255,255,255,0))
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use(activator)
	self:EmitSound("items/medshot4.wav")
	self:Remove()
	activator:SetHealth(activator:GetMaxHealth())
	activator:SetNumBleedOuts(0)
end
