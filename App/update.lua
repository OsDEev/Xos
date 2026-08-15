-- App/update.lua - Dynamic Auto-Updater for Xos
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local API_URL = "https://api.github.com/repos/OsDEev/Xos/contents/"
local RAW_URL = "https://raw.githubusercontent.com/OsDEev/Xos/main/"

term.setTextColor(colors.cyan)
print("==========================================")
print("        Xos Dynamic Auto-Updater          ")
print("==========================================")
term.setTextColor(colors.white)

local function downloadFile(repoPath, localPath)
    term.setTextColor(colors.yellow)
    write("[SYNC] " .. localPath .. " ... ")

    local res = http.get(RAW_URL .. repoPath)
    if res then
        local dir = fs.getDir(localPath)
        if dir and dir ~= "" and not fs.exists(dir) then
            fs.makeDir(dir)
        end
        local f = fs.open(localPath, "w")
        f.write(res.readAll())
        f.close()
        res.close()
        term.setTextColor(colors.lime)
        print("OK")
        return true
    else
        term.setTextColor(colors.red)
        print("FAIL")
        return false
    end
end

-- Скачивание файлов из папки через GitHub API
local function syncDirectory(dirPath)
    local url = API_URL .. (dirPath or "")
    local res = http.get(url, { ["User-Agent"] = "ComputerCraft-Xos" })

    if not res then
        return false
    end

    local data = textutils.unserializeJSON(res.readAll())
    res.close()

    if type(data) ~= "table" then return false end

    for _, item in ipairs(data) do
        if item.type == "file" and item.name:find("%.lua$") then
            local repoPath = dirPath ~= "" and (dirPath .. "/" .. item.name) or item.name
            local localPath = repoPath
            downloadFile(repoPath, localPath)
        elseif item.type == "dir" and item.name == "App" then
            syncDirectory("App")
        end
    end
    return true
end

print("\nFetching current repository manifest from GitHub...\n")

-- Обновляем файлы в корне (os.lua, install.lua) и всю папку App/
local okCore = downloadFile("os.lua", "os.lua")
local okApps = syncDirectory("App")

print("\n==========================================")
if okCore and okApps then
    term.setTextColor(colors.lime)
    print(" Update Complete! All system files synced.")
else
    term.setTextColor(colors.yellow)
    print(" Update finished with basic files (API limit fallback).")
end
term.setTextColor(colors.white)
print(" Press Enter to return to Xos...")
print("==========================================")
read()
