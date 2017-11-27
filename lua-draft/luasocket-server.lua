local socket = require("socket")
local bit = require("bit")
local lpack = require('pack')

--message handler
--[[
  lpack format
#define	OP_ZSTRING	'z'		/* zero-terminated string */
#define	OP_BSTRING	'p'		/* string preceded by length byte */
#define	OP_WSTRING	'P'		/* string preceded by length word */
#define	OP_SSTRING	'a'		/* string preceded by length size_t */
#define	OP_STRING	'A'		/* string */
#define	OP_FLOAT	'f'		/* float */
#define	OP_DOUBLE	'd'		/* double */
#define	OP_NUMBER	'n'		/* Lua number */
#define	OP_CHAR		'c'		/* char */
#define	OP_BYTE		'b'		/* byte = unsigned char */
#define	OP_SHORT	'h'		/* short */
#define	OP_USHORT	'H'		/* unsigned short */
#define	OP_INT		'i'		/* int */
#define	OP_UINT		'I'		/* unsigned int */
#define	OP_LONG		'l'		/* long */
#define	OP_ULONG	'L'		/* unsigned long */
#define	OP_LITTLEENDIAN	'<'		/* little endian */
#define	OP_BIGENDIAN	'>'		/* big endian */
#define	OP_NATIVE	'='	/* native endian */

  client data format
#define	OP_WSTRING 's'		/* string preceded by length word */
#define	OP_FLOAT	 'f'		/* float */
#define	OP_DOUBLE	 'd'		/* double */
#define	OP_CHAR		 'b'		/* char */
#define	OP_BYTE		 'B'		/* byte = unsigned char */
#define	OP_SHORT	 'h'		/* short */
#define	OP_USHORT	 'H'		/* unsigned short */
#define	OP_INT		 'i'		/* int */s
#define	OP_UINT		 'I'		/* unsigned int */
#define	OP_LONG		 'l'		/* 64bit int */
#define	OP_ULONG	 'L'		/* unsigned 64bit int */
--]]
--unpack and show message
local function onMessage(client, opcode, data)
  --shakeReq is inserted by client socket
  local index, shakeReq = string.unpack(data, 'I')
  if opcode == 1 then
    --CMSG_PING: pingReq(I)
    local index, pingReq = string.unpack(data, 'I', index)
    print('CMSG_PING', pingReq)
    
    client:send(string.pack('>H<H', 2, 2))
  elseif opcode == 921 then
    local index, dataFmt = string.unpack(data, 'P', index)
    print('CMSG_CUSTOM', select(2, string.unpack(data, dataFmt, index)))
    
    client:send(string.pack('>H<H', 2, 2))
  else
    print('unknown message, opcode', opcode)
  end
end

--socket server framework
local BYTE_PER_SHORT = 2
local BYTE_PER_INT = 4

local host = host or "localhost"
local port = port or 8686
local master = assert(socket.tcp())
assert(master:bind(host, port))
assert(master:listen())

local server = master
while true do
  print('waiting for connections on', server:getsockname())
  local client = assert(server:accept())
  --client:settimeout(10)
  print('connection accepted')
  while true do
    --message header ushort for packsize
    local packsize, error = client:receive(BYTE_PER_SHORT)
    if packsize then
      _,packsize = string.unpack(packsize, '>H')
      print('packsize', packsize)
    else
      print(error); client:close(); break
    end

    --message header ushort for opcode
    local opcode, error = client:receive(BYTE_PER_SHORT)
    if opcode then
      _,opcode = string.unpack(opcode, 'H')
      print('optncode', opcode)
    else
      print(error); client:close(); break
    end

    --message body
    local dataSize = packsize - BYTE_PER_SHORT
    if dataSize > 0 then
      local data, error = client:receive(dataSize)
      if data then
        onMessage(client, opcode, data)
      else
        print(error); client:close(); break
      end
    end
  end
end
server:close()

--[[
  --test for module lpack
  do
    local fmt = 'ifa'
    local data = {1,2.5,'xyz'}
    print(unpack(data))
    local bstr = string.pack(fmt, unpack(data))
    print(string.unpack(bstr, fmt))
  end  
--]]