-- App/pakkugaru.lua - Package Manager for Xos OS
-- Repository: https://github.com/OsDEev/Xos

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local OFFICIAL_REPO_BASE = "https://raw.githubusercontent.com/OsDEev/Xos/main/App/"

-- Helper function to parse URL / Identifiers
local function parseURL(input)
    -- 1. Pastebin URL or Raw ID
    local pastebinId = input:match("pastebin%.com/raw/([%w]+)") or input:match("pastebin%.com/([%w]+)")
    if pastebinId then
        return "https://pastebin.com/raw/" .. pastebinId, pastebinId
    end

    if #input == 8 and not input:find("/") and not input:find("%.") then
        return "https://pastebin.com/raw/" .. input, input
    end

    -- 2. Direct GitHub Raw URL
    if input:find("raw%.githubusercontent%.com") then
        local name = input:match("([^/]+)%.lua$") or input:match("([^/]+)$")
        return input, name
    end

    -- 3. GitHub Blob/Web URL
    local user, repo, branch, filepath = input:match("github%.com/([^/]+)/([^/]+)/blob/([^/]+)/(%S+)")
    if user and repo and branch and filepath then
        local raw = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, filepath)
        local name = filepath:match("([^/]+)$")
        return raw, name
    end

    return nil, nil
end

local function drawHeader()
    term.setTextColor(colors.yellow)
    print("   .--.   .-. ")
    print("  / _= \\ / -' ")
    print(" | /====| |   ")
    print(" | \\====| |   ")
    print("  \\ `--` \\ -._")
    print("   `--`   `--` ")
    term.setTextColor(colors.lime)
    print("=== PAKKUGARU v3.1 (Package Manager) ===")
    term.setTextColor(colors.white)
end

local function showHelp()
    term.setTextColor(colors.cyan)
    print("\nCommands:")
    print(" - list                              (Show installed apps)")
    print(" - install <app_name>                (Official Xos repo)")
    print(" - install <github_url> [filename]   (GitHub repo)")
    print(" - install <pastebin_code> <name>    (Pastebin code)")
    print(" - remove <filename>                 (Delete app)")
    print(" - exit                              (Return to OS)")
    term.setTextColor(colors.white)
end

-- Check HTTP API availability
if not http then
    term.setTextColor(colors.red)
    print("ERROR: HTTP API is disabled in ComputerCraft config!")
    print("Press Enter to exit...")
    read()
    return
end

drawHeader()
showHelp()

-- Main Command Loop
while true do
    term.setTextColor(colors.yellow)
    write("\npakkugaru> ")
    term.setTextColor(colors.white)

    local input = read()
    if not input or input:lower() == "exit" or input:lower() == "quit" then
        break
    end

    local parts = {}
    for word in input:gmatch("%S+") do
        table.insert(parts, word)
    end

    local cmd = parts[1] and parts[1]:lower() or ""

    if cmd == "list" then
        term.setTextColor(colors.yellow)
        print("\nInstalled apps in /App:")
        if not fs.exists("App") then fs.makeDir("App") end
        local apps = fs.list("App")

        if #apps == 0 then
            term.setTextColor(colors.lightGray)
            print(" (directory is empty)")
        else
            term.setTextColor(colors.lime)
            for _, f in ipairs(apps) do
                print(" - " .. f)
            end
        end

    elseif cmd == "install" then
        local downloadUrl = ""
        local targetName = ""

        if not parts[2] then
            term.setTextColor(colors.red)
            print("Error: Specify app name, Pastebin code, or GitHub URL!")
        else
            local parsedUrl, parsedName = parseURL(parts[2])

            if parsedUrl then
                downloadUrl = parsedUrl
                targetName = parts[3] or parsedName or "app"
            else
                -- Official Xos Repository Fallback
                targetName = parts[2]
                downloadUrl = OFFICIAL_REPO_BASE .. targetName .. ".lua"
            end
        end

        if downloadUrl ~= "" and targetName ~= "" then
            if not targetName:find("%.lua$") then
                targetName = targetName .. ".lua"
            end

            term.setTextColor(colors.yellow)
            print("\n[+] Downloading from:")
            term.setTextColor(colors.lightGray)
            print("    " .. downloadUrl)
            term.setTextColor(colors.yellow)
            print("    Saving as: App/" .. targetName .. " ...")

            local res = http.get(downloadUrl)
            if res then
                if not fs.exists("App") then fs.makeDir("App") end
                local f = fs.open("App/" .. targetName, "w")
                f.write(res.readAll())
                f.close()
                res.close()

                term.setTextColor(colors.lime)
                print("[OK] Success! Package App/" .. targetName .. " installed.")
            else
                term.setTextColor(colors.red)
                print("[ERROR] Download failed. Check network or parameters.")
            end
        end

    elseif cmd == "remove" or cmd == "rm" then
        if not parts[2] then
            term.setTextColor(colors.red)
            print("Error: Specify file name to remove!")
        else
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
        end

    elseif cmd == "help" then
        showHelp()

    else
        term.setTextColor(colors.red)
        print("Unknown command. Type 'help' for command list.")
    end
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
