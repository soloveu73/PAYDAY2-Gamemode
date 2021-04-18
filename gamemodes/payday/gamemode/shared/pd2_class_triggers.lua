triggerclass_pd2 = {}

function triggerclass_pd2:Instance(pos1, pos2, resetpos)
	local obj = {}
	obj.resetpos = resetpos
	obj.pos1 = pos1
	obj.pos2 = pos2
	function obj:IsSet()
   		return (not self.resetpos and not self.pos1 and not self.pos2)
	end
	return obj
end