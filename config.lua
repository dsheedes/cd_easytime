Config = {}

Config.Framework = 'esx' --[ 'esx / 'qbus' / 'vrp' / 'ace' / 'custom' ] Choose your framework so you can add resctict the command to be used by staff only.
Config.Framework_perms = { --You can choose multiple permission group to have access to use the UI. (This will be used by all framework versions by default except the "custom" option).
  	['superadmin'] = true,
    ['admin'] = true,
    ['mod'] = true,
    ['helper'] = false,
}

Config.Command = 'easytime' --Customise the command name to open the UI.
Config.Notification_Type = 'chat' --[ 'chat' / 'mythic_old' / 'mythic_new' / 'esx' / 'custom' ] Choose your notification type.
Config.Language = 'EN' --[ 'EN' / 'FR' / 'ES' ] Choose your preferred language.
Config.NUI_keepinput = false --Do you want to be able to walk around when the UI is open?

Config.TimeCycleSpeed = 2 --(in seconds) Changing this value will effects the day/night time cycle, decreasing slows it down, incresing speeds it up. Right now its similar to the default gta5 time cycle.
Config.DynamicWeather = true --Do you want to allow dynamic weather?
Config.DynamicWeather_time = 10 --(in minutes) If dynamic weather is enabled, this value is how long until the weather changes.
Config.RainChance = 10 --The percent chance for it to rain out of 100.
Config.SnowChance = 1 --The percent chance for it to snow out of 100.
Config.ThunderChance = 20 --The percent chance for it to thunder when raining out of 100.

Config.WeatherGroups = { --These are the weather groups, it will cycle through each group from left to right making sure it cycles through low intensity rain to high intensity for example (48 mins for 1 full day cycle).
    [1] = {'CLEAR', 'OVERCAST','EXTRASUNNY', 'CLOUDS'},--clear
    [2] = {'CLEARING', 'RAIN', 'NEUTRAL', 'THUNDER'},--rain
    [3] = {'SMOG', 'FOGGY'},--foggy
    [4] = {'SNOWLIGHT', 'SNOW', 'BLIZZARD', 'XMAS'},--snow
}