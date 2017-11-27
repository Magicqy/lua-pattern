local function foo()
    some_thing.val = 1
end

print('1')
if pcall(foo) then
    print('succ')
else
    print('exception')
end
print('2')