#!/bin/sh
set -e
export _parallelyn=y
#number of jobs for parallel
export _inputthreads=$(expr $(nproc) \* 2)
export LANG=C
_basedir="$(dirname "$(readlink -f "${0}")")"
_basesizes="16 22 32 48"
_scales48="96 144 192 240"
_fakescales="24 64 72 80 112 128 160 176 208 224 256"
_allsizes="$(echo $_basesizes $_scales48 $_fakescales)"
_symlinkdirs="misc misc-animations misc-mimetypes misc-filesystems misc-symbolic"
_categories="actions animations applications emoticons folders logos mimetypes devices international menus status"
_tmpdir=/tmp

settings_parallel() {
	type parallel >/dev/null 2>&1&&_parallel=found
	if [ "$_parallel" = "found" ]; then
		case $_parallelyn in
			[yY])
				_parallel=true
				if type nproc &>/dev/null; then
					_parallelthreads=$(expr $(nproc) \* 2)
				else
					_parallelthreads=1
				fi
				if [ ! -z ${_inputthreads} ]; then
					_parallelthreads="$_inputthreads"
				fi;;
			*)
				printf "";;
		esac
	fi
}

optimize_pngs() {
	if type optipng &>/dev/null; then
		printf "\nOptimizing PNGs in $PWD\n\n"
		case $_parallel in
			true)
				parallel --no-notice -j "$_parallelthreads" optipng -nb -strip all -out "{}" {} ::: *.png;;
			*)
				optipng -nb -strip all ./*.png;;
		esac
		printf "\nPNG optimization... DONE\n\n"
	fi
}

check_req() {
	printf "\nChecking Requirements...\n\n"
	_requirements="sed convert inkscape awk"
	for _requirement in $_requirements; do
		type $_requirement &>/dev/null || { 
		printf >&2 "I require $_requirement but it's not installed. Aborting.\n"
		sleep 2
		exit 1
		}
	done
	sleep 1
	printf "\nChecking Requirements... DONE\n\n"
}

check_optreq() {
	printf "\nChecking optional Requirements...\n\n"
	type optipng &>/dev/null||_missing=1
	type parallel &>/dev/null||_missing=1
	if type gtk-update-icon-cache &>/dev/null; then
		printf ""
	elif type gtk-update-icon-cache-3.0 &>/dev/null; then
		printf ""
	else
		printf "gtk-update-icon-cache is missing..."
		_missing=1
	fi
	if [ "$_missing" = "1" ];then
		printf "\n\n-->Would you like to continue? [N/y]\n"
		read _abort1
		case $_abort1 in
			[yY])
				printf "";;
			*)
				printf "\nAborting!\n"
				exit 1;;
		esac
	fi
	printf "\nChecking optional Requirements... DONE\n\n"
}
settings_parallel() {
	type parallel >/dev/null 2>&1&&_parallel=found
	if [ "$_parallel" = "found" ]; then
		case $_parallelyn in
			[yY])
				_parallel=true
				if type nproc &>/dev/null; then
					_parallelthreads=$(expr $(nproc) \* 2)
				else
					_parallelthreads=1
				fi
				if [ ! -z ${_inputthreads} ]; then
					_parallelthreads="$_inputthreads"
				fi;;
			*)
				printf "";;
		esac
	fi
}

check_req() {
	printf "\nChecking Requirements...\n\n"
	_requirements="sed convert inkscape awk"
	for _requirement in $_requirements; do
		type $_requirement &>/dev/null || { 
		printf >&2 "I require $_requirement but it's not installed. Aborting.\n"
		sleep 2
		exit 1
		}
	done
	sleep 1
	printf "\nChecking Requirements... DONE\n\n"
}

check_optreq() {
	printf "\nChecking optional Requirements...\n\n"
	type optipng &>/dev/null||_missing=1
	type parallel &>/dev/null||_missing=1
	if type gtk-update-icon-cache &>/dev/null; then
		printf ""
	elif type gtk-update-icon-cache-3.0 &>/dev/null; then
		printf ""
	else
		printf "gtk-update-icon-cache is missing..."
		_missing=1
	fi
	if [ "$_missing" = "1" ];then
		printf "\n\n-->Would you like to continue? [N/y]\n"
		read _abort1
		case $_abort1 in
			[yY])
				printf "";;
			*)
				printf "\nAborting!\n"
				exit 1;;
		esac
	fi
	printf "\nChecking optional Requirements... DONE\n\n"
}

clean_build() {
	if [ -d $_tmpdir/Ivy ];then
		rm -rf $_tmpdir/Ivy
	fi
}

copybase_folders() {
	printf "\nPreparing folders...\n\n"
	cp -r $_basedir/xdg $_tmpdir/Ivy
	for _scale48 in $_scales48; do
		cp -rn $_tmpdir/Ivy/48 $_tmpdir/Ivy/$_scale48
	done
	if [ ! -d $_tmpdir/Ivy/240 ]; then
		printf "failed - Aborting..."
		exit 1
	fi
	printf "\nPreparing folders... DONE\n\n"
}

create_icon_cache() {
		printf "\ntrying to create icon cache\n\n"
		if type gtk-update-icon-cache &>/dev/null; then
			gtk-update-icon-cache $_tmpdir/Ivy
		elif type gtk-update-icon-cache-3.0 &>/dev/null; then
			gtk-update-icon-cache-3.0 $_tmpdir/Ivy
		fi
		if [ ! -f $_tmpdir/Ivy/icon-theme.cache ]; then
			printf "\nIcon cache creation... DONE\n\n"
		fi
}

svg2png() {
	printf "\nConverting SVGs to PNGs...\n\n"
	_sizes=$(echo "$_basesizes $_scales48")
	for _size in $(echo $_sizes);do
		cd $_tmpdir/Ivy/$_size
			for _category in $_categories; do
				if [ -d $_category ]; then
					cd $_category
					printf "\n\nConverting ${_size}px SVGs($_category)\n"
					if [ "$_parallel" = "true" ]; then
						parallel --no-notice -j "$_parallelthreads" inkscape -z -w $_size -h $_size -e "{}.png" {} ::: *.svg
						for _stupid in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.svg.png"); do
							mv "$_stupid" "$(echo $_stupid|sed 's/.svg.png/.png/')"
						done
					else
						for _name in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.svg"); do
							inkscape -z -w $_size -h $_size -e "$(echo $_name|sed 's/.svg/.png/')" "$_name"
						done
					fi
					optimize_pngs
					cd ..
				fi
			done
			convert +append $_tmpdir/Ivy/$_size/status/status-busy*.png $_tmpdir/Ivy/$_size/animations/process-working.png
			convert -append $_tmpdir/Ivy/$_size/status/status-busy*.png $_tmpdir/Ivy/$_size/animations/process-working-kde.png
			cd animations
			optimize_pngs
			cd ..
			if [ ! -f $_tmpdir/Ivy/$_size/logos/emblem-ivy.png ]; then
				printf "converting for $_size failed - Aborting..."
				exit 1
			fi
	done
}

create_fakescales() {
	printf "\n\nCreating fake scales...\n"
	_basescales="24 22
64 48
72 48
80 48
112 96
128 96
160 144
176 144
208 192
224 192
256 240"
	for _fakescale in $_fakescales; do
		cp -r $_tmpdir/Ivy/$(echo "$_basescales"|awk '{if ($1 == '$_fakescale') print $2}') $_tmpdir/Ivy/$_fakescale
		cd $_tmpdir/Ivy/$_fakescale
		for _category in $_categories; do
			if [ -d $_category ]; then
				cd $_category
				for _namebasescale in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.png"); do
					convert -gravity center -extent "$_fakescale"x"$_fakescale" -background Transparent "$_namebasescale" -set colorspace RGB "$_namebasescale"
				done
				optimize_pngs
				cd ..
			fi
		done
			convert +append $_tmpdir/Ivy/$_fakescale/status/status-busy*.png $_tmpdir/Ivy/$_fakescale/animations/process-working.png
			convert -append $_tmpdir/Ivy/$_fakescale/status/status-busy*.png $_tmpdir/Ivy/$_fakescale/animations/process-working-kde.png
		cd animations
		optimize_pngs
		cd ..
		if [ ! -f $_tmpdir/Ivy/$_fakescale/logos/emblem-ivy.png ]; then
			printf "converting for $_fakescale failed - Aborting..."
			exit 1
		fi
	done
}

svgsymlinks2png() {
	printf "\nConverting symlinks...\n\n"
	cd $_tmpdir/Ivy/48
	for _symlinkdir in $(echo $_symlinkdirs); do
		if [ -d "${_symlinkdir}" ]; then
			cd "${_symlinkdir}"
			printf "\n\nConverting Symlinks in ${PWD}\n"
			for _svgsymlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.svg"|cut -d/ -f2); do
				ln -s "$(readlink $_svgsymlink|sed 's#.svg$#.png#')" "$(ls $_svgsymlink|sed 's#.svg$#.png#')"
			done
			cd $_tmpdir/Ivy/48
		fi
	done
	if [ ! -L "$_tmpdir/Ivy/48/misc-mimetypes/all-allfiles.png" ]; then
		printf "\nCan't find png symlink - Aborting!\n\n"
		exit 1
	fi
}

copy_symlinks() {
	printf "\nCopying symlinks...\n\n"
	cd $_tmpdir
	for _allsize in $(echo $_allsizes|sed -e 's# 48 # #'); do
		for _createsymlinkdir in $(echo $_symlinkdirs); do
			cp -rn $_tmpdir/Ivy/48/$_createsymlinkdir  $_tmpdir/Ivy/$_allsize
		done
		if [ "$_allsize" -ne "48" ];then
			if [ "$_allsize" -ne "32" ];then
					if [ "$_allsize" -ne "22" ];then
							if [ "$_allsize" -ne "16" ];then
								cp -fR $_tmpdir/Ivy/32/misc-icondata $_tmpdir/Ivy/$_allsize/
							fi
					fi
			fi
		fi
	done
}


make_indextheme() {
	printf "\nCreating theme index...\n\n"
	cat <<\EOF > $_tmpdir/Ivy/index.theme.xdg
[Icon Theme]
Name=Ivy
Name[de]=Efeu
Example=start-here
Inherits=hicolor

##Dirs
EOF
	printf "Directories=" >> $_tmpdir/Ivy/index.theme.xdg
###dirs!
	for _allsize in $_allsizes; do
		printf "$_allsize/actions,$_allsize/applications,$_allsize/animations,$_allsize/devices,$_allsize/emoticons,$_allsize/folders,$_allsize/international,$_allsize/logos,$_allsize/menus,$_allsize/mimetypes,$_allsize/status,$_allsize/misc,$_allsize/misc-animations,$_allsize/misc-mimetypes,$_allsize/misc-filesystems,$_allsize/misc-symbolic," >> $_tmpdir/Ivy/index.theme.xdg
	done
	for _allsize in $(echo $_allsizes); do
		cat <<EOF >> $_tmpdir/Ivy/index.theme.xdg

[$_allsize/actions]
Size=$_allsize
Context=Actions
Type=Threshold
Threshold=1

[$_allsize/applications]
Size=$_allsize
Context=Applications
Type=Threshold
Threshold=1

[$_allsize/animations]
Size=$_allsize
Context=Animations
Type=Threshold
Threshold=1

[$_allsize/menus]
Size=$_allsize
Context=Categories
Type=Threshold
Threshold=1

[$_allsize/devices]
Size=$_allsize
Context=Devices
Type=Threshold
Threshold=1

[$_allsize/logos]
Size=$_allsize
Context=Emblems
Type=Threshold
Threshold=1

[$_allsize/emoticons]
Size=$_allsize
Context=Emotes
Type=Threshold
Threshold=1

[$_allsize/mimetypes]
Size=$_allsize
Context=MimeTypes
Type=Threshold
Threshold=1

[$_allsize/folders]
Size=$_allsize
Context=Places
Type=Threshold
Threshold=1

[$_allsize/status]
Size=$_allsize
Context=Status
Type=Threshold
Threshold=1

[$_allsize/international]
Size=$_allsize
Context=International
Type=Threshold
Threshold=1

[$_allsize/misc-filesystems]
Size=$_allsize
Context=FileSystems
Type=Threshold
Threshold=1

[$_allsize/misc-animations]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc-mimetypes]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Stock
Type=Threshold
Threshold=1

[$_allsize/misc-symbolic]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc-animations]
Size=$_allsize
Context=Animations
Type=Threshold
Threshold=1

[$_allsize/misc-mimetypes]
Size=$_allsize
Context=MimeTypes
Type=Threshold
Threshold=1
EOF
	done
}

make_indexthemeqt() {
	printf "\nCreating theme index...\n\n"
	cat <<\EOF > $_tmpdir/Ivy/index.theme
[Icon Theme]
Name=Ivy
Name[de]=Efeu
Comment=Qt/KDE workaround
Example=start-here
Inherits=hicolor

#######
#KDE-STuff
#######
DisplayDepth=32
LinkOverlay=emblem-symbolic-link
LockOverlay=emblem-nowrite
ShareOverlay=preferences-system-network-sharing
ZipOverlay=p7zip
DesktopDefault=48
DesktopSizes=48,96,144,176,224
ToolbarDefault=16
ToolbarSizes=16,22,24,32,48
MainToolbarDefault=22
MainToolbarSizes=16,22,24,32,48
SmallDefault=16
SmallSizes=16,22,24,32,48
PanelDefault=22
PanelSizes=16,22,24,32,48,96
DialogDefault=48
DialogSizes=16,22,24,32,48,96

##Dirs
EOF
	printf "Directories=" >> $_tmpdir/Ivy/index.theme
###dirs!
	for _allsize in $_allsizes; do
		printf "$_allsize/actions,$_allsize/applications,$_allsize/animations,$_allsize/devices,$_allsize/emoticons,$_allsize/folders,$_allsize/international,$_allsize/logos,$_allsize/menus,$_allsize/mimetypes,$_allsize/status,$_allsize/misc,$_allsize/misc-animations,$_allsize/misc-mimetypes,$_allsize/misc-filesystems,$_allsize/misc-symbolic," >> $_tmpdir/Ivy/index.theme
	done
	for _allsize in $(echo $_allsizes); do
		cat <<EOF >> $_tmpdir/Ivy/index.theme

######
# ${_allsize}px
######

[$_allsize/actions]
Size=$_allsize
Context=Actions
Type=Threshold
Threshold=1

[$_allsize/applications]
Size=$_allsize
Context=Applications
Type=Threshold
Threshold=1

[$_allsize/animations]
Size=$_allsize
Context=Animations
Type=Threshold
Threshold=1

[$_allsize/menus]
Size=$_allsize
Context=Categories
Type=Threshold
Threshold=1

[$_allsize/devices]
Size=$_allsize
Context=Devices
Type=Threshold
Threshold=1

[$_allsize/logos]
Size=$_allsize
Context=Emblems
Type=Threshold
Threshold=1

[$_allsize/emoticons]
Size=$_allsize
Context=Emotes
Type=Threshold
Threshold=1

[$_allsize/mimetypes]
Size=$_allsize
Context=MimeTypes
Type=Threshold
Threshold=1

[$_allsize/folders]
Size=$_allsize
Context=Places
Type=Threshold
Threshold=1

[$_allsize/status]
Size=$_allsize
Context=Status
Type=Threshold
Threshold=1

[$_allsize/international]
Size=$_allsize
Context=International
Type=Threshold
Threshold=1

[$_allsize/misc-filesystems]
Size=$_allsize
Context=FileSystems
Type=Threshold
Threshold=1

[$_allsize/misc-animations]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc-mimetypes]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Stock
Type=Threshold
Threshold=1

[$_allsize/misc-symbolic]
Size=$_allsize
Context=Misc
Type=Threshold
Threshold=1

[$_allsize/misc-animations]
Size=$_allsize
Context=Animations
Type=Threshold
Threshold=1

[$_allsize/misc-mimetypes]
Size=$_allsize
Context=MimeTypes
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Actions
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Applications
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Categories
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Devices
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=FileSystems
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Places
Type=Threshold
Threshold=1

[$_allsize/misc]
Size=$_allsize
Context=Status
Type=Threshold
Threshold=1

EOF
	done
}


cd "$_basedir"
sh -c "$_basedir"/xdg/updatesymlinks.sh
clean_build
check_req
check_optreq
copybase_folders
settings_parallel
svg2png
create_fakescales
svgsymlinks2png
copy_symlinks
make_indextheme
make_indexthemeqt
create_icon_cache
for _allsize in $(echo $_allsizes|sed 's/48 //'); do
    mv $_tmpdir/Ivy/$_allsize/misc-icondata/emblem-*.icon $_tmpdir/Ivy/$_allsize/logos/
    mv $_tmpdir/Ivy/$_allsize/misc-icondata/flag-*.icon $_tmpdir/Ivy/$_allsize/international/
    rm -rf $_tmpdir/Ivy/$_allsize/misc-icondata
done
cd $_tmpdir/Ivy/48/misc-icondata
for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.icon"|cut -d/ -f2); do
    cp --remove-destination $(readlink $_symlink) $_symlink
done
for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./emblem-*.icon"|cut -d/ -f2); do
    ln -s ../misc-icondata/$_symlink ../logos/$_symlink
done
for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./flag-*.icon"|cut -d/ -f2); do
    ln -s ../misc-icondata/$_symlink ../international/$_symlink
done
if [ -d "$_tmpdir/Ivy" ];then
	rm $_tmpdir/Ivy/updatesymlinks.sh
	find $_tmpdir/Ivy -mindepth 1 -name "*.svg" -exec rm -rf {} \;
fi
for _allsize in in $(echo $_allsizes); do
	if [ -d $_tmpdir/Ivy/$_allsize/pool ];then
		rm -rf $_tmpdir/Ivy/$_allsize/pool
	fi
done
cp "$_basedir"/.misc/COPYING $_tmpdir/Ivy/COPYING
ln -s COPYING $_tmpdir/Ivy/LICENSE
#FIXME RE-ADD TEXT (embeddedtextrectangles)
cd $_tmpdir
env XZ_OPT=-5 tar -cJvf $HOME/ivy-icon-theme.txz Ivy
