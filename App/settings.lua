-- App/settings.lua - Xos System Settings
local w, h = term.getSize()

-- Загрузка или создание настроек по умолчанию
local configPath = "xos.cfg"
local settingsData = {
    label = os.getComputerLabel() or "Xos-PC",
    theme = "Blue",
    bgColor = colors.blue,
    autoNet = true
}

if fs.exists(configPath) then
    local f = fs.open(configPath, "r")
    if f then
        local content = f.readAll()
        f.close()
        local parsed = textutils.unserialize(content)
        if type(parsed) == "table" then
            settingsData = parsed
        end
    end
end

local function saveSettings()
    local f = fs.open(configPath, "w")
    if f then
        f.write(textutils.serialize(settingsData))
        f.close()
    end
    if settingsData.label ~= "" then
        os.setComputerLabel(settingsData.label)
    end
end

local function drawHeader()
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write(" [Xos Settings] Panel")

    term.setBackgroundColor(colors.red)
    term.setCursorPos(w - 2, 1)
    term.write(" X ")
end

local function drawUI()
    term.setBackgroundColor(colors.black)
    term.clear()
    drawHeader()

    term.setBackgroundColor(colors.black)

    -- 1. PC Label
    term.setCursorPos(3, 3)
    term.setTextColor(colors.yellow)
    term.write("Computer Name: ")
    term.setTextColor(colors.white)
    term.write(settingsData.label)
    term.setCursorPos(30, 3)
    term.setTextColor(colors.lightGray)
    term.write("[Edit]")

    -- 2. Theme Selection
    term.setCursorPos(3, 5)
    term.setTextColor(colors.yellow)
    term.write("Desktop Theme: ")
    term.setTextColor(colors.cyan)
    term.write(settingsData.theme)
    term.setCursorPos(30, 5)
    term.setTextColor(colors.lightGray)
    term.write("[Change]")

    -- 3. Modem Status
    term.setCursorPos(3, 7)
    term.setTextColor(colors.yellow)
    term.write("Modem Peripheral: ")
    local modem = peripheral.find("modem")
    if modem then
        term.setTextColor(colors.lime)
        term.write("Connected (" .. peripheral.getName(modem) .. ")")
    else
        term.setTextColor(colors.red)
        term.write("Not Found")
    end

    -- 4. Storage Info
    term.setCursorPos(3, 9)
    term.setTextColor(colors.yellow)
    term.write("Free Storage: ")
    term.setTextColor(colors.white)
    term.write(math.floor(fs.getFreeSpace("/") / 1024) .. " KB")

    -- Нижнее меню
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(1, h)
    term.clearLine()
    term.write(" [S]ave & Exit  |  [Q]uit without Saving")
end

local themes = {
    { name = "Blue", color = colors.blue },
    { name = "Dark", color = colors.gray },
    { name = "Purple", color = colors.purple },
    { name = "Green", color = colors.green }
}

local function cycleTheme()
    for i, t in ipairs(themes) do
        if t.name == settingsData.theme then
            local nextIdx = (i % #themes) + 1
            settingsData.theme = themes[nextIdx].name
            settingsData.bgColor = themes[nextIdx].color
            return
        end
    end
    settingsData.theme = themes[1].name
    settingsData.bgColor = themes[1].color
end

local function main()
    while true do
        drawUI()
        local event, p1, p2, p3 = os.pullEvent()

        if event == "mouse_click" and p1 == 1 then
            local cx, cy = p2, p3
            -- Close window
            if cy == 1 and cx >= w - 2 then
                break
            end

            -- Change Label
            if cy == 3 and cx >= 30 then
                term.setCursorPos(1, h)
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.yellow)
                term.clearLine()
                term.write("New PC Name: ")
                local input = read()
                if input and input ~= "" then
                    settingsData.label = input
                end
            end

            -- Change Theme
            if cy == 5 and cx >= 30 then
                cycleTheme()
            end

        elseif event == "char" then
            local char = string.lower(p1)
            if char == "s" then
                saveSettings()
                term.setCursorPos(1, h)
                term.setBackgroundColor(colors.lime)
                term.setTextColor(colors.black)
                term.clearLine()
                term.write(" Settings Saved!")
                sleep(1)
                break
            elseif char == "q" then
                break
            end
        end
    end
end

main()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
