fx_version 'cerulean'
game 'gta5'


shared_scripts {
    'config/config.lua',
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

files {
    'config/languages/*.json'
}

dependency {
    "qb-target",
    "qb-core",
    "oxmysql"
}
