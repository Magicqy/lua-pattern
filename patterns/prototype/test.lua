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
show('all properties inherited from prototype:', book)

book.id = 1001
show('override property:', book)

book.id = nil
show('reset property to default value:', book)

book.author = 'jack'
show('access undefined property:', book)

book:update({id = 2001, price = 80})
show('update properties:', book)

book:reset()
show('reset all override properties:', book)