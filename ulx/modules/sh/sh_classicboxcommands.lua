
-- addons/classicbox-scripts/lua/ulx/modules/sh/sh_classicboxcommands.lua


local function FormatBan(calling_ply, steamid, time, reason, should_unban, target_ply)
    --none
end

local function stopsound(calling_ply)
    ulx.fancyLogAdmin(calling_ply, "#A stopped all sounds")
    ulx.BroadcastLua("RunConsoleCommand(\"stopsound\")")
end

local function cleardecals(calling_ply)
    ulx.fancyLogAdmin(calling_ply, "#A cleared all decals")
    ulx.BroadcastLua("RunConsoleCommand(\"r_cleardecals\")")
end

ulx.concommand(ulx.ACCESS_ADMIN, "stopsound",  stopsound)
ulx.concommand(ulx.ACCESS_ADMIN, "cleardecals", cleardecals)

local function restartmap(calling_ply, time)
    ulx.fancyLogAdmin(calling_ply, "#A started a map restart timer in #i seconds", time)
    classicbox.RestartMap(time)
end

local function cleanupmap(calling_ply, time)
    if time and time > 0 then
        ulx.fancyLogAdmin(calling_ply, "#A started a map cleanup timer in #i seconds", time)
    else
        ulx.fancyLogAdmin(calling_ply, "#A cleaned up the map")
    end
    classicbox.CleanupMap(time)
end

ulx.concommand(ulx.ACCESS_ADMIN, "restartmap", restartmap)
ulx.concommand(ulx.ACCESS_ADMIN, "cleanupmap", cleanupmap)


local function e2tracker(calling_ply)
    local chips = {}

    for _, ent in ipairs(ents.FindByClass("gmod_wire_expression2")) do
        local ok, context = pcall(function() return ent.context end)
        if not ok then error("e2tracker: context error") end

        table.insert(chips, {
            name      = ent:GetName(),
            prfbench  = context and context.prfbench  or 0,
            timebench = context and context.timebench or 0,
            entindex  = ent:EntIndex(),
            owner     = ent.player,
        })
    end

    local msg = net.Start("classicbox_e2tracker")
        net.WriteUInt(#chips, MAX_EDICT_BITS)
        for _, chip in ipairs(chips) do
            net.WriteString(chip.name)
            net.WriteUInt(chip.entindex, MAX_EDICT_BITS)
            net.WritePlayer(chip.owner)
        end
    net.Send(calling_ply)
end

ulx.concommand(ulx.ACCESS_ADMIN, "e2tracker", e2tracker)

local function chipban(calling_ply, steamid, time, reason, should_unban, target_ply)
    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid")
        return
    end

    FormatBan(calling_ply, steamid, time, reason, should_unban, target_ply)

    if should_unban then
        util.RemovePData(steamid, "ULX_ChipBan")
        hook.Run("ULX_USER_UNCHIPBANNED", steamid)
    else
        util.SetPData(steamid, "ULX_ChipBan", time)

        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) then
            ply:SetNW2Bool("chips", true)
        end

        hook.Run("ULX_USER_CHIPBANNED", steamid, time, reason)
    end
end

ulx.concommand(ulx.ACCESS_ADMIN, "chipban", chipban)

local function pacban(calling_ply, steamid, time, reason, should_unban, target_ply)
    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid")
        return
    end

    FormatBan(calling_ply, steamid, time, reason, should_unban, target_ply)

    if should_unban then
        util.RemovePData(steamid, "PAC_Banned")
        pace.Unban(steamid)
        hook.Run("ULX_USER_UNPACBANNED", steamid)
    else
        util.SetPData(steamid, "PAC_Banned", time)

        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) then
            pace.Ban(ply)
        end

        hook.Run("ULX_USER_PACBANNED", steamid, time, reason)
    end
end

ulx.concommand(ulx.ACCESS_ADMIN, "pacban", pacban)


local ULXGotoRequest  = {}
local ULXGotoPlayers  = {}

local function requestgoto(calling_ply, target_ply)
    if not IsValid(target_ply) then return end

    ULXGotoRequest[calling_ply:UserID()] = target_ply

    calling_ply:ChatPrint("Запрос отправлен игроку " .. target_ply:Nick())
    target_ply:ChatPrint(calling_ply:Nick() .. " хочет телепортироваться к вам. Напишите !acceptgoto " .. calling_ply:Nick())

    timer.Create("f" .. calling_ply:UserID(), 30, 1, function()
        ULXGotoRequest[calling_ply:UserID()] = nil
        if IsValid(calling_ply) then
            ULXGotoPlayers[calling_ply] = nil
            calling_ply:ChatPrint("Запрос на goto истёк")
        end
    end)
