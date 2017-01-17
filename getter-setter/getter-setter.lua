--[[
	implict replace direct field access by getter and setter function call
--]]

local function class(className, super)
	local getter = {}
	local setter = {}
	local cls =
	{
		__className = className,
		get = getter,
		set = setter,
	}

	function cls.__index(self, key)
	    local val = cls[key]
	    if val then
	    	return val
	    end
	    
	    local getFunc = getter[key]
	    if getFunc then
	        return getFunc(self)
	    end

	    return nil
	end

	function cls.__newindex(self, key, val)
	    local setFunc = setter[key]
	    if setFunc then
	        setFunc(self, val)
	        return
	    end

	    if getter[key] then
	        assert(false, "readonly property")
	    end
	    
		rawset(self, key, val)
	end

    function cls.new(...)
        local inst = setmetatable({}, cls)
        local ctor = cls[cls.__className]
        if ctor and type(ctor) == 'function' then
        	ctor(inst, ...)
        end
        return inst
    end

    return cls
end

return class