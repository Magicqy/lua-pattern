local function show(msg, tbl)
	for k, v in pairs(tbl) do
		msg = msg..string.format(' %s=%s', k, v)
	end
	print(msg)
end

--test case
local prototype = require('prototype')
local Product =
{
	id = 0,
	price = 100,
}

local book = prototype.new(Product)
show('initial:', book)

book.id = 1001
show('changed:', book)

book.author = 'jack'
show('undefined:', book)

book:reset()
show('reset:', book)

book:update({price = 80, author = 'jack'})
show('update:', book)

book:reset('price')
show('reset:', book)
