--[[
	share properties between instances base on prototype
	restrict properties accessable within prototype
	
	note:
		override prototype property by set a not-nil value, set nil to reset
		default value in prototype can't be nil
--]]

local prototype = {}

function prototype.new(proto)
	return setmetatable({},
	{
		__index = function(t, k)
			local v = proto[k]
			if not v then v = prototype[k] end
			return v
		end,
		__newindex = function(t, k, v)
			local pv = proto[k]
			if pv ~= nil then
				if pv ~= v then rawset(t, k, v) end
			end
		end,
	})
end

function prototype:reset()
	for k, v in pairs(self) do
		rawset(self, k, nil)
	end
end

function prototype:update(values)
	for k, v in pairs(values) do
		self[k] = v
	end
end

return prototype
