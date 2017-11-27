--[[
  mini server framework based on luasocket
--]]

--only works on lua 5.1
local socket = require("socket")
--alternative for string.pack and string.unpack in lua 5.3
require('pack')
require('defines')

--message handlers
local handlers = {}
--format: pingReq(I)
handlers[CMSG_PING] = function(client, opcode, data, index)
    print('CMSG_PING', select(2, string.unpack(data, 'I', index)))
    --response SMSG_PONG
    client:send(string.pack('>H<H', SIZE_SHORT, SMSG_PONG))
end

--format: fmt(P), ...
handlers[CMSG_MINI] = function(client, opcode, data, index)
    local index, dataFmt = string.unpack(data, 'P', index)
    print('CMSG_MINI', select(2, string.unpack(data, dataFmt, index)))
    client:send(string.pack('>H<H', SIZE_SHORT, SMSG_MINI))
end

--format: packSize(H),opcode(H)[,shakeReq(i),message(binary)]
local function unpackPacket(client, packData, packSize)
    local index, opcode, shakeReq = string.unpack(packData, 'Hi')
    local handlerFunc = handlers[opcode]
    if handlerFunc then
      handlerFunc(client, opcode, packData, index)
    else
      print('handler not found for opcode', opcode)
    end
end

--mini server framework
local host = host or "localhost"
local port = port or 8686
local master = assert(socket.tcp())
assert(master:bind(host, port))
assert(master:listen())

local server = master
while true do
  print('waiting connections on', server:getsockname())
  local client = assert(server:accept())
  print('connection accepted', client:getpeername())
  while true do
    --ushort header for packSize
    local packSize, error = client:receive(SIZE_SHORT)
    if packSize then
      --big endian for the first header, little endian for the rest
      _,packSize = string.unpack(packSize, '>H')
      local packData = assert(client:receive(packSize))
      unpackPacket(client, packData, packSize)
    else
      print(error); client:close(); break
    end
  end
end