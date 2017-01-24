--[[
	implict replace direct field access by getter and setter function call
--]]

local function index(classType, self, key)
    local val = classType[key]
    if val == nil then
	    local getFunc = classType.__get[key]
	    if getFunc ~= nil then
	        val = getFunc(self)
	    end
    end
    return val
end

local function class(className, super)
	local classType =
	{
		__className = className,
		__super = super,
		__get = {},
		__set = {},
	}

	function classType.__index(self, key)
		local val = index(classType, self, key)
		if val == nil and classType.__super then
			val = index(classType.__super, self, key)
		end
		return val
	end

	function classType.__newindex(self, key, val)
	    local setFunc = classType.__set[key]
	    if setFunc == nil and classType.__supper then
	    	setFunc = classType.__super.__set[key]
	    end
	    if setFunc then
	        setFunc(self, val)
	    else
	    	rawset(self, key, val)
	    end
	end

    function classType.new(...)
        local self = setmetatable({}, classType)
        local ctor = classType[classType.__className]
        if ctor and type(ctor) == 'function' then
        	ctor(self, ...)
        end
        return self
    end

    return classType
end

return class