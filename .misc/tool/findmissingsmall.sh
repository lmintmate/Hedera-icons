#!/bin/sh
_basedir="$(dirname "$(readlink -f "${0}")")"
cd "$_basedir"
_folders="32 22 16"
for _folder in $_folders; do
	cd $_folder/pool
	for _svg in ./*.svg; do
		$(cat $_svg|grep 'viewBox="0 0 '$_folder'')|| printf "$(basename $_svg)\n" >>../../missing_$_folder
	done
	cd ../..
done
