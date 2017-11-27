local function printf(val)
    print(string.format('%.32f', val))
end
local x = 1.0
local y = 0.1
local n = math.floor(x / y)
printf(x)
printf(y)
printf(x % y)
printf(math.fmod(x, y))
printf(x - math.floor(x/y) * y)