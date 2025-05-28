fx_version 'cerulean'
game 'gta5'

author 'Ruptz'
description 'Report Menu System for Standalone'
version '1.0.0'
lua54 'yes'

--ui_page 'web/dist/index.html'
ui_page 'http://localhost:3000' -- Only use this for development

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'web/dist/*',
    'web/dist/**/*'
}

dependencies {
    'ox_lib',
    'oxmysql'
}