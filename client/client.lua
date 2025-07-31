self = {}
local NUI_status = false
local original_time = {}
local pause_realtime = false
local my_source = GetPlayerServerId(PlayerId())
PauseSync = {}
PauseSync.state = false


RegisterNetEvent('cd_easytime:OpenUI', function(values)
    TriggerEvent('cd_easytime:ToggleNUIFocus')
    values.game_build = GetGameBuildNumber()
    values.original_timemethod = Config.Time.METHOD
    values.original_weathermethod = Config.Weather.METHOD
    original_time = {hours = values.hours, mins = values.mins}
    SendNUIMessage({action = 'open', values = values})
end)

RegisterNetEvent('cd_easytime:PauseSync', function(boolean, hours)
    if boolean == PauseSync.state then return end
    if boolean then
        PauseSync.state = true
        ChangeWeather('EXTRASUNNY', true)
        while PauseSync.state do
            Wait(0)
            NetworkOverrideClockTime(hours or 20, 00, 00)
        end
    else
        PauseSync.state = false
        Wait(300)
        TriggerServerEvent('cd_easytime:SyncMe_basics', {weather = true, time = true})
    end
end)

RegisterNetEvent('cd_easytime:ForceUpdate', function(data, source)
    if not PauseSync.state then
        if data.weather ~= nil and data.weather ~= self.weather then
            CheckSnowSync(data.weather)
            ChangeWeather(data.weather, data.instantweather)
            self.weather = data.weather
        end
        
        if (data.hours ~= nil and data.hours ~= self.hours) or (data.mins ~= nil and data.mins ~= self.mins) then
            if not data.instanttime then
                SmoothChangeTime(data, CalculateTransitionSpeed(data.hours, data.mins))
                self.hours = data.hours
                self.mins = data.mins
                if source == my_source then
                    TriggerServerEvent('cd_easytime:SetNewGameTime', {hours = data.hours, mins = data.mins})
                end
            else
                self.hours = data.hours
                self.mins = data.mins
                NetworkOverrideClockTime(self.hours, self.mins, 0)
            end
        end
        
    end

    self.freeze = data.freeze
    CreateThread(function()
        while self.freeze and not PauseSync.state do
            Wait(0)
            NetworkOverrideClockTime(data.hours, data.mins, 0)
        end
    end)

    if data.blackout ~= nil and data.blackout ~= self.blackout then
        self.blackout = data.blackout
        ChangeBlackout(self.blackout)
    end

    if data.tsunami ~= nil and Config.TsunamiWarning.ENABLE and data.tsunami ~= self.tsunami then
        self.tsunami = data.tsunami
        TriggerEvent('cd_easytime:StartTsunamiCountdown', data.tsunami)
    end

    if data.timemethod ~= nil and data.timemethod ~= self.timemethod then
        self.timemethod = data.timemethod
    end

    if data.weathermethod ~= nil and data.weathermethod ~= self.weathermethod then
        self.weathermethod = data.weathermethod
    end
end)


RegisterNetEvent('cd_easytime:SyncWeather', function(data)
    if not PauseSync.state then
        CheckSnowSync(data.weather)
        self.weather = data.weather
        ChangeWeather(self.weather, data.instantweather)
    end
end)

RegisterNetEvent('cd_easytime:SyncTime')
AddEventHandler('cd_easytime:SyncTime', function(data)
    if not PauseSync.state and not self.freeze then
        if self.timemethod == 'game' then
            NetworkOverrideClockTime(data.hours, data.mins, data.seconds or 0)

        elseif self.timemethod == 'real' then
            pause_realtime = true
            SmoothChangeTime(data, Config.Time.RealTime.transition_speed)
            pause_realtime = false
            self.hours = data.hours
            self.mins = data.mins
        end
    end
end)

if Config.Time.METHOD == 'real' then
    CreateThread(function()
        while true do
            Wait(5) --increase this timer to reduce resource usage. but this may cause jumping clouds.
            if self.timemethod == 'real' and not pause_realtime and not self.freeze then
                NetworkOverrideClockTime(self.hours, self.mins, 0)
            end
        end
    end)
end

function CalculateTransitionSpeed(hours, mins)
    local current_total_seconds = (GetClockHours() * 3600) + (GetClockMinutes() * 60) + GetClockSeconds()
    local target_total_seconds = (hours * 3600) + (mins * 60) + (0)
    local time_difference = math.abs(target_total_seconds - current_total_seconds)

    if time_difference <= 3600 then --1 hour.
        return 5
    elseif time_difference <= 21600 then --6 hours.
        return 10
    elseif time_difference <= 43200 then --12 hours.
        return 15
    else --12+ hours.
        return 20
    end
end

