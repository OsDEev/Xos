-- install.lua - Installer with Custom Profiles & Auto-Updater setup for Xos
-- Repository: https://github.com/OsDEev/Xos

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local REPO_RAW = "https://raw.githubusercontent.com/OsDEev/Xos/main/"

local function downloadFile(repoPath, localPath)
    term.setTextColor(colors.yellow)
    print("[GET] " .. repoPath .. " -> " .. localPath)
    local res = http.get(REPO_RAW .. repoPath)
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
        print(" [OK] Success")
        return true
    else
        term.setTextColor(colors.red)
        print(" [FAIL] Could not download: " .. repoPath)
        return false
    end
end

term.setTextColor(colors.cyan)
print("==========================================")
print("       Xos Installation Wizard v3.0       ")
print("==========================================")
term.setTextColor(colors.white)
print("\nSelect Installation Profile:")
print(" [1] Full OS (Core + All Utilities & Apps)")
print(" [2] Minimal Core (Kernel + Pakkugaru)")
print(" [3] Server Node (Core + localfile host)")
print(" [4] Cancel")

write("\nSelect option (1-4): ")
local choice = read()

local filesToDownload = {}

if choice == "1" then
    filesToDownload = {
        { repo = "os.lua", localP = "os.lua" },
        { repo = "App/pakkugaru.lua", localP = "App/pakkugaru.lua" },
        { repo = "App/network.lua", localP = "App/network.lua" },
        { repo = "App/localfile.lua", localP = "App/localfile.lua" },
        { repo = "App/download.lua", localP = "App/download.lua" },
        { repo = "App/update.lua", localP = "App/update.lua" }
    }
elseif choice == "2" then
    filesToDownload = {
        { repo = "os.lua", localP = "os.lua" },
        { repo = "App/pakkugaru.lua", localP = "App/pakkugaru.lua" },
        { repo = "App/update.lua", localP = "App/update.lua" }
    }
elseif choice == "3" then
    filesToDownload = {
        { repo = "os.lua", localP = "os.lua" },
        { repo = "App/network.lua", localP = "App/network.lua" },
        { repo = "App/localfile.lua", localP = "App/localfile.lua" },
        { repo = "App/update.lua", localP = "App/update.lua" }
    }
else
    term.setTextColor(colors.yellow)
    print("\nInstallation aborted.")
    return
end

print("\nStarting installation...\n")

local successCount = 0
for _, item in ipairs(filesToDownload) do
    if downloadFile(item.repo, item.localP) then
        successCount = successCount + 1
    end
end

-- Create startup script for auto-boot
term.setTextColor(colors.cyan)
print("\nConfiguring startup script...")
local startupFile = fs.open("startup.lua", "w")
startupFile.write([[
-- Auto-start Xos Kernel
if fs.exists("os.lua") then
    shell.run("os.lua")
else
    print("Xos Kernel missing!")
end
]])
startupFile.close()

term.setTextColor(colors.lime)
print("\n==========================================")
print(string.format(" Installed %d/%d components successfully!", successCount, #filesToDownload))
print(" Startup file created as 'startup.lua'")
print(" Press Enter to launch Xos now...")
print("==========================================")
term.setTextColor(colors.white)
read()
shell.run("os.lua")