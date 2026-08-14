-- startup.lua - Boot Manager

local args = { ... }
local forceBootMenu = false

if args[1] == "bootmenu" then
    forceBootMenu = true
end

local function drawMenu(selected)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(2, 2)
    print("=== CraftOS Boot Manager ===")

    local options = { "1. Launch Main OS", "2. CraftOS Shell (Emergency)", "3. Reboot", "4. Shutdown" }
    for i, opt in ipairs(options) do
        term.setCursorPos(4, 3 + i)
        if i == selected then
            term.setTextColor(colors.yellow)
            print("> " .. opt)
        else
            term.setTextColor(colors.white)
            print("  " .. opt)
        end
    end
end

local function showBootMenu()
    local selected = 1
    while true do
        drawMenu(selected)
        local _, key = os.pullEvent("key")
        if key == keys.up and selected > 1 then
            selected = selected - 1
        elseif key == keys.down and selected < 4 then
            selected = selected + 1
        elseif key == keys.enter then
            if selected == 1 then
                break
            elseif selected == 2 then
                term.clear()
                term.setCursorPos(1, 1)
                print("Emergency Shell activated. Type 'reboot' to restart.")
                return false
            elseif selected == 3 then
                os.reboot()
            elseif selected == 4 then
                os.shutdown()
            end
        end
    end
    return true
end

-- Быстрая проверка: зажата ли клавиша при старте или вызвано через reboot bootmenu
local timer = os.startTimer(0.3)
local event = os.pullEvent()

if forceBootMenu or event == "key" then
    if not showBootMenu() then
        return -- Выход в стандартный Shell
    end
end

-- Переход к загрузке ОС
if fs.exists("os.lua") then
    shell.run("os.lua")
else
    print("Error: os.lua not found!")
end
