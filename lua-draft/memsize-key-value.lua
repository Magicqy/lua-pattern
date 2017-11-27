
function gc()
	collectgarbage("collect")
	collectgarbage("collect")
	collectgarbage("collect")
	return collectgarbage("count")
end

function intkeys(count)
	local data = {}
	local before = gc()

	for i = 1, count do
		table.insert(data, i)
	end

	local current = gc()
	local delta = current - before
	print(string.format('int key memory delta %s / %s = %s', delta, count, delta / count))
end

function strkeys(count)
    local keys = {}
    for i = 1, count do table.insert(keys, tostring(i)) end

	local data = {}
	local before = gc()

	for i = 1, count do
		data[keys[i]] = i
	end

	local current = gc()
	local delta = current - before
	print(string.format('str key memory delta %s / %s = %s', delta, count, delta / count))
end

function conkeys(count, continuous)
	local data = {}
	local before = gc()

	for i = 1, count do
		if continuous then
			data[i] = i
		else
			if i % 2 == 1 then data[i] = i end
		end
	end

	local current = gc()
	local delta = current - before
	print(string.format('memory delta %s / %s = %s, continuous = %s', delta, count, delta / count, continuous))
	local pairsCount = 0
	for k,v in pairs(data) do pairsCount = pairsCount + 1 end
	local ipairsCount = 0
	for k,v in ipairs(data) do ipairsCount = ipairsCount + 1 end
	print('pairs count', pairsCount, 'ipairs count', ipairsCount)
end

local function foo(...)
	local count = select('#', ...)
	local args = {...}
	--logic log call(level 3) > logw.log (level 2) > logw._logMsg (level 1)
	table.insert(args, debug.traceback('\r\n', 3))
	print('-----')
	for k,v in pairs(args) do print(k,v) end
	print('-----')
	print(table.unpack(args, 1, count + 1))
end

foo('#1', nil, nil, nil, '#4')


-- intkeys(1024)
-- strkeys(1024)
-- conkeys(1024, true)
-- conkeys(1024, false)

--for i = 1, 32 do intkeys(i) end
--for i = 1, 32 do strkeys(i) end

-- local t = {}
-- t[3] = 3
-- t[2] = 2
-- t[1] = 1
-- for k,v in pairs(t) do print(k,v) end
-- for n,v in ipairs(t) do print(n,v) end
