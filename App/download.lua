-- App/download.lua - HTTP Downloader
term.setBackgroundColor(colors.black)
term.clear()

term.setTextColor(colors.cyan)
print("=== File Downloader ===")

term.setTextColor(colors.white)
write("URL: ")
local url = read()

write("Save path: ")
local path = read()

if url ~= "" and path ~= "" then
    print("Downloading...")
    local response = http.get(url)
    if response then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
        response.close()
        term.setTextColor(colors.lime)
        print("Success! Saved to " .. path)
    else
        term.setTextColor(colors.red)
        print("Failed to download from URL!")
    end
end

print("\nPress Enter to exit...")
read()
