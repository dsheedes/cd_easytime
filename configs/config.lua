Config = {}
function L(cd) if Locales[Config.Language][cd] then return Locales[Config.Language][cd] else print('Locale is nil ('..cd..')') end end


--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


--WHAT DOES 'auto_detect' DO?
--The 'auto_detect' feature automatically identifies the resources you have and applies the appropriate default settings accordingly.

Config.Framework = 'auto_detect' --[ 'auto_detect' / 'other' ]
--If you select 'auto_detect', only ESX, QBCore and Qbox frameworks will be detected. Use 'other' for custom frameworks.

Config.Notification = 'auto_detect' --[ 'auto_detect' / 'other' ]
--If you select 'auto_detect', only ESX, QBCore, Qbox, cd_notifications, okokNotify, ps-ui and ox_lib notifications will be detected. Use 'other' for custom notification resources.

Config.Language = 'EN' --[ 'EN' / 'FR' / 'ES' ]
--You can add your own locales to Locales.lua, but be sure to update the Config.Language to match it.

Config.FrameworkTriggers = {
    esx = { --If you have modified the default event names in the es_extended resource, change them here.
        resource_name = 'es_extended',
        main = 'esx:getSharedObject',
        load = 'esx:playerLoaded'
    },
    qbcore = { --If you have modified the default event names in the qb-core resource, change them here.
        resource_name = 'qb-core',
        main = 'QBCore:GetObject',
        load = 'QBCore:Client:OnPlayerLoaded'
    },
    qbox = { --If you have modified the default event names in the qbx-core resource, change them here.
        resource_name = 'qbx_core'
    }
}

