#!/bin/sh
# add option to create symbolic symlinks(add per folder settings)
# add option for a qt-bug workaround
# add option for distributor icons
# dfsg option

###old stuff
create_symbolicsymlinks() {
	printf "\nCreating symbolic symlinks...\n\n"
	cd "$_basedir"/build/48
	for _symlinkdir in $(echo $_symlinkdirs); do
		cp -r "$_basedir"/src/48/"${_symlinkdir}" "$_basedir"/build/48
	done
	for _symlinkdir in $(echo $_symlinkdirs); do
		cd "${_symlinkdir}"
			for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "*.svg"|cut -d/ -f2); do
			if [ ! -L "$(echo $_symlink|sed 's/\.svg$/-symbolic.svg/')" ]; then
				if [ ! -f "$(echo $_symlink|sed 's/\.svg$/-symbolic.svg/')" ]; then
					ln -s "$(readlink $_symlink)" "$(echo $_symlink|sed 's/\.svg$/-symbolic.svg/')"
				fi
			fi
			if [ ! -L "$(echo $_symlink|sed 's/\.svg$/-symbolic.symbolic.svg/')" ]; then
				if [ ! -f "$(echo $_symlink|sed 's/\.svg$/-symbolic.symbolic.svg/')" ]; then
					#even more shit in newer adwaita themes...
					ln -s "$(readlink $_symlink)" "$(echo $_symlink|sed 's/\.svg$/-symbolic.symbolic.svg/')"
				fi
			fi
		done
		for _desc in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.icon"); do
			ln -s "$_desc" "$(ls $_desc|sed 's/\.icon$/-symbolic.icon/')"
			ln -s "$_desc" "$(ls $_desc|sed 's/\.icon$/-symbolic.symbolic.icon/')"
		done
		if [ "$_symlinkdir" != "misc" ]; then
			find . -maxdepth 1 -mindepth 1 -wholename "*-symbolic.svg" -exec mv {} ../misc \;
		fi
		cd ..
	done
}

make_dfsg() {
	case $_dfsg in
		[nN])
			printf "";;
		*)
_dangerlogos="multimedia-arte multimedia-video-player
network-chrome network-web-browser
network-opera network-web-browser
network-vivaldi network-web-browser
steam system-package-manager
folder-gog folder-games"
			for _allsize in $_allsizes; do
				cd "${_basedir}"/build/$_allsize/pool
				for _logo in $(echo "$_dangerlogos"|awk '{print $1}'); do
					if [ -f "$_logo.png" ]; then
						cp -f "$(echo "$_dangerlogos"|awk '{if ($1 == "'$_logo'") print $2}').png" "$_logo.png"
					fi
				done
				cd "${_basedir}"
			done;;
	esac
}

workaround_forqtbug43620() {
	case $_bug43620 in
		[yY])
			for _allsize in $_allsizes; do
				cat << EOF >>"${_basedir}"/build/index.theme

[$_allsize/misc]
Size=$_allsize
Context=Actions
Type=Threshold

[$_allsize/misc]
Size=$_allsize
Context=Applications
Type=Threshold

[$_allsize/misc]
Size=$_allsize
Context=Categories
Type=Threshold

[$_allsize/misc]
Size=$_allsize
Context=Devices
Type=Threshold

[$_allsize/misc]
Size=$_allsize
Context=FileSystems
Type=Threshold

[$_allsize/misc]
Size=$_allsize
Context=Places
Type=Threshold

[$_allsize/misc]
Size=$_allsize
Context=Status
Type=Threshold
EOF
			done;;
		*)
			printf "";;
	esac
}
