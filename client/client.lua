local Weather = 'CLEAR'
local Blackout = false
local Dynamic = false
local FreezeTime = false
local NUI_status = false
local PauseSync = false
local Hours = 8
local Mins = 0
local Seconds = 0
local InstantTimeChange = false
local InstantWeatherChange = false
local SyncHours = nil
local SyncMins = nil
local CB = {}
local CB_id = 0

Citizen.CreateThread(function()
    SetNuiFocus(false, false)
    while not NetworkIsSessionStarted() do Citizen.Wait(1000) end
    TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
end)

RegisterNetEvent('cd_easytime:PauseSync')
AddEventHandler('cd_easytime:PauseSync', function(boolean)
    if boolean then
        PauseSync = true
        ChangeWeather('EXTRASUNNY', Blackout, true)
    else
        PauseSync = false
        TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
    end
end)

RegisterNetEvent('cd_easytime:ForceUpdate')
AddEventHandler('cd_easytime:ForceUpdate', function(data, instant, first_sync)
    if not PauseSync then
        if data.weather ~= nil then
            CheckSnowSync(data.weather)
            Weather = data.weather
            Blackout = data.blackout
            FreezeTime = data.freeze
            ChangeWeather(Weather, Blackout, instant.weather)
        end
        if data.hours ~= nil then
            local newhours = GetClockHours()
            NetworkOverrideClockTime(newhours, data.mins, Seconds)
            if not instant.time and not FreezeTime then
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
            elseif instant.time or FreezeTime then
                Hours = data.hours
                Mins = data.mins
                NetworkOverrideClockTime(Hours, Mins, Seconds)
            end
        end
        if first_sync then
            CheckIfSynced(data)
        end
    end   
end)

RegisterNetEvent('cd_easytime:SyncWeather')
AddEventHandler('cd_easytime:SyncWeather', function(data, instant, sync_checking)
    if not PauseSync then
        CheckSnowSync(data.weather)
        Weather = data.weather
        Blackout = data.blackout
        ChangeWeather(Weather, Blackout, instant)
        if sync_checking then
            CheckIfSynced(data)
        end
    end
end)

RegisterNetEvent('cd_easytime:SyncTime')
AddEventHandler('cd_easytime:SyncTime', function(data, sync_checking)
    if not PauseSync then
        SyncHours = data.hours
        SyncMins = data.mins
        if sync_checking then
            CheckIfSynced(data)
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

RegisterNUICallback('instanttime', function(data)
    TriggerServerEvent('cd_easytime:ToggleInstantChange:Time', data.instanttime)
end)

RegisterNUICallback('instantweather', function(data)
    TriggerServerEvent('cd_easytime:ToggleInstantChange:Weather', data.instantweather)
end)

RegisterNUICallback('change', function(data)
    NUI_status = false
    local settings = data.values
    TriggerServerEvent('cd_easytime:ForceUpdate', {weather = settings.weather, hours = settings.time, dynamic = settings.dynamic, blackout = settings.blackout, freeze = settings.freeze, instanttime = settings.instanttime, instantweather = settings.instantweather}, nil)
    if data.savesettings then
        print('Saving Settings - please wait 3 seconds ...')
        Citizen.Wait(3000)
        TriggerServerEvent('cd_easytime:SaveSettings')
        print('Settings Saved.')
    end
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
    if instant then
        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weather)
        SetWeatherTypeNow(weather)
        SetWeatherTypeNowPersist(weather)
    else
        SetBlackout(blackout)
        ClearOverrideWeather()
        SetWeatherTypeOvertimePersist(weather, 180.0) --180.0 takes around 2-3 minutes to fully change the weather.
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
        if Config.NUI_keepinput then
            SetNuiFocus(NUI_status, NUI_status)
            SetNuiFocusKeepInput(NUI_status)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            SetPlayerCanDoDriveBy(PlayerId(), false)
        else
            SetNuiFocus(NUI_status, NUI_status)
        end
        Citizen.Wait(5)
    end
    SetNuiFocus(false, false)
end)

function CheckIfSynced(data)
    local result = true
    if Weather ~= data.weather or Blackout ~= data.blackout or FreezeTime ~= data.freeze then
        TriggerEvent('cd_easytime:SyncWeather', json.decode(Callback()), true, true)
        print('WEATHER SYNC CHECK FAILED - RESYNCING NOW')
        result = false
    end
    if Hours ~= data.hours then
        TriggerEvent('cd_easytime:SyncTime', json.decode(Callback()), true)
        print('TIME SYNC CHECK FAILED - RESYNCING NOW')
        result = false
    end
    if result then
        print('SYNC CHECK COMPLETE')
    end
end

function Callback(plate)
    CB_id = CB_id + 1
    TriggerServerEvent('cd_easytime:Callback', CB_id, plate)
    local timeout = 0 while CB[CB_id] == nil and timeout <= 50 do Citizen.Wait(0) timeout=timeout+1 end
    return CB[CB_id]
end

RegisterNetEvent('cd_easytime:Callback')
AddEventHandler('cd_easytime:Callback', function(id, result)
    CB[id] = result
    Wait(5000)
    CB[id] = nil
end)