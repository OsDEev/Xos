-- App/pakkugaru.lua - Package Manager (Paku-Paku)

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local REPO_BASE = "https://raw.githubusercontent.com/OsDEev/Xos/main/App/"

-- Pac-Man ASCII Logo
term.setTextColor(colors.yellow)
print("   .--.   .-. ")
print("  / _= \\ / -' ")
print(" | /====| |   ")
print(" | \\====| |   ")
print("  \\ `--` \\ -._")
print("   `--`   `--` ")
term.setTextColor(colors.lime)
print("=== PAKKUGARU v1.2 ===")
print("  'The Package Gobbler' (paku-paku)")
term.setTextColor(colors.white)
print("Commands:")
print(" - list")
print(" - install <package_name>")
print(" - install <URL> <filename>")
print(" - remove <filename>")

write("\npakkugaru> ")
local input = read()
local parts = {}
for word in input:gmatch("%S+") do table.insert(parts, word) end

local cmd = parts[1]

if cmd == "list" then
    print("\nInstalled apps in /App:")
    local apps = fs.list("App")
    if #apps == 0 then
        print(" (empty)")
    else
        for _, f in ipairs(apps) do
            print(" - " .. f)
        end
    end

elseif cmd == "install" then
    local url = ""
    local name = ""

    if parts[2] and not parts[3] then
        name = parts[2]
        url = REPO_BASE .. name .. ".lua"
    elseif parts[2] and parts[3] then
        url = parts[2]
        name = parts[3]
    else
        term.setTextColor(colors.red)
        print("Error: Specify package! Usage: install calc OR install <url> <name>")
    end

    if url ~= "" and name ~= "" then
        if not name:find("%.lua$") then
            name = name .. ".lua"
        end

        term.setTextColor(colors.yellow)
        print("Gobbling " .. name .. "...")

        local res = http.get(url)
        if res then
            local f = fs.open("App/" .. name, "w")
            f.write(res.readAll())
            f.close()
            res.close()
            term.setTextColor(colors.lime)
            print("Success! Package " .. name .. " saved to /App.")
        else
            term.setTextColor(colors.red)
            print("Error: Could not download package.")
        end
    end

elseif cmd == "remove" and parts[2] then
    local name = parts[2]
    if not name:find("%.lua$") then name = name .. ".lua" end
    local path = "App/" .. name

    if fs.exists(path) then
        fs.delete(path)
        term.setTextColor(colors.lime)
        print("Package " .. name .. " removed.")
    else
        term.setTextColor(colors.red)
        print("File " .. name .. " not found in /App.")
    end

else
    term.setTextColor(colors.lightGray)
    print("Unknown command.")
end

term.setTextColor(colors.white)
print("\nPress Enter to exit...")
read()
