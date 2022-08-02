---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 18:24
---
local AddonName, E = ...

Bohemian_ProfessionsConfig = {
    showProfessions = true,
    showOwnReagents = true,
    showOfflineMembers = true,
    collapsed = {},
}
Bohemian.RegisterModule(AddonName, E, function()

    Bohemian_ProfessionsConfig.lastCraftSync = Bohemian_ProfessionsConfig.lastCraftSync or {}
    E:CreateGuildFrameProfessionsColumnHeader()
    E:CreateGuildCraftFrame()
    E:AddLFGFrameButton()
    E:CreateGuildCraftListFrame()
    E:AdjustDetailFrame()
    E:RenderColumns()
    E:Hook()
end)

local C = E.CORE
E.sharedCrafts = {}
if not Professions then
    Professions = {}
end

if not Crafts then
    Crafts = {}
end

E.EVENT = {
    PROFESSION_INFO = "PROFESSION_INFO",
    PROFESSION_INFO_REQUEST = "PROFESSION_INFO_REQUEST",
    CRAFT = "CRAFT",
}

function E:ShareProfessions(sendTo)
    local skills = {}
    local skillRanks = {}
    for skillIndex = 1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank, _, _,
        skillMaxRank, _, _, _, _, _,
        _ = GetSkillLineInfo(skillIndex)
        if not isHeader then
            if E.PROFESSIONS[skillName] then
                skillRanks[skillName] = skillRank .. "-" .. skillMaxRank
            end
        end
    end
    local _, _, offset, numSlots = GetSpellTabInfo(1)
    local foundMining = false
    for j = offset + 1, offset + numSlots do
        local name, _, _, _, _, _, spellId = GetSpellInfo(GetSpellBookItemName(j, BOOKTYPE_SPELL))
        if E.PROFESSIONS[name] then
            local data = spellId
            if name ~= "Mining" then
                if name == "Find Herbs" then
                    data = 9134
                    name = "Herbalism"
                elseif name == "Find Minerals" then
                    data = 29354
                    name = "Mining"
                    foundMining = true
                end
                if skillRanks[name] then
                    data = data .. "-" .. skillRanks[name]
                end
                table.insert(skills, data)
            end
        end
    end
    local payload = table.concat(skills, ",")
    C:SendEventTo(sendTo, self.EVENT.PROFESSION_INFO, payload)
end

function E:GetPlayerProfessions(fullName)
    return Professions[fullName] or {}
end

function E:RequestProfessionInfo()
    C:SendEvent("GUILD", self.EVENT.PROFESSION_INFO_REQUEST)
end

function E:RequestProfessionInfoFrom(player)
    C:SendEventTo(player, self.EVENT.PROFESSION_INFO_REQUEST)
end

function E:CanSync()
    return not IsInInstance() and not IsActiveBattlefieldArena() and not E.sharing
end

E.updateQueue = {}

function E:ShareCrafts()
    local numCrafts = GetNumCrafts()
    local payload = {}
    local profName, _, _ = GetCraftDisplaySkillLine()
    if not profName then
        return
    end
    self.sharedCrafts[profName] = GetServerTime()
    local i = 1
    local wait = 0
    C:AddToUpdateQueue(function(id, elapsed)
        if wait > 0 then
            wait = wait - elapsed
            return
        end
        if i > numCrafts then
            C:RemoveFromUpdateQueue(id)
            C:BroadcastPayload("CRAFTS", "GUILD", payload)
            return
        end
        if not E:ValidateCraft(profName) then
            C:RemoveFromUpdateQueue(id)
            return
        end
        local craftName, _, craftType, numAvailable = GetCraftInfo(i)
        local numReagents = GetCraftNumReagents(i)
        local minMade, maxMade = GetCraftNumMade(i)
        local icon = GetCraftIcon(i)
        local desc = GetCraftDescription(i) or ""
        desc = C:encodeBase64(desc)
        local link = GetCraftItemLink(i)
        local cooldown = GetCraftCooldown(i) or 0
        local reagents = {}
        for j = 1, numReagents do
            local _, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo(i, j);
            local reagentLink = GetCraftReagentItemLink(i, j)
            table.insert(reagents, table.concat(table.removeNil({ reagentTexture, reagentCount, playerReagentCount, reagentLink }), "~"))
        end
        reagents = table.concat(reagents, "*")
        table.insert(payload, C:PreparePayload(self.EVENT.CRAFT, profName, craftName, craftType, numAvailable, icon, desc, cooldown, reagents, link, i, minMade, maxMade))
        i = i + 1
    end)
