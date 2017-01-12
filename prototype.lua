--[[
	share properties between instances base on prototype
	restrict property assignment within prototype
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
			if proto[k] then
				rawset(t, k, v)
			else
				print('key not found in prototype:', k, v)
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
