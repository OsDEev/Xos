-- App/update.lua - System Updater for Xos

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local REPO_RAW = "https://raw.githubusercontent.com/OsDEev/Xos/main/"

local systemComponents = {
    { name = "Core Kernel (os.lua)", repo = "os.lua", localP = "os.lua" },
    { name = "Package Manager (Pakkugaru)", repo = "App/pakkugaru.lua", localP = "App/pakkugaru.lua" },
    { name = "Network Library", repo = "App/network.lua", localP = "App/network.lua" },
    { name = "Local File Host", repo = "App/localfile.lua", localP = "App/localfile.lua" },
    { name = "Network Downloader", repo = "App/download.lua", localP = "App/download.lua" },
    { name = "System Updater", repo = "App/update.lua", localP = "App/update.lua" }
}

term.setTextColor(colors.cyan)
print("==========================================")
print("         Xos Auto-Update System           ")
print("==========================================")
term.setTextColor(colors.white)
print("\nOptions:")
print(" [1] Check & Update ALL System Components")
print(" [2] Update Core Kernel Only")
print(" [3] Update App Suite")
print(" [4] Cancel")

write("\nChoice (1-4): ")
local choice = read()

local function fetchUpdate(item)
    term.setTextColor(colors.yellow)
    print("\n[+] Fetching latest " .. item.name .. "...")
    local res = http.get(REPO_RAW .. item.repo)
    if res then
        local dir = fs.getDir(item.localP)
        if dir and dir ~= "" and not fs.exists(dir) then
            fs.makeDir(dir)
        end
        local f = fs.open(item.localP, "w")
        f.write(res.readAll())
        f.close()
        res.close()
        term.setTextColor(colors.lime)
        print(" [OK] Updated: " .. item.localP)
        return true
    else
        term.setTextColor(colors.red)
        print(" [ERROR] Failed to fetch: " .. item.repo)
        return false
    end
end

if choice == "1" then
    for _, comp in ipairs(systemComponents) do
        fetchUpdate(comp)
    end
elseif choice == "2" then
    fetchUpdate(systemComponents[1])
elseif choice == "3" then
    for i = 2, #systemComponents do
        fetchUpdate(systemComponents[i])
    end
else
    print("\nUpdate cancelled.")
end

term.setTextColor(colors.white)
print("\nPress Enter to exit updater...")
read()
