---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 08.02.2022 1:11
---

local _, E = ...
SHOW_OFFLINE_MEMBERS = "Offline Members"
E.GUILD_FRAME_ADDITIONAL_WIDTH = 0
GUILD_FRAME_SCROLL_WIDTH = 25

E.GuildStatusHeaderOrder = {
    { frame = "GuildFrameGuildStatusColumnHeader1", order = 1 },
    { frame = "GuildFrameGuildStatusColumnHeader2", order = 2 },
    { frame = "GuildFrameGuildStatusColumnHeader3", order = 3 },
    { frame = "GuildFrameGuildStatusColumnHeader4", order = 4 },
}

E.GuildHeaderOrder = {
    { frame = "GuildFrameColumnHeader1", order = 1 },
    { frame = "GuildFrameColumnHeader2", order = 2 },
    { frame = "GuildFrameColumnHeader3", order = 3 },
    { frame = "GuildFrameColumnHeader4", order = 4 },
}

E.GuildHeaderColumns = {
    ["GuildFrameColumnHeader1"] = "Name",
    ["GuildFrameColumnHeader2"] = "Zone",
    ["GuildFrameColumnHeader3"] = "Level",
    ["GuildFrameColumnHeader4"] = "Class",
}

E.GuildStatusHeaderColumns = {
    ["GuildFrameGuildStatusColumnHeader1"] = "Name",
    ["GuildFrameGuildStatusColumnHeader2"] = "Rank",
    ["GuildFrameGuildStatusColumnHeader3"] = "Note",
    ["GuildFrameGuildStatusColumnHeader4"] = "Online",
}

E.GuildLFGButtonOrder = {
    { frame = "GuildFrameLFGButton", order = 1, offsetX = 102, offsetY = -2 },
}

function E:AddLFGButton(button, order, offsetX)
    table.insert(self.GuildLFGButtonOrder, { ["frame"] = button, ["order"] = order, ["offsetX"] = offsetX })
end

function E:RenderLFGButtons()
    local relativeTo
    table.sort(self.GuildLFGButtonOrder, function(a, b)
        return a.order < b.order
    end)
    for i, button in ipairs(self.GuildLFGButtonOrder) do
        local name = button.frame
        _G[name]:ClearAllPoints(true)
        if relativeTo then
            _G[name]:SetPoint("LEFT", relativeTo, "RIGHT", button.offsetX or 0, button.offsetY or 0)
        else
            _G[name]:SetPoint("TOPLEFT", GuildFrameLFGFrame, "TOPLEFT", button.offsetX or 0, button.offsetY or 0)
        end
        relativeTo = name
    end
    self:UpdateLFGFrameSize()
end

function E:AdjustGuildFrameControlButtons()
    GuildFrameGuildInformationButton:ClearAllPoints(true)
    GuildFrameAddMemberButton:ClearAllPoints(true)
    GuildFrameControlButton:ClearAllPoints(true)
    GuildFrameGuildInformationButton:SetPoint("BOTTOMLEFT", "GuildFrame", 4, 4)
    GuildFrameAddMemberButton:SetPoint("LEFT", "GuildFrameGuildInformationButton", "RIGHT", 0, 0)
    GuildFrameControlButton:SetPoint("LEFT", "GuildFrameAddMemberButton", "RIGHT", 0, 0)

    GuildListScrollFrame:HookScript("OnVerticalScroll", function()
        if GameTooltip:IsVisible() then
            GameTooltip:Hide()
        end
    end)
end

function E:RenderGuildFrame()
    local width = E:GetChildrenHeaderWidth(FriendsFrame.playerStatusFrame and GuildPlayerStatusFrame or GuildStatusFrame) + GUILD_FRAME_PADDING_RIGHT
    width = width + E.GUILD_FRAME_ADDITIONAL_WIDTH
    local tabIndex = PanelTemplates_GetSelectedTab(FriendsFrame)
    if tabIndex == 3 then
        if not InCombatLockdown() then
            if GuildListScrollFrame:IsVisible() then
                width = width + GUILD_FRAME_SCROLL_WIDTH
            end
            width = math.floor(math.max(E.FRIENDS_FRAME_DEFAULT_WIDTH, width))
            FriendsFrame:SetWidth(width)
            GuildListScrollFrame:SetWidth(width - 30)
            GuildFrameNotesText:SetWidth(FriendsFrame:GetWidth() - 20)
        end
    end
    E:RenderGuildFrameButtons(width)
