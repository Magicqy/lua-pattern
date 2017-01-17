local class = require('getter-setter')

local Hero = class('Hero')

function Hero.get:level()
	return self._level
end

function Hero.set:level(val)
	self._level = val
end

function Hero.get:attack()
	return 10*self.level
end

function Hero:Hero(level)
	self.level = level
end

--test case
local h = Hero.new(5)

print('---class---')
for k,v in pairs(Hero) do print(k,v) end
print('---getter---')
for k,v in pairs(Hero.get) do print(k,v) end
print('---setter---')
for k,v in pairs(Hero.set) do print(k,v) end

print('---property---')
print(h.level, h.attack)
h.level = 10
print(h.level, h.attack)
--failed
--h.attack = 1