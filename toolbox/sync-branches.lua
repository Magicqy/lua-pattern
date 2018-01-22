local PATH_BASE = SYNC_PATH_BASE or 'YOUR_PROJ_PATH_BASE'
local URL_BASE = SYNC_URL_BASE or 'YOUR_REPO_URL_BASE'

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

local function sync(wc, src, ...)
    local pathDst = PATH_BASE..wc
    local urlSrc = URL_BASE..src
    for _,dst in ipairs({...}) do
        local urlDst = URL_BASE..dst
        print(string.format('#Sync [%s] => [%s]', src, dst))
        local mergeRev = merge(pathDst, urlDst, urlSrc)
        if mergeRev then
            local msg = string.format('"sync with %s, %s"', src, mergeRev)
            exec('svn commit -m '..msg..' '..pathDst)
            print('#Sync Finished')
        else
            print('#Sync Nothing')
        end
    end
end

sync('WORKING_COPY_DIR', 'SYNC_SRC_BRANCH', 'SYNC_DST_BRANCH_1', 'SYNC_DST_BRANCH_2')