end

function E:RenderGuildFrameButtons(width)
    local buttonPrefix = FriendsFrame.playerStatusFrame and "GuildFrameButton" or "GuildFrameGuildStatusButton"
    width = width - 5
    if GuildListScrollFrame:IsVisible() then
        width = width - GUILD_FRAME_SCROLL_WIDTH
    end
    for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
        local button = _G[buttonPrefix .. i]
        button:SetWidth(width)
        local highlightTexture = button:GetHighlightTexture()
        highlightTexture:SetWidth(width - 13)
        highlightTexture:SetPoint("LEFT", button, 5, 0)
    end
end

function E:AddGuildStatusColumnHeader(name, width, order, colName, isStringOnly, inherits)
    local f = E:CreateFrame("BUTTON", name, GuildStatusFrame, "GuildFrameColumnHeaderTemplate");
    table.insert(self.GuildStatusHeaderOrder, { ["frame"] = name, ["order"] = order })
    self.GuildStatusHeaderColumns[name] = colName
    WhoFrameColumn_SetWidth(f, width)
    E:CreateGuildStatusColumnsForHeader(name, colName, isStringOnly, inherits)
    return f
end

function E:AddGuildColumnsToExistingHeaders()
    for header, buttonName in pairs(E.GuildHeaderColumns) do
        E:AddGuildColumnsToHeader(header, "GuildFrameButton", buttonName)
    end
    for header, buttonName in pairs(E.GuildStatusHeaderColumns) do
        E:AddGuildColumnsToHeader(header, "GuildFrameGuildStatusButton", buttonName)
    end
end
COLUMN_PADDING = 4
function E:AddGuildColumnsToHeader(header, buttonPrefix, buttonName)
    local relativeTo
    for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
        local button = _G[buttonPrefix .. i .. buttonName]
        button:SetWidth(_G[header]:GetWidth())
        button:ClearAllPoints(true)
        if relativeTo then
            button:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -2)
        else
            button:SetPoint("TOPLEFT", _G[header], "BOTTOMLEFT", 4 + COLUMN_PADDING, -4)
        end
        relativeTo = button
    end
end

function E:AddVersionColumn()
    for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
        local button = _G["GuildFrameGuildStatusButton"..i]
        local online = _G["GuildFrameGuildStatusButton" .. i .. "Online"]
        local version = E:CreateFrame("Frame", "GuildFrameGuildStatusButton"..i.."Version", button)
        version:SetPoint("LEFT")
        version:SetSize(5, button:GetHeight())
        version:SetPoint("LEFT", online, "RIGHT", -version:GetWidth(), 0)
        local font = version:CreateFontString("$parentText", "ARTWORK", "GameFontNormal")
        font:SetText("·")
        font:SetFont("Fonts\\FRIZQT__.TTF", 20)
        font:SetPoint("CENTER", version, 0, 0)

        version:SetScript("OnEnter", function(self)
            if self.tooltip then
                GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0);
                GameTooltip:SetText(self.tooltip);
                GameTooltip:Show();
            end
        end)
        version:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)
        version:Hide()
    end

end

function E:SetGuildStatusColumnWidth()
    for header, buttonName in pairs(E.GuildHeaderColumns) do
        for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
            local button = _G["GuildFrameButton" .. i .. buttonName]
            if not _G[header]:IsVisible() then
                 button:Hide()
            else
                button:Show()
            end
            button:SetWidth(_G[header]:GetWidth() - 8 - COLUMN_PADDING)
        end
    end
    for header, buttonName in pairs(E.GuildStatusHeaderColumns) do
        for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
            local button = _G["GuildFrameGuildStatusButton" .. i .. buttonName]
            if not _G[header]:IsVisible() then
                button:Hide()
            else
                button:Show()
            end
            button:SetWidth(_G[header]:GetWidth() - 8 - COLUMN_PADDING)
        end
    end
end

function E:CreateGuildColumnsForHeader(header, buttonName, isStringOnly, inherits)
    E:CreateGuildStatusColumnsForHeaderBase("GuildFrameButton", _G[header], header, buttonName, nil, isStringOnly, inherits)
