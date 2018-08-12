#!/bin/sh
ccmd="/home/hardd/MNT/Lua/LuaSrcDiet --noopt-binequiv"
ccmd2="/home/hardd/MNT/Lua/LuaSrcDiet --opt-comments --noopt-binequiv  --opt-whitespace --opt-emptylines --opt-numbers --opt-locals --noopt-srcequiv"
echo "Dir: "$1
if $ccmd -o $1.o $1
then 
echo $1 " - OK"
mv -f $1.o $1
else if $ccmd2 -o $1.o $1
	then 
	echo $1 " - OK"
	mv -f $1.o $1
	else echo $1 >>/tmp/lua2_err.txt
	fi
fi
