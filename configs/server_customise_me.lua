--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


ESX, QBCore = nil, nil

if Config.Framework == 'esx' then
    pcall(function() ESX = exports[Config.FrameworkTriggers.resource_name]:getSharedObject() end)
    if ESX == nil then
        TriggerEvent(Config.FrameworkTriggers.main, function(obj) ESX = obj end)
    end

elseif Config.Framework == 'qbcore' then
    TriggerEvent(Config.FrameworkTriggers.main, function(obj) QBCore = obj end)
    if QBCore == nil then
        QBCore = exports[Config.FrameworkTriggers.resource_name]:GetCoreObject()
    end
end

function PermissionsCheck(source)
    if Config.Permissions.Framework.ENABLE then

        if Config.Framework == 'esx' then 
            local xPlayer = ESX.GetPlayerFromId(source)
            local perms = xPlayer.getGroup()
            for c, d in ipairs(Config.Permissions.Framework[Config.Framework]) do
                if perms == d then
                    return true
                end
            end
        
        elseif Config.Framework == 'qbcore' then
            local perms = QBCore.Functions.GetPermission(source)
            for c, d in ipairs(Config.Permissions.Framework[Config.Framework]) do
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
    
        elseif Config.Framework == 'qbox' then
            local perms = exports.qbx_core:GetPermission(source)
            for c, d in ipairs(Config.Permissions.Framework[Config.Framework]) do
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

        elseif Config.Framework == 'other' then
            --Add your own permissions check here (boolean).
            return true
        end
    end

    if Config.Permissions.Identifiers.ENABLE then
        local temp_table = {}
        for c, d in pairs(GetPlayerIdentifiers(source)) do
            temp_table[#temp_table+1] = {full = d, trimmed = d:sub(d:find(':')+1, #d)}
        end

        for c, d in pairs(Config.Permissions.Identifiers.identifier_list) do
            for cc, dd in pairs(temp_table) do
                if (dd.full == d:lower()) or (dd.trimmed == d:lower()) then
                    return true
                end
            end
        end
    end

    if Config.Permissions.AcePerms.ENABLE then        
        for c, d in pairs(Config.Permissions.AcePerms.aceperms_list) do
            if IsPlayerAceAllowed(source, d) then
                return true
            end
        end

    end

    if Config.Permissions.Discord.ENABLE then
        local discord_roles = exports.Badger_Discord_API:GetDiscordRoles(source)
        for c, d in pairs(Config.Permissions.Discord.discord_list) do
            for cc, dd in pairs(discord_roles) do
                if d == dd then
                    return true
                end
            end
        end
    end
    return false
end


-- ██████╗██╗  ██╗ █████╗ ████████╗     ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗
--██╔════╝██║  ██║██╔══██╗╚══██╔══╝    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝
--██║     ███████║███████║   ██║       ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██╔██╗ ██║██║  ██║███████╗
--██║     ██╔══██║██╔══██║   ██║       ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║╚════██║
--╚██████╗██║  ██║██║  ██║   ██║       ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████║
-- ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝


RegisterCommand(Config.Command, function(source)
    local source = source
    if PermissionsCheck(source) then
        TriggerClientEvent('cd_easytime:OpenUI', source, self)
    else
        Notification(source, 3, L('invalid_permissions'))
    end
end)

RegisterServerEvent('cd_easytime:OpenUI', function(_source)
    local source = source
    if _source then source = _source end
    if PermissionsCheck(source) then
        TriggerClientEvent('cd_easytime:OpenUI', source, self)
    else
        Notification(source, 3, L('invalid_permissions'))
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

function GetRealData()
    local data

    if Config.Weather.METHOD == 'real' then
        data = GetRealWorldData(Config.Weather.RealWeather.city)
    elseif Config.Time.METHOD == 'real' then
        data = GetRealWorldData(Config.Time.RealTime.city)
    else
        return nil
    end

    return {
        hours = data.hours,
        mins = data.mins,
        gta_weather = data.weather,
        real_weather = data.info.weather,
        real_weather_description = data.info.weather_description,
        country = data.info.country,
        city = data.info.city
    }
end


--███╗   ██╗ ██████╗ ████████╗██╗███████╗██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--████╗  ██║██╔═══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--██╔██╗ ██║██║   ██║   ██║   ██║█████╗  ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--██║╚██╗██║██║   ██║   ██║   ██║██╔══╝  ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--██║ ╚████║╚██████╔╝   ██║   ██║██║     ██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝


function Notification(source, notif_type, message)
    if source and notif_type and message then
        if Config.Notification == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        
        elseif Config.Notification == 'qbcore' then
            if notif_type == 1 then
                TriggerClientEvent('QBCore:Notify', source, message, 'success')
            elseif notif_type == 2 then
                TriggerClientEvent('QBCore:Notify', source, message, 'primary')
            elseif notif_type == 3 then
                TriggerClientEvent('QBCore:Notify', source, message, 'error')
            end

        elseif Config.Notification == 'qbox' then
            if notif_type == 1 then
                exports.qbx_core:Notify(source, message, 'success')
            elseif notif_type == 2 then
                exports.qbx_core:Notify(source, message, 'inform')
            elseif notif_type == 3 then
                exports.qbx_core:Notify(source, message, 'error')
            end
        
        elseif Config.Notification == 'cd_notifications' then
            if notif_type == 1 then
                TriggerClientEvent('cd_notifications:Add', source, {title =  L('easytime'), message = message, type = 'success', options = {duration = 5}})
            elseif notif_type == 2 then
                TriggerClientEvent('cd_notifications:Add', source, {title =  L('easytime'), message = message, type = 'inform', options = {duration = 5}})
            elseif notif_type == 3 then
                TriggerClientEvent('cd_notifications:Add', source, {title =  L('easytime'), message = message, type = 'error', options = {duration = 5}})
            end

        elseif Config.Notification == 'okokNotify' then
            if notif_type == 1 then
                TriggerClientEvent('okokNotify:Alert', source, L('easytime'), message, 5000, 'success')
            elseif notif_type == 2 then
                TriggerClientEvent('okokNotify:Alert', source, L('easytime'), message, 5000, 'info')
            elseif notif_type == 3 then
                TriggerClientEvent('okokNotify:Alert', source, L('easytime'), message, 5000, 'error')
            end

        elseif Config.Notification == 'ps-ui' then
            if notif_type == 1 then
                TriggerClientEvent('ps-ui:Notify', source, message, 'success')
            elseif notif_type == 2 then
                TriggerClientEvent('ps-ui:Notify', source, message, 'primary')
            elseif notif_type == 3 then
                TriggerClientEvent('ps-ui:Notify', source, message, 'error')
            end

        elseif Config.Notification == 'ox_lib' then
            if notif_type == 1 then
                lib.notify({title = L('easytime'), description = message, type = 'success'})
            elseif notif_type == 2 then
                lib.notify({title = L('easytime'), description = message, type = 'inform'})
            elseif notif_type == 3 then
                lib.notify({title = L('easytime'), description = message, type = 'error'})
            end

        elseif Config.Notification == 'chat' then
            TriggerClientEvent('chatMessage', source, message)

        elseif Config.Notification == 'other' then
            --add your own notification.

        end
    end
end


--██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


if Config.Debug then
    RegisterServerEvent('cd_easytime:Debug')
    AddEventHandler('cd_easytime:Debug', function()
        local source = source
        print('^6-----------------------^0')
        print('^1CODESIGN DEBUG^0')
        print(string.format('^6Source:^0 %s', source))
        print(string.format('^6Resource Name:^0 %s', GetCurrentResourceName()))
        print(string.format('^6Version:^0 %s', GetResourceMetadata(GetCurrentResourceName(), 'version', 0)))
        print(string.format('^6Framework:^0 %s', Config.Framework))
        print(string.format('^6Notification:^0 %s', Config.Notification))
        print(string.format('^6Language:^0 %s', Config.Language))
        print(string.format('^6Config.Weather.METHOD:^0 %s', Config.Weather.METHOD))
        print(string.format('^6Config.Time.METHOD:^0 %s', Config.Time.METHOD))
        print(string.format('^6API Key:^0 %s', Config.APIKey))
        print(string.format('^6Config.Permissions: [Framework: ^0%s^6] [Identifiers: ^0%s^6] [AcePerms: ^0%s^6] [Discord: ^0%s^6]', Config.Permissions.Framework.ENABLE, Config.Permissions.Identifiers.ENABLE, Config.Permissions.AcePerms.ENABLE, Config.Permissions.Discord.ENABLE))
        print(string.format('^6Has Permission:^0 %s', PermissionsCheck(source)))
        print('^6-----------------------^0')
    end)

    RegisterCommand('debug_easytime_table', function(source)
        if GetResourceState('cd_devtools') == 'started' then
            TriggerClientEvent('table', source, self)
        else
            print('^1Error: cd_devtools_not_started.^0')
        end
    end)

end