end

function E:CreateGuildStatusColumnsForHeader(header, buttonName, isStringOnly, inherits)
    E:CreateGuildStatusColumnsForHeaderBase("GuildFrameGuildStatusButton", _G[header], header, buttonName, nil, isStringOnly, inherits)
end

function E:CreateGuildStatusColumnsForHeaderBase(buttonPrefix, parent, header, buttonName, template, isStringOnly, inherits)
    local relativeTo
    for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
        local button = isStringOnly and _G[buttonPrefix .. i]:CreateFontString("$parent" .. buttonName, "BORDER", inherits or "GameFontNormal") or E:CreateFrame("Frame", buttonPrefix .. i .. buttonName, parent, template);
        button:SetWidth(_G[header]:GetWidth())
        if isStringOnly then
            button:SetJustifyH("LEFT")
        end
        button:SetHeight(14)
        if relativeTo then
            button:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -2)
        else
            button:SetPoint("TOPLEFT", _G[header], "BOTTOMLEFT", 4, -4)
        end
        relativeTo = button
    end
end

function E:AddGuildColumnHeader(name, width, order, colName, isStringOnly, inherits)
    local f = E:CreateFrame("BUTTON", name, GuildPlayerStatusFrame, "GuildFrameColumnHeaderTemplate");
    table.insert(self.GuildHeaderOrder, { ["frame"] = name, ["order"] = order })
    WhoFrameColumn_SetWidth(f, width)
    self.GuildHeaderColumns[name] = colName
    E:CreateGuildColumnsForHeader(name, colName, isStringOnly, inherits)
    return f
end

function E:SetGuildColumnOrder(name, order)
    for i, frame in ipairs(self.GuildHeaderOrder) do
        if frame.frame == name then
            self.GuildHeaderOrder[i].order = order
            break
        end
    end
end

function E:SetGuildStatusColumnOrder(name, order)
    for i, frame in ipairs(self.GuildStatusHeaderOrder) do
        if frame.frame == name then
            self.GuildStatusHeaderOrder[i].order = order
            break
        end
    end
end

function E:SwapColumnBetween(name, parent1, parent2)
    local f
    local newParent = parent1 == self.GuildHeaderOrder and GuildStatusFrame or GuildPlayerStatusFrame
    for i, frame in ipairs(parent1) do
        if frame.frame == name then
            f = table.remove(parent1, i)
            break
        end
    end
    if f then
        _G[f.frame]:SetParent(newParent)
        table.insert(parent2, f)
    end
end

function E:RenderGuildStatusColumnHeaders()
    self:RenderGuildColumnHeadersBase(self.GuildStatusHeaderOrder, GuildStatusFrame)
end

function E:RenderGuildColumnHeaders()
    self:RenderGuildColumnHeadersBase(self.GuildHeaderOrder, GuildPlayerStatusFrame)
end

function E:RenderGuildColumnHeadersAll()
    if FriendsFrame.playerStatusFrame then
        self:RenderGuildColumnHeaders()
    else
        self:RenderGuildStatusColumnHeaders()
    end
end

function E:RenderGuildColumnHeadersBase(order, parent)
    local relativeTo
    table.sort(order, function(a, b)
        return a.order < b.order
    end)
    for i, header in ipairs(order) do
        local name = header.frame
        local button = _G[name]
        if button:IsVisible() then
            button:ClearAllPoints(true)
            if relativeTo then
                button:SetPoint("LEFT", relativeTo, "RIGHT", -2, 0)
            else
                button:SetPoint("TOPLEFT", parent, "TOPLEFT", 7, -57)
            end
            relativeTo = name
        end
    end
end

function E:GetChildrenWidth(frame)
    local kids = { frame:GetChildren() };
    local width = 0
    for _, child in ipairs(kids) do
        if child:GetName() then
            local point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint()
            width = child:GetWidth() + width + (xOfs or 0)
        end
    end
    return width
end

function E:GetChildrenHeaderWidth(frame)
    local kids = { frame:GetChildren() };
    local width = 0
    for _, child in ipairs(kids) do
        if child:IsVisible() and string.find(child:GetName(), "Header") then
            width = child:GetWidth() + width
        end
    end
    return width
end

