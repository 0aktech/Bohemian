---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 08.02.2022 2:46
---

local _, E = ...
local C = E.CORE
local A = E.EVENTS

E.CORE:RegisterEvent('GROUP_ROSTER_UPDATE')
E.CORE:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
E.CORE:RegisterEvent('ENCOUNTER_END')
E.CORE:RegisterEvent('ENCOUNTER_START')

function A:COMBAT_LOG_EVENT_UNFILTERED()
    local _, eventType, _, _, _, _, _, _, destName, _, _, recapID, _ = CombatLogGetCurrentEventInfo()
    if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" or eventType == "UNIT_DISSIPATES" then
        if not IsInRaid() or not UnitIsGroupLeader("player") or E.isEncounterInProgress then
            return
        end
        local reward = E:GetCurrentBossRewards(destName)
        if reward then
            E:AwardDKPRaid(reward, "killing of " .. destName)
        end
    end
end

function A:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
    E.isEncounterInProgress = false
    if not success then
        return
    end
    local reward = E:GetCurrentBossRewards(encounterName)
    if reward then
        E:AwardDKPRaid(reward, "killing of " .. encounterName)
    end
end

function A:ENCOUNTER_START()
    E.isEncounterInProgress = true
end

function A:GUILD_FRAME_UPDATE()
    if FriendsFrame.playerStatusFrame then
        C:SwapColumnBetween("GuildFrameGuildStatusColumnHeader3", C.GuildStatusHeaderOrder, C.GuildHeaderOrder)
    else
        C:SwapColumnBetween("GuildFrameGuildStatusColumnHeader3", C.GuildHeaderOrder, C.GuildStatusHeaderOrder)
    end

    E:FixToggleButton()
    E:UpdateColumnAfterUpdate()
    E:UpdateDetailFrame()
    E:UpdateUIGuildPermissions()
    if E.isEditMode then
        E:UpdateSelectedMembers()
    end
end

function A:CACHED_GUILD_DATA()
    local totalMembers, _, _ = GetNumGuildMembers();
    local canEdit = CanEditPublicNote()
    local canEditOfficer = CanEditOfficerNote()
    local newRosterDKP = {}
    for i = 0, totalMembers do
        local fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName = GetGuildRosterInfo(i);
        if fullName then
            local currentDKP = self:NoteDKPToNumber(note)

            if currentDKP == nil and canEdit and canEditOfficer and not E.inProcess[fullName] then
                currentDKP = Bohemian_DKPConfig.startingDKP
                E.inProcess[fullName] = currentDKP
                if note ~= nil and note ~= "" then
                    GuildRosterSetOfficerNote(i, note)
                end
                C_Timer.After(math.random(1, 20), function()
                    E:SetInitialDKPDelayed(fullName)
                end)
            elseif E.inProcess[fullName] and currentDKP ~= nil then
                E.inProcess[fullName] = nil
            end
            newRosterDKP[fullName] = currentDKP
        end
    end
    E.roster = newRosterDKP
    E:ProcessQueue()
end

function A:ADDON_LOADED(name)
    if name == "Blizzard_RaidUI" then
        E.raidUILoaded = true
        E:AdjustRaidFrame()
    end
end

function A:GROUP_ROSTER_UPDATE()
    E:UpdateAwardDKPButton()
end

function A:GUILD_ROSTER_UPDATE()
    E.canEdit = E:CanEditDKP()
end

function A:UPDATE_GUILD_MEMBER(row, i, numMembers, fullName, rank, rankIndex, level, class, zone, note, officerNote, online, isAway, classFileName)
    if i <= numMembers then
        _G["GuildFrameGuildStatusButton" .. row .. "OfficerNote"]:SetText(officerNote)
        E:RefreshDKPColumn(row, note, online)
    else
        _G["GuildFrameGuildStatusButton" .. row .. "OfficerNote"]:SetText("")
        _G["GuildFrameGuildStatusButton" .. row .. "Note"]:SetText("")
    end

    local dkpCheckButton = _G["GuildFrameDKPSelectButton" .. row]
    if E.isEditMode and Bohemian_DKPConfig.showDKP then
        if i <= numMembers then
            dkpCheckButton:Show()
        else
            dkpCheckButton:Hide()
        end
    else
        dkpCheckButton:Hide()
    end
end
