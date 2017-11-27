local MyClass = {}

--memeber function
function MyClass:Func()
    print('hello', self.name)
end

--constructor
function MyClass.new(name)
    local inst = {name = name}
    setmetatable(inst, MyClass)
    MyClass.__index = MyClass
    return inst
end

--usage
local a = MyClass.new('Tom')
local b = MyClass.new('Tom111')
a:Func()
b:Func()

print(package.path)