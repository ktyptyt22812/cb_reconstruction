
local PANEL = {}
PANEL.Base = "EditablePanel"

PANEL.ThisClass         = "CBPanel"
PANEL.Rounding          = false
PANEL.RoundingScale     = 5
PANEL.Outlining         = false
PANEL.OutlineThickness  = 1
PANEL.OutlineColor      = Color(0, 0, 0, 255)
PANEL.Hovering          = false
PANEL.HoveredColor      = Color(103, 103, 103, 255)
PANEL.UnHoveredColor    = Color(88, 88, 88, 255)


function PANEL:GetRounding()        return self.Rounding        end
function PANEL:GetRoundingScale()   return self.RoundingScale   end
function PANEL:GetOutlining()       return self.Outlining       end
function PANEL:GetOutlineThickness() return self.OutlineThickness end
function PANEL:GetOutlineColor()    return self.OutlineColor     end
function PANEL:GetMainColor()       return self.MainColor        end
function PANEL:GetSecondColor()     return self.SecondColor      end
function PANEL:GetHovering()        return self.Hovering         end
function PANEL:GetChildHover()      return self.ChildHover       end

function PANEL:SetRounding(v)        self.Rounding = v        end
function PANEL:SetRoundingScale(v)   self.RoundingScale = v   end
function PANEL:SetOutlining(v)       self.Outlining = v       end
function PANEL:SetOutlineThickness(v) self.OutlineThickness = v end
function PANEL:SetOutlineColor(v)    self.OutlineColor = v    end
function PANEL:SetMainColor(v)       self.MainColor = v       end
function PANEL:SetSecondColor(v)     self.SecondColor = v     end
function PANEL:SetHovering(v)        self.Hovering = v        end
function PANEL:SetChildHover(v)      self.ChildHover = v      end


function PANEL:Init()

end


function PANEL:Paint(w, h)
    local color = self.Hovering
        and self.HoveredColor
        or  self.UnHoveredColor

    if self.Rounding then
        draw.RoundedBox(self.RoundingScale, 0, 0, w, h, color)
    else
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h)
    end

    if self.Outlining then
        surface.SetDrawColor(self.OutlineColor)
        surface.DrawOutlinedRect(0, 0, w, h, self.OutlineThickness)
    end
end


function PANEL:OnCursorEntered()
    self.Hovering = true
end

function PANEL:OnCursorExited()
    self.Hovering = false
end

vgui.Register("CBPanel", PANEL, "EditablePanel")


local PANEL = {}
PANEL.Base      = "DScrollPanel"
PANEL.ThisClass = "CBScrollPanel"

PANEL.backgroundColor       = Color(66, 66, 66, 255)
PANEL.vbarColor              = Color(44, 44, 44, 255)
PANEL.gripColor              = Color(88, 88, 88, 255)
PANEL.gripHoveredColor       = Color(103, 103, 103, 255)
PANEL.shouldDrawVBarBackground = false

function PANEL:GetBackgroundColor()         return self.backgroundColor         end
function PANEL:GetVBarColor()               return self.vbarColor               end
function PANEL:GetGripColor()               return self.gripColor               end
function PANEL:GetGripHoveredColor()        return self.gripHoveredColor        end
function PANEL:GetShouldDrawVBarBackground() return self.shouldDrawVBarBackground end

function PANEL:SetBackgroundColor(v)         self.backgroundColor = v         end
function PANEL:SetVBarColor(v)               self.vbarColor = v               end
function PANEL:SetGripColor(v)               self.gripColor = v               end
function PANEL:SetGripHoveredColor(v)        self.gripHoveredColor = v        end
function PANEL:SetShouldDrawVBarBackground(v) self.shouldDrawVBarBackground = v end

function PANEL:Init()

    local vbar = self:GetVBar()

    if self.shouldDrawVBarBackground then
        vbar:SetWide(8)
        vbar.Paint = function(s, w, h)
            surface.SetDrawColor(self.vbarColor)
            surface.DrawRect(0, 0, w, h)
        end
    else
        vbar.Paint = function() end  
    end

    vbar.btnGrip.Paint = function(s, w, h)
        local col = s.Hovered
            and self.gripHoveredColor
            or  self.gripColor
        draw.RoundedBox(4, 0, 0, w, h, col)
    end

    vbar.btnUp.Paint   = function() end
    vbar.btnDown.Paint = function() end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.backgroundColor)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("CBScrollPanel", PANEL, "DScrollPanel")

local PANEL = {}
PANEL.Base       = "CBPanel"
PANEL.ThisClass  = "CBButton"
PANEL.Font       = "CBFont"
PANEL.ShadowFont = "CBFont_Shadow"

function PANEL:GetText()         return self.Text         end
function PANEL:GetFont()         return self.Font         end
function PANEL:GetShadowFont()   return self.ShadowFont   end
function PANEL:GetMaterial()     return self.Material     end
function PANEL:GetEnableShadow() return self.EnableShadow end

function PANEL:SetText(v)
    self.Text = v
    self:InvalidateCache()
end

function PANEL:SetFont(v)
    self.Font = v
    self:InvalidateCache()
end

function PANEL:SetShadowFont(v)   self.ShadowFont = v   end
function PANEL:SetMaterial(v)     self.Material = v     end
function PANEL:SetEnableShadow(v) self.EnableShadow = v end

function PANEL:InvalidateCache()
    self._cachedText = nil
end

function PANEL:Init()
    self.Text         = ""
    self.EnableShadow = false
    self.Material     = nil
    self.Cursor       = "hand"
    self:SetCursor("hand")
end

function PANEL:PaintOver(w, h)

    if self.Material then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.Material)
        surface.DrawTexturedRect(4, 4, h - 8, h - 8)
    end

    if self.EnableShadow and self.Text ~= "" then
        surface.SetFont(self.ShadowFont)
        surface.SetTextColor(0, 0, 0, 180)
        local tw, th = surface.GetTextSize(self.Text)
        surface.SetTextPos(w/2 - tw/2 + 1, h/2 - th/2 + 1)
        surface.DrawText(self.Text)
    end

    if self.Text ~= "" then
        surface.SetFont(self.Font)
        surface.SetTextColor(255, 255, 255, 255)
        local tw, th = surface.GetTextSize(self.Text)
        surface.SetTextPos(w/2 - tw/2, h/2 - th/2)
        surface.DrawText(self.Text)
    end
end

vgui.Register("CBButton", PANEL, "CBPanel")