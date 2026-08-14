-- App/calc.lua - Calculator
term.setBackgroundColor(colors.gray)
term.clear()

term.setCursorPos(2, 2)
term.setTextColor(colors.yellow)
print("--- Simple Calculator ---")

term.setTextColor(colors.white)
write("Expr (e.g. 10 + 5): ")
local input = read()

local func, err = load("return " .. input)
if func then
    local ok, res = pcall(func)
    if ok then
        term.setTextColor(colors.lime)
        print("Result: " .. tostring(res))
    else
        term.setTextColor(colors.red)
        print("Math Error!")
    end
else
    term.setTextColor(colors.red)
    print("Invalid Syntax!")
end

print("\nPress Enter to exit...")
read()
