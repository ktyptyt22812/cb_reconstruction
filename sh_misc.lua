
-- addons/classicbox-scripts/lua/autorun/sh_misc.lua


function classicbox.IsWinter()
    return classicbox.WinterAddon ~= nil
end

function classicbox.IsHalloween()
    return classicbox.HalloweenAddon ~= nil
end

function classicbox.SetupSkidMarkMeshes()
    --инициализация мешей следов
end

function classicbox.DestroySkidMarkMeshes()
    --очистка мешей следов
end

local function SendFile(name, data)
    express.Send("AdvDupe2_ReceiveFile", {
        File = data,
        Uploading = name,
    })
    AdvDupe2.RemoveProgressBar()
end

net.Receive("advdupe2_receivefile", function()
    local data = net.ReadString() 
    AdvDupe2.ReceiveFile(data)
end)

net.Receive("prop2mesh_download", function()
    local data = {}
    local downloads = prop2mesh.downloads

    for _, part in ipairs(downloads) do
        data[#data + 1] = part
    end

    prop2mesh.handleDownload(data)
end)

net.Receive("prop2mesh_upload_start", function()
    local entid    = net.ReadUInt(16)   
    local filecache_keys = net.ReadString()

    local data = {
        entid    = entid,
        filecache = filecache_keys,
    }

    express.Send("prop2mesh_upload", data)
end)


net.Receive("Receive", function(len, ply)
    local ent    = net.ReadEntity()  -- !ent
    local lenght = net.ReadUInt(8)   -- астрал ты специально? !lenght 

    if not IsValid(ply) then return end  -- !ply
    if not IsValid(ent) then return end

    local scale = math.min(net.ReadFloat(), ent:GetModelScale())

    if properties.CanBeTargeted(ent, ply) then
        ent:SetModelScale(scale)
        ent:Filter()
    end
end)

local function pac_submit_check(name, size, needsproof)
    if not pace.IsEnabled(name) then return false end
    return true
end

pace.HandleReceiveData = function(data)
    local owner = Player(data.owner)
    local lp    = LocalPlayer()

    if pace.IsPacOnUseOnly() then
        pace.HandleOnUseReceivedData(data)
        return
    end

    if not IsValid(owner) then
        Message("received message from server but owner is not valid!? typeof " .. type(owner))
        return
    end

    for _, part in ipairs(data) do
        --none
    end
end

local function SendPartToServer(part)
    local lp    = LocalPlayer()
    local owner = part:GetPlayerOwner()

    local allowed, reason, extra = pace.CallHook("CanWearParts", lp)
    if allowed == false then
        Message("the server doesn't want you to wear parts for some reason")
        return
    end

    if not pace.IsPartSendable(part) then return end

    local wear_filter = pace.CreateWearFilter(part)
    local data = table.Merge(part:ToTable(), {
        extra      = extra,
        allowed    = allowed,
        reason     = reason,
        data       = wear_filter,
    })

    table.insert(parts, data)

    timer.Create("GMExpress_SendPAC3Parts", 0.1, 1, function()
        express.Send("pac_submit", {
            parts = parts,
        })
        parts = {}
    end)
end

local function RemovePartOnServer(part)
    local lp = LocalPlayer()

    local name        = part.Name or "<unknown>"
    local server_only = part.server_only
    local filter      = part.filter

    pace.CallHook("RemoveOutfit", lp, "__ALL__")

    table.insert(parts, {
        name        = name,
        server_only = server_only,
        filter      = filter,
        data        = part,
    })

    timer.Create("GMExpress_SendPAC3Parts", 0.1, 1, function()
        express.Send("pac_submit", {
            parts = parts,
        })
        parts = {}
    end)
end