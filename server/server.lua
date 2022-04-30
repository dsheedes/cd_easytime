--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


ESX = nil
QBCore = nil
vRP, vRPclient = nil, nil

if Config.Framework == 'esx' then
    TriggerEvent(Config.FrameworkTriggers.main, function(obj) ESX = obj end)

elseif Config.Framework == 'qbcore' then
    TriggerEvent(Config.FrameworkTriggers.main, function(obj) QBCore = obj end)
    if QBCore == nil then
        QBCore = exports[Config.FrameworkTriggers.resource_name]:GetCoreObject()
    end

elseif Config.Framework == 'vrp' then
    local Proxy = module('vrp', 'lib/Proxy')
    local Tunnel = module('vrp', 'lib/Tunnel')
    vRP = Proxy.getInterface('vRP')
    vRPclient = Tunnel.getInterface('vRP', 'chat_commands')
end


--███╗   ███╗ █████╗ ██╗███╗   ██╗
--████╗ ████║██╔══██╗██║████╗  ██║
--██╔████╔██║███████║██║██╔██╗ ██║
--██║╚██╔╝██║██╔══██║██║██║╚██╗██║
--██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
--╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝


local self = {}
local LastWeatherTable = {}
local LastWeather = false
local WeatherCounter = 0
local TimesChanged = 0
local HasTriggered = false
local TimeCounter = 0
local Group = Config.WeatherGroups[1]
local LastGroup = Config.WeatherGroups[1]
local resource_name = GetCurrentResourceName()
local TsunamiCountdownStarted = false

RegisterCommand(Config.Command.OpenUI, function(source)
    local _source = source
    if PermissionsCheck(_source) then
        TriggerClientEvent('cd_easytime:OpenUI', _source, self)
    else
        Notification(_source, 3, L('invalid_permissions'))
    end
end)

RegisterServerEvent('cd_easytime:SyncMe')
AddEventHandler('cd_easytime:SyncMe', function(instant)
    local _source = source
    local temp = json.decode(json.encode(self))
    temp.instanttime = true
    temp.instantweather = true
    TriggerClientEvent('cd_easytime:ForceUpdate', _source, temp)
end)

RegisterServerEvent('cd_easytime:ForceUpdate')
AddEventHandler('cd_easytime:ForceUpdate', function(data)
    local _source = source
    if PermissionsCheck(_source) then
        if data.hours then
            self.mins = 00
            self.hours = data.hours
        end
        if data.weather and data.weather ~= self.weather then
            self.weather = data.weather
            local shouldstop = false
            TimesChanged = 0
            LastWeatherTable = nil
            LastWeatherTable = {}
            for c_1, d_1 in pairs(Config.WeatherGroups) do
                if shouldstop then
                    break
                end
                for c_2, d_2 in pairs(d_1) do
                    if d_2 == self.weather then
                        shouldstop = true
                        Group = d_1
                        break
                    end
                end
            end
            for c_3, d_3 in pairs(Group) do
                if d_3 == self.weather then
                    break
                end
                TimesChanged = TimesChanged+1
                LastWeatherTable[d_3] = d_3
            end
        end
        if data.dynamic ~= nil then
            self.dynamic = data.dynamic
        end
        if data.blackout ~= nil then
            self.blackout = data.blackout
        end
        if data.freeze ~= nil then
            self.freeze = data.freeze
        end
        if data.instanttime ~= nil then
            self.instanttime = data.instanttime
        end
        if data.instantweather ~= nil then
            self.instantweather = data.instantweather
        end
        if data.tsunami ~= nil and Config.TsunamiWarning then
            self.tsunami = data.tsunami
        end
        TriggerClientEvent('cd_easytime:ForceUpdate', -1, data)
    else
        DropPlayer(_source, L('drop_player'))
    end
end)

local function LoadSettings()
    local settings = json.decode(LoadResourceFile(resource_name,'./settings.txt'))
    self.weather = settings.weather or 'CLEAR'
    self.hours = settings.hours or 08
    self.mins = settings.mins or 00
    self.dynamic = settings.dynamic or true
    self.blackout = settings.blackout or false
    self.freeze = settings.freeze or false
    self.instanttime = settings.instanttime or false
    self.instantweather = settings.instantweather or false
    self.tsunami = false
    print('^3['..resource_name..'] - Saved settings applied.^0')
    if Config.Framework ~= 'vrp' or Config.Framework ~= 'aceperms' then
        Wait(2000)
        local temp = json.decode(json.encode(self))
        temp.instanttime = true
        temp.instantweather = true
        TriggerClientEvent('cd_easytime:ForceUpdate', -1, temp)
    end
end

