local function process(prog)
    print(prog)
    --TODO how to get exit code or stderr handle svn error like svn: E155007:
    local result = io.popen(prog):read('*a')
    return result
end

local function execute(cmd)
    print(cmd)
    local exitcode = os.execute(cmd)
    assert(exitcode == 0, "command execution exit with code:"..exitcode)
    return exitcode
end

--get and trim log message
local function repo_logFile(repoUrl, repoName, rev)
    local result = process("svn log -c "..rev.." "..repoUrl)
    local logContent = string.gsub(result, "^(%-+\r?\n)(.+)(\r?\n%-+\r?\n)$", "%2")
    local logFileName = repoName..rev..'.txt'
    local logFile = io.open(logFileName, "w")
    logFile:write(logContent)
    logFile:close()
    return logFileName
end

local function repo_transport(sourceUrl, targetUrl, wcpath, revBegin, revEnd)
    --prepare working copy path
    execute("svn checkout --force --ignore-externals "..targetUrl.." "..wcpath)
    execute("svn cleanup --remove-unversioned --remove-ignored "..wcpath)
    execute("svn revert -R "..wcpath)
    execute("svn update --ignore-externals "..wcpath)

    local result = process("svn info "..wcpath)
    local repoUrl = string.match(result, "URL: ([%w%p]+)\r?\n")
    assert(repoUrl == targetUrl, "repo url of working copy directory not match: "..repoUrl)

    --prepare revision ranges
    if revEnd == nil then
        local result = process("svn info "..sourceUrl)
        revEnd = string.match(result, "Revision: (%d+)\r?\n")
    end

    revBegin = tonumber(revBegin or 1)
    revEnd = tonumber(revEnd)
    assert(revBegin and type(revBegin) == "number", "begin revision invalid:"..tostring(revBegin))
    assert(revEnd and type(revEnd) == "number", "end revision invalid:"..tostring(revEnd))
    print("transport ranges:", revBegin, revEnd)
    print()

    local repoName = string.match(result, "URL: [%w%p]+/([%w%p]+)\r?\n")
    --merge and commit
    for rev = revBegin, revEnd do
        print("transport revision:", rev)
        
        --read log message and save to temp file
        local logFileName = repo_logFile(sourceUrl, repoName, rev)
        --merge and commit
        execute("svn update -q --ignore-externals "..wcpath)
        execute("svn merge -q -c "..rev.." "..sourceUrl.." "..wcpath)
        execute("svn commit -q "..wcpath.." -F "..logFileName)
        --cleanup temp log file
        os.remove(logFileName)
        print()
    end
end

-- revert commits from repo working copy
local function repo_revert(repoUrl, wcpath, revBegin, revEnd)
    execute("svn update --ignore-externals "..wcpath)
    local ranges = (revEnd or "HEAD:")..(revBegin or "0")
    execute("svn merge -r "..ranges.." "..repoUrl.." "..wcpath)
    execute("svn commit -m \"revert revisions: "..ranges.."\" "..wcpath)
end

return {
    transport = repo_transport,
    logFile = repo_logFile,
    revert = repo_revert,
}