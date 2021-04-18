/*---------------------------------
Created with buu342s Swep Creator
---------------------------------*/

SWEP.PrintName = "P220"
    
SWEP.Author = "HarionPlayZ"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to shoot."

SWEP.Category = "PAYDAY 2"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_pist_p228.mdl" 
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 1
 
SWEP.UseHands = false

SWEP.HoldType = "pistol" 

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair = true

SWEP.DrawAmmo = true

SWEP.ReloadSound = "weapons/p220/magout.wav"

SWEP.Base = "weapon_base"

SWEP.Primary.Sound = Sound("weapons/p220/p220-1.wav") 
SWEP.Primary.Damage = 20
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 13
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.DefaultClip = 130
SWEP.Primary.Spread = 0.2
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.06
SWEP.Primary.Force = 2

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CSMuzzleFlashes = false

function SWEP:Initialize()
util.PrecacheSound(self.Primary.Sound) 
util.PrecacheSound(self.ReloadSound) 
        self:SetWeaponHoldType( self.HoldType )
end 

function SWEP:PrimaryAttack()
 
if ( !self:CanPrimaryAttack() ) then return end
 
local bullet = {} 
bullet.Num = self.Primary.NumberofShots 
bullet.Src = self.Owner:GetShootPos() 
bullet.Dir = self.Owner:GetAimVector() 
bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
bullet.Tracer = 0 
bullet.Force = self.Primary.Force 
bullet.Damage = self.Primary.Damage 
bullet.AmmoType = self.Primary.Ammo 
 
local rnda = self.Primary.Recoil * -1 
local rndb = self.Primary.Recoil * math.random(-1, 1) 
 
self:ShootEffects()
 
self.Owner:FireBullets( bullet ) 
self:EmitSound(Sound(self.Primary.Sound)) 
self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
 
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Primary.Delay ) 
end 

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	self:EmitSound(Sound(self.ReloadSound)) 
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
end

