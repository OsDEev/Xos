-- os.lua - Xos Core Kernel with Categorized Tabbed GUI
-- Repository: https://github.com/OsDEev/Xos

term.setBackgroundColor(colors.gray)
term.clear()

local w, h = term.getSize()

-- Categorization Registry
local categories = {
    { id = "SYSTEM", name = "SYSTEM" },
    { id = "FILES", name = "FILES" },
    { id = "PACKAGES", name = "PACKAGES" },
    { id = "ALL", name = "ALL APPS" }
}

local activeTab = "SYSTEM"

local appCategories = {
    ["settings.lua"] = "SYSTEM",
    ["update.lua"] = "SYSTEM",
    ["terminal.lua"] = "SYSTEM",
    ["explorer.lua"] = "FILES",
    ["localfile.lua"] = "FILES",
    ["download.lua"] = "FILES",
    ["pakkugaru.lua"] = "PACKAGES"
}

-- Helper function to draw colored rectangle blocks
local function drawRect(x, y, width, height, bgColor)
    term.setBackgroundColor(bgColor)
    for i = 0, height - 1 do
        term.setCursorPos(x, y + i)
        term.write(string.rep(" ", width))
    end
end

-- App Catalog State
local apps = {}
local appButtons = {}
local tabButtons = {}

local function scanApps()
    apps = {}
    if fs.exists("App") and fs.isDir("App") then
        local files = fs.list("App")
        for _, file in ipairs(files) do
            if not fs.isDir("App/" .. file) and file:find("%.lua$") then
                local appName = file:gsub("%.lua$", "")
                local category = appCategories[file] or "ALL"
                table.insert(apps, { name = appName, path = "App/" .. file, file = file, category = category })
            end
        end
    end
end

-- Render Desktop UI
local function drawUI()
    w, h = term.getSize()

    -- Status Bar (Top)
    drawRect(1, 1, w, 1, colors.cyan)
    term.setTextColor(colors.black)
    term.setCursorPos(2, 1)
    term.write("Xos v3.5")

    local timeStr = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #timeStr, 1)
    term.write(timeStr)

    -- Desktop Background
    drawRect(1, 2, w, h - 2, colors.gray)

    -- Category Tabs Navigation Bar (Row 2 & 3)
    tabButtons = {}
    local tabX = 2
    local tabY = 3

    for _, tab in ipairs(categories) do
        local isSelected = (tab.id == activeTab)
        local label = " " .. tab.name .. " "
        local bgColor = isSelected and colors.blue or colors.lightGray
        local textColor = isSelected and colors.white or colors.black

        drawRect(tabX, tabY, #label, 1, bgColor)
        term.setTextColor(textColor)
        term.setCursorPos(tabX, tabY)
        term.write(label)

        table.insert(tabButtons, {
            x1 = tabX,
            y1 = tabY,
            x2 = tabX + #label - 1,
            y2 = tabY,
            id = tab.id
        })

        tabX = tabX + #label + 1
    end

    -- Render Filtered App Buttons
    appButtons = {}
    local startY = 6
    local startX = 2
    local displayedApps = 0

    for _, app in ipairs(apps) do
        if activeTab == "ALL" or app.category == activeTab then
            displayedApps = displayedApps + 1
            local btnX = startX
            local btnY = startY + (displayedApps - 1) * 2

            if btnY >= h - 1 then break end

            local label = " [ " .. app.name:upper() .. " ] "
            drawRect(btnX, btnY, #label, 1, colors.blue)
            term.setTextColor(colors.white)
            term.setCursorPos(btnX, btnY)
            term.write(label)

            table.insert(appButtons, {
                x1 = btnX,
                y1 = btnY,
                x2 = btnX + #label - 1,
                y2 = btnY,
                path = app.path,
                name = app.name
            })
        end
    end

    if displayedApps == 0 then
        term.setTextColor(colors.lightGray)
        term.setCursorPos(2, startY)
        term.write("No apps in this category.")
    end

    -- Bottom Navigation Bar
    drawRect(1, h, w, 1, colors.lightGray)

    -- EXIT Button
    drawRect(2, h, 8, 1, colors.red)
    term.setTextColor(colors.white)
    term.setCursorPos(3, h)
    term.write("EXIT")

    -- REFRESH Button
    drawRect(12, h, 10, 1, colors.lime)
    term.setTextColor(colors.black)
    term.setCursorPos(13, h)
    term.write("REFRESH")
end

-- Launch Application inside a Controlled Window Environment
local function launchApp(appPath, appName)
    w, h = term.getSize()

    local appWin = window.create(term.current(), 1, 2, w, h - 1, true)

    local function drawAppHeader()
        drawRect(1, 1, w, 1, colors.gray)
        term.setCursorPos(2, 1)
        term.setTextColor(colors.white)
        term.write("App: " .. appName)

        drawRect(w - 4, 1, 5, 1, colors.red)
        term.setTextColor(colors.white)
        term.setCursorPos(w - 3, 1)
        term.write("[X]")
    end

    drawAppHeader()

    local oldTerm = term.redirect(appWin)

    local appThread = coroutine.create(function()
        shell.run(appPath)
    end)

    local appRunning = true
    local eventData = {}

    while appRunning and coroutine.status(appThread) ~= "dead" do
        local ok, param = coroutine.resume(appThread, table.unpack(eventData))
        if not ok then
            term.redirect(oldTerm)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.red)
            print("\nApp crashed: " .. tostring(param))
            print("Press Enter to continue...")
            read()
            break
        end

        if coroutine.status(appThread) == "dead" then break end

        eventData = { os.pullEvent() }
        local eventName = eventData[1]

        if eventName == "mouse_click" then
            local mouseBtn, clickX, clickY = eventData[2], eventData[3], eventData[4]
            if clickY == 1 and clickX >= w - 4 then
                appRunning = false
            end
        end
    end

    term.redirect(oldTerm)
    scanApps()
    drawUI()
end

-- Main System Loop
scanApps()
drawUI()

local systemRunning = true
while systemRunning do
    local event, button, x, y = os.pullEvent()

    if event == "mouse_click" and button == 1 then
        -- 1. Check Tab Selection
        for _, tabBtn in ipairs(tabButtons) do
            if x >= tabBtn.x1 and x <= tabBtn.x2 and y == tabBtn.y1 then
                activeTab = tabBtn.id
                drawUI()
            end
        end

        -- 2. Check App Selection
        for _, btn in ipairs(appButtons) do
            if x >= btn.x1 and x <= btn.x2 and y == btn.y1 then
                launchApp(btn.path, btn.name)
            end
        end

        -- 3. Bottom Controls
        if y == h then
            if x >= 2 and x <= 9 then
                systemRunning = false
            elseif x >= 12 and x <= 21 then
                scanApps()
                drawUI()
            end
        end
    elseif event == "term_resize" then
        drawUI()
    end
end

-- Shutdown Xos
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
print("Returned to CraftOS.")
