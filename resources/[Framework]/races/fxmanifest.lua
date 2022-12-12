fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'web-side/app.html'

client_scripts {
 'client-side/*'
}

shared_scripts {
 '@vrp/lib/utils.lua',
 'config.lua'
}

server_scripts {
 'server-side/*'
}

files {
 'web-side/app.html',
 'web-side/src/**/*'
}