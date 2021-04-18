AddCSLuaFile()

SWEP.Base = "sb_anb_payday2_m4"
SWEP.PrintName = "CAR-4 (Taser M4) for SB ANB PAYDAY 2"

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Initialize()
	BaseClass.Initialize(self)
	
	self:SetSkin(1)
end