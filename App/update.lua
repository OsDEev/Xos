-- App/update.lua - Official System Updater for Xos Core
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local RAW_URL = "https://raw.githubusercontent.com/OsDEev/Xos/main/"

term.setTextColor(colors.cyan)
print("==========================================")
print("        Xos Official System Updater       ")
print("==========================================")
term.setTextColor(colors.white)

-- Список всех системных файлов, входящих в состав Xos
local systemFiles = {
    -- Core & Boot files
    "os.lua",
    "startup.lua",
    "install.lua",

    -- Official System Apps
    "App/settings.lua",
    "App/update.lua",
    "App/terminal.lua",
    "App/explorer.lua",
    "App/localfile.lua",
    "App/download.lua",
    "App/pakkugaru.lua",
    "App/calc.lua",
    "App/network.lua"
}

local function updateSystemFile(path)
    term.setTextColor(colors.yellow)
    write("[UPDATE] " .. path .. " ... ")

    local res = http.get(RAW_URL .. path)
    if res then
        local dir = fs.getDir(path)
        if dir and dir ~= "" and not fs.exists(dir) then
            fs.makeDir(dir)
        end

        local content = res.readAll()
        res.close()

        local f = fs.open(path, "w")
        f.write(content)
        f.close()

        term.setTextColor(colors.lime)
        print("OK")
        return true
    else
        term.setTextColor(colors.red)
        print("FAIL")
        return false
    end
end

if not http then
    term.setTextColor(colors.red)
    print("ERROR: HTTP API is disabled on this computer!")
    print("Press Enter to return...")
    read()
    return
end

print("\nDownloading system updates from official repository...\n")

local successCount = 0
local totalFiles = #systemFiles

for _, filePath in ipairs(systemFiles) do
    if updateSystemFile(filePath) then
        successCount = successCount + 1
    end
end

print("\n==========================================")
if successCount == totalFiles then
    term.setTextColor(colors.lime)
    print(" System Update Complete! All core files updated.")
else
    term.setTextColor(colors.yellow)
    print(" Updated " .. successCount .. " of " .. totalFiles .. " system files.")
end
term.setTextColor(colors.white)
print(" Press Enter to return to Xos...")
print("==========================================")
read()
