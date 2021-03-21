Config = {}

Config.Framework = 'esx' --[ 'esx / 'vrp' / 'custom' ] Choose your framework so you can add resctict the command to be used by staff only.
Config.ESX_perms = { --If a permisison group is set to true, they will have access to use the command. (if the Config.Framework is set to 'esx').
  	['superadmin'] = true,
    ['admin'] = true,
    ['mod'] = true,
    ['helper'] = false,
}

Config.Command = 'easytime' --Customise the command name to open the UI.
Config.Notification_Type = 'chat' --[ 'chat' / 'mythic_old' / 'mythic_new' / 'esx' / 'custom' ] Choose your notification type.
Config.Language = 'EN' --[ 'EN' / 'FR' / 'ES' ] Choose your preferred language.

Config.InstantTimeChange = false --When you change the time via the UI, do you want it to be set instantly, instead of the time changing very smoothly and barely noticeable?
Config.InstantWeatherChange = false --When you change the weather via the UI, do you want it to be set instantly, instead of the weather changing very smoothly and barely noticeable?
Config.PersistentWeather = true --Do you want to allow the resource to set the saved weather and time settings automatically after a server restart?

Config.TimeCycleSpeed = 2 --(in seconds) Changing this value will effects the day/night time cycle, decreasing slows it down, incresing speeds it up. Right now its similar to the default gta5 time cycle.
Config.DynamicWeather = true --Do you want to allow dynamic weather?
Config.DynamicWeather_time = 10 --(in minutes) If dynamic weather is enabled, this value is how long until the weather changes.
Config.RainChance = 10 --The percent chance for it to rain out of 100.
Config.SnowChance = 1 --The percent chance for it to snow out of 100.
Config.ThunderChance = 20 --The percent chance for it to thunder when raining out of 100.

Config.WeatherGroups = { --These are the weather groups, it will cycle through each group from left to right making sure it cycles through low intensity rain to high intensity for example.
    [1] = {'CLEAR', 'OVERCAST','EXTRASUNNY', 'CLOUDS'},--clear
    [2] = {'CLEARING', 'RAIN', 'NEUTRAL', 'THUNDER'},--rain
    [3] = {'SMOG', 'FOGGY'},--foggy
    [4] = {'SNOWLIGHT', 'SNOW', 'BLIZZARD', 'XMAS'},--snow
}