end

function E:ShareTradeSkills()
    local numCrafts = GetNumTradeSkills()
    local payload = {}
    local profName = GetTradeSkillLine()
    if not profName then
        return
    end
    self.sharedCrafts[profName] = GetServerTime()
    local i = 1
    local wait = 0
    C:AddToUpdateQueue(function(id, elapsed)
        if wait > 0 then
            wait = wait - elapsed
            return
        end
        if i > numCrafts then
            C:RemoveFromUpdateQueue(id)
            C:BroadcastPayload("CRAFTS", "GUILD", payload)
            return
        end
        if not E:ValidateProf(profName) then
            C:RemoveFromUpdateQueue(id)
            return
        end

        local craftName, craftType, numAvailable = GetTradeSkillInfo(i)
        if craftType ~= "header" then
            local numReagents = GetTradeSkillNumReagents(i)
            local minMade, maxMade = GetTradeSkillNumMade(i)
            local icon = GetTradeSkillIcon(i)
            local desc = " "
            desc = C:encodeBase64(desc)
            local link = GetTradeSkillRecipeLink(i)
            local cooldown = GetTradeSkillCooldown(i) or 0
            local reagents = {}
            for j = 1, numReagents do
                local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(i, j);
                local reagentLink = GetTradeSkillReagentItemLink(i, j)
                if reagentName == nil or reagentLink == nil then
                    wait = 0.1
                    return
                end

                table.insert(reagents, table.concat(table.removeNil({ reagentTexture, reagentCount, playerReagentCount, reagentLink }), "~"))
            end
            reagents = table.concat(reagents, "*")
            if not E:ValidateProf(profName) then
                C:RemoveFromUpdateQueue(id)
                return
            end
            table.insert(payload, C:PreparePayload(E.EVENT.CRAFT, profName, craftName, craftType, numAvailable, icon, desc, cooldown, reagents, link, i, minMade, maxMade))
        end
        i = i + 1
    end)
end
function E:ValidateProf(profName)
    local profNameTest = GetTradeSkillLine()
    if profNameTest ~= profName then
        self.sharedCrafts[profName] = nil
        return false
    end
    return true
end
function E:ValidateCraft(profName)
    local profNameTest = GetCraftDisplaySkillLine()
    if profNameTest ~= profName then
        self.sharedCrafts[profName] = nil
        return false
    end
    return true
end
function E:ShareCraftsDelayed()
    local profName = GetCraftName()
    if self.sharedCrafts[profName] and GetServerTime() - self.sharedCrafts[profName] < 60 then
        return
    end
    self:ShareCrafts()
end

function E:ShareTradeSkillsDelayed()
    local profName = GetTradeSkillLine()
    if self.sharedCrafts[profName] and GetServerTime() - self.sharedCrafts[profName] < 60 then
        return
    end
    self:ShareTradeSkills()