function SmoothChangeTime(data, transition_speed)
    local current_total_seconds = (GetClockHours() * 3600) + (GetClockMinutes() * 60) + GetClockSeconds()
    local target_total_seconds = (data.hours * 3600) + (data.mins * 60) + (data.seconds or 0)

    if target_total_seconds < current_total_seconds then
        target_total_seconds = target_total_seconds + 86400
    end

    local start_time = GetGameTimer()
    while GetGameTimer() - start_time < (transition_speed*1000) do
        local progress = (GetGameTimer() - start_time) / (transition_speed*1000)
        local total_seconds = (current_total_seconds + ((target_total_seconds - current_total_seconds) * progress)) % 86400

        local hours = math.floor(total_seconds / 3600) % 24
        local mins = math.floor((total_seconds % 3600) / 60) % 60
        local seconds = math.floor(total_seconds % 60)

        NetworkOverrideClockTime(hours, mins, seconds)
        Wait(0)
    end
    NetworkOverrideClockTime(data.hours, data.mins, data.seconds or 0)
end

local TsunamiCanceled = false
RegisterNetEvent('cd_easytime:StartTsunamiCountdown', function(boolean)
    if not Config.TsunamiWarning.ENABLE then return end
    if boolean then
        PauseSync.state = true
        PauseSync.hours = self.hours
        TsunamiCanceled = false
        ChangeWeather((GetGameBuildNumber() >= 3258) and 'RAIN_HALLOWEEN' or 'HALLOWEEN', false, Config.TsunamiWarning.time*60*1000/4/1000+0.0)
        Wait(Config.TsunamiWarning.time*60*1000/4*2)
        if TsunamiCanceled then return end
        ChangeBlackout(true)
        SendNUIMessage({action = 'playsound'})
    else
        PauseSync.state = false
        TsunamiCanceled = true
        TriggerServerEvent('cd_easytime:SyncMe')
    end
end)

RegisterNUICallback('close', function()
    NUI_status = false
end)

RegisterNUICallback('instanttime', function(data)
    TriggerServerEvent('cd_easytime:ToggleInstantChange', 'time', data.instanttime)
end)

RegisterNUICallback('instantweather', function(data)
    TriggerServerEvent('cd_easytime:ToggleInstantChange', 'weather', data.instantweather)
end)

RegisterNUICallback('change', function(data)
    if data.values.hours ~= nil and data.values.hours == original_time.hours and data.values.mins ~= nil and data.values.mins == original_time.mins then
        data.values.hours = nil
        data.values.mins = nil
    end
    original_time = {}

    TriggerServerEvent('cd_easytime:ForceUpdate', data.values)
    if data.savesettings then
        NUI_status = false
        print('Saving Settings - please wait 2 seconds ...')
        Wait(2000)
        TriggerServerEvent('cd_easytime:SaveSettings')
        print('Settings Saved.')
    end
end)

RegisterNetEvent('cd_easytime:WeatherMethodChange', function(new_weather_method)
    self.weathermethod = new_weather_method
    if new_weather_method == 'real' then
        self.dynamic = false
        self.instantweather = false
    end
end)

RegisterNetEvent('cd_easytime:TimeMethodChange', function(new_time_method)
    self.timemethod = new_time_method
    if new_time_method == 'real' then
        self.freeze = false
        self.instanttime = false
    end
end)

function CheckSnowSync(NewWeather)
    if self.weather == 'XMAS' or self.weather == 'SNOW_HALLOWEEN' then
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
    elseif NewWeather == 'XMAS' or NewWeather == 'SNOW_HALLOWEEN' then
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
    end
end

function ChangeWeather(weather, instant, change_speed)
    if change_speed == nil then
        change_speed = (Config.Weather.GameWeather.dynamic_weather_time / 10) * 180
    end
    
    if instant then
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weather)
        SetWeatherTypeNow(weather)
        SetWeatherTypeNowPersist(weather)
    else
        ClearOverrideWeather()
        SetWeatherTypeOvertimePersist(weather, change_speed)
    end
end


function ChangeBlackout(blackout)
    if GetGameBuildNumber() >= 2372 then
        SetArtificialLightsState(blackout)
        SetArtificialLightsStateAffectsVehicles(Config.VehicleBlackoutEffect)
    else
        SetBlackout(blackout)
    end
end

RegisterNetEvent('cd_easytime:ToggleNUIFocus')
AddEventHandler('cd_easytime:ToggleNUIFocus', function()
    NUI_status = true
    while NUI_status do
        Wait(0)
        SetNuiFocus(NUI_status, NUI_status)
        SetNuiFocusKeepInput(NUI_status)
        DisableControlAction(0, 1,   true)
        DisableControlAction(0, 2,   true)
        DisableControlAction(0, 106, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 21,  true)
        DisableControlAction(0, 24,  true)
        DisableControlAction(0, 25,  true)
        DisableControlAction(0, 47,  true)
        DisableControlAction(0, 58,  true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 143, true)
        DisableControlAction(0, 75,  true)
        DisableControlAction(27, 75, true)
        SetPlayerCanDoDriveBy(PlayerId(), false)
    end
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SetPlayerCanDoDriveBy(PlayerId(), true)
    local count, keys = 0, {177, 200, 202, 322}
    while count < 100 do 
        Wait(0)
        count=count+1
        for c, d in pairs(keys) do
            DisableControlAction(0, d, true)
        end
    end
end)

NetworkOverrideClockMillisecondsPerGameMinute(Config.Time.GameTime.time_cycle_speed*1000)