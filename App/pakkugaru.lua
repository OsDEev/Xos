-- App/pakkugaru.lua - Package Manager (Paku-Paku)

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

-- Базовый репозиторий (можно заменить на свой GitHub / Pastebin API)
local REPO_BASE = "https://raw.githubusercontent.com/pastebin/"

-- Pac-Man ASCII пасхалка
term.setTextColor(colors.yellow)
print("   .--.   .-. ")
print("  / _= \\ / -' ")
print(" | /====| |   ")
print(" | \\====| |   ")
print("  \\ `--` \\ -._")
print("   `--`   `--` ")
term.setTextColor(colors.lime)
print("=== PAKKUGARU (パックガル) v1.2 ===")
print("  'The Package Gobbler' (paku-paku)")
term.setTextColor(colors.white)
print("Команды:")
print(" - list")
print(" - install <имя_пакета>")
print(" - install <URL> <имя_файла>")
print(" - remove <имя_файла>")

write("\npakkugaru> ")
local input = read()
local parts = {}
for word in input:gmatch("%S+") do table.insert(parts, word) end

local cmd = parts[1]

if cmd == "list" then
    print("\nУстановленные программы в /App:")
    local apps = fs.list("App")
    if #apps == 0 then
        print(" (пусто)")
    else
        for _, f in ipairs(apps) do
            print(" - " .. f)
        end
    end

elseif cmd == "install" then
    local url = ""
    local name = ""

    -- Вариант 1: install <имя_пакета> (из дефолтного репозитория)
    if parts[2] and not parts[3] then
        name = parts[2]
        url = REPO_BASE .. name .. ".lua"
    -- Вариант 2: install <URL> <имя_файла> (прямая ссылка)
    elseif parts[2] and parts[3] then
        url = parts[2]
        name = parts[3]
    else
        term.setTextColor(colors.red)
        print("Ошибка: Укажите пакет! Пример: install calc или install https://... app")
    end

    if url ~= "" and name ~= "" then
        -- Авто-добавление .lua к имени
        if not name:find("%.lua$") then
            name = name .. ".lua"
        end

        term.setTextColor(colors.yellow)
        print("Загрузка " .. name .. "...")
        print("Ссылка: " .. url)

        local res = http.get(url)
        if res then
            local f = fs.open("App/" .. name, "w")
            f.write(res.readAll())
            f.close()
            res.close()
            term.setTextColor(colors.lime)
            print("Успех! Пакет " .. name .. " съеден и сохранен в /App.")
        else
            term.setTextColor(colors.red)
            print("Ошибка: Не удалось скачать пакет. Проверьте ссылку и включен ли HTTP в конфиге CC.")
        end
    end

elseif cmd == "remove" and parts[2] then
    local name = parts[2]
    if not name:find("%.lua$") then name = name .. ".lua" end
    local path = "App/" .. name

    if fs.exists(path) then
        fs.delete(path)
        term.setTextColor(colors.lime)
        print("Пакет " .. name .. " удален.")
    else
        term.setTextColor(colors.red)
        print("Файл " .. name .. " не найден в /App.")
    end

else
    term.setTextColor(colors.lightGray)
    print("Неизвестная команда.")
end

term.setTextColor(colors.white)
print("\nНажмите Enter для выхода...")
read()
