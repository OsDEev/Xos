-- install.lua - Xos System Installer (Edition & Label Selection)
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
write("Enter new Label (Press Enter to keep): ")
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

-- 2. Выбор редакции системы (Edition)
term.setTextColor(colors.yellow)
print("\n------------------------------------------")
print(" Select Xos Edition:")
term.setTextColor(colors.white)
print(" 1. Xos Standard (Desktop PC - 51x19)")
print(" 2. Xos Mini     (Pocket Computer - 26x20)")
write("\nEdition choice (1-2) [1]: ")

local editionChoice = read()
local kernelFile = "os.lua"

if editionChoice == "2" then
    kernelFile = "os_mini.lua"
    term.setTextColor(colors.lime)
    print("-> Selected: Xos Mini Edition")
else
    term.setTextColor(colors.lime)
    print("-> Selected: Xos Standard Edition")
end

-- 3. Выбор профиля установки
term.setTextColor(colors.yellow)
print("\n------------------------------------------")
print(" Select Installation Profile:")
term.setTextColor(colors.white)
print(" 1. Full    (OS Kernel + All Apps)")
print(" 2. Minimal (OS Kernel only)")
write("\nProfile choice (1-2) [1]: ")

local profileChoice = read()

local filesToDownload = {
    { repo = kernelFile, localPath = kernelFile }
}

if profileChoice ~= "2" then
    local appList = {
        "explorer.lua", "terminal.lua", "settings.lua",
        "pakkugaru.lua", "localfile.lua", "download.lua",
        "network.lua", "update.lua"
    }
    for _, appName in ipairs(appList) do
        table.insert(filesToDownload, {
            repo = "App/" .. appName,
            localPath = "App/" .. appName
        })
    end
end

print("\nStarting installation...\n")

local function download(repoPath, localPath)
    term.setTextColor(colors.white)
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
        return true
    else
        term.setTextColor(colors.red)
        print("FAIL")
        return false
    end
end

local success = true
for _, item in ipairs(filesToDownload) do
    if not download(item.repo, item.localPath) then
        success = false
    end
end

-- 4. Создаем startup.lua под выбранную редакцию
local startup = fs.open("startup.lua", "w")
if startup then
    startup.writeLine('-- Xos Autorun Config')
    startup.writeLine('shell.run("' .. kernelFile .. '")')
    startup.close()
    term.setTextColor(colors.cyan)
    print("\n[CONFIG] Created startup.lua pointing to " .. kernelFile)
end

print("\n==========================================")
if success then
    term.setTextColor(colors.lime)
    print(" Installation finished successfully!")
    print(" Label: " .. (os.getComputerLabel() or "Xos-PC"))
    print(" Kernel: " .. kernelFile)
    print(" Rebooting in 3 seconds...")
    sleep(3)
    os.reboot()
else
    term.setTextColor(colors.yellow)
    print(" Installation finished with warnings.")
    print(" Run '" .. kernelFile .. "' manually to start.")
end
term.setTextColor(colors.white)
