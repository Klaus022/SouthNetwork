fx_version "bodacious"
game "gta5"
lua54 "yes"

ui_page "gui/index.html"

client_scripts {
	"Config/*",
	"Lib/vehicles.lua",
	"Lib/itemlist.lua",
	"Lib/utils.lua",
	"Client/*",
	"Config/Client.lua"
}

server_scripts {
	"Config/*",
	"Config/Vehicle.lua",
	"Config/Item.lua",
	"Lib/utils.lua",
	"Modules/*"
}

files {
	"loading/*",
	"Lib/*",
	"Gui/*"
}

loadscreen "loading/index.html"