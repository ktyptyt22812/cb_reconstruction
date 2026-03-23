
-- addons/classicbox-scripts/lua/autorun/client/cl_misc.lua

local function AddScroll(pnl, power, enable)
    if not pnl:GetBool(enable) then return end

    local data = {
        doing_scroll = false,
        tScroll      = 0,
        newerT       = 0,
        Old_Pos      = 0,
        Old_Sign     = 0,
    }

    local function getBiggerPos(delta, oldScroll)
        return oldScroll + delta
    end

    local anim = pnl:NewAnimation(0.2) 

    pnl.Think = function(self)
        local ctime = RealTime()
        local delta = ctime - data.newerT
        data.newerT = ctime

        if not data.doing_scroll then return end

        local StartPos  = data.Old_Pos
        local TargetPos = data.tScroll
        local fraction  = anim:GetFloat()

        local nowpos = Lerp(fraction, StartPos, TargetPos)
        nowpos = math.Clamp(nowpos, 0, pnl:CanvasSize())

        pnl:SetScroll(nowpos)

        if nowpos == TargetPos then
            data.doing_scroll = false
        end

        data.Old_Sign = data.tScroll - nowpos > 0 and 1 or -1
        data.Old_Pos  = pnl:GetScroll()
    end

    local OldScroll = pnl.OnMouseWheeled
    pnl.OnMouseWheeled = function(self, scroll)
        local oldScroll = self:GetScroll()
        local tScroll   = getBiggerPos(scroll * power, oldScroll)
        tScroll = math.Clamp(tScroll, 0, self:CanvasSize())

        data.Old_Pos      = oldScroll
        data.tScroll      = tScroll
        data.doing_scroll = true
        data.newerT       = RealTime()

        anim:NewAnimation(0.2)
    end
end

net.Receive("classicbox_timer", function()
    local time     = net.ReadUInt(32)
    local is_red   = net.ReadBool()

    local col = is_red and Color(255, 80, 80) or color_white

    chat.AddText(col, tostring(time))
end)

net.Receive("hitmarker_hit", function()
    if not GetConVar("himarkers"):GetBool() then return end

    local is_headshot = net.ReadBool()

    if is_headshot then
        surface.PlaySound("rust_headshot.wav")
    else
        surface.PlaySound("rust_hitmarker.wav")
    end
end)

net.Receive("hitmarker_killhit", function()
    if not GetConVar("killeffect"):GetBool() then return end

    surface.PlaySound("rust_headshot.wav")

    LocalPlayer():ScreenFade(
        SCREENFADE.IN,
        Color(180, 0, 0, 100),
        0.3, 
        0.1   
    )
end)