hook.Add("HUDPaint", "CBDraw_Example", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local sw = ScrW()
    local sh = ScrH()

    local x = cbdraw.ScreenScale(200)
    local y = cbdraw.ScreenScaleH(70)
    local fontSize = cbdraw.ScreenScale(16)

    cbdraw.SimpleText(
        ply:Nick(),
        "CBFont",
        sw / 2, cbdraw.ScreenScaleH(10),
        Color(255, 255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP,
        "CBFont_Shadow", 2
    )

    local hp    = ply:Health()
    local hpCol = Color(
        255 - hp * 2,   
        hp * 2,         
        0, 255
    )

    cbdraw.SimpleText(
        "♥ " .. hp,
        "CBFont",
        x, sh - cbdraw.ScreenScaleH(40),
        hpCol,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_TOP,
        "CBFont_Shadow", 1
    )

    cbdraw.DrawText(
        ply:Nick() .. "\n" .. tostring(ply:Frags()),
        {
            {
                font   = "CBFont",
                color  = Color(255, 255, 255, 255),
                xalign = TEXT_ALIGN_LEFT,
                yalign = TEXT_ALIGN_TOP,
            },

            {
                font   = "CBFont",
                color  = Color(255, 215, 0, 255),
                xalign = TEXT_ALIGN_LEFT,
                yalign = TEXT_ALIGN_TOP,
            },
        },
        x,
        sh - cbdraw.ScreenScaleH(80)
    )
end)