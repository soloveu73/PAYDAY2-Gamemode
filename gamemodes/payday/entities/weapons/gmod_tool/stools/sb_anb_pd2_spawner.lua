
TOOL.Category = "PAYDAY 2"
TOOL.Name = "PAYDAY 2 NextBots Police Spawner"

TOOL.ClientConVar["difficulty"] = 0
TOOL.ClientConVar["maxonmap"] = 0
TOOL.ClientConVar["hpdifficulty"] = 0
TOOL.ClientConVar["proficiency"] = 0
TOOL.ClientConVar["classes"] = ""
TOOL.ClientConVar["policechase"] = 1
TOOL.ClientConVar["spawndelay"] = 1
TOOL.ClientConVar["spawnenabled"] = 1

TOOL.Information = {
	{name = "left"},
	{name = "right"},
	{name = "reload"},
}

if CLIENT then
	language.Add("tool.sb_anb_pd2_spawner.name",TOOL.Name)
	language.Add("tool.sb_anb_pd2_spawner.desc","Spawner, that can be used to create your own assault system from PAYDAY 2. Spawns only Police classes.")
	language.Add("tool.sb_anb_pd2_spawner.left","Create spawner.")
	language.Add("tool.sb_anb_pd2_spawner.right","Update spawner.")
	language.Add("tool.sb_anb_pd2_spawner.reload","Copy info from spawner.")
end

local function TableClassesToString(data)
	local str = ""
	
	for k,v in ipairs(data) do
		str = str..";"..v[1]..";"..v[2]..";"..v[3]..";"..v[4]..";"
		
		if v[5] then
			for i=1,#v[5] do
				str = str..(i==1 and "" or ",")..v[5][i]
			end
		end
	end
	
	return str:sub(2,-1)
end

