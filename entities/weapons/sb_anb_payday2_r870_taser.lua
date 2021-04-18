AddCSLuaFile()

SWEP.Base = "sb_anb_payday2_r870"
SWEP.PrintName = "Reinfeld 880 (Taser R870) for SB ANB PAYDAY 2"

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Initialize()
	BaseClass.Initialize(self)
	
	self:SetSkin(1)
end