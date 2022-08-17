---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 09.02.2022 15:52
---
local _, E = ...

local C = E.CORE

function E:RenderMainCharacterInfo(i, fullName)
    local charData = self:GetGuildMemberCharactersData(fullName)
    local name, rank = self:GetMainCharacter(charData)
    if name and name ~= fullName then
        _G["GuildFrameButton" .. i].tooltip = C:AddClassColorToName(name) .. " - " .. rank
        _G["GuildFrameButton" .. i .. "Name"]:SetAlpha(0.75)
    else
        _G["GuildFrameButton" .. i].tooltip = nil
        _G["GuildFrameButton" .. i .. "Name"]:SetAlpha(1)
    end
end

function E:AdjustGuildFrameButtons()
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local charFrame = _G["GuildFrameButton" .. i]
        charFrame:SetScript("OnEnter", function(self)
            if self.tooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -27);
                GameTooltip:SetText(self.tooltip);
                GameTooltip:Show();
            end
        end)
        charFrame:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)
    end
end

