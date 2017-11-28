--[[
    mini client framework based on luasocket
--]]

--only works on lua 5.1
local socket = require("socket")
--alternative for string.pack and string.unpack in lua 5.3
require('pack')
require('defines')

local function sendPacket(client, opcode, fmt, ...)
    local shakeReq = 0
    local pack = string.pack('Hi'..fmt, opcode, shakeReq, ...)
    pack = string.pack('>H<A', #pack, pack)
    return client:send(pack)
end

--mini client framework 
local host = host or "localhost"
local port = port or 8686
local ipv6 = true
local master = assert(ipv6 and socket.tcp6() or socket.tcp())
assert(master:connect(host, port))
local client = master
print('connection established on', client:getpeername())

while true do
    print('input message to send:')
    local input = io.read()
    local index, error = #input > 0 and sendPacket(client, CMSG_MINI, 'PP', 'P', input)
        or sendPacket(client, CMSG_PING, 'I', os.time())
    if index ~= nil then
        print(index, 'byte was sent')
    else
        print(error)
        client:close()
        break
    end
end