end
function E:ShareCraftHistory()
    local crafts = self:GetPlayerCraftHistory()
    if crafts then
        local payload = {}
        for profName, item in ipairs(crafts) do
            for craftName, data in pairs(item) do
                local reagents = {}
                for _, reagent in pairs(data.reagents) do
                    table.insert(reagents, { reagent.texture, reagent.count, reagent.playerCount, reagent.link }, "~")
                end
                reagents = table.concat(reagents, "*")
                local data = C:PreparePayload(self.EVENT.CRAFT, profName, craftName, data.type, data.available, data.icon, data.desc, data.cooldown, reagents, data.link, data.id, data.min, data.max)
                table.insert(payload, data)
            end
        end
        E:Debug("Sharing craft history")
        if sendTo then
            C:SendEventTo(sendTo, C.EVENT.PAYLOAD_START, "CRAFTS", #chunks, id)
        else
            C:SendEvent("GUILD", C.EVENT.BROADCAST_START, "CRAFTS", #chunks, id)
            C_Timer.After(1, function()
                C:StartBroadcastPayload(id)
            end)
        end
    end
end

function E:CacheCraftHistoryPayload()
    local payload = {}
    E.craftsHistoryPayload = {}
    local allCrafts = {}
    for playerName, professions in pairs(E:GetGuildCrafts()) do
        for profName, item in pairs(professions) do
            for craftName, data in pairs(item) do
                allCrafts[#allCrafts + 1] = { playerName, profName, craftName, data }
            end
        end
    end
    for _, item in ipairs(allCrafts) do
        local playerName = item[1]
        local profName = item[2]
        local craftName = item[3]
        local data = item[4]

        local reagents = {}
        for _, reagent in pairs(data.reagents) do
            table.insert(reagents, table.concat({ reagent.texture, reagent.count, reagent.playerCount, reagent.link }, "~"))
        end
        reagents = table.concat(reagents, "*")
        local data = C:PreparePayload(E.EVENT.CRAFT, profName, craftName, data.type, data.available, data.icon, C:encodeBase64(data.desc), data.cooldown, reagents, data.link, data.id, data.min, data.max, playerName)
        -- C:SendEventTo(sendTo, E.EVENT.CRAFT, profName, craftName, data.type, data.available, data.icon, C:encodeBase64(data.desc), data.cooldown, reagents, data.link, data.id, data.min, data.max, playerName)
        table.insert(payload, data)
    end
    local i = 1
    C:AddToUpdateQueue(function(id, elapsed)
        if i > #payload then
            C:RemoveFromUpdateQueue(id)
            E.historyCached = true
            return
        end
        local chunk = {}
        for j = 1, 10 do
            if i + j > #payload + 1 then
                break
            end
            table.insert(chunk, payload[i + j])
            i = i + 1
        end
        table.insert(E.craftsHistoryPayload, {C:PreparePayloadForSend(chunk)})
    end)
    --E.craftsHistoryPayload = { C:PreparePayloadForSend(E.craftsHistoryPayload) }
end
function E:SendAllCraftHistory(sendTo)
    for _, payload in ipairs(E.craftsHistoryPayload) do
        local id, chunks = unpack(payload)
         if sendTo then
            C:SendEventTo(sendTo, C.EVENT.PAYLOAD_START, "CRAFTS", #chunks, id)
        else
            C:SendEvent("GUILD", C.EVENT.BROADCAST_START, "CRAFTS", #chunks, id)
            C_Timer.After(1, function()
                C:StartBroadcastPayload(id)
            end)
        end
    end
end
function E:ShareAllCraftHistory(sendTo)
    if E.sharing then
        return
    end
    E.sharing = true
    C:AddToUpdateQueue(function(id, elapsed)
        if E.historyCached then
            C:RemoveFromUpdateQueue(id)
            E:SendAllCraftHistory(sendTo)
            E.sharing = false
            return
        end
    end)
end

function E:GetPlayerCraftHistory(name)
    return E:GetGuildCrafts()[name or C:GetPlayerName(true)]
end
function E:FilterCrafts(searchValue, profName, playerName)
    local crafts = self:GetPlayerCraftHistory(playerName)
    local result = {}
    if crafts and crafts[profName] then
        for craftName, data in pairs(crafts[profName]) do
            if string.find(strlower(craftName), searchValue) then
                result[craftName] = data
            end
        end
    end
    return result
end
function E:FilterCraftPlayers(searchValue)
    local result = {}
    for playerName, professions in pairs(E:GetGuildCrafts()) do
        for profName, profession in pairs(professions) do
            for craftName, data in pairs(profession) do
                if string.find(strlower(craftName), strlower(searchValue)) then
                    if not result[playerName] then
                        result[playerName] = {}
                    end
                    if not result[playerName][profName] then
                        result[playerName][profName] = {}
                    end
                    result[playerName][profName][craftName] = data
                end
            end
        end
    end
    return result
end
function E:GetProfessionIcon(profession)
    return E.PROFESSION_ICON_OVERRIDE[profession.name] or profession.icon
end

function E:GetGuildCrafts()
    local guildName = C:GetGuildName()
    return Crafts[guildName] or {}
end

function E:CleanUpOldMembers(cb)
    for playerName, _ in pairs(E:GetGuildCrafts()) do
        local inGuild = false
        for name, _ in pairs(C.guildRoster) do
            if playerName == name then
                inGuild = true
                break
            end
        end
        if not inGuild then
            cb(playerName)
        end
    end
end