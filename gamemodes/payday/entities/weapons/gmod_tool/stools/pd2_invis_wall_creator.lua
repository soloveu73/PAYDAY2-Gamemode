TOOL.Category = "PAYDAY 2"
TOOL.Name = "Invisible Wall Creator"

TOOL.Mode = false
TOOL.Triggers = {}
TOOL.Vector = nil
TOOL.Points = {pos1 = nil, pos2 = nil}

if SERVER then
	function TOOL:LeftClick()
      snet.ClientRPC(self, 'LeftClick')
   end

   function TOOL:RightClick()
      snet.ClientRPC(self, 'RightClick')
   end

   function TOOL:Reload()
      snet.ClientRPC(self, 'Reload')
   end
else
    function TOOL:LeftClick()
    	local tr = self:GetTrace()
    	if not tr.Hit then return end
    	local pos = tr.HitPos
    	if not self.Mode then
    		self.Vector = pos
    		self.Mode = not self.Mode 
    	else
    		if not self.Points.pos1 then
    			self.Points.pos1 = pos
    		elseif not self.Points.pos2 then
    			self.Points.pos2 = pos
    		else
    			local trigger = triggerclass_pd2:Instance(self.Points.pos1, self.Points.pos2, self.Vector)
    			table.insert(self.Triggers, trigger)
    		end
    	end
    end

    function TOOL:RightClick()

    end

    function TOOL:Reload()
    	self.Mode = false
		self.Triggers = {}
		self.Vector = nil
		self.Points = {pos1 = nil, pos2 = nil}
    end

    function TOOL:GetTrace()
       local ply = self:GetOwner()
       local tr = util.TraceLine({
          start = ply:GetShootPos(),
          endpos = ply:GetShootPos() + ply:GetAimVector() * 1000,
          filter = function(ent)
             if ent ~= ply then 
                return true
             end
          end
       })
       return tr
    end
    hook.Add('PostDrawOpaqueRenderables', 'TriggerShowTool', function()
  		local wep = LocalPlayer():GetActiveWeapon()
  		if not IsValid(wep) or wep:GetClass() ~= 'gmod_tool' then return end
  		local tool = ply:GetTool()
  		if not tool or not tool.GetMode or tool:GetMode() ~= 'pd2_invis_wall_creator' then return end
  		for k, v in ipairs(tool.Triggers) do
  			render.SetColorMaterial()
			render.SetMaterial(Material("color"))

			local center = (v.pos1 + v.pos2) / 2

			render.DrawWireframeBox(center, 
			Angle(0, 0, 0), 
			center - v.pos1, 
			center - v.pos2, 
			Color(255, 255, 255)
			)

			render.DrawBox(center, 
			Angle(0, 0, 0), 
			center - v.pos1, 
			center - v.pos2, 
			Color(135, 135, 135, 100)
			)
  		end
	end)
end

