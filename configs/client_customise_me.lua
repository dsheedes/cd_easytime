--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


ESX, QBCore, Qbox = nil, nil, nil

CreateThread(function()
    if Config.Framework == 'esx' then
        while ESX == nil do
            pcall(function() ESX = exports[Config.FrameworkTriggers.resource_name]:getSharedObject() end)
            if ESX == nil then
                TriggerEvent(Config.FrameworkTriggers.main, function(obj) ESX = obj end)
            end
            Wait(100)
        end

        RegisterNetEvent(Config.FrameworkTriggers.load)
        AddEventHandler(Config.FrameworkTriggers.load, function()
            TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
            Wait(5000)
            TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
        end)

        RegisterNetEvent('vSync:toggle')
        AddEventHandler('vSync:toggle', function(boolean)
            TriggerEvent('cd_easytime:PauseSync', boolean)
        end)
    
    elseif Config.Framework == 'qbcore' then
        while QBCore == nil do
            TriggerEvent(Config.FrameworkTriggers.main, function(obj) QBCore = obj end)
            if QBCore == nil then
                QBCore = exports[Config.FrameworkTriggers.resource_name]:GetCoreObject()
            end
            Wait(100)
        end

        RegisterNetEvent(Config.FrameworkTriggers.load)
        AddEventHandler(Config.FrameworkTriggers.load, function()
            TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
            Wait(5000)
            TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
        end)

        RegisterNetEvent('qb-weathersync:client:EnableSync')
        AddEventHandler('qb-weathersync:client:EnableSync', function()
            TriggerEvent('cd_easytime:PauseSync', true)
        end)

        RegisterNetEvent('qb-weathersync:client:DisableSync')
        AddEventHandler('qb-weathersync:client:DisableSync', function()
            TriggerEvent('cd_easytime:PauseSync', false)
        end)

    elseif Config.Framework == 'qbox' then

        RegisterNetEvent('qb-weathersync:client:EnableSync')
        AddEventHandler('qb-weathersync:client:EnableSync', function()
            TriggerEvent('cd_easytime:PauseSync', true)
        end)

        RegisterNetEvent('qb-weathersync:client:DisableSync')
        AddEventHandler('qb-weathersync:client:DisableSync', function()
            TriggerEvent('cd_easytime:PauseSync', false)
        end)

    elseif Config.Framework == 'aceperms' or Config.Framework == 'identifiers' then
        CreateThread(function()
            Wait(5000)
            while true do
                Wait(1000)
                if NetworkIsSessionStarted() then
                    TriggerServerEvent('cd_easytime:SyncMe', {time = true, weather = true})
                    break
                end
            end
        end)

    elseif Config.Framework == 'other' then
        --Add your framework code here.

    end
end)


-- ██████╗ ████████╗██╗  ██╗███████╗██████╗ 
--██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
--██║   ██║   ██║   ███████║█████╗  ██████╔╝
--██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
--╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
-- ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


function GetWeather()
    return self
end

function GetAllData()
    return self
end

function GetPauseSyncState()
    return PauseSync.state
end

TriggerEvent('chat:addSuggestion', '/'..Config.Command, L('chat_suggestion'))


--██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


if Config.Debug then
    local function Debug()
        print('^6-----------------------^0')
        print('^1CODESIGN DEBUG^0')
        print(string.format('^6Resource Name:^0 %s', GetCurrentResourceName()))
        print(string.format('^6Framework:^0 %s', Config.Framework))
        print(string.format('^6Notification:^0 %s', Config.Notification))
        print(string.format('^6Language:^0 %s', Config.Language))
        print(string.format('^6Config.Weather.METHOD:^0 %s', Config.Weather.METHOD))
        print(string.format('^6Config.Time.METHOD:^0 %s', Config.Time.METHOD))
        print(string.format('^6Config.Permissions: [Framework: ^0%s^6] [Identifiers: ^0%s^6] [AcePerms: ^0%s^6] [Discord: ^0%s^6]', Config.Permissions.Framework.ENABLE, Config.Permissions.Identifiers.ENABLE, Config.Permissions.AcePerms.ENABLE, Config.Permissions.Discord.ENABLE))
        print('^6-----------------------^0')
        TriggerServerEvent('cd_easytime:Debug')
    end

    CreateThread(function()
        Wait(3000)
        Debug()
    end)

    RegisterCommand('debug_easytime', function()
        Debug()
    end)
end