local function HookFisher()

    local found_sources = {}

    for event_name, event_table in pairs(hook.GetTable()) do
        for identifier, func in pairs(event_table) do
            if type(func) == "function" then
                local info = debug.getinfo(func, "S")
                if info.source and info.source ~= "=[C]" then
                    local path = info.source:gsub("^@", "")
                    if not found_sources[path] then
                        found_sources[path] = true
                        print("[!] finded source with hook [" .. event_name .. "]: " .. path)
                    end
                end
            end
        end
    end

    for timer_name, timer_data in pairs(timer.GetTable or {}) do
        if type(timer_data) == "table" and type(timer_data.func) == "function" then
             local info = debug.getinfo(timer_data.func, "S")
             if info.source and info.source ~= "=[C]" then
                 local path = info.source:gsub("^@", "")
                 if not found_sources[path] then
                    found_sources[path] = true
                    print("[!] finded source with timer: " .. path)
                 end
             end
        end
    end

    local result = ""
    for path, _ in pairs(found_sources) do
        result = result .. path .. "\n"
    end
    file.Write("hook_sources_found.txt", result)

end

HookFisher()
