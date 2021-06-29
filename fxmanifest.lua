fx_version 'bodacious'
games { 'gta5' }
author 'Codesign#2715'
description 'Weather & Time'
version '1.2.1'

client_scripts {
	'config.lua',
    'client/*.lua',
}

server_scripts {
    'config.lua',
    'server/*.lua',
}

ui_page {
    'html/index.html',
}
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
}
