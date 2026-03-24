-- gmod_balancesystem/lua/ulx/modules/sh/sh_pointshop.lua

local function balance(calling_ply, target_ply)
    local points = balancesystem.GetPoints(target_ply)
    calling_ply:ChatPrint(target_ply:Nick() .. ": " .. points)
end

ulx.concommand(ulx.ACCESS_ADMIN, "balance", balance)

local function setpoints(calling_ply, target_ply, points)
    balancesystem.SetPoints(target_ply, points)
    ulx.fancyLogAdmin(calling_ply, "#A set #i points for #T", points, target_ply)
end

ulx.concommand(ulx.ACCESS_ADMIN, "setpoints", setpoints)

local function setpointsid(calling_ply, steamid, points)
    steamid = string.upper(steamid)

    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid.")
        return
    end

    local steamid64 = util.SteamIDTo64(steamid)
    balancesystem.SetPoints(steamid64, points)

    ulx.fancyLogAdmin(calling_ply, "#A set #i points for #s", points, steamid)
end

ulx.concommand(ulx.ACCESS_ADMIN, "setpointsid", setpointsid)


local function sendpoints(calling_ply, target_ply, points)
    balancesystem.SendPoints(calling_ply, target_ply, points, function(success)
        if success then
            calling_ply:ChatPrint("Вы передали " .. points .. " очков игроку " .. target_ply:Nick())
            target_ply:ChatPrint(calling_ply:Nick() .. " передал вам " .. points .. " очков")
        else
            calling_ply:ChatPrint("Не удалось передать очки")
        end
    end)
end

ulx.concommand(ulx.ACCESS_ALL, "sendpoints", sendpoints)


local function sendpointsid(calling_ply, steamid, points)
    steamid = string.upper(steamid)

    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid.")
        return
    end

    points = math.floor(points)

    local steamid64  = util.SteamIDTo64(steamid)
    local target_ply = player.GetBySteamID(steamid)

    local senderPoints = balancesystem.GetPoints(calling_ply)
    if senderPoints < points then
        calling_ply:ChatPrint("Недостаточно очков")
        return
    end

    balancesystem.RemovePoints(calling_ply, points)

    balancesystem.AddPoints(steamid64, points)

    calling_ply:ChatPrint("Вы передали " .. points .. " очков игроку " .. steamid)

    if IsValid(target_ply) then
        target_ply:ChatPrint(calling_ply:Nick() .. " передал вам " .. points .. " очков")
    end
end

ulx.concommand(ulx.ACCESS_ALL, "sendpointsid", sendpointsid)


local function requestpoints(calling_ply, target_ply, points)
    balancesystem.RequestPoints(calling_ply, target_ply, points, function(success)
        if success then
            calling_ply:ChatPrint("Игрок " .. target_ply:Nick() .. " принял запрос")
        else
            calling_ply:ChatPrint("Игрок " .. target_ply:Nick() .. " отклонил запрос")
        end
    end)
end

ulx.concommand(ulx.ACCESS_ALL, "requestpoints", requestpoints)