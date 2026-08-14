-- os.lua - Graphical OS & File Explorer

local net = fs.exists("network.lua") and require("network") or nil
if net then net.init() end

local w, h = term.getSize()
local currentPath = "/"

-- Проверка и создание папки приложений
if not fs.exists("App") then
    fs.makeDir("App")
end

local function drawHeader()
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write(" [OS] File System")

    local time = textutils.formatTime(os.time(), true)
    term.setCursorPos(w - #time + 1, 1)
    term.write(time)
end

local function drawFiles()
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)

    for y = 2, h - 1 do
        term.setCursorPos(1, y)
        term.clearLine()
    end

    term.setCursorPos(2, 2)
    term.setTextColor(colors.yellow)
    term.write("Path: " .. currentPath)

    local list = fs.list(currentPath)
    local y = 4

    if currentPath ~= "/" then
        term.setCursorPos(2, y)
        term.setTextColor(colors.lightGray)
        term.write("[..] (Back)")
        y = y + 1
    end

    for _, name in ipairs(list) do
        if y >= h - 1 then break end
        term.setCursorPos(2, y)

        if fs.isDir(fs.combine(currentPath, name)) then
            term.setTextColor(colors.lime)
            term.write("[DIR] " .. name)
        else
            term.setTextColor(colors.white)
            term.write("      " .. name)
        end
        y = y + 1
    end
end

local function drawFooter()
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.setCursorPos(1, h)
    term.clearLine()
    term.write(" [App/calc]  [App/download]  [App/pakkugaru] ")
end

local function openFile(path)
    local win = window.create(term.current(), 3, 3, w - 4, h - 5, true)
    win.setBackgroundColor(colors.black)
    win.clear()
    win.setTextColor(colors.cyan)
    win.setCursorPos(1, 1)
    win.write("=== " .. fs.getName(path) .. " ===")

    local file = fs.open(path, "r")
    if file then
        local lineNum = 2
        local line = file.readLine()
        while line and lineNum < h - 6 do
            win.setCursorPos(1, lineNum)
            win.setTextColor(colors.white)
            win.write(string.sub(line, 1, w - 4))
            line = file.readLine()
            lineNum = lineNum + 1
        end
        file.close()
    end

    win.setCursorPos(1, h - 5)
    win.setTextColor(colors.yellow)
    win.write("Press any key to close...")
    os.pullEvent("key")
end

-- Запуск приложения во вложенном окне
local function runApp(appPath)
    -- Сохраняем текущий терминал
    local oldTerm = term.redirect(term.native())

    -- Создаем окно под приложение
    local win = window.create(oldTerm, 1, 2, w, h - 2, true)
    term.redirect(win)
    win.setBackgroundColor(colors.black)
    win.clear()

    local ok, err = pcall(function()
        shell.run(appPath)
    end)

    -- Восстанавливаем исходный терминал
    term.redirect(oldTerm)

    if not ok then
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        term.setCursorPos(1, h - 1)
        term.write("App Error: " .. tostring(err))
        sleep(2)
    end
end

-- Главный цикл обработки событий
while true do
    drawHeader()
    drawFiles()
    drawFooter()

    local event, button, x, y = os.pullEvent()

    if event == "mouse_click" and button == 1 then
        -- Клики по панели приложений
        if y == h then
            if x >= 2 and x <= 11 then
                runApp("App/calc.lua")
            elseif x >= 14 and x <= 27 then
                runApp("App/download.lua")
            elseif x >= 30 and x <= 45 then
                runApp("App/pakkugaru.lua")
            end

        -- Навигация по проводнику
        elseif y >= 4 and y < h - 1 then
            local list = fs.list(currentPath)
            local offset = (currentPath ~= "/") and 1 or 0
            local clickIndex = (y - 4) + 1

            if currentPath ~= "/" and clickIndex == 1 then
                currentPath = fs.getDir(currentPath)
            else
                local itemIndex = clickIndex - offset
                local selected = list[itemIndex]
                if selected then
                    local fullPath = fs.combine(currentPath, selected)
                    if fs.isDir(fullPath) then
                        currentPath = fullPath
                    else
                        openFile(fullPath)
                    end
                end
            end
        end
    end
end
