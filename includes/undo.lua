
local ClientUndos = {}
local bIsDirty    = false

local function MakeUIDirty()
    bIsDirty = true
end

local function GetTable()
    return ClientUndos
end

local function SetupUI()
    local UndoPanel = controlpanel.Get("UndoPanel")
    if not IsValid(UndoPanel) then return end

    UndoPanel.Think = function(self)
        if not bIsDirty then return end
        bIsDirty = false
        self:CPanelUpdate()
    end
end

net.Receive("undo_addundo", function()
    local undoName      = net.ReadString()
    local undoSecondary = net.ReadInt(32)

 
    local base, extra = string.match(undoName, "^(#.*) %((.*)%)$")

    local name
    if base then

        name = string.format("%s (%s)",
            language.GetPhrase(base),
            extra
        )
    else

        local found = string.find(undoName, " (", 1, true)
        if found then
            name = undoName
        else
            name = language.GetPhrase(undoName)
        end
    end

    table.insert(ClientUndos, {
        name      = name,
        secondary = undoSecondary,
    })

    MakeUIDirty()
end)

net.Receive("undo_undone", function()
    local index = net.ReadInt(32)

    for i, v in ipairs(ClientUndos) do
        if v.secondary == index then
            table.remove(ClientUndos, i)

            Undo.NewUndo()
            break
        end
    end

    MakeUIDirty()
end)

net.Receive("undo_fireundo", function()
    local name          = net.ReadString()
    local hasCustomText = net.ReadBool()
    local customtext    = hasCustomText and net.ReadString() or nil

    hook.Run("OnUndo", name, customtext)
end)
Undo = Undo or {}
Undo.GetTable  = GetTable
Undo.SetupUI   = SetupUI
Undo.MakeUIDirty = MakeUIDirty



pace.UndoHistory  = {}
pace.UndoPosition = 0

function pace.RecordUndoHistory()
    local data      = pace.get_current_outfit()
    local json      = util.TableToJSON(data)
    local last_json = pace.UndoHistory[pace.UndoPosition]

    if last_json == json then return end

    while #pace.UndoHistory > pace.UndoPosition do
        table.remove(pace.UndoHistory)
    end

    table.insert(pace.UndoHistory, json)
    pace.UndoPosition = #pace.UndoHistory
end

local function ApplyDifference(data)
    local current = pace.get_current_outfit()

    for _, part in ipairs(data.diff_remove or {}) do
        current:diff_remove(part)
    end

    for _, part in ipairs(data.diff_create or {}) do
        current:diff_create(part)
    end

    if data.children then
        current.children = data.children
    end
end

-- Ctrl+Z
function pace.Undo()
    if pace.UndoPosition <= 1 then
        pace.FlashNotification("Nothing to undo")
        return
    end

    pace.UndoPosition = math.Clamp(
        pace.UndoPosition - 1,
        1,
        #pace.UndoHistory
    )

    local data = pace.UndoHistory[pace.UndoPosition]
    ApplyDifference(data)

    pace.FlashNotification("Undo position: " .. pace.UndoPosition)
end

-- Ctrl+Y
function pace.Redo()
    if pace.UndoPosition >= #pace.UndoHistory then
        pace.FlashNotification("Nothing to redo")
        return
    end

    pace.UndoPosition = math.Clamp(
        pace.UndoPosition + 1,
        1,
        #pace.UndoHistory
    )

    local data = pace.UndoHistory[pace.UndoPosition]
    ApplyDifference(data)

    pace.FlashNotification("Undo position: " .. pace.UndoPosition)
end

function pace.ClearUndo()
    pace.UndoHistory  = {}
    pace.UndoPosition = 0
end