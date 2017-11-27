
local lpack = require('pack')
local str = string.char(128, 128)

print(string.unpack(string.pack('>h', 2), '<h'))
print(string.unpack(string.pack('h', 2), '<h'))
