fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Mack'
description 'Arousal Effect Script'
version '1.1.0'

shared_scripts {
    'config.lua',
    'locales/en.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'rsg-core',
    'bln_notify',
    'ox_target'
}
