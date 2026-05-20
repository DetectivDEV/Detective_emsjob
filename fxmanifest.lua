fx_version 'cerulean'
use_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
version '1.0.0'
author 'Detective'
description 'Detective EMS Job - advanced ambulance & death system (redesign from Arius)'

ui_page 'ui/index.html'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	'shared/bridge/inventory.lua',
}

client_scripts {
	"client/modules/weapons.lua",
	"client/modules/utils.lua",
	"client/modules/death_ui.lua",

	"client/main.lua",

	"client/bridge/esx.lua",
	"client/bridge/qb.lua",
	"client/bridge/target.lua",
	"client/bridge/inventory.lua",

	"client/injuries.lua",
	"client/death.lua",
	"client/stretcher.lua",
	"client/paramedic.lua",

	"client/job/job.lua",
	"client/job/medical_bag.lua",
	"client/job/stashes.lua",
	"client/job/shops.lua",
	"client/job/clothing.lua",
	"client/modules/coords_debug.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/bridge/esx.lua",
	"server/bridge/qb.lua",
	"server/bridge/inventory_ox.lua",
	"server/bridge/inventory_qb.lua",
	"server/main.lua",
	"server/commands.lua",
	"server/txadmin.lua",
}

files {
	'locales/*.json',
	'ui/index.html',
	'ui/style.css',
	'ui/app.js',
}