end

local function acceptgoto(calling_ply, target_ply)
    if not IsValid(target_ply) then return end

    local eyepos = calling_ply:EyePos()
    local trace = util.TraceEntityHull({
        start  = eyepos,
        endpos = eyepos + calling_ply:GetAimVector() * 64,
        filter = calling_ply,
    })

    target_ply:SetPos(trace.HitPos)

    calling_ply:ChatPrint(target_ply:Nick() .. " телепортирован к вам")
    target_ply:ChatPrint("Вы телепортированы к " .. calling_ply:Nick())

    ULXGotoPlayers[calling_ply] = nil
    ULXGotoPlayers[target_ply]  = nil
end

ulx.concommand(ulx.ACCESS_ALL,   "requestgoto", requestgoto)
ulx.concommand(ulx.ACCESS_ADMIN, "acceptgoto",  acceptgoto)


local function checkropes(calling_ply)
    local players = {}

    for _, ply in player.Iterator() do
        table.insert(players, {
            ply   = ply,
            count = ropeconstraints.GetCount(ply),
        })
    end

    table.sort(players, function(a, b) return a.count > b.count end)

    for _, data in ipairs(players) do
        calling_ply:ChatPrint(string.format(
            " %s(%s) %i ",
            data.ply:Nick(),
            data.ply:SteamID(),
            data.count
        ))
    end
end

ulx.concommand(ulx.ACCESS_ADMIN, "checkropes", checkropes)


local rolldelay = {}

local function roll(calling_ply, maximum_value)
    local now = CurTime()

    if rolldelay[calling_ply] and now - rolldelay[calling_ply] < 1 then
        ULib.tsayError(calling_ply, "You just rolled recently! Please wait a second before using this command again")
        return
    end

    rolldelay[calling_ply] = now
    local result = math.random(1, maximum_value)
    ulx.fancyLogAdmin(calling_ply, "#A rolled #i/#i", result, maximum_value)
end

ulx.concommand(ulx.ACCESS_ALL, "roll", roll)

local function motd(calling_ply)
    calling_ply:SendLua("classicbox.OpenMOTD()")
end

local function wiki(calling_ply)
    calling_ply:SendLua("classicbox.OpenMOTD(true)")
end

local function donate(calling_ply)
    calling_ply:SendLua([[
        IGS.UI(nil, nil,
            classicbox.cbdraw.ScreenScale(640),
            classicbox.cbdraw.ScreenScaleH(360)
        )
    ]])
end

local function discord(calling_ply)
    calling_ply:SendLua([[gui.OpenURL("https://discord.gg/HAYqdWFrGE")]])
end

ulx.concommand(ulx.ACCESS_ALL, "motd",    motd)
ulx.concommand(ulx.ACCESS_ALL, "wiki",    wiki)
ulx.concommand(ulx.ACCESS_ALL, "donate",  donate)
ulx.concommand(ulx.ACCESS_ALL, "discord", discord)


