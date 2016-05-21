#!/bin/bash
####
#./rename.sh oldfile newname
####
oldname="${1}".svg
newname="${2}".svg
_basedir="$(dirname "$(readlink -f "${0}")")"
cd "$_basedir"
pools="48 32 22 16"
for pool in $(echo $pools); do
	cd $_basedir/$pool/pool
	if [ -f $oldname ]; then
		if [ ! -f $newname ]; then
			mv -v $oldname $newname
		fi
	fi
	cd ..
done
printf "done\n"
