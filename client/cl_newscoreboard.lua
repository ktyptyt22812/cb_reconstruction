-- addons/classicbox-scripts/lua/autorun/client/cl_newscoreboard.lua

function GM:ScoreboardShow()
    if IsValid(self.Scoreboard) then
        self.Scoreboard:Show()
    end
end

function GM:ScoreboardHide()
    if IsValid(self.Scoreboard) then
        self.Scoreboard:Hide()
    end
end