fx_version 'cerulean'
game 'gta5'
author 'UnKnownJohn'
description 'NoPixel Inspired Graffiti Script'

client_script 'client/cl_*.lua'
server_script 'server/sv_*.lua'
shared_script 'config.lua'

files {
    'stream/*.ydr',
    'stream/*.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/*.ydr'