Config.Permissions = { --Define which players can access the cd_easytime features.
    Framework = { --Ignore this section if you're not using a framework.
        ['esx'] = {'superadmin', 'admin', 'mod', },
        ['qbcore'] = {'god', 'admin', },
        ['qbox'] = {'god', 'admin', },
    },

    Identifiers = {
        ENABLE = false, --Allow players with specific identifiers to access cd_easytime?
        identifier_list = {'steam:xxxxx', 'license:xxxxx', 'fivem:xxxxx', } --List player identifiers (Steam, license, or FiveM ID).
    },

    AcePerms = { 
        ENABLE = false, --Allow players with specific ACE permissions to access cd_easytime?
        aceperms_list = {'command', 'easytime.staff', } --Ensure your ACE permissions are set up in server.cfg.
    },

    Discord = { --This feature requires the Badger Discord API resource.
        ENABLE = false, --Allow players with specific Discord roles to access cd_easytime?
        discord_list = {'xxxxx', 'xxxxx', } --Enter the role IDs from your Discord (see https://www.itgeared.com/how-to-get-role-id-on-discord).
    }
}


--██╗███╗   ███╗██████╗  ██████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗████████╗
--██║████╗ ████║██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║╚══██╔══╝
--██║██╔████╔██║██████╔╝██║   ██║██████╔╝   ██║   ███████║██╔██╗ ██║   ██║   
--██║██║╚██╔╝██║██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║   ██║   
--██║██║ ╚═╝ ██║██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║ ╚████║   ██║   
--╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝


Config.Debug = false -- Set to true to enable debug prints for troubleshooting.
Config.APIKey = 'CHANGE_ME' --You need this when using real time or weather. Get your free API key from https://openweathermap.org/api.


--███╗   ███╗ █████╗ ██╗███╗   ██╗
--████╗ ████║██╔══██╗██║████╗  ██║
--██╔████╔██║███████║██║██╔██╗ ██║
--██║╚██╔╝██║██╔══██║██║██║╚██╗██║
--██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
--╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝


Config.Command = 'easytime' --The command for staff to open the UI.
Config.ConsolePrints = true --Do you want the console to print the weather changes?
Config.VehicleBlackoutEffect = false --Do you want the lights on vehicles to be turned off during blackouts?

Config.TsunamiWarning = {
    ENABLE = true, --Do you want to enable the tsunami warning countdown just before a server restart?
    time = 2 --(in minutes) How long the tsunami warning should last. Read the docs for more info.
}

Config.Weather = {
    METHOD = 'game', --Choose between 'game' (GTA weather) or 'real' (real-world weather).

    GameWeather = { --If you chose 'game', you have the following configurable options:
        dynamic_weather_time = 10, --How often (in minutes) should the weather change?
        rain_chance = 20, --Chance of rain (0-100%) if the rain WeatherGroup is randomly selected.
        thunder_chance = 20, --Chance of thunder during rain (0-100%).
        fog_chance = 20, --Chance of fog (0-100%) if the fog WeatherGroup is randomly selected.
        snow_chance = 5, --Chance of snow (0-100%) if the rain WeatherGroup is randomly selected.
        WeatherGroups = { --Different weather groups to cycle through.
            [1] = {'CLEAR', 'CLOUDS','EXTRASUNNY', 'OVERCAST'},--Clear weather
            [2] = {'CLEARING', 'RAIN', 'NEUTRAL', 'THUNDER'},--Rainy weather
            [3] = {'SMOG', 'FOGGY'},--Foggy weather
            [4] = {'SNOWLIGHT', 'SNOW', 'BLIZZARD', 'XMAS'}--Snowy weather
        }
    },

    RealWeather = { --If you chose 'real', you have the following configurable options:
        city = 'London', --The city from which you want to fetch the weather, e.g., London, Miami, Dubai, or Paris.
        weather_check = 30, --How often (in minutes) to check for weather changes.
        weather_types = { ['CLEAR'] = {802}, ['CLOUDS'] = {803}, ['EXTRASUNNY'] = {800,801}, ['OVERCAST'] = {804}, ['CLEARING'] = {300,301,310,311,313,321}, ['RAIN'] = {501,502,503,504,511,522,531}, ['NEUTRAL'] = {302,312,314,500,520,521}, ['THUNDER'] = {200,201,202,210,211,212,221,230,231,232}, ['SMOG'] = {701,711,721,731,771}, ['FOGGY'] = {741,751,761,762,781}, ['SNOWLIGHT'] = {611,615,616}, ['SNOW'] = {600,620}, ['BLIZZARD'] = {612,613,620,621,622}, ['XMAS'] = {601,602} } --Weather types and their codes (do not change this).
    }
}

Config.Time = {
    METHOD = 'game', --Choose between 'game' (GTA time) or 'real' (real-world time).

    GameTime = { --If you chose 'game', you have the following configurable options:
        time_cycle_speed = 2 --How long a full day/night cycle lasts. 1 = 24 mins, 2 = 48 mins, 3 = 72 mins, etc. Must be between 1 and 10. Must be an integer not a float. 2 is the default same as GTA.
    },

    RealTime = { --If you chose 'real', you have the following configurable options:
        city = 'London', --The city from which you want to fetch the time, e.g., London, Miami, Dubai, or Paris.
        manual_UTC_offset = 0, --Manually set the time zone offset (in hours) if automatic detection is inaccurate. For example, use 3 for UTC+3 or -2 for UTC-2. Set to nil to disable this feature.
        transition_speed = 10 --The speed at which time transitions occur to ensure smooth minute-to-minute changes (in seconds).
    }
}


-- █████╗ ██╗   ██╗████████╗ ██████╗     ██████╗ ███████╗████████╗███████╗ ██████╗████████╗
--██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
--███████║██║   ██║   ██║   ██║   ██║    ██║  ██║█████╗     ██║   █████╗  ██║        ██║   
--██╔══██║██║   ██║   ██║   ██║   ██║    ██║  ██║██╔══╝     ██║   ██╔══╝  ██║        ██║   
--██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██████╔╝███████╗   ██║   ███████╗╚██████╗   ██║   
--╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝   ╚═╝   
        

-----DO NOT TOUCH ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.-----
if Config.Framework == 'auto_detect' then
    if GetResourceState(Config.FrameworkTriggers.esx.resource_name) == 'started' then
        Config.Framework = 'esx'
    elseif GetResourceState(Config.FrameworkTriggers.qbcore.resource_name) == 'started' then
        Config.Framework = 'qbcore'
    elseif GetResourceState(Config.FrameworkTriggers.qbox.resource_name) == 'started' then
        Config.Framework = 'qbox'
    end
    if Config.Framework == 'esx' or Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        for c, d in pairs(Config.FrameworkTriggers[Config.Framework]) do
            Config.FrameworkTriggers[c] = d
        end
        Config.FrameworkTriggers.esx, Config.FrameworkTriggers.qbcore, Config.FrameworkTriggers.qbox = nil, nil, nil
        Config.Permissions.Framework.ENABLE = true
    else
        Config.Permissions.Framework.ENABLE = false
    end
end

if GetResourceState('Badger_Discord_API') ~= 'started' then
    if Config.Permissions.Discord.ENABLE and Config.Debug then
        print('^1Error: Badger_Discord_API_not_started.^0')
    end
    Config.Permissions.Discord.ENABLE = false
end

if Config.Notification == 'auto_detect' then
    if GetResourceState('cd_notifications') == 'started' then
        Config.Notification = 'cd_notifications'
    elseif GetResourceState('okokNotify') == 'started' then
        Config.Notification = 'okokNotify'
    elseif GetResourceState('ps-ui') == 'started' then
        Config.Notification = 'ps-ui'
    elseif GetResourceState('ox_lib') == 'started' then
        Config.Notification = 'ox_lib'
    else
        if Config.Framework == 'esx' or Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            Config.Notification = Config.Framework
        else
            Config.Notification = 'chat'
        end
    end
end

Config.Time.GameTime.time_cycle_speed = math.ceil(Config.Time.GameTime.time_cycle_speed) --this value can not be a float.
-----DO NOT TOUCH ANYTHING ABOVE THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.-----