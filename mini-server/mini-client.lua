--[[
    mini client framework based on luasocket
--]]

--only works on lua 5.1
local socket = require("socket")
--alternative for string.pack and string.unpack in lua 5.3
require('pack')
require('defines')

local function sendPacket(sock, opcode, fmt, ...)
    local shakeReq = 0
    local pack = string.pack('Hi'..fmt, opcode, shakeReq, ...)
    pack = string.pack('>H<A', #pack, pack)
    return sock:send(pack)
end

--mini client framework 
local host = host or "localhost"
local port = port or 868600
local sock = assert(socket.connect(host, port))
print('connection established on', sock:getpeername())

while true do
    print('input message to send:')
    local input = io.read()
    if #input > 0 then
        sendPacket(sock, CMSG_MINI, 'PP', 'P', input)
    else
        sendPacket(sock, CMSG_PING, 'I', os.time())
    end
end