local Weather = 'CLEAR'
local Blackout = false
local Dynamic = false
local FreezeTime = false
local NUI_status = false
local PauseSync = false
local Hours = 8
local Mins = 0
local Seconds = 0
local SyncHours = nil
local SyncMins = nil

Citizen.CreateThread(function()
    SetNuiFocus(false, false)
    while true do
        Citizen.Wait(1000)
        if NetworkIsSessionStarted() then
            Wait(10000)
            TriggerServerEvent('cd_easytime:SyncMe', false)
            break
        end
    end
end)

RegisterNetEvent('cd_easytime:PauseSync')
AddEventHandler('cd_easytime:PauseSync', function(boolean)
    if boolean then
        PauseSync = true
        ChangeWeather('EXTRASUNNY', Blackout, true)
    else
        PauseSync = false
        TriggerServerEvent('cd_easytime:SyncMe', true)
    end
end)

RegisterNetEvent('cd_easytime:ForceUpdate')
AddEventHandler('cd_easytime:ForceUpdate', function(data, instant)
    if not PauseSync then
        if data.weather ~= nil then
            CheckSnowSync(data.weather)
            Weather = data.weather
            Blackout = data.blackout
            FreezeTime = data.freeze
            ChangeWeather(Weather, Blackout, instant)
        end
        
        if data.hours ~= nil and not FreezeTime then
            local newhours = GetClockHours()
            NetworkOverrideClockTime(newhours, data.mins, Seconds)
            if not Config.InstantTimeChange then
                for i=1, 24 do
                    newhours = newhours+1
                    if newhours == 24 then newhours = 0 end
                    if newhours < 24 then
                        Hours = newhours
                        Mins = data.mins
                        for i=1, 60 do
                            Wait(10)
                            NetworkOverrideClockTime(newhours, i, Seconds)
                        end
                    end
                    if newhours == data.hours then break end
                end
            else
                Hours = data.hours
                Mins = data.mins
                NetworkOverrideClockTime(Hours, Mins, Seconds)
            end
        end
    end   
end)

RegisterNetEvent('cd_easytime:SyncAll')
AddEventHandler('cd_easytime:SyncAll', function(data, instant)
    if not PauseSync then
        CheckSnowSync(data.weather)
        Weather = data.weather
        Blackout = data.blackout
        FreezeTime = data.freeze
        ChangeWeather(Weather, Blackout, instant)
        SyncHours = data.hours
        SyncMins = data.mins
    end
end)

RegisterNetEvent('cd_easytime:SyncWeather')
AddEventHandler('cd_easytime:SyncWeather', function(data, instant)
    if not PauseSync then
        CheckSnowSync(data.weather)
        Weather = data.weather
        Blackout = data.blackout
        ChangeWeather(Weather, Blackout, instant)
    end
end)

RegisterNetEvent('cd_easytime:SyncTime')
AddEventHandler('cd_easytime:SyncTime', function(data)
    if not PauseSync then
        if data.hours == Hours then
            SyncHours = data.hours
            SyncMins = data.mins
        else
            Wait(2000)
            TriggerServerEvent('cd_easytime:SyncMe', false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if not FreezeTime then
            if not PauseSync then
                NetworkOverrideClockTime(Hours, Mins, Seconds)
                Seconds = Seconds+30
                if SyncHours ~= nil and SyncMins ~= nil then
                    Hours = SyncHours
                    Mins = SyncMins
                    SyncHours = nil
                    SyncMins = nil
                end
                if Seconds >= 60 then Seconds = 0 Mins = Mins+1 end
                if Mins >= 60 then Mins = 0 Hours = Hours+1 end
                if Hours >= 24 then Hours = 0 end
            else
                NetworkOverrideClockTime(23, 00, 00)
            end
        else
            NetworkOverrideClockTime(Hours, Mins, Seconds)
        end
        Citizen.Wait(Config.TimeCycleSpeed*1000/2)
    end
end)

RegisterNUICallback('close', function()
    NUI_status = false
end)

RegisterNUICallback('change', function(data)
    NUI_status = false
    TriggerServerEvent('cd_easytime:ForceUpdate', {weather = data.weather, hours = data.time, dynamic = data.dynamic, blackout = data.blackout, freeze = data.freeze}, false)
end)

RegisterNUICallback('savesettings', function()
    TriggerServerEvent('cd_easytime:SaveSettings')
end)

function CheckSnowSync(NewWeather)
    if Weather == 'XMAS' then
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
    elseif NewWeather == 'XMAS' then
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
    end
end

function ChangeWeather(weather, blackout, instant)
    if Config.InstantWeatherChange or instant then
        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weather)
        SetWeatherTypeNow(weather)
        SetWeatherTypeNowPersist(weather)
    else
        SetBlackout(blackout)
        ClearOverrideWeather()
        SetWeatherTypeOvertimePersist(weather, 180.0)
    end
end

RegisterNetEvent('cd_easytime:OpenUI')
AddEventHandler('cd_easytime:OpenUI', function(values)
    Open_UI(values)
end)

function Open_UI(values)
    TriggerEvent('cd_easytime:ToggleNUIFocus')
    SendNUIMessage({action = 'open', values = values})
end

function Close_UI()
    NUI_status = false
    SendNUIMessage({action = 'close'})
end

RegisterNetEvent('cd_easytime:ToggleNUIFocus')
AddEventHandler('cd_easytime:ToggleNUIFocus', function()
    NUI_status = true
    while NUI_status do
        Citizen.Wait(5)
        SetNuiFocus(NUI_status, NUI_status)
    end
    SetNuiFocus(false, false)
end)
