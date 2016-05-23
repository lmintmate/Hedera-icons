#!/bin/sh
_basedir="$(dirname "$(readlink -f "${0}")")"
###make sure all icons are avail.
_sizes="16 22 32"
cd $_basedir/48/pool
for _size in $_sizes; do
	for _svg in $(echo $(find *.svg));do
		cp -n $_svg $_basedir/$_size/pool/$_svg
	done
done
###symlinks
_sizes="16 22 32 48"
for _size in $_sizes; do
	cd $_basedir/$_size/pool
	#actions
	for _svg in $(echo $(find action-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../actions/$_svg
	done
	#devices
	for _svg in $(echo $(find device-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../devices/$_svg
	done
	#logos
	for _svg in $(echo $(find emblem-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../logos/$_svg
	done
	#intl
	for _svg in $(echo $(find flag-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../international/$_svg
	done
	#folders
	for _svg in $(echo $(find folder-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../folders/$_svg
	done
	#mime
	for _svg in $(echo $(find mime-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../mimetypes/$_svg
	done
	#status
	for _svg in $(echo $(find status-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../status/$_svg
	done
	#emoticons
	for _svg in $(echo $(find emoticon-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../emoticons/$_svg
	done
	#animations
	for _svg in $(echo $(find animation-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../animations/$_svg
	done
	#menu
	for _svg in $(echo $(find menu-*.svg -not -name "*symbolic*"));do
		ln -sf ../pool/$_svg ../menus/$_svg
	done
	#apps
	_apps="development game graphics multimedia network office settings system utilities"
	for _app in $_apps;do
		for _svg in $(echo $(find $_app-*.svg -not -name "*symbolic*"));do
			ln -sf ../pool/$_svg ../applications/$_svg
		done
	done
	#symbolic
	for _svg in $(echo $(find *.svg -name "*symbolic.svg"));do
		ln -sf ../pool/$_svg ../misc-symbolic/$_svg
	done
	cd $_basedir
done
###icon data
cd 48/pool
for _icon in $(echo $(find *.icon));do
	ln -sf ../pool/$_icon ../misc-icondata/$_icon
done
cd ../misc-icondata
_sizes="16 22 32"
for _size in $_sizes; do
	if [ ! -d $_basedir/$_size/misc-icondata ]; then
		mkdir -p $_basedir/$_size/misc-icondata
	fi
	for _icon in $(echo $(find *.icon));do
		ln -sf ../../48/misc-icondata/$_icon $_basedir/$_size/misc-icondata/$_icon
	done
done
printf "\nEverything updated!\n"