local function eventplayed(calling_ply, target_plys, winner, winners)
    for _, ply in ipairs(target_plys) do
        classicbox.AddBadge(ply:SteamID64(), "event_joined")
        if winner then
            classicbox.AddEventWin(ply:SteamID64())
            classicbox.AddBadge(ply:SteamID64(), "event_winner")
        end
    end

    local msg = net.Start("classicbox_eventwin")
        net.WriteUInt(#target_plys, MAX_PLAYER_BITS)
        for _, ply in ipairs(target_plys) do
            net.WritePlayer(ply)
        end
    net.Broadcast()

    if winner then
        ulx.fancyLogAdmin(calling_ply, "#A marked as winners in the event #T", winners)
    else
        ulx.fancyLogAdmin(calling_ply, "#A marked as players in the event #T", target_plys)
    end
end

net.Receive("classicbox_eventwin", function()
    local count = net.ReadUInt(MAX_PLAYER_BITS)
    for i = 1, count do
        local ply = net.ReadPlayer()
        if IsValid(ply) then
            ply:EmitSound("classicevent_win.mp3")

            local emitter = ParticleEmitter(ply:GetPos())
            for j = 1, 30 do
                local effect = emitter:Add("effects/spark", ply:GetPos())
                if effect then
                    effect:SetColor(math.random(0,255), math.random(0,255), math.random(0,255))
                    effect:SetDieTime(math.Rand(1, 3))
                    effect:SetStartAlpha(255)
                    effect:SetEndAlpha(0)
                    effect:SetStartSize(4)
                    effect:SetEndSize(0)
                    effect:SetAirResistance(100)
                    effect:SetGravity(Vector(0, 0, -200))
                    effect:SetRoll(math.Rand(0, 360))
                    effect:SetRollDelta(math.Rand(-2, 2))
                    effect:SetVelocity(VectorRand() * 200)
                end
            end
            emitter:Finish()
        end
    end
end)

ulx.concommand(ulx.ACCESS_ADMIN, "eventplayed", eventplayed)

local function resetcustomization(calling_ply, target_plys, resetnicks, resetdescription, resettitle, resetbackground)
    local reset_list = {}

    for _, ply in ipairs(target_plys) do
        classicbox.ResetPlayerCustomization(ply, {
            nick        = resetnicks,
            description = resetdescription,
            title       = resettitle,
            background  = resetbackground,
        })
    end

    if resetnicks        then table.insert(reset_list, "nick")        end
    if resetdescription  then table.insert(reset_list, "description") end
    if resettitle        then table.insert(reset_list, "title")       end
    if resetbackground   then table.insert(reset_list, "background")  end

    ulx.fancyLogAdmin(calling_ply, "#A reseted #s for #T",
        table.concat(reset_list, ", "),
        target_plys
    )
end

ulx.concommand(ulx.ACCESS_ADMIN, "resetcustomization", resetcustomization)

local function download_ulxlogs(data)
    file.CreateDir("classicbox_logs")
    file.Write("classicbox_logs/" .. data.logname, data.data)
end

local function downloadlogs(calling_ply, forweek)
    local logs = file.Find("ulx_logs/*", "DATA", "datedesc")

    if #logs == 0 then
        calling_ply:ChatPrint(": data/classicbox_logs - логи не найдены")
        return
    end

    for _, logname in ipairs(logs) do
        local data = file.Read("ulx_logs/" .. logname, "DATA")
        express.Send("download_ulxlogs", {
            logname = logname,
            data    = data,
        })
    end

    calling_ply:ChatPrint(": data/classicbox_logs")
end

express.Receive("download_ulxlogs", download_ulxlogs)
ulx.concommand(ulx.ACCESS_SUPERADMIN, "downloadlogs", downloadlogs)

express.Receive("screengrab_grabscreen", function(data)
    local quality = net.ReadUInt(8)

    hook.Add("PostRender", "Screengrab_TakeScreen", function()
        hook.Remove("PostRender", "Screengrab_TakeScreen")

        local w = ScrW()
        local h = ScrH()

        local screenshot = render.Capture({
            format  = "jpg",
            quality = quality,
            x = 0, y = 0,
            w = w, h = h,
            alpha = false,
        })

        express.Send("screengrab_receivescreen", {
            data = screenshot,
        })
    end)
end)

express.Receive("screengrab_receivescreen", function(data)
    local filename = string.format("classicbox_screengrab/screengrab_cache_%i.jpg", os.time())

    file.CreateDir("classicbox_screengrab")
    file.Write(filename, data.data)

    for _, f in ipairs(file.Find("classicbox_screengrab/*", "DATA")) do
        file.Delete("DATA/classicbox_screengrab/" .. f)
    end

    local cached_material = Material("data/" .. filename)

    local frame = vgui.Create("CBFrame")
    frame:SetTitle("Screenshot")
    frame:SetSize(ScrW(), ScrH())
    frame:MakePopup()
    frame:Center()

    local preview_image = frame:Add("Panel")
    preview_image:Dock(FILL)
    preview_image.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(cached_material)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    hook.Add("ShutDown", "ScreengrabCleanup", function()
        for _, f in ipairs(file.Find("classicbox_screengrab/*", "DATA")) do
            file.Delete("DATA/classicbox_screengrab/" .. f)
        end
    end)
end)

local function screengrab(calling_ply, target_ply, quality)
    if not IsValid(target_ply) then return end

    net.Start("screengrab_grabscreen")
        net.WriteUInt(quality or 80, 8)
    net.Send(target_ply)

    express.Receive("screengrab_receivescreen", function(data)
        if not isstring(data) then return end
        if not IsValid(calling_ply) then return end
        if not IsValid(target_ply)  then return end

        express.Send("screengrab_sendscreen", {
            data     = data,
            preview  = true,
            filename = "screengrab",
        })
    end)

    calling_ply:ChatPrint("Запрос скриншота отправлен игроку " .. target_ply:Nick())
end

ulx.concommand(ulx.ACCESS_SUPERADMIN, "screengrab", screengrab)