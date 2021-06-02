ESX = nil
QBCore = nil
vRP = nil
vRPclient = nil

if Config.Framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

elseif Config.Framework == 'qbus' then
    TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

elseif Config.Framework == 'vrp' then
    local Proxy = module('vrp', 'lib/Proxy')
    local Tunnel = module('vrp', 'lib/Tunnel')
    vRP = Proxy.getInterface('vRP')
    vRPclient = Tunnel.getInterface('vRP', 'chat_commands')

end

local Weather = 'CLEAR'
local LastWeather = false
local Dynamic = Config.DynamicWeather
local Blackout = false
local FreezeTime = false
local Hours = 08
local Mins = 00
local InstantTimeChange = false
local InstantWeatherChange = false
local LastWeatherTable = {}
local WeatherCounter = 0
local TimesChanged = 0
local HasTriggered = false
local TimeCounter = 0
local Group = Config.WeatherGroups[1]
local LastGroup = Config.WeatherGroups[1]

RegisterCommand(Config.Command, function(source)
    local _source = source
    if PermissionsCheck(_source) then
        TriggerClientEvent('cd_easytime:OpenUI', _source, {weather = Weather, time = Hours, dynamic = Dynamic, blackout = Blackout, freeze = FreezeTime, instanttime = InstantTimeChange, instantweather = InstantWeatherChange})
    else
        Notification(_source, Config.Locales[Config.Language]['invalid_permissions'])
    end
end)

RegisterServerEvent('cd_easytime:SyncMe')
AddEventHandler('cd_easytime:SyncMe', function(instant)
    TriggerClientEvent('cd_easytime:ForceUpdate', source, {weather = Weather, hours = Hours, mins = Mins, dynamic = Dynamic, blackout = Blackout, freeze = FreezeTime, instanttime = InstantTimeChange, instantweather = InstantWeatherChange}, instant, true)
end)

RegisterServerEvent('cd_easytime:ForceUpdate')
AddEventHandler('cd_easytime:ForceUpdate', function(data, instant)
    local _source = source
    if instant == nil then
        instant = {time = InstantTimeChange, weather = InstantWeatherChange}
    end
    if PermissionsCheck(_source) then
        if data.hours ~= nil then
            Hours = data.hours
        end
        if data.weather ~= nil then
            Weather = tostring(data.weather)
            local shouldstop = false
            TimesChanged = 0
            LastWeatherTable = nil
            LastWeatherTable = {}
            for k, v in pairs(Config.WeatherGroups) do
                if shouldstop then
                    break
                end
                for k, w in pairs(v) do
                    if w == Weather then
                        shouldstop = true
                        Group = v
                        break
                    end
                end
            end
            for k, n in pairs(Group) do
                if n == Weather then
                    break
                end
                TimesChanged = TimesChanged+1
                LastWeatherTable[n] = n
            end
        end
        if data.dynamic ~= nil then
            Dynamic = data.dynamic
        end
        if data.blackout ~= nil then
            Blackout = data.blackout
        end
        if data.freeze ~= nil then
            FreezeTime = data.freeze
        end
        if data.instanttime ~= nil then
            InstantTimeChange = data.instanttime
        end
        if data.instantweather ~= nil then
            InstantWeatherChange = data.instantweather
        end
        TriggerClientEvent('cd_easytime:ForceUpdate', -1, {weather = Weather, hours = data.hours, mins = Mins, dynamic = Dynamic, blackout = Blackout, freeze = FreezeTime, instanttime = InstantTimeChange, instantweather = InstantWeatherChange}, instant)
    else
        DropPlayer(_source, 'Did you know, that banging your head against a wall for one hour burns 150 calories. Alternatively, you can walk your dog for 45 minutes, which also burns 150 calories – and is much less painful.')
    end
end)

