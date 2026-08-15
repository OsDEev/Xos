-- App/explorer.lua - Xos File Explorer
local w, h = term.getSize()
local currentPath = ""

local function drawHeader()
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write(" [Xos Explorer] /" .. currentPath)

    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.setCursorPos(w - 2, 1)
    term.write(" X ")
end

local function drawFileList()
    term.setBackgroundColor(colors.black)
    term.clear()
    drawHeader()

    local list = fs.list(currentPath)
    table.sort(list)

    term.setBackgroundColor(colors.black)

    -- Кнопка назад / вверх
    term.setCursorPos(2, 3)
    if currentPath ~= "" then
        term.setTextColor(colors.yellow)
        print("[..] (Back)")
    else
        term.setTextColor(colors.gray)
        print("[/] Root")
    end

    local line = 4
    for _, item in ipairs(list) do
        if line >= h - 1 then break end
        local fullPath = fs.combine(currentPath, item)
        term.setCursorPos(2, line)

        if fs.isDir(fullPath) then
            term.setTextColor(colors.blue)
            print("[DIR]  " .. item)
        else
            term.setTextColor(colors.white)
            print("[FILE] " .. item)
        end
        line = line + 1
    end

    -- Нижняя панель действий
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(1, h)
    term.clearLine()
    term.write(" [N]ew File  |  [D]el File  |  [Q]uit")
end

local function runExplorer()
    while true do
        drawFileList()
        local event, p1, p2, p3 = os.pullEvent()

        if event == "mouse_click" and p1 == 1 then
            local cx, cy = p2, p3
            -- Закрыть окно
            if cy == 1 and cx >= w - 2 then
                break
            end

            -- Клик по директориям / файлам
            if cy == 3 and currentPath ~= "" then
                currentPath = fs.getDir(currentPath)
            elseif cy >= 4 then
                local list = fs.list(currentPath)
                table.sort(list)
                local index = cy - 3
                if list[index] then
                    local selected = list[index]
                    local fullPath = fs.combine(currentPath, selected)
                    if fs.isDir(fullPath) then
                        currentPath = fullPath
                    else
                        -- Открыть/Редактировать файл
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        shell.run("edit", fullPath)
                    end
                end
            end

        elseif event == "char" then
            local char = string.lower(p1)
            if char == "q" then
                break
            elseif char == "n" then
                term.setCursorPos(1, h)
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.yellow)
                term.clearLine()
                term.write("New File Name: ")
                local name = read()
                if name and name ~= "" then
                    local f = fs.open(fs.combine(currentPath, name), "w")
                    if f then f.close() end
                end
            elseif char == "d" then
                term.setCursorPos(1, h)
                term.setBackgroundColor(colors.red)
                term.setTextColor(colors.white)
                term.clearLine()
                term.write("Delete Name: ")
                local name = read()
                if name and name ~= "" then
                    local target = fs.combine(currentPath, name)
                    if fs.exists(target) then fs.delete(target) end
                end
            end
        end
    end
end

runExplorer()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
