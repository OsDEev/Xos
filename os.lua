-- os.lua - Xos Core Kernel with Categorized Tabbed GUI & Mouse Scroll
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
local scrollOffset = 0

local appCategories = {
    ["settings.lua"] = "SYSTEM",
    ["update.lua"] = "SYSTEM",
    ["terminal.lua"] = "SYSTEM",
    ["explorer.lua"] = "FILES",
    ["localfile.lua"] = "FILES",
    ["download.lua"] = "FILES",
    ["pakkugaru.lua"] = "PACKAGES"
}

local function drawRect(x, y, width, height, bgColor)
    term.setBackgroundColor(bgColor)
    for i = 0, height - 1 do
        term.setCursorPos(x, y + i)
        term.write(string.rep(" ", width))
    end
end

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

local function getFilteredApps()
    local filtered = {}
    for _, app in ipairs(apps) do
        if activeTab == "ALL" or app.category == activeTab then
            table.insert(filtered, app)
        end
    end
    return filtered
end

-- Render Desktop UI
local function drawUI()
    w, h = term.getSize()

    -- Status Bar (Top)
    drawRect(1, 1, w, 1, colors.cyan)
    term.setTextColor(colors.black)
    term.setCursorPos(2, 1)
    term.write("Xos v3.6")

    local timeStr = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #timeStr, 1)
    term.write(timeStr)

    -- Desktop Background
    drawRect(1, 2, w, h - 2, colors.gray)

    -- Category Tabs Navigation Bar (Row 3)
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

    -- Render Filtered App Buttons with Scroll
    appButtons = {}
    local filteredApps = getFilteredApps()
    local startY = 5
    local maxVisibleRows = math.floor((h - startY - 1) / 2)

    -- Clamp Scroll Offset
    local maxScroll = math.max(0, #filteredApps - maxVisibleRows)
    if scrollOffset > maxScroll then scrollOffset = maxScroll end
    if scrollOffset < 0 then scrollOffset = 0 end

    local visibleCount = 0
    for i = scrollOffset + 1, #filteredApps do
        local app = filteredApps[i]
        visibleCount = visibleCount + 1
        local btnX = 2
        local btnY = startY + (visibleCount - 1) * 2

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

    if #filteredApps == 0 then
        term.setTextColor(colors.lightGray)
        term.setCursorPos(2, startY)
        term.write("No apps in this category.")
    end

    -- Scroll Indicator
    if #filteredApps > maxVisibleRows then
        term.setTextColor(colors.yellow)
        term.setCursorPos(w - 1, startY)
        term.write("^")
        term.setCursorPos(w - 1, h - 2)
        term.write("v")
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

-- Launch Application inside Window Environment
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
    local event, p1, p2, p3 = os.pullEvent()

    if event == "mouse_click" and p1 == 1 then
        local x, y = p2, p3

        -- 1. Check Tab Selection
        for _, tabBtn in ipairs(tabButtons) do
            if x >= tabBtn.x1 and x <= tabBtn.x2 and y == tabBtn.y1 then
                activeTab = tabBtn.id
                scrollOffset = 0
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

    elseif event == "mouse_scroll" then
        local direction = p1 -- -1 for Up, 1 for Down
        scrollOffset = scrollOffset + direction
        drawUI()

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
