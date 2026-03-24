-- sh/anticrash.lua

local function getlag(calling_ply)

    local physdelay = physenv.GetLastSimulationTime() * 1000 -- в мс

    local e2delay = 0
    for _, ent in ipairs(ents.FindByClass("gmod_wire_expression2")) do
        local ok, context = pcall(function() return ent.context end)
        if ok and context then
            e2delay = e2delay + (context.timebench or 0)
        end
    end

    local sfdelay = 0
    for _, ent in ipairs(ents.FindByClass("starfall_processor")) do
        local ok, instance = pcall(function() return ent.instance end)
        if ok and instance then
            sfdelay = sfdelay + (perf.getAverageCpu(instance) or 0)
        end
    end

    calling_ply:ChatPrint(string.format(
        "Задержка от физики: %ims \n
        Задержка от E2: %ius \n
        Задержка от SF: %ius",
        physdelay, e2delay, sfdelay
    ))
end

local function forceanticrash(calling_ply)
    hook.Call("HolyLib:PostPhysicsLag")
    ulx.fancyLogAdmin(calling_ply, "#A forced anticrash start")
end

ulx.concommand(ulx.ACCESS_ADMIN,      "getlag",        getlag)
ulx.concommand(ulx.ACCESS_SUPERADMIN, "forceanticrash", forceanticrash)

--[[
--client
net.Receive("anticrash_crashmsg", function()
    local ply    = net.ReadPlayer()
    local length = net.ReadUInt(MAX_EDICT_BITS)

    if IsValid(ply) then
        notification.AddLegacy(tostring(length), NOTIFY_GENERIC, 5)
        chat.AddText(Color(255, 80, 80), "[zhest] ", color_white, ply:Nick() .. " вызвал краш (" .. length .. ")")
    end
end)
--]]