Citizen.CreateThread(function()
    LoadSettings()
    while true do
        Citizen.Wait(Config.TimeCycleSpeed*1000)
        if not FreezeTime then
            TimeCounter = TimeCounter+1
            Mins = Mins+1
            if Mins >= 60 then Mins = 0 Hours = Hours+1 end
            if Hours >= 24 then Hours = 0 end

            if TimeCounter == 5 then
                HasTriggered = false
            end
            if not HasTriggered then
                HasTriggered = true
                TimeCounter = 0
                TriggerClientEvent('cd_easytime:SyncTime', -1, {hours = Hours, mins = Mins}, false)
            end
        end

        if Config.DynamicWeather and Dynamic and not shouldstop then
            WeatherCounter = WeatherCounter+1
            if WeatherCounter >= (Config.DynamicWeather_time*60*1000/Config.TimeCycleSpeed*1000) then
                WeatherCounter = 0
                if #Group >= TimesChanged then
                    local TableCleared = true
                    for k, v in pairs(Group) do
                        if LastWeatherTable[v] == nil then
                            if v == 'THUNDER' and math.random(1,100) > Config.ThunderChance then
                                break
                            end
                            TimesChanged = TimesChanged+1
                            LastWeatherTable[v] = v
                            Weather = v
                            TriggerClientEvent('cd_easytime:SyncWeather', -1, {weather = Weather, blackout = Blackout}, InstantTimeChange, false)
                            print('^3['..GetCurrentResourceName()..'] - Weather changed to '..Weather..'^0')
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

function PermissionsCheck(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        local group = xPlayer.getGroup()
        if Config.Framework_perms[group] ~= nil and Config.Framework_perms[group] == true then
            return true
        else
            return false
        end

    elseif Config.Framework == 'qbus' then
        local group = QBCore.Functions.GetPermission(source)
        if Config.Framework_perms[group] ~= nil and Config.Framework_perms[group] == true then
            return true
        else
            return false
        end

    elseif Config.Framework == 'vrp' then
        for c, d in pairs(Config.Framework_perms) do
            if vRP.hasPermission({vRP.getUserId({source}), c}) then 
                return true
            end
        end
        return false

    elseif Config.Framework == 'ace' then
        for c, d in pairs(Config.Framework_perms) do
            if IsPlayerAceAllowed(source, c) then
                return true
            end
        end
        return false
        
    elseif Config.Framework == 'custom' then
        --add your own permissions check here.
        return true
        
    end
end

RegisterServerEvent('cd_easytime:Callback')
AddEventHandler('cd_easytime:Callback', function(id)
    TriggerClientEvent('cd_easytime:Callback', source, id, json.encode({weather = Weather, hours = Hours, mins = Mins, dynamic = Dynamic, blackout = Blackout, freeze = FreezeTime, instanttime = InstantTimeChange, instantweather = InstantWeatherChange}))
end)

RegisterServerEvent('cd_easytime:ToggleInstantChange:Time')
AddEventHandler('cd_easytime:ToggleInstantChange:Time', function(boolean)
    InstantTimeChange = boolean
end)

RegisterServerEvent('cd_easytime:ToggleInstantChange:Weather')
AddEventHandler('cd_easytime:ToggleInstantChange:Weather', function(boolean)
    InstantWeatherChange = boolean
end)

RegisterServerEvent('cd_easytime:SaveSettings')
AddEventHandler('cd_easytime:SaveSettings', function()
    SaveSettngs()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SaveSettngs()
    end
end)

function SaveSettngs()
    SaveResourceFile(GetCurrentResourceName(),'settings.txt', json.encode({weather = Weather, hours = Hours, mins = Mins, dynamic = Dynamic, blackout = Blackout, freeze = FreezeTime, instanttime = InstantTimeChange, instantweather = InstantWeatherChange}), -1)
    print('^3['..GetCurrentResourceName()..'] - Settings Saved^0')
end

function LoadSettings()
    local settings = json.decode(LoadResourceFile(GetCurrentResourceName(),'./settings.txt'))
    Weather = settings.weather or Weather
    Hours = settings.hours or Hours
    Mins = settings.mins or Mins
    Dynamic = settings.dynamic or Dynamic
    Blackout = settings.blackout or Blackout
    FreezeTime = settings.freeze or FreezeTime
    InstantTimeChange = settings.instanttime or FreezeTime
    InstantWeatherChange = settings.instantweather or FreezeTime
    print('^3['..GetCurrentResourceName()..'] - Saved settings applied^0')
end
