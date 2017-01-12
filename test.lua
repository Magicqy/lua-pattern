local prototype = require('prototype')

--test case
local Product =
{
	id = 0,
	price = 100,
}

local book = prototype.new(Product)
local pen = prototype.new(Product)

print('book:', book.id, book.price)
print('pen:', pen.id, pen.price)

book.id = 1001
pen.id = 1002
print('book change id:', book.id, book.price)
print('pen change id:', pen.id, pen.price)

book:reset()
print('book reset:', book.id, book.price)

pen:update({price = 20})
print('pen update:', pen.id, pen.price)

book.name = 'cookbook'
book.author = 'jack'
print('undefined:', book.name, pen.author)