function E:FixToggleButton()
    GuildFrameGuildListToggleButton:ClearAllPoints()
    local totalMembers, onlineMembers, _ = GetNumGuildMembers();
    local numGuildMembers = 0;
    local showOffline = GetGuildRosterShowOffline();
    if (showOffline) then
        numGuildMembers = totalMembers;
    else
        numGuildMembers = onlineMembers;
    end
    local diff = E.ToggleButtonPosition or 0
    if numGuildMembers <= GUILDMEMBERS_TO_DISPLAY then
        diff = diff + 25
    end
    GuildFrameGuildListToggleButton:SetPoint("BOTTOMRIGHT", "GuildListScrollFrame", diff, 0);
end

function E:UpdateLFGFrame()
    GuildFrameLFGFrame:ClearAllPoints(true)
    GuildFrameLFGFrame:SetPoint("TOPLEFT", 60, -25)
    GuildFrameLFGButton:ClearAllPoints(true)
    GuildFrameLFGButton:SetPoint("TOPLEFT", "GuildFrameLFGFrame", 102, -2)
    GuildFrameLFGButtonText:SetPoint("RIGHT", "GuildFrameLFGButton", "LEFT", -3, 1)
    GuildFrameLFGButtonText:SetText(SHOW_OFFLINE_MEMBERS)
    self:UpdateLFGFrameSize()
end

function E:UpdateLFGFrameSize()
    local diff = 24
    local width = self:GetChildrenWidth(GuildFrameLFGFrame) + 8
    GuildFrameLFGFrame:SetWidth(width)
    GuildFrameLFGFrameMiddle:SetWidth(width - diff)
end

function E:GetLFGFrameLastItem()
    local kids = { GuildFrameLFGFrame:GetChildren() };
    local last
    for _, child in ipairs(kids) do
        last = child
    end
    return last
end
GUILD_FRAME_COLUMN_WIDTH_ZONE = 10

function E:UpdateColumnAfterUpdate()
    local showScrollBar = GuildListScrollFrame:IsVisible()
    if ( showScrollBar ) then
        WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 95);
    else
        GUILD_FRAME_COLUMN_WIDTH_ZONE = 0
        WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 120);
    end
    local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
    local numMembers = E:GetNumVisibleGuildMembers()
    for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
        local guildIndex = guildOffset + i;
        local guildMember = E:GetGuildMemberByIndex(guildIndex)
        if guildMember then
            local _, _, _, _, _, _, _, _, online, _, classFileName = unpack(guildMember)
            E:OnEvent("UPDATE_GUILD_MEMBER", i, guildIndex, numMembers, unpack(guildMember))
            if i <= numMembers then
                if online then
                    if classFileName then
                        local color = RAID_CLASS_COLORS[classFileName]
                        _G["GuildFrameButton" .. i .. "Class"]:SetTextColor(color.r, color.g, color.b)
                    end
                end
            end
        end

    end
end
function E:IncreaseDetailFrameHeight(height)
    E.DETAIL_FRAME_HEIGHTS = E.DETAIL_FRAME_HEIGHTS + height
end
function E:UpdateDetailFrame()
    local fullName, _, _, _, _, _, _, _, _ = GetGuildRosterInfo(GetGuildRosterSelection());
    local isCombat = InCombatLockdown()
    E.DETAIL_FRAME_DEFAULT_HEIGHT = C_GuildInfo.CanViewOfficerNote() and GUILD_DETAIL_OFFICER_HEIGHT - 5 or GUILD_DETAIL_NORM_HEIGHT
    if ( GetGuildRosterSelection() > 0 ) then
        GuildMemberDetailName:SetText(self:AddClassColorToName(fullName))
    elseif not isCombat then
        GuildMemberDetailFrame:Hide()
    end
    if not isCombat then
        GuildMemberDetailFrame:SetHeight(E.DETAIL_FRAME_HEIGHTS + E.DETAIL_FRAME_DEFAULT_HEIGHT)
    end
end

function E:SetFrameOffsetY(frame, offset)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + offset)
end
function E:SetFrameOffsetX(frame, offset)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOfs + offset, yOfs)
end

function E:SetFrameOffset(frame, offsetX, offsetY)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOfs + offsetX, yOfs + offsetY)
end

