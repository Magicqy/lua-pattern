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
handlers[CMSG_PING] = function(sock, opcode, data, index)
  print('CMSG_PING', select(2, string.unpack(data, 'I', index)),
    '<=', sock:getpeername())
  --response SMSG_PONG
  sock:send(string.pack('>H<H', SIZE_SHORT, SMSG_PONG))
end

--format: fmt(P), ...
handlers[CMSG_MINI] = function(sock, opcode, data, index)
  local index, dataFmt = string.unpack(data, 'P', index)
  print('CMSG_MINI', select(2, string.unpack(data, dataFmt, index)),
    '<=', sock:getpeername())
  sock:send(string.pack('>H<H', SIZE_SHORT, SMSG_MINI))
end

--format: packSize(H),opcode(H)[,shakeReq(i),message(binary)]
local function unpackPacket(sock, packData, packSize)
    local index, opcode, shakeReq = string.unpack(packData, 'Hi')
    local handlerFunc = handlers[opcode]
    if handlerFunc then
      handlerFunc(sock, opcode, packData, index)
    else
      print('handler not found for opcode', opcode)
    end
end

--mini server framework
local SELECT_TIMEOUT = 0.05
local host, port = "*", 868600
local sockConn = assert(socket.bind(host, port))
sockConn:settimeout(SELECT_TIMEOUT)
print('waiting connections on', sockConn:getsockname())

local checkConn = {sockConn}
local checkRecv = {}

local function checkSocket(recv, send, timeout)
  --select function return two tables, maybe poor performence
  local readable, writeable, error = socket.select(recv, send, timeout)
  if error then
    if error == 'timeout' then --just wait for next check
    else print('select error', error) end
  else
    return #readable > 0 and readable or nil, #writeable > 0 and writeable or nil
  end
end

while true do
  --check new connections
  local readable = checkSocket(checkConn, nil, SELECT_TIMEOUT)
  if readable then
    for _,sock in ipairs(readable) do
      local newConn = assert(sock:accept())
      print('connection accepted', newConn:getpeername())
      table.insert(checkRecv, newConn)
    end
  end
    
  --check readable connections
  if #checkRecv > 0 then
    local closedSock = {}
    local readable = checkSocket(checkRecv, nil, SELECT_TIMEOUT)
    if readable then
      for _,sock in ipairs(readable) do
        local packSize, error = sock:receive(SIZE_SHORT)
        if error then
          if error == 'closed' then table.insert(closedSock, sock)
          else print('receive error', error) end
        elseif packSize then
          --big endian for the first header, little endian for the rest
          _,packSize = string.unpack(packSize, '>H')
          local packData = assert(sock:receive(packSize))
          unpackPacket(sock, packData, packSize)
        else
          print('recvive unknown format, skiped')
          sock:receive('*a')
        end
      end
      --remove closed socket
      if #closedSock > 0 then
        for i,closed in ipairs(closedSock) do
          for j,conn in ipairs(checkRecv) do
            if closed == conn then
              print('connection closed ', conn:getpeername())
              table.remove(checkRecv, j)
              break
            end
          end
        end
      end
    end
  end
end