-- App/pakkugaru.lua - Smart Package Manager & GitHub Parser for Xos
-- Repository: https://github.com/OsDEev/Xos

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local OFFICIAL_REPO_BASE = "https://raw.githubusercontent.com/OsDEev/Xos/main/App/"

-- Function to convert GitHub web URL to direct RAW download URL
local function parseGitHubURL(url)
    if url:find("raw%.githubusercontent%.com") then
        return url
    end

    local user, repo, branch, filepath = url:match("github%.com/([^/]+)/([^/]+)/blob/([^/]+)/(%S+)")
    if user and repo and branch and filepath then
        return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, filepath)
    end

    user, repo, branch, filepath = url:match("^([^/]+)/([^/]+)/([^/]+)/(%S+)$")
    if user and repo and branch and filepath then
        return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, filepath)
    end

    return url
end

-- Pac-Man ASCII Logo
term.setTextColor(colors.yellow)
print("   .--.   .-. ")
print("  / _= \\ / -' ")
print(" | /====| |   ")
print(" | \\====| |   ")
print("  \\ `--` \\ -._")
print("   `--`   `--` ")
term.setTextColor(colors.lime)
print("=== PAKKUGARU v2.0 (GitHub Parser) ===")
print("  'The Package Gobbler' (paku-paku)")
term.setTextColor(colors.white)
print("\nCommands:")
print(" - list")
print(" - install <app_name>                   (From official Xos repo)")
print(" - install <github_url_or_path> [name]  (From any GitHub repo)")
print(" - remove <filename>")

write("\npakkugaru> ")
local input = read()
local parts = {}
for word in input:gmatch("%S+") do table.insert(parts, word) end

local cmd = parts[1]

if cmd == "list" then
    print("\nInstalled apps in /App:")
    if not fs.exists("App") then fs.makeDir("App") end
    local apps = fs.list("App")
    if #apps == 0 then
        print(" (empty)")
    else
        for _, f in ipairs(apps) do
            print(" - " .. f)
        end
    end

elseif cmd == "install" then
    local rawUrl = ""
    local targetName = ""

    if not parts[2] then
        term.setTextColor(colors.red)
        print("Error: Specify app name or GitHub URL!")
    elseif parts[2]:find("github%.com") or parts[2]:find("/") then
        rawUrl = parseGitHubURL(parts[2])
        
        if parts[3] then
            targetName = parts[3]
        else
            targetName = parts[2]:match("([^/]+)%.lua$") or parts[2]:match("([^/]+)$") or "app"
        end
    else
        targetName = parts[2]
        rawUrl = OFFICIAL_REPO_BASE .. targetName .. ".lua"
    end

    if rawUrl ~= "" and targetName ~= "" then
        if not targetName:find("%.lua$") then
            targetName = targetName .. ".lua"
        end

        term.setTextColor(colors.yellow)
        print("\n[+] Parsing & Gobbling from:")
        term.setTextColor(colors.lightGray)
        print("    " .. rawUrl)
        term.setTextColor(colors.yellow)
        print("    Saving as: App/" .. targetName .. " ...")

        local res = http.get(rawUrl)
        if res then
            if not fs.exists("App") then fs.makeDir("App") end
            local f = fs.open("App/" .. targetName, "w")
            f.write(res.readAll())
            f.close()
            res.close()
            
            term.setTextColor(colors.lime)
            print("\n[OK] Success! Package " .. targetName .. " installed to /App.")
        else
            term.setTextColor(colors.red)
            print("\n[ERROR] Download failed. Check URL or network access.")
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
    print("Unknown command or missing parameters.")
end

term.setTextColor(colors.white)
print("\nPress Enter to exit...")
read()
