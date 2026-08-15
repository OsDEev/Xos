-- App/localfile.lua - Local File Server for Xos (uses network.lua)

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
    print("Error: No modem found! Attach a wireless or wired modem.")
    term.setTextColor(colors.white)
    print("\nPress Enter to exit...")
    read()
    return
end

local hostname = "xos_host"
rednet.host("xos_files", hostname)

term.setTextColor(colors.cyan)
print("====================================")
print("     Xos Local File Host Server     ")
print("====================================")
term.setTextColor(colors.lime)
print("Status: ONLINE")
print("Computer ID: " .. os.getComputerID())
print("Hostname: " .. hostname)
print("Protocol: xos_files")
term.setTextColor(colors.white)
print("------------------------------------")
print("Serving files from /App/ directory...")
print("Press 'q' to stop server.\n")

while true do
    local senderId, message, protocol = network.receive("xos_files", 1)

    if message and type(message) == "table" then
        local cmd = message.cmd
        local param = message.param

        if cmd == "list" then
            term.setTextColor(colors.yellow)
            print("[REQ] Client #" .. senderId .. " requested file list.")
            local files = fs.exists("App") and fs.list("App") or {}
            rednet.send(senderId, { status = "OK", files = files }, "xos_files")

        elseif cmd == "get" and param then
            term.setTextColor(colors.yellow)
            print("[REQ] Client #" .. senderId .. " requested: " .. param)
            local path = "App/" .. param
            if fs.exists(path) and not fs.isDir(path) then
                local f = fs.open(path, "r")
                local content = f.readAll()
                f.close()
                rednet.send(senderId, { status = "OK", content = content }, "xos_files")
                term.setTextColor(colors.lime)
                print("  [->] Sent " .. param .. " successfully.")
            else
                rednet.send(senderId, { status = "ERROR", msg = "File not found" }, "xos_files")
                term.setTextColor(colors.red)
                print("  [!] File not found: " .. param)
            end
        end
    end

    local event, key = os.pullEventRaw()
    if event == "key" and key == keys.q then
        term.setTextColor(colors.yellow)
        print("\nStopping Local File Host...")
        rednet.unhost("xos_files")
        rednet.close()
        break
    end
end

term.setTextColor(colors.white)
print("Server stopped. Press Enter to exit...")
read()
