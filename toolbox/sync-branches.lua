local function exec(prog, pattern)
    print('#Execute', prog)
    local stdout = io.popen(prog)
    local result = stdout:read('*a')
    print(result)
    return result
end

local function merge(pathDst, urlDst, urlSrc)
    exec('svn revert -R '..pathDst)
    exec('svn switch '..urlDst..' '..pathDst)
    exec('svn up '..pathDst)
    local result = exec('svn merge '..urlSrc..' '..pathDst)
    local ibeg, iend = string.find(result, 'Merging r%d+ through r%d+')
    if ibeg and iend then
        return string.sub(result, ibeg, iend)
    end
end

local function sync(urlbase, wcpath, src, ...)
    local urlSrc = urlbase..src
    for _,dst in ipairs({...}) do
        local urlDst = urlbase..dst
        print(string.format('#Sync [%s] => [%s]', src, dst))
        local mergeRev = merge(wcpath, urlDst, urlSrc)
        if mergeRev then
            local msg = string.format('"sync with %s, %s"', src, mergeRev)
            exec('svn commit -m '..msg..' '..wcpath)
            print('#Sync Finished')
        else
            print('#Sync Nothing')
        end
    end
end

--sync(YOUR_SVN_URL_BASE, YOUR_WORKING_COPY_PATH, SRC_BRANCH, TARGET_BRANCH_1, TARGET_BRANCH_2, ...)