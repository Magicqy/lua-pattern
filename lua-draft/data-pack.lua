local bit = require("bit")

local BIT_PER_BYTE = 8
local BYTE_PER_SHORT = 2
local BYTE_PER_INT = 4

--unpack data utility
local function unpackFromNet(...)
    local ret = 0
    local count = select('#', ...)
    for n = 1, count do
      local byte = select(n, ...)
      ret = bit.bor(ret, bit.lshift(byte, BIT_PER_BYTE * (count - n)))
    end
    return ret
  end
  
  local function unpackFromHost(...)
    local ret = 0
    local count = select('#', ...)
    for n = 1, count do
      local byte = select(n, ...)
      ret = bit.bor(ret, bit.lshift(byte, BIT_PER_BYTE * (n - 1)))
    end
    return ret
  end