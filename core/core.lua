---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 17:28
---
local _, E = ...

E.FRAMES = {}
E.MODULES = {}
E.EVENTS = {}
E.REQUIRED_ADDONS = {}
E.DETAIL_FRAME_HEIGHTS = 0
E.MODULE_QUEUE = {}

E.updateQueue = {}

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(_, elapsed)
    for _, item in pairs(E.updateQueue) do
        item(elapsed)
    end
end)
function E:Load()
    BohemianConfig.debug = BohemianConfig.debug or false
    BohemianConfig.cpsLimit = BohemianConfig.cpsLimit or 3000

    E.onlineSince = GetServerTime()
    E.FRIENDS_FRAME_DEFAULT_WIDTH = FriendsFrame:GetWidth()
    E:FixGuildOfflineState()
    E:AdjustGuildInfo()
    E:UpdateLFGFrame()
    E:AddGuildColumnsToExistingHeaders()
    E:AdjustGuildFrameControlButtons()
    E:CreateInterfaceConfig()
    C_Timer.After(20, function()
        E.stopIgnoringOffline = true
    end)
end

function E:AddToUpdateQueue(cb)
    local id = E:uuid()
    E:Debug("Added new task to update queue", id)
    E.updateQueue[id] = function(elapsed)
        cb(id, elapsed)
    end
    return id
end

function E:RemoveFromUpdateQueue(id)
    E.updateQueue[id] = nil
    E:Debug("Removed", id, "from update queue")
end

function E:FixGuildOfflineState()
    SetGuildRosterShowOffline(BohemianConfig.showOffline)
    GuildFrameLFGButton:SetChecked(BohemianConfig.showOffline)
end

function E:RepeatAfter(duration, cb)
    cb()
    C_Timer.After(duration, function () BohemkaDKP:RepeatAfter(duration, cb) end)
end

function E:RegisterAddon(addonName)
    self.REQUIRED_ADDONS[addonName] = {
        loaded = false
    }
end

function E:RegisterModule(moduleName, module, onLoad)
    module.CORE = self
    module.EVENTS = {}
    module.NAME = moduleName
    module.Print = function(self, ...)
        self.CORE:debugMessage(self.NAME, ...)
    end
    module.Debug = function(self, ...)
        if not BohemianConfig.debug then
            return
        end
        self.CORE:debugMessage(self.NAME, ...)
    end
    self.MODULES[moduleName] = { ["module"] = module, OnLoad = onLoad }
    self:Debug("Registered module", moduleName)
end

function E:RegisterEvent(event)
    self.EventFrame:RegisterEvent(event)
    self:Debug("Registered event", event)
end


function E:UnregisterEvent(event)
    self.EventFrame:UnregisterEvent(event)
    self:Debug("Unregistered event", event)
end


function E:ExecuteEvent(frame, event, ...)
    if frame.EVENTS[event] then
        frame.EVENTS[event](frame, ...)
        self:Debug(frame.NAME, "Executing", event, ...)
    end
end

function E:QueueEvent(...)
    E.QUEUE[#E.QUEUE + 1] = {...}
end

function E:QueueModuleEvent(module, ...)
    if not E.MODULE_QUEUE[module.NAME] then
        E.MODULE_QUEUE[module.NAME] = {}
    end
    E.MODULE_QUEUE[module.NAME][#E.MODULE_QUEUE[module.NAME] + 1] = {...}
end

function E:ProcessModuleQueue(module)
    if not E.MODULE_QUEUE[module.NAME] then
        return
    end
    local i = #E.MODULE_QUEUE[module.NAME]
    while #E.MODULE_QUEUE[module.NAME] > 0 do
        local event = table.remove(E.MODULE_QUEUE[module.NAME], i)
        E:OnEvent(unpack(event))
        i = i - 1
    end
end


function E:OnEvent(event, ...)
    local args = { ... }
    E:Debug("Received event", event, "| args:", ...)
    self:ExecuteEvent(self, event, ...)
    self:CallModules(function(module)
        if module.isLoaded then
            self:ExecuteEvent(module, event, unpack(args))
        else
            E:QueueModuleEvent(module, event, unpack(args))
        end
    end)
end

function E:CallModules(cb)
    for _, m in pairs(self.MODULES) do
        cb(m.module)
    end
end

function E:LoadModules()
    local playerName = self:GetPlayerName()
    for _, module in ipairs(self.AVAILABLE_MODULES) do
        local enabled = GetAddOnEnableState(playerName, module)
        if enabled then
            self:Debug("Loading module", module)
            LoadAddOn(module)
        end
    end
end

function E:GetModule(name)
    if self.MODULES[name] then
        return self.MODULES[name].module
    end
end

function E:LoadDataWhenReady()
    if GetNumGuildMembers() == 0 then
        C_Timer.After(1, function ()
            E:LoadDataWhenReady()
        end)
    else
        E:CacheGuildRoster()
        E.firstLoad = true
        E.EventFrame:SetScript('OnEvent', function(_, ...)
            E:OnEvent(...)
        end)
        E:OnEvent(E.EVENT.READY)
        E:GuildStatus_UpdateHook()
    end
end

function E:ProcessQueue()
    local i = #E.QUEUE
    while #E.QUEUE > 0 do
        E:OnEvent(unpack(table.remove(E.QUEUE, i)))
        i = i - 1
    end
    E:Debug("Queue processed")
end

function E:CreateFrame(type, ...)
    local frame = CreateFrame(type, ...)
    local frameName = frame:GetName()
    type = string.lower(type)
    if not E.FRAMES[type] then
        E.FRAMES[type] = {}
    end
    E.FRAMES[type][frameName] = frame
    E:OnEvent("FRAME_CREATED", frameName, type)
    return frame
end