function E:CreateModuleInterfaceConfig(name, parent)
    local module = E:CreateFrame("Frame", "BohemianInterfaceOptionsPanel"..name)
    module:SetPoint("CENTER")
    module:SetSize(512, 512)
    module.name = name
    module.parent = parent or "Bohemian"
    module:Hide()
    InterfaceOptions_AddCategory(module)
    return module
end

function E:AddConfigEditBox(parent, relativeTo, frameName, name, value, suffix)
    local font = parent:CreateFontString("$parentText"..frameName,"ARTWORK", "GameFontNormal")
    font:SetJustifyH("LEFT")
    font:SetSize(140, 14)
    font:SetPoint(unpack(relativeTo))
    font:SetText(name)

    local editbox = E:CreateFrame("EditBox", "$parentEditBox"..frameName, parent, "InputBoxTemplate")
    editbox:SetAutoFocus(false)
    editbox:SetNumber(value or 0)
    editbox:SetSize(50,20)
    editbox:SetPoint("LEFT", font, "RIGHT", 0, 0)
    editbox:SetNumeric(true)
    editbox:SetMultiLine(false)
    editbox:SetFontObject("GameFontHighlight")
    editbox:SetTextInsets(5,8,0,0)
    editbox:SetJustifyH("RIGHT")
    editbox:SetScript( "OnEscapePressed", function( self )
        self:ClearFocus()
    end )

    editbox:SetScript( "OnEnterPressed", function( self )
        self:ClearFocus()
    end )

    local font2 = parent:CreateFontString("$parentText"..frameName.."Suffix","ARTWORK", "GameFontNormal")
    font2:SetJustifyH("LEFT")
    font2:SetSize(140, 14)
    font2:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
    font2:SetText(suffix or "")

    return font, editbox
end

function E:CreateInterfaceConfig()
    local f = E:CreateFrame("Frame", "BohemkaDKPInterfaceOptionsPanel")
    f:SetPoint("CENTER")
    f:SetSize(512, 512)
    f.name = "Bohemian"
    f:Hide()

    local debug = E:CreateFrame("CheckButton", "$parentDebug", f, "UICheckButtonTemplate");
    debug:SetSize(22,22)
    debug:SetPoint("TOPRIGHT", f, "TOPRIGHT", -30, -26)
    debug:SetChecked(BohemianConfig.debug)

    local font = debug:CreateFontString("$parentTextItemPrice","ARTWORK", "GameFontNormal")
    font:SetJustifyH("LEFT")
    font:SetSize(50, 14)
    font:SetPoint("RIGHT", debug, "LEFT", 0, 0)
    font:SetText("Debug")
    local title, _ = E:AddConfigEditBox(f, {"TOPLEFT", f, "TOPLEFT", 30, -26}, "CpsLimit", "Bandwith", BohemianConfig.cpsLimit, "CPS")

    E:AddModuleControl()

    BohemkaDKPInterfaceOptionsPanel.okay = function()
        BohemianConfig.debug = BohemkaDKPInterfaceOptionsPanelDebug:GetChecked()
        BohemianConfig.cpsLimit = BohemkaDKPInterfaceOptionsPanelEditBoxCpsLimit:GetNumber()
        E:SendRequiredModules()
    end
    BohemkaDKPInterfaceOptionsPanel.cancel = function()
        BohemkaDKPInterfaceOptionsPanelDebug:SetChecked(BohemianConfig.debug)
        BohemkaDKPInterfaceOptionsPanelEditBoxCpsLimit:SetNumber(BohemianConfig.cpsLimit)
    end

    InterfaceOptions_AddCategory(f)
end


function E:TableToConfigText(t)
    local str = {}
    for k, v in pairs(t) do
        table.insert(str, k.."="..v)
    end
    return table.concat(str, "\n")
end
function E:ConfigTextToTable(txt)
    local t = {}
    for _, v in ipairs({strsplit("\n", txt)}) do
        local k, v2 = strsplit("=", v)
        t[k] = tonumber(v2) or v2
    end
    return t
end

