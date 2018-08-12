#!/bin/sh
cmprs="/home/hardd/MNT/Lua/compress_lua.sh"
find $1 -type f -name '*.lua' -exec $cmprs {} \;
