local function exec(prog)
    print('#Execute', prog)
    local result = io.popen(prog):read('*a')
    print(result)
    return result
end

local function merge(pathDst, urlDst, urlSrc, revRanges)
    exec('svn revert -R '..pathDst)
    exec('svn switch '..urlDst..' '..pathDst)
    exec('svn up '..pathDst)

    local prog = 'svn merge '..urlSrc..' '..pathDst
    if revRanges and type(revRanges) == 'table' and #revRanges > 0 then
        for _,rev in ipairs(revRanges) do
            if type(rev) == 'number' then
                prog = prog..' -c '..rev
            elseif type(rev) == 'string' then
                prog = prog..' -r '..rev
            end
        end
    end

    local result = exec(prog)
    local matched = {}
    for cap in string.gmatch(result, 'Merging (r%d+ through r%d+) into') do
        table.insert(matched, cap)
    end
    for cap in string.gmatch(result, 'Merging (r%d+) into') do
        table.insert(matched, cap)
    end
    return #matched > 0 and 'Merging '..table.concat(matched, ',') or nil
end

local function sync(wcpath, urlbase, src, revRanges, ...)
    local urlSrc = urlbase..src
    for _,dst in ipairs({...}) do
        local urlDst = urlbase..dst
        print(string.format('#Sync [%s] => [%s]', src, dst))
        local mergeRev = merge(wcpath, urlDst, urlSrc, revRanges)
        if mergeRev then
            local msg = string.format('"sync with %s, %s"', src, mergeRev)
            exec('svn commit -m '..msg..' '..wcpath)
            print('#Sync Finished')
        else
            print('#Sync Nothing')
        end
    end
end

--sync(YOUR_WORKING_COPY_PATH, YOUR_SVN_URL_BASE, SRC_BRANCH, REVISION_RANGES, TARGET_BRANCH_1, TARGET_BRANCH_2, ...)