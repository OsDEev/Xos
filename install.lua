-- install.lua - Xos System Installer with Label Setup
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local RAW_URL = "https://raw.githubusercontent.com/OsDEev/Xos/main/"

term.setTextColor(colors.cyan)
print("==========================================")
print("        Xos Operating System Installer    ")
print("==========================================")
term.setTextColor(colors.white)

-- 1. Запрос и установка Label для ПК
local currentLabel = os.getComputerLabel()
print("\nCurrent Computer Label: " .. (currentLabel or "None"))
write("Enter new Computer Label (Press Enter to keep current): ")
local newLabel = read()

if newLabel and newLabel ~= "" then
    os.setComputerLabel(newLabel)
    term.setTextColor(colors.lime)
    print("-> Label set to: " .. newLabel)
elseif currentLabel then
    term.setTextColor(colors.lime)
    print("-> Keeping label: " .. currentLabel)
else
    os.setComputerLabel("Xos-PC")
    term.setTextColor(colors.lime)
    print("-> Default label set: Xos-PC")
end

term.setTextColor(colors.white)
print("\nSelect Installation Profile:")
print("1. Full (OS + All Apps + Autorun)")
print("2. Minimal (OS Kernel only)")
write("\nChoice (1-2): ")

local choice = read()

local filesToDownload = {}

if choice == "2" then
    filesToDownload = {
        { repo = "os.lua", localPath = "os.lua" }
    }
else
    filesToDownload = {
        { repo = "os.lua", localPath = "os.lua" },
        { repo = "App/explorer.lua", localPath = "App/explorer.lua" },
        { repo = "App/terminal.lua", localPath = "App/terminal.lua" },
        { repo = "App/settings.lua", localPath = "App/settings.lua" },
        { repo = "App/pakkugaru.lua", localPath = "App/pakkugaru.lua" },
        { repo = "App/localfile.lua", localPath = "App/localfile.lua" },
        { repo = "App/download.lua", localPath = "App/download.lua" },
        { repo = "App/network.lua", localPath = "App/network.lua" },
        { repo = "App/update.lua", localPath = "App/update.lua" }
    }
end

print("\nStarting installation...\n")

local function download(repoPath, localPath)
    write("[DOWNLOADING] " .. localPath .. " ... ")
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
        term.setTextColor(colors.white)
        return true
    else
        term.setTextColor(colors.red)
        print("FAIL")
        term.setTextColor(colors.white)
        return false
    end
end

local success = true
for _, item in ipairs(filesToDownload) do
    if not download(item.repo, item.localPath) then
        success = false
    end
end

-- Создаем startup.lua для автозагрузки
local startup = fs.open("startup.lua", "w")
if startup then
    startup.writeLine('-- Xos Autorun')
    startup.writeLine('shell.run("os.lua")')
    startup.close()
    print("[CONFIG] Created startup.lua")
end

print("\n==========================================")
if success then
    term.setTextColor(colors.lime)
    print(" Installation finished successfully!")
    print(" Computer Label: " .. (os.getComputerLabel() or "Xos-PC"))
    print(" Rebooting in 3 seconds...")
    sleep(3)
    os.reboot()
else
    term.setTextColor(colors.yellow)
    print(" Installation finished with errors.")
    print(" Run 'os.lua' manually to start.")
end
term.setTextColor(colors.white)
