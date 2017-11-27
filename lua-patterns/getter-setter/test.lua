local class = require('getter-setter')

local Hero = class('Hero')

function Hero.__get:level()
	return self._level
end

function Hero.__set:level(val)
	self._level = val
end

function Hero.__get:attack()
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
for k,v in pairs(Hero.__get) do print(k,v) end
print('---setter---')
for k,v in pairs(Hero.__set) do print(k,v) end

print('---property---')
print(h.level, h.attack)
h.level = 10
print(h.level, h.attack)
--failed
--h.attack = 1