local function StringToTableClasses(data)
	local tab = {}
	
	local stage,cur = 0
	for k,v in ipairs(string.Explode(";",data)) do
		if stage==0 then
			cur = {v}
		elseif stage==1 or stage==2 or stage==3 then
			local val = tonumber(v)
			if !val then return end
		
			cur[#cur+1] = val
		elseif stage==4 then
			if v!="" then
				local t = {}
				
				for k2,v2 in ipairs(string.Explode(",",v)) do
					local val = tonumber(v2)
					if !val then return end
					
					t[#t+1] = val
				end
				
				cur[#cur+1] = t
			end
		end
		
		if stage==4 then
			stage = 0
			tab[#tab+1] = cur
		else
			stage = stage+1
		end
	end
	
	return tab
end

function TOOL:LeftClick(trace)
	local difficulty = math.Clamp(math.floor(self:GetClientNumber("difficulty",0)),0,7)
	local maxonmap,hpdiff,prof,classes
	
	if difficulty==0 then
		maxonmap = math.Clamp(math.floor(self:GetClientNumber("maxonmap",0)),0,100)
		hpdiff = math.Clamp(math.floor(self:GetClientNumber("hpdifficulty",0)),0,4)
		prof = math.Clamp(math.floor(self:GetClientNumber("proficiency",0)),0,5)
		classes = StringToTableClasses(self:GetClientInfo("classes"))
		
		if !classes then return false end
	end
	
	local policechase = tobool(self:GetClientNumber("policechase",1))
	local spawndelay = math.Clamp(self:GetClientNumber("spawndelay",1),1,60)
	
	if SERVER then
		local ang = trace.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(),90)
	
		local ent = ents.Create("sb_advanced_nextbot_payday2_spawner")
		ent:SetPos(trace.HitPos+trace.HitNormal)
		ent:SetAngles(ang)
		ent:SetData(difficulty,maxonmap,hpdiff,prof,classes,policechase,spawndelay)
		ent.Owner = self:GetOwner()
		ent.SpawnEnabled = tobool(self:GetClientNumber("spawnenabled",1))
		ent:Spawn()
		
		undo.Create("PAYDAY 2 NextBots Spawner")
			undo.AddEntity(ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	end

	return true
end

function TOOL:RightClick(trace)
	local ent = trace.Entity
	if !IsValid(ent) or ent:GetClass()!="sb_advanced_nextbot_payday2_spawner" then return false end
	
	local difficulty = math.Clamp(math.floor(self:GetClientNumber("difficulty",0)),0,7)
	local maxonmap,hpdiff,prof,classes
	
	if difficulty==0 then
		maxonmap = math.Clamp(math.floor(self:GetClientNumber("maxonmap",0)),0,100)
		hpdiff = math.Clamp(math.floor(self:GetClientNumber("hpdifficulty",0)),0,4)
		prof = math.Clamp(math.floor(self:GetClientNumber("proficiency",0)),0,5)
		classes = StringToTableClasses(self:GetClientInfo("classes"))
		
		if !classes then return false end
	end
	
	local policechase = tobool(self:GetClientNumber("policechase",1))
	local spawndelay = math.Clamp(self:GetClientNumber("spawndelay",1),1,60)
	
	if SERVER then
		ent:SetData(difficulty,maxonmap,hpdiff,prof,classes,policechase,spawndelay)
	end
	
	return true
end

function TOOL:Reload(trace)
	local ent = trace.Entity
	if !IsValid(ent) or ent:GetClass()!="sb_advanced_nextbot_payday2_spawner" then return false end
	
	if SERVER then
		local difficulty,maxonmap,hpdiff,prof,classes,policechase,spawndelay = ent:GetData()
	
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_difficulty "..difficulty)
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_maxonmap "..maxonmap)
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_hpdifficulty "..hpdiff)
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_proficiency "..prof)
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_classes \""..TableClassesToString(classes).."\"")
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_policechase "..(policechase and 1 or 0))
		self:GetOwner():ConCommand("sb_anb_pd2_spawner_spawndelay "..spawndelay)
	end

	return true
end

function TOOL:Think()
end

function TOOL:Holster()
end

function TOOL.BuildCPanel(CPanel)
	CPanel:Help("Spawner settings")
	
	CPanel:Help("Difficulty. Automatically sets Classes and Max count of bots according difficulty.")
	
	local max,hpdiff,prof,classes_control,classes_list
	
	local diff = CPanel:NumSlider("","sb_anb_pd2_spawner_difficulty",0,7,0)
	diff.OnValueChanged = function(s,val)
		val = math.Round(val)
	
		s:SetText(
			val==0 and "Custom" or
			val==1 and "Normal" or
			val==2 and "Hard" or
			val==3 and "Very hard" or
			val==4 and "Overkill" or
			val==5 and "Mayhem" or
			val==6 and "Death wish" or
			val==7 and "Death Sentence" or "???"
		)
		
		local custom = val==0
		
		max:SetEnabled(custom)
		hpdiff:SetEnabled(custom)
		prof:SetEnabled(custom)
		classes_control:SetEnabled(custom)
		classes_control.AddClass:SetEnabled(custom)
		classes_control.Normalize:SetEnabled(custom)
		classes_list:SetEnabled(custom)
	end
	
	CPanel:Help("Max count of bots (including bots spawned by other spawners).")
	max = CPanel:NumSlider("Max count","sb_anb_pd2_spawner_maxonmap",0,100,0)
	
	CPanel:Help("Health and headshot multipliers. According to difficulty.")
	hpdiff = CPanel:NumSlider("","sb_anb_pd2_spawner_hpdifficulty",0,4,0)
	hpdiff.OnValueChanged = function(s,val)
		val = math.Round(val)
	
		s:SetText(
			val==0 and "Normal/Hard" or
			val==1 and "Very Hard" or
			val==2 and "Overkill" or
			val==3 and "Mayhem" or
			val==4 and "Death Wish/Death Sentence"
		)
	end
	
	CPanel:Help("Weapon proficiency. Affects on bot's weapon spread.")
	prof = CPanel:NumSlider("Weapon proficiency","sb_anb_pd2_spawner_proficiency",0,5,0)
	prof.OnValueChanged = function(s,val)
		val = math.Round(val)
	
		s:SetText(
			val==0 and "Default" or
			val==1 and "Poor" or
			val==2 and "Average" or
			val==3 and "Good" or
			val==4 and "Very good" or
			val==5 and "Perfect"
		)
	end
	
	CPanel:Help("Classes of bots to spawn.")
	
	classes_list = vgui.Create("DListView")
	classes_list:AddColumn("Class/Group"):SetWidth(150)
	classes_list:AddColumn("Max"):SetWidth(30)
	classes_list:AddColumn("%"):SetWidth(30)
	classes_list:AddColumn("Variants")
	classes_list:SetTall(200)
	
	local ENT = scripted_ents.GetStored("sb_advanced_nextbot_payday2").t
	
	classes_list.SetupClasses = function(s)
		s:Clear()
	
		local data = StringToTableClasses(GetConVarString("sb_anb_pd2_spawner_classes"))
		if !data then return end
		
		for k,v in ipairs(data) do
			local dt = ENT[v[2]==1 and "BotGroups" or "BotClasses"][v[1]]
			
			local line = s:AddLine((v[2]==1 and "(Group) " or "")..(dt and dt.Name or "#"..v[1]),v[3],v[4],v[5] and table.concat(v[5],",") or "")
			line.data = v
			
			line.OnRightClick = function(self)
				local menu = DermaMenu()
				menu:AddOption("Change Max",function()
					if !IsValid(self) then return end
					
					Derma_StringRequest("Enter Max","Enter max amount of this class/group of bots on map.",self:GetColumnText(2),function(text)
						if !IsValid(self) then return end
						
						local value = tonumber(text)
						
						if value then
							v[3] = math.Clamp(math.floor(value),0,100)
							
							GetConVar("sb_anb_pd2_spawner_classes"):SetString(TableClassesToString(data))
						end
					end)
				end)
				menu:AddOption("Change Percentage",function()
					if !IsValid(self) then return end
					
					Derma_StringRequest("Enter Percentage","Enter percentage of spawn of this class/group of bots.",self:GetColumnText(3),function(text)
						if !IsValid(self) then return end
						
						local value = tonumber(text)
						
						if value then
							v[4] = math.max(0,math.Round(value,1))
							
							GetConVar("sb_anb_pd2_spawner_classes"):SetString(TableClassesToString(data))
						end
					end)
				end)
				menu:AddOption("Change Variants",function()
					if !IsValid(self) then return end
					
					Derma_StringRequest("Enter Variants","Enter variants that bot can use. Example: '1,2'",self:GetColumnText(4),function(text)
						if !IsValid(self) then return end
						
						if text=="" then
							v[5] = nil
						else
							local t = {}
							
							for k2,v2 in ipairs(string.Explode(",",text)) do
								local val = tonumber(v2:Trim())
								if !val then return end
								
								if v[2]==1 then
									local leader = ENT.BotClasses[dt.LeaderClass]
									if !leader or !leader.Variants[val] then continue end
									
									local member = ENT.BotClasses[dt.MemberClass]
									if !member or !member.Variants[val] then continue end
								else
									if !dt.Variants[val] then continue end
								end
								
								t[#t+1] = val
							end
						
							v[5] = t
						end
						
						GetConVar("sb_anb_pd2_spawner_classes"):SetString(TableClassesToString(data))
					end)
				end)
				menu:AddSpacer()
				menu:AddOption("Remove",function()
					if !IsValid(self) then return end
					
					table.remove(data,k)
					
					GetConVar("sb_anb_pd2_spawner_classes"):SetString(TableClassesToString(data))
				end)
				
				menu:Open()
			end
		end
	end
	
	Derma_Install_Convar_Functions(classes_list)
	classes_list.SetValue = classes_list.SetupClasses
	classes_list.Think = classes_list.ConVarStringThink
	
	classes_list:SetConVar("sb_anb_pd2_spawner_classes")
	
	classes_control = vgui.Create("DPanel")
	classes_control:SetTall(44)
	
	classes_control.AddClass = classes_control:Add("DButton")
	classes_control.AddClass:SetText("Add Class/Group")
	classes_control.AddClass:Dock(TOP)
	classes_control.AddClass.DoClick = function(s)
		local menu = DermaMenu()
		
		local function CreateClassGroup(name,isgroup)
			local data = StringToTableClasses(GetConVarString("sb_anb_pd2_spawner_classes")) or {}
			table.insert(data,{name,isgroup and 1 or 0,0,0})
			
			GetConVar("sb_anb_pd2_spawner_classes"):SetString(TableClassesToString(data))
		end
		
		for k,v in pairs(ENT.BotGroups) do
			menu:AddOption("(Group) "..v.Name,function()
				if !IsValid(s) then return end
				
				CreateClassGroup(k,true)
			end)
		end
		
		menu:AddSpacer()
		
		for k,v in pairs(ENT.BotClasses) do
			menu:AddOption(v.Name,function()
				if !IsValid(s) then return end
				
				CreateClassGroup(k,false)
			end)
		end
		
		menu:Open()
	end
	
	classes_control.Normalize = classes_control:Add("DButton")
	classes_control.Normalize:SetText("Normalize percentage")
	classes_control.Normalize:Dock(TOP)
	classes_control.Normalize.DoClick = function(s)
		local data = StringToTableClasses(GetConVarString("sb_anb_pd2_spawner_classes")) or {}
		local count = 0
		
		for k,v in ipairs(data) do
			count = count+v[4]
		end
		
		if count>0 then
			count = count/100
		
			for k,v in ipairs(data) do
				v[4] = math.Round(v[4]/count,1)
			end
			
			GetConVar("sb_anb_pd2_spawner_classes"):SetString(TableClassesToString(data))
		end
	end
	
	CPanel:AddItem(classes_control)
	CPanel:AddItem(classes_list)
	
	diff:SetValue(GetConVarNumber("sb_anb_pd2_spawner_difficulty"))
	
	CPanel:Help("Delay between bot spawns in seconds.")
	CPanel:NumSlider("Spawn Delay","sb_anb_pd2_spawner_spawndelay",1,60,0)
	
	CPanel:Help("Chasing behaviour. Enables chasing behaviour if bot can not find enemy for a long time.")
	CPanel:CheckBox("Chasing","sb_anb_pd2_spawner_policechase")
	
	CPanel:Help("Spawn enabled. Should be spawner enabled when created?")
	CPanel:CheckBox("Spawn enabled","sb_anb_pd2_spawner_spawnenabled")
end
