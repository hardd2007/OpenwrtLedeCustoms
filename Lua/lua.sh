#!/bin/sh
cmprs="/home/hardd/MNT/MYREP/Lua/compress_lua.sh"
find $1 -type f -name '*.lua' -exec $cmprs {} \;
