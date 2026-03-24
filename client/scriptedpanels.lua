-- addons/classicbox-scripts/lua/includes/extensions/client/panel/scriptedpanels.lua

local PanelFactory = {}


function vgui.Register(classname, mtable, base)
    base = base or "Panel"
    mtable.Base      = base
    mtable.ThisClass = classname

    local baseTbl = vgui.GetControlTable(base)
    if baseTbl then
        setmetatable(mtable, { __index = baseTbl })
    end

    if not mtable.Init then
        mtable.Init = function(self) end
    end

    hook.Run("PreRegisterPANEL", classname, mtable)

    PanelFactory[classname] = mtable
    return mtable
end

function vgui.RegisterTable(mtable, base)
    base = base or "Panel"
    mtable.Base = base
    if not mtable.Init then
        mtable.Init = function(self) end
    end
    PANEL = mtable
    return mtable
end

function vgui.RegisterFile(filename)
    local OldPanel = PANEL
    PANEL = {}
    include(filename)
    local mtable = PANEL
    PANEL = OldPanel
    mtable.Base = mtable.Base or "Panel"
    if not mtable.Init then
        mtable.Init = function(self) end
    end
    return mtable
end

function vgui.Exists(classname)
    return PanelFactory[classname] ~= nil
end

function vgui.GetControlTable(classname)
    return PanelFactory[classname]
end

function vgui.CreateFromTable(panel, parent, name)
    if not istable(panel) then return end

    local base = panel.Base or "Panel"
    local pnl  = vgui.Create(base, parent, name)
    if not IsValid(pnl) then return end
    table.Merge(pnl:GetTable(), panel)

    pnl.BaseClass = vgui.GetControlTable(base)

    pnl:Prepare()
    pnl:Init()

    return pnl
end


local panels = {
    "CBPanel", "CBButton", "CBFrame", "CBLabel",
    "CBScrollPanel", "CBScrollBar", "CBTextEntry",
    "CBCheckBox", "CBComboBox", "CBSlider",
    "CBImage", "CBIcon", "CBListView",
    "CBPropertySheet", "CBTabPanel",
    "CBMenu", "CBMenuOption",
}

for _, name in ipairs(panels) do
    local path = "classicbox-scripts/lua/vgui/" .. name:lower() .. ".lua"
    if file.Exists(path, "LUA") then
        local mtable = vgui.RegisterFile(path)
        vgui.Register(name, mtable, mtable.Base or "CBPanel")
    end
end