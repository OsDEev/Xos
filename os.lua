-- os.lua - Xos Core Kernel with Window Task Manager & Controls
-- Repository: https://github.com/OsDEev/Xos

term.setBackgroundColor(colors.gray)
term.clear()

local w, h = term.getSize()

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

local function scanApps()
    apps = {}
    if fs.exists("App") and fs.isDir("App") then
        local files = fs.list("App")
        for _, file in ipairs(files) do
            if not fs.isDir("App/" .. file) and file:find("%.lua$") then
                local appName = file:gsub("%.lua$", "")
                table.insert(apps, { name = appName, path = "App/" .. file })
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
    term.write("Xos v2.5")

    local timeStr = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #timeStr, 1)
    term.write(timeStr)

    -- Desktop Background
    drawRect(1, 2, w, h - 2, colors.gray)

    -- App Catalog Header
    term.setTextColor(colors.white)
    term.setCursorPos(2, 3)
    term.write("=== APP CATALOG ===")

    -- Render App Buttons
    appButtons = {}
    local startY = 5
    local startX = 2

    if #apps == 0 then
        term.setTextColor(colors.lightGray)
        term.setCursorPos(2, startY)
        term.write("No apps found in /App folder.")
    else
        for i, app in ipairs(apps) do
            local btnX = startX
            local btnY = startY + (i - 1) * 2

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

    -- Create sub-window for the app (leaving row 1 for the Xos Title Bar)
    local appWin = window.create(term.current(), 1, 2, w, h - 1, true)

    -- Function to draw the Top Application Bar
    local function drawAppHeader()
        drawRect(1, 1, w, 1, colors.gray)
        
        -- Title
        term.setCursorPos(2, 1)
        term.setTextColor(colors.white)
        term.write("App: " .. appName)

        -- Close Button [ X ]
        drawRect(w - 4, 1, 5, 1, colors.red)
        term.setTextColor(colors.white)
        term.setCursorPos(w - 3, 1)
        term.write("[X]")
    end

    drawAppHeader()

    -- Redirect output to window
    local oldTerm = term.redirect(appWin)
    
    -- Run the app in a coroutine with event interceptor
    local appThread = coroutine.create(function()
        shell.run(appPath)
    end)

    local appRunning = true
    local eventData = {}

    while appRunning and coroutine.status(appThread) ~= "dead" do
        -- Resume application execution
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

        -- Intercept mouse & system events
        eventData = { os.pullEvent() }
        local eventName = eventData[1]

        if eventName == "mouse_click" then
            local mouseBtn, clickX, clickY = eventData[2], eventData[3], eventData[4]

            -- Check if click happened on the top Xos Title Bar (y == 1)
            if clickY == 1 then
                -- Clicked Close Button [X]
                if clickX >= w - 4 then
                    appRunning = false
                end
            end
        end
    end

    -- Restore parent terminal redirection
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
        -- 1. Check App Selection
        for _, btn in ipairs(appButtons) do
            if x >= btn.x1 and x <= btn.x2 and y == btn.y1 then
                launchApp(btn.path, btn.name)
            end
        end

        -- 2. Bottom Controls
        if y == h then
            -- EXIT System
            if x >= 2 and x <= 9 then
                systemRunning = false
            -- REFRESH Catalog
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
