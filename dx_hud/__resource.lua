resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "ui.html"

local postalFile = 'new-postals.json'

files {
    "ui.html",
    "ui.css",
    "ui.js",
    "recgif.gif",
    "axon_logo.png",
    "motor_icon.png",
    "belt_icon.png",
    "dalkova_svetla.png",
    "fuel_icon.png",
    "gear.png",
    "klasicka_svetla.png",

    "limiter.png",
    "beltoff.png",
    "belton.png",
    "left_blank.png",
    "left_full.png",
    "right_blank.png",
    "right_full.png",
    "front_car.png",
    "back_car.png",
    "sign.png",
    "weapon_icon.png",
    "personal_icon.png",
    "fonts/ShareTechMono-Regular.ttf",
	'fonts/Montserrat-Regular.ttf',
	'fonts/Montserrat-Bold.ttf',
    'fonts/RussoOne-Regular.ttf',
}

client_script {
    'client.lua',
    'config.lua',
    'mptuner.lua',
}
server_script {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server.lua',
    'config.lua',
}
file(postalFile)
postal_file(postalFile)

file 'version.json'