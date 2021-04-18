local serverphases = CreateConVar("pd2_assaultphases_serverphases","0",bit.bor(FCVAR_ARCHIVE,FCVAR_REPLICATED),"If enabled, will be used server values on clients.",0,1)
local servermusic = CreateConVar("pd2_assaultphases_server_music","",bit.bor(FCVAR_ARCHIVE,FCVAR_REPLICATED),"Internal name of music to play.")
local assaultphase = CreateConVar("pd2_assaultphases_server_assaultphase","0",FCVAR_REPLICATED,"Current assault phase. 0 - Disabled, 1 - Stealth, 2 - Control/Anticipation, 3 - Assault, 4 - Fade.",0,4)
local controltime = CreateConVar("pd2_assaultphases_server_controlduration","60",bit.bor(FCVAR_ARCHIVE,FCVAR_REPLICATED),"Control phase duration. Used to properly play Anticipation music.",0,600)
local asbar_capenabled = CreateConVar("pd2_assaultphases_server_assaultbar_captainenabled","0",bit.bor(FCVAR_ARCHIVE,FCVAR_REPLICATED),"Drawing assault bar as if there is a Captain Winters.",0,1)
local asbar_text = CreateConVar("pd2_assaultphases_server_assaultbar_text","",bit.bor(FCVAR_ARCHIVE,FCVAR_REPLICATED),"Custom text for Assault bar. Make empty '' to use default.")
local asbar_difficulty = CreateConVar("pd2_assaultphases_server_assaultbar_difficulty","0",bit.bor(FCVAR_ARCHIVE,FCVAR_REPLICATED),"Affects on skulls on Assault bar, according to PAYDAY 2 difficulty. 0 - Normal, 1 - Hard, 2 - Very Hard, 3 - Overkill, 4 - Mayhem, 5 - Death Wish, 6 - Death Sentence.",0,6)

local PhaseCycle
local LastControlAnticipation = 0

cvars.AddChangeCallback("pd2_assaultphases_server_assaultphase",function(cvar,old,new)
	if new=="2" then
		LastControlAnticipation = CurTime()
	end
end)

hook.Add("Think","pd2_assaultphases",function()
	if PhaseCycle then
		local time = SysTime()
		local phase = assaultphase:GetInt()
		local newphase = phase
		
		while true do
			if newphase==0 then
				newphase = 1
			elseif newphase==1 and time-PhaseCycle.Time>=PhaseCycle.Stealth then
				newphase = 2
				PhaseCycle.Time = time
				controltime:SetFloat(PhaseCycle.Control)
			elseif newphase==2 and time-PhaseCycle.Time>=PhaseCycle.Control then
				newphase = 3
				PhaseCycle.Time = time
			elseif newphase==3 and time-PhaseCycle.Time>=PhaseCycle.Assault then
				newphase = 4
				PhaseCycle.Time = time
			elseif newphase==4 and time-PhaseCycle.Time>=PhaseCycle.Fade then
				newphase = 1
				PhaseCycle.Time = time
				
				if phase==0 or phase==1 then
					newphase = phase
					PhaseCycle = nil
					assaultphase:SetInt(0)
					
					break
				end
			else
				break
			end
		end
		
		if newphase!=phase then assaultphase:SetInt(newphase) end
	end
end)

concommand.Add("pd2_assaultphases_server_cycle",function(ply,cmd,args,argstr)
	if IsValid(ply) and !ply:IsSuperAdmin() then return end

	if #args==0 then
		PhaseCycle = nil
		assaultphase:SetInt(0)
	
		return
	end

	local stealth = math.max(0,tonumber(args[1]) or 0)
	local control = math.max(0,tonumber(args[2]) or 60)
	local assault = math.max(0,tonumber(args[3]) or 180)
	local fade = math.max(0,tonumber(args[4]) or 20)
	
	PhaseCycle = {
		Time = SysTime(),
		Stealth = stealth,
		Control = control,
		Assault = assault,
		Fade = fade,
	}
	
	assaultphase:SetInt(0)
end)

pd2_assaultphases_GetPoliceSpawnForce = function()
	local phase = assaultphase:GetInt()
	if phase==0 then return -1 end
	
	if phase==1 then return 0 end
	if phase==3 then return 1 end
	if phase==4 then return 0 end
	
	local controllen = controltime:GetFloat()
	local endtime = LastControlAnticipation+controllen
	
	if CurTime()<LastControlAnticipation then return 0 end
	if CurTime()>endtime then return 1 end
	
	return math.Remap(CurTime(),LastControlAnticipation,endtime,0,1)
end