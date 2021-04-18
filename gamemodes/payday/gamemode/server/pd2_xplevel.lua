local ply = FindMetaTable("Player")
local path = "pd2_xp_data/xp.txt"

if not file.IsDir( "pd2_xp_data", "DATA" ) then
	file.CreateDir("pd2_xp_data")
	file.Write( path, "76561198201651767 0" )
end

if not file.Exists( path, "DATA" ) then
	file.Write( path, "76561198201651767 0" )
end

local function getxptable()
	return string.Split(file.Read( path, "DATA" ), "\n")
end

local function getxptable_id(ply)
	local tab = getxptable()
	for i, v in pairs(tab) do
		local txt = string.Split(v, " ")
		if txt[1] == ply:SteamID64() then
			return i
		end
	end
end

local function rewritexp(id, number)
	local tab = string.Split(file.Read( path, "DATA" ), "\n")
	local replace = string.Split(tab[id], " ")[1].." "..tostring(number)
	tab[id] = replace
	local txt = ""
	for i, t in pairs(tab) do
		txt = txt..t.."\n"
	end
	txt = string.Left(txt,string.len(txt)-1)
	file.Write( path, txt )
end

function ply:pd2_set_xp(xp)
	rewritexp(getxptable_id(self), xp)
	self:pd2_update_level()
end

function ply:pd2_add_xp(xp)
	rewritexp(getxptable_id(self), xp+self:pd2_get_xp())
	self:pd2_update_level()
end

function ply:pd2_get_xp()
	local tab = getxptable()
	for k, v in pairs(tab) do
		local txt = string.Split(v, " ")
		if txt[1] == self:SteamID64() then
			return tonumber(txt[2])
		end
	end	
end

function ply:pd2_update_level()
	local level = self:GetNWInt("pd2_level_data")
	local xp = math.min(math.floor(self:pd2_get_xp()/1000), 5050)
	local i = 0
	while xp > 0 do
		i = i+1
		xp = xp-i
	end
	if xp < 0 then
		i = i-1
	end
	self:SetNWInt("pd2_level_data", i)
	if self:GetNWInt("pd2_level_data") != level then
		self:ChatPrint("You reached a "..tostring(i).." level.")
	end
end

hook.Add("PlayerInitialSpawn", "pd2_player_join_steamid_xp", function(ply)
	if not game.SinglePlayer() and not ply:IsBot() then
		local tab = getxptable()
		local exist = false
		for k, v in pairs(tab) do
			local txt = string.Split(v, " ")
			if txt[1] == ply:SteamID64() then
				exist = true
			end
		end
		if not exist then file.Append(path, "\n"..ply:SteamID64().." 0") end
		ply:pd2_add_xp(0)
	end
end)