Citizen.CreateThread(function()
    LoadSettings()
    while true do
        Citizen.Wait(Config.TimeCycleSpeed*1000)
        if not self.freeze then
            TimeCounter = TimeCounter+1
            self.mins = self.mins+1
            if self.mins >= 60 then self.mins = 0 self.hours = self.hours+1 end
            if self.hours >= 24 then self.hours = 0 end

            if TimeCounter == 5 then
                HasTriggered = false
            end
            if not HasTriggered then
                HasTriggered = true
                TimeCounter = 0
                TriggerClientEvent('cd_easytime:SyncTime', -1, {hours = self.hours, mins = self.mins})
            end
        end

        if self.dynamic and not shouldstop then
            WeatherCounter = WeatherCounter+1
            if WeatherCounter >= ((Config.DynamicWeather_time*60*1000)/(Config.TimeCycleSpeed*1000)) then
                WeatherCounter = 0
                if #Group >= TimesChanged then
                    local TableCleared = true
                    for _, d in pairs(Group) do
                        if LastWeatherTable[d] == nil then
                            if d == 'THUNDER' and math.random(1,100) > Config.ThunderChance then
                                break
                            end
                            TimesChanged = TimesChanged+1
                            LastWeatherTable[d] = d
                            self.weather = d
                            TriggerClientEvent('cd_easytime:SyncWeather', -1, {weather = self.weather, instantweather = self.instantweather})
                            print('^3['..resource_name..'] - Weather changed to '..self.weather..'^0')
                            TableCleared = false
                            break
                        end
                    end
                    Wait(0)
                    if TableCleared then
                        Group = ChooseWeatherType()
                        TimesChanged = 0
                        LastWeatherTable = nil
                        LastWeatherTable = {}
                    end 
                    LastGroup = Group
                end
            end
        end
    end
end)
     
function ChooseWeatherType()
    local result = math.random(1,#Config.WeatherGroups)
    if result == 2 then
        if math.random(1,100) <= Config.RainChance then
            return Config.WeatherGroups[result]
        else
            local StartLoop = true
            while StartLoop do
                Wait(0)
                local finalaresult = math.random(1,#Config.WeatherGroups)
                if finalaresult ~= result and finalaresult ~= 4 then
                    StartLoop = false
                    return Config.WeatherGroups[finalaresult]
                end
            end
        end
    elseif result == 3 then
        if LastGroup == Config.WeatherGroups[result] then
            return Config.WeatherGroups[1]
        else
            return Config.WeatherGroups[result]
        end
    elseif result == 4 then
        if math.random(1,100) <= Config.SnowChance then
            return Config.WeatherGroups[result]
        else
            local StartLoop = true
            while StartLoop do
                Wait(0)
                local finalaresult = math.random(1,#Config.WeatherGroups)
                if finalaresult ~= result and finalaresult ~= 2 then
                    StartLoop = false
                    return Config.WeatherGroups[finalaresult]
                end
            end
        end
    else
        return Config.WeatherGroups[result]
    end 
end

RegisterServerEvent('cd_easytime:ToggleInstantChange:Time')
AddEventHandler('cd_easytime:ToggleInstantChange:Time', function(boolean)
    self.instanttime = boolean
end)

RegisterServerEvent('cd_easytime:ToggleInstantChange:Weather')
AddEventHandler('cd_easytime:ToggleInstantChange:Weather', function(boolean)
    self.instantweather = boolean
end)

local function SaveSettngs()
    SaveResourceFile(resource_name,'settings.txt', json.encode(self), -1)
    print('^3['..resource_name..'] - Settings Saved^0')
end

RegisterServerEvent('cd_easytime:SaveSettings')
AddEventHandler('cd_easytime:SaveSettings', function()
    SaveSettngs()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == resource_name then
        SaveSettngs()
    end
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == math.ceil(Config.TsunamiWarning_time*60) then
        SaveSettngs()
        if not Config.TsunamiWarning then return end
        self.tsunami = true
        TriggerClientEvent('cd_easytime:StartTsunamiCountdown', -1, true)
    end
end)

RegisterServerEvent('cd_easytime:StartTsunamiCountdown')
AddEventHandler('cd_easytime:StartTsunamiCountdown', function(boolean)
    if not Config.TsunamiWarning then return end
    self.tsunami = boolean
    TriggerClientEvent('cd_easytime:StartTsunamiCountdown', -1, boolean)
end)

function PermissionsCheck(source)
    if Config.Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        local perms = xPlayer.getGroup()
        for c, d in ipairs(Config.Command.Perms[Config.Framework]) do
            if perms == d then
                return true
            end
        end
        return false
    
    elseif Config.Framework == 'qbcore' then
        local perms = QBCore.Functions.GetPermission(source)
        for c, d in ipairs(Config.Command.Perms[Config.Framework]) do
            if type(perms) == 'string' then
                if perms == d then
                    return true
                end
            elseif type(perms) == 'table' then
                if perms[d] then
                    return true
                end
            end
        end
        return false

    elseif Config.Framework == 'vrp' then
        for c, d in pairs(Config.Command.Perms[Config.Framework]) do
            if vRP.hasPermission({vRP.getUserId({source}), d}) then 
                return true
            end
        end
        return false

    elseif Config.Framework == 'aceperms' then
        if IsPlayerAceAllowed(source, 'command.'..Config.Command.OpenUI) then
            return true
        end
        return false

    elseif Config.Framework == 'identifiers' then
        for c, d in ipairs(Config.Command.Perms[Config.Framework]) do
            for cc, dd in ipairs(GetPlayerIdentifiers(source)) do
                if string.lower(dd) == string.lower(d) then
                return true
            end
        end
    end
    return false

    elseif Config.Framework == 'other' then
        --Add your own permissions check here (boolean).
        return true
        
    end
end
