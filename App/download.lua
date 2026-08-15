-- App/download.lua - Client for Xos Local File Host (uses network.lua)

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local netPath = "network.lua"
if not fs.exists(netPath) then
    netPath = "App/network.lua"
end

if not fs.exists(netPath) then
    term.setTextColor(colors.red)
    print("Error: network.lua library not found!")
    term.setTextColor(colors.white)
    print("\nPress Enter to exit...")
    read()
    return
end

local network = dofile(netPath)

if not network.init() then
    term.setTextColor(colors.red)
    print("Error: No modem attached!")
    term.setTextColor(colors.white)
    print("\nPress Enter to exit...")
    read()
    return
end

term.setTextColor(colors.cyan)
print("=== Xos Local Downloader ===")
term.setTextColor(colors.yellow)
print("Searching for local file host...")

local serverId = rednet.lookup("xos_files", "xos_host")

if not serverId then
    term.setTextColor(colors.red)
    print("Error: No 'xos_host' file server found on network!")
    term.setTextColor(colors.white)
    print("\nPress Enter to exit...")
    read()
    return
end

term.setTextColor(colors.lime)
print("Connected to Local Host Server (ID: " .. serverId .. ")")
term.setTextColor(colors.white)

-- 1. Fetch File List
rednet.send(serverId, { cmd = "list" }, "xos_files")
local senderId, response = network.receive("xos_files", 3)

if response and response.status == "OK" then
    print("\nAvailable files on host:")
    for _, file in ipairs(response.files) do
        print(" - " .. file)
    end
else
    term.setTextColor(colors.red)
    print("Failed to retrieve file list from host.")
    term.setTextColor(colors.white)
    print("Press Enter to exit...")
    read()
    return
end

-- 2. Select File to Download
term.setTextColor(colors.yellow)
write("\nEnter filename to download: ")
term.setTextColor(colors.white)
local filename = read()

if filename and filename ~= "" then
    if not filename:find("%.lua$") then filename = filename .. ".lua" end

    rednet.send(serverId, { cmd = "get", param = filename }, "xos_files")
    local _, fileRes = network.receive("xos_files", 5)

    if fileRes and fileRes.status == "OK" then
        if not fs.exists("App") then fs.makeDir("App") end
        local f = fs.open("App/" .. filename, "w")
        f.write(fileRes.content)
        f.close()

        term.setTextColor(colors.lime)
        print("\nSuccess! Saved to App/" .. filename)
    else
        term.setTextColor(colors.red)
        print("\nError downloading file: " .. (fileRes and fileRes.msg or "Timeout"))
    end
end

term.setTextColor(colors.white)
print("\nPress Enter to exit...")
read()
