fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'esx_pedchanger'
author 'Bert + GPT-5 Thinking'
description 'Change player model with /ped <model> and persist using mysql-async'
version 'v1.1.0'

shared_scripts {
  'config.lua'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'server/main.lua'
}