function E:AdjustGuildInfo()
    local e = CreateFrame("EditBox", "$parentFakeMOTD", GuildFrameNotesText:GetParent())
    e:SetFontObject("GameFontDisableSmall")
    e:SetPoint("TOPLEFT", GuildFrameNotesText, 0, 0)
    e:SetPoint("BOTTOMRIGHT", GuildFrameNotesText, 0, 0)
    e:SetSize(GuildFrameNotesText:GetSize())
    e:SetMultiLine(true)
    e:SetAutoFocus(false)
    e:SetJustifyH("LEFT")
    e:SetScript( "OnEscapePressed", function( )
        e:ClearFocus()
        e:SetText(GuildFrameNotesText:GetText())
    end )
    e:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        e:SetText(GuildFrameNotesText:GetText())
    end)
    e:SetScript("OnChar", function(self)
        self:ClearFocus()
        e:SetText(GuildFrameNotesText:GetText())
    end)


    GuildInfoTextBackground:HookScript("OnShow", function()
        if CanEditGuildInfo() then
            return
        end
        GuildInfoEditBox:EnableMouse(1)
        GuildInfoEditBox:Enable()
    end)
    GuildInfoEditBox:HookScript( "OnEscapePressed", function(self)
        if CanEditGuildInfo() then
            return
        end
        self:ClearFocus()
        self:SetText(GetGuildInfoText())
    end )
    GuildInfoEditBox:HookScript("OnEnterPressed", function(self)
        if CanEditGuildInfo() then
            return
        end
        self:ClearFocus()
        self:SetText(GetGuildInfoText())
    end)
    GuildInfoEditBox:SetScript("OnChar", function(self)
        if CanEditGuildInfo() then
            return
        end
        self:ClearFocus()
        self:SetText(GetGuildInfoText())
    end)
end

function E:UpdateGMOTDState()
    if CanEditMOTD() then
        GuildFrameFakeMOTD:Hide()
        GuildFrameNotesText:Show()
        GuildMOTDEditButton:Show()
    else
        GuildFrameFakeMOTD:SetText(GetGuildRosterMOTD() or "")
        GuildFrameFakeMOTD:Show()
        GuildFrameNotesText:Hide()
        GuildMOTDEditButton:Hide()
    end
end

function E:AddModuleControl()
    local font = BohemkaDKPInterfaceOptionsPanel:CreateFontString("$parentModuleControl","ARTWORK", "GameFontNormal")
    font:SetJustifyH("LEFT")
    font:SetSize(300, 14)
    font:SetPoint("TOPLEFT", 30, -66)
    font:SetText("Guild Module Control")
end

function E:UpdateModuleControlItems()
    for name, _ in pairs(self.MODULES) do
        local required = BohemianConfig.requiredModules[name]
        local module = _G["BohemkaDKPInterfaceOptionsPanelModule"..name]
        if module then
            module:SetChecked(required)
            if not IsGuildLeader() then
                module:Disable()
            end
        end
    end
end

function E:AddModuleControlItem(name, title)
    local item = E:CreateFrame("CheckButton", "$parentModule"..name, BohemkaDKPInterfaceOptionsPanel, "UICheckButtonTemplate");
    item:SetSize(22,22)
    item:SetPoint("TOPLEFT", E.lastModuleControlItem or BohemkaDKPInterfaceOptionsPanelModuleControl, "BOTTOMLEFT", 0, -5)
    item:SetChecked(BohemianConfig.requiredModules[name] or false)
    if not IsGuildLeader() then
        item:Disable()
    end
    local font = item:CreateFontString("$parentText","ARTWORK", "GameFontNormal")
    font:SetJustifyH("LEFT")
    font:SetSize(200, 14)
    font:SetPoint("LEFT", item, "RIGHT", 5, 0)
    font:SetText(title)
    local okay = BohemkaDKPInterfaceOptionsPanel.okay
    BohemkaDKPInterfaceOptionsPanel.okay = function()
        BohemianConfig.requiredModules[name] = item:GetChecked()
        okay()
    end
    local cancel = BohemkaDKPInterfaceOptionsPanel.cancel
    BohemkaDKPInterfaceOptionsPanel.cancel = function()
        cancel()
        item:SetChecked(BohemianConfig.requiredModules[name])
    end
    E.lastModuleControlItem = item
end

function E:AddTooltip(frame, anchorType)
    frame:SetScript("OnEnter", function(self)
        if self.tooltip then
            GameTooltip:SetOwner(self, anchorType);
            GameTooltip:SetText(self.tooltip);
            GameTooltip:Show();
        end
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end)
end
