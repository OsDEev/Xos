-- App/terminal.lua - Xos Shell Terminal with Cyrillic Translit Helper
local w, h = term.getSize()

-- Таблица конвертации раскладки / транслита (QWERTY -> Translit Cyrillic)
local cyrMap = {
    ["a"]="a", ["b"]="b", ["v"]="v", ["g"]="g", ["d"]="d", ["e"]="e",
    ["z"]="z", ["i"]="i", ["k"]="k", ["l"]="l", ["m"]="m", ["n"]="n",
    ["o"]="o", ["p"]="p", ["r"]="r", ["s"]="s", ["t"]="t", ["u"]="u",
    ["f"]="f", ["h"]="h", ["c"]="c", ["ch"]="ch", ["sh"]="sh", ["y"]="y"
}

local function drawHeader()
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write(" [Xos Terminal]  (Type 'exit' or 'help')")

    term.setBackgroundColor(colors.red)
    term.setCursorPos(w - 2, 1)
    term.write(" X ")

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

term.clear()
drawHeader()
term.setCursorPos(1, 2)
print("Xos Shell v1.0 Ready.")
print("CC:Tweaked ASCII mode active. Cyrillic unsupported natively.")
print("==========================================")

local history = {}

while true do
    local cy = select(2, term.getCursorPos())
    if cy >= h then
        term.scroll(1)
        term.setCursorPos(1, h - 1)
    end

    drawHeader()

    term.setTextColor(colors.lime)
    term.write("xos:" .. shell.dir() .. "> ")
    term.setTextColor(colors.white)

    local input = read(nil, history)
    if input then
        table.insert(history, input)

        if input == "exit" or input == "quit" then
            break
        elseif input == "cls" or input == "clear" then
            term.clear()
            drawHeader()
            term.setCursorPos(1, 2)
        elseif input == "help" then
            term.setTextColor(colors.yellow)
            print("Commands: ls, cd, edit, cat, mkdir, rm, pakkugaru, exit")
            print("Tip: Use standard CraftOS shell utilities.")
            term.setTextColor(colors.white)
        else
            -- Запуск любой стандартной команды CraftOS
            shell.run(input)
        end
    end
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
