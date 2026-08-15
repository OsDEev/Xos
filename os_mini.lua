-- os_mini.lua - Xos Pocket OS Edition (26x20 Display)
-- Repository: https://github.com/OsDEev/Xos

term.setBackgroundColor(colors.gray)
term.clear()

local w, h = term.getSize() -- Для Pocket PC обычно 26x20

local categories = { "SYS", "FILES", "PKG", "ALL" }
local activeTab = "SYS"
local scrollOffset = 0

local appCategories = {
    ["settings.lua"] = "SYS",
    ["update.lua"] = "SYS",
    ["terminal.lua"] = "SYS",
    ["explorer.lua"] = "FILES",
    ["localfile.lua"] = "FILES",
    ["download.lua"] = "FILES",
    ["pakkugaru.lua"] = "PKG"
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

local function drawUI()
    w, h = term.getSize()

    -- 1. Верхний статус-бар (Компактный)
    drawRect(1, 1, w, 1, colors.cyan)
    term.setTextColor(colors.black)
    term.setCursorPos(1, 1)
    term.write("Xos Mini")

    local timeStr = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #timeStr + 1, 1)
    term.write(timeStr)

    -- Фон
    drawRect(1, 2, w, h - 2, colors.gray)

    -- 2. Вкладки категорий (Узкие, в 1 строку)
    tabButtons = {}
    local tabX = 1
    local tabY = 2

    for _, cat in ipairs(categories) do
        local isSelected = (cat == activeTab)
        local label = " " .. cat .. " "
        local bgColor = isSelected and colors.blue or colors.lightGray
        local textColor = isSelected and colors.white or colors.black

        if tabX + #label - 1 <= w then
            drawRect(tabX, tabY, #label, 1, bgColor)
            term.setTextColor(textColor)
            term.setCursorPos(tabX, tabY)
            term.write(label)

            table.insert(tabButtons, {
                x1 = tabX,
                y1 = tabY,
                x2 = tabX + #label - 1,
                y2 = tabY,
                id = cat
            })
            tabX = tabX + #label
        end
    end

    -- 3. Список приложений
    appButtons = {}
    local filteredApps = getFilteredApps()
    local startY = 4
    local maxVisibleRows = h - startY - 1

    local maxScroll = math.max(0, #filteredApps - maxVisibleRows)
    if scrollOffset > maxScroll then scrollOffset = maxScroll end
    if scrollOffset < 0 then scrollOffset = 0 end

    local visibleCount = 0
    for i = scrollOffset + 1, #filteredApps do
        local app = filteredApps[i]
        visibleCount = visibleCount + 1
        local btnY = startY + (visibleCount - 1)

        if btnY >= h then break end

        -- Сокращаем длинные имена для 26 символов ширины
        local displayName = app.name:upper()
        if #displayName > 18 then
            displayName = displayName:sub(1, 15) .. ".."
        end

        local label = "> " .. displayName
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
        term.setCursorPos(1, btnY)
        term.write(label .. string.rep(" ", w - #label))

        table.insert(appButtons, {
            x1 = 1,
            y1 = btnY,
            x2 = w,
            y2 = btnY,
            path = app.path,
            name = app.name
        })
    end

    if #filteredApps == 0 then
        term.setTextColor(colors.lightGray)
        term.setCursorPos(1, startY)
        term.write(" No apps here")
    end

    -- Индикатор скролла справа
    if #filteredApps > maxVisibleRows then
        term.setTextColor(colors.yellow)
        term.setCursorPos(w, startY)
        term.write("^")
        term.setCursorPos(w, h - 1)
        term.write("v")
    end

    -- 4. Нижняя панель управления
    drawRect(1, h, w, 1, colors.lightGray)

    -- Кнопка OFF
    drawRect(1, h, 5, 1, colors.red)
    term.setTextColor(colors.white)
    term.setCursorPos(2, h)
    term.write("OFF")

    -- Кнопка REFRESH
    drawRect(7, h, 5, 1, colors.lime)
    term.setTextColor(colors.black)
    term.setCursorPos(8, h)
    term.write("SYNC")
end

local function launchApp(appPath, appName)
    w, h = term.getSize()

    local appWin = window.create(term.current(), 1, 2, w, h - 1, true)

    local function drawAppHeader()
        drawRect(1, 1, w, 1, colors.gray)
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
        term.write(" " .. appName:sub(1, 18))

        drawRect(w - 2, 1, 3, 1, colors.red)
        term.setTextColor(colors.white)
        term.setCursorPos(w - 1, 1)
        term.write("X")
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
            print("\nError: " .. tostring(param))
            print("Press Enter...")
            read()
            break
        end

        if coroutine.status(appThread) == "dead" then break end

        eventData = { os.pullEvent() }
        local eventName = eventData[1]

        if eventName == "mouse_click" then
            local mouseBtn, clickX, clickY = eventData[2], eventData[3], eventData[4]
            if clickY == 1 and clickX >= w - 2 then
                appRunning = false
            end
        end
    end

    term.redirect(oldTerm)
    scanApps()
    drawUI()
end

-- Main Loop
scanApps()
drawUI()

local systemRunning = true
while systemRunning do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "mouse_click" and p1 == 1 then
        local x, y = p2, p3

        -- Нажатие на вкладки
        for _, tabBtn in ipairs(tabButtons) do
            if x >= tabBtn.x1 and x <= tabBtn.x2 and y == tabBtn.y1 then
                activeTab = tabBtn.id
                scrollOffset = 0
                drawUI()
            end
        end

        -- Нажатие на приложения
        for _, btn in ipairs(appButtons) do
            if x >= btn.x1 and x <= btn.x2 and y == btn.y1 then
                launchApp(btn.path, btn.name)
            end
        end

        -- Нижняя панель
        if y == h then
            if x >= 1 and x <= 5 then
                systemRunning = false
            elseif x >= 7 and x <= 12 then
                scanApps()
                drawUI()
            end
        end

    elseif event == "mouse_scroll" then
        scrollOffset = scrollOffset + p1
        drawUI()

    elseif event == "term_resize" then
        drawUI()
    end
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
print("Xos Mini Closed.")
