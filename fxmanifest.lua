fx_version 'cerulean'
game 'gta5'
author 'discord.gg/codesign'
description 'Codesign Weather & Time Managment'
version '2.0.1'
lua54 'yes'

shared_scripts {
    'configs/locales.lua',
    'configs/config.lua',
    --'@ox_lib/init.lua', --⚠️PLEASE READ⚠️; Uncomment this line if you use 'ox_lib'.⚠️
    --'@qbx_core/modules/lib.lua', --⚠️PLEASE READ⚠️; Uncomment this line if you use 'qbx_core'.⚠️
}

client_scripts {
    'configs/client_customise_me.lua',
    'client/*.lua',
    --'@qbx_core/modules/playerdata.lua', --⚠️PLEASE READ⚠️; Uncomment this line if you use 'qbx_core'.⚠️
}

server_scripts {
    'configs/server_customise_me.lua',
    'server/*.lua'
}

ui_page 'html/index.html'
files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/font/*.svg',
    'html/font/*.ttf',
    'html/font/*.eot',
    'html/font/*.woff',
    'html/font/*.woff2',
    'html/images/**/*.svg',
    'html/sound/*.ogg'
}

exports {
    'GetWeather',
    'GetAllData',
    'GetPauseSyncState'
}

server_exports {
    'GetWeather',
    'GetAllData',
    'GetRealData'
}

provide 'vSync'
provide 'qb-weathersync'
provide 'qbx_weathersync'