local host = host or "localhost"
local port = port or 8686
local socket = require("socket")

local master = assert(socket.tcp())
assert(master:connect(host, port))
local client = master
print('connection established on', client:getpeername())

while true do
    print('input message to send:')
    local msg = io.read()
    if msg == 'close' then
        client:close()
        break
    end
    local index, error = client:send(msg .. '\n')
    if index ~= nil then
        print(index, 'byte was sent')
    else
        print(error)
        client:close()
        break
    end
end