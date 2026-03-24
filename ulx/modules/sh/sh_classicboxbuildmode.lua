-- buildmode/lua/ulx/modules/sh/sh_classicboxbuildmode.lua

local function togglemode(calling_ply, target_plys, mode)
    for _, ply in ipairs(target_plys) do
        ply:SetBuildMode(mode)
    end
    ulx.fancyLogAdmin(calling_ply, "#A toggled build mode for #T", target_plys)
end

local function disallowchange(calling_ply, target_plys, allow)
    for _, ply in ipairs(target_plys) do
        ply.Buildmode_Disabled = not allow
    end
    local status = allow and "allowed" or "disallowed"
    ulx.fancyLogAdmin(calling_ply, "#A " .. status .. " mode changing for #T", target_plys)
end

ulx.concommand(ulx.ACCESS_ADMIN, "togglemode",    togglemode)
ulx.concommand(ulx.ACCESS_ADMIN, "disallowchange", disallowchange)