fx_version "bodacious"
game "gta5"

ui_page "web-side/index.html"

client_scripts {
	"@vrp/Lib/utils.lua",
	"client-side/*" 
}

server_scripts {
	"@vrp/Lib/utils.lua",
	"server-side/*"
}

files {
	"web-side/*"
}