#!/bin/sh
########################################################################
# FIXME 
# 	+ RE-ADD TEXT (embeddedtextrectangles)
########################################################################
set -e
#SHELLOPTS=posix
#use parallel?
_parallelyn=y
#number of jobs for parallel
_inputthreads=$(expr \( $(nproc) \* 2 \) - 1)
LANG=C
_basedir="$(dirname "$(readlink -f "${0}")")"
_basesizes="16 22 32 48"
_scales48="96 144 192 240"
_fakescales="24 64 72 80 112 128 160 176 208 224 256"
_allsizes="$(echo $_basesizes $_scales48 $_fakescales)"
_symlinkdirs="misc misc-animations misc-mimetypes misc-filesystems"
_categories="actions animations applications emoticons folders logos mimetypes devices international menus status"
_tmpdir=/tmp

settings_parallel() {
	type parallel >/dev/null 2>&1&&_parallel=found
	if [ "$_parallel" = "found" ]; then
		case $_parallelyn in
			[yY])
				_parallel=true
				if type nproc &>/dev/null; then
					_parallelthreads=$(expr \( $(nproc) \* 2 \) - 1)
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
		printf "\nOptimizing PNGs in $PWD\n"
		case $_parallel in
			true)
#				parallel --no-notice -j "$_parallelthreads" optipng -o5 -nb -strip all -out "{}" {} ::: *.png;;
				parallel --no-notice -j "$_parallelthreads" optipng -nb -strip all -out "{}" {} ::: *.png;;
			*)
#				optipng -nb -o5 -strip all ./*.png;;
				optipng -nb -strip all ./*.png;;
		esac
		printf "\nPNG optimization... DONE\n"
	fi
}

check_req() {
	printf "\nChecking Requirements...\n"
	_requirements="sed convert inkscape awk"
	for _requirement in $_requirements; do
		type $_requirement &>/dev/null || { 
		printf "I require $_requirement but it's not installed. Aborting.\n"
		exit 1
		}
	done
	printf "\nChecking Requirements... DONE\n"
}

check_optreq() {
	printf "\nChecking optional Requirements...\n"
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
	printf "\nChecking optional Requirements... DONE\n"
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
	printf "\nChecking Requirements...\n"
	_requirements="sed convert inkscape awk"
	for _requirement in $_requirements; do
		type $_requirement &>/dev/null || { 
		printf >&2 "I require $_requirement but it's not installed. Aborting.\n"
		exit 1
		}
	done
	printf "\nChecking Requirements... DONE\n"
}

clean_build() {
	if [ -d "$_tmpdir/Hedera" ];then
		rm -rf "$_tmpdir/Hedera"
	fi
}

copybase_folders() {
	printf "\nPreparing folders...\n"
	cp -r $_basedir/xdg "$_tmpdir/Hedera"
	for _scale48 in $_scales48; do
		cp -rn "$_tmpdir/Hedera"/48 "$_tmpdir/Hedera"/$_scale48
	done
	if [ ! -d "$_tmpdir/Hedera"/240 ]; then
		printf "failed - Aborting..."
		exit 1
	fi
	printf "\nPreparing folders... DONE\n"
}

create_icon_cache() {
		printf "\ntrying to create icon cache\n"
		if type gtk-update-icon-cache &>/dev/null; then
			gtk-update-icon-cache "$_tmpdir/Hedera"
		elif type gtk-update-icon-cache-3.0 &>/dev/null; then
			gtk-update-icon-cache-3.0 "$_tmpdir/Hedera"
		fi
		if [ ! -f "$_tmpdir/Hedera"/icon-theme.cache ]; then
			printf "\nIcon cache creation... DONE\n"
		fi
}

svg2png() {
	printf "\nConverting SVGs to PNGs...\n"
	_sizes=$(echo "$_basesizes $_scales48")
	for _size in $(echo $_sizes);do
		cd "$_tmpdir/Hedera"/$_size
			for _category in $_categories; do
				if [ -d $_category ]; then
					cd $_category
					printf "\nConverting ${_size}px SVGs($_category)\n"
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
			convert +append "$_tmpdir/Hedera"/$_size/status/status-busy*.png "$_tmpdir/Hedera"/$_size/animations/process-working.png
			convert -append "$_tmpdir/Hedera"/$_size/status/status-busy*.png "$_tmpdir/Hedera"/$_size/animations/process-working-kde.png
			cd animations
			optimize_pngs
			cd ..
			if [ ! -f "$_tmpdir/Hedera"/$_size/logos/emblem-ivy.png ]; then
				printf "converting for $_size failed - Aborting..."
				exit 1
			fi
	done
}

create_fakescales() {
	printf "\nCreating fake scales...\n"
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
		cp -r "$_tmpdir/Hedera"/$(echo "$_basescales"|awk '{if ($1 == '$_fakescale') print $2}') "$_tmpdir/Hedera"/$_fakescale
		cd "$_tmpdir/Hedera"/$_fakescale
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
			convert +append "$_tmpdir/Hedera"/$_fakescale/status/status-busy*.png "$_tmpdir/Hedera"/$_fakescale/animations/process-working.png
			convert -append "$_tmpdir/Hedera"/$_fakescale/status/status-busy*.png "$_tmpdir/Hedera"/$_fakescale/animations/process-working-kde.png
		cd animations
		optimize_pngs
		cd ..
		if [ ! -f "$_tmpdir/Hedera"/$_fakescale/logos/emblem-ivy.png ]; then
			printf "converting for $_fakescale failed - Aborting..."
			exit 1
		fi
	done
}

svgsymlinks2png() {
	printf "\nConverting symlinks...\n"
	cd "$_tmpdir/Hedera"/48
	for _symlinkdir in $(echo $_symlinkdirs); do
		if [ -d "${_symlinkdir}" ]; then
			cd "${_symlinkdir}"
			printf "\nConverting Symlinks in ${PWD}\n"
			for _svgsymlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.svg"|cut -d/ -f2); do
				ln -s "$(readlink $_svgsymlink|sed 's#.svg$#.png#')" "$(ls $_svgsymlink|sed 's#.svg$#.png#')"
			done
			cd "$_tmpdir/Hedera"/48
		fi
	done
	if [ ! -L ""$_tmpdir/Hedera"/48/misc-mimetypes/all-allfiles.png" ]; then
		printf "\nCan't find png symlink - Aborting!\n"
		exit 1
	fi
}

copy_symlinks() {
	printf "\nCopying symlinks...\n"
	cd $_tmpdir
	for _allsize in $(echo $_allsizes|sed 's# 48 # #'); do
		for _createsymlinkdir in $(echo $_symlinkdirs); do
			cp -rn "$_tmpdir/Hedera"/48/$_createsymlinkdir  "$_tmpdir/Hedera"/$_allsize
		done
		if [ "$_allsize" -ne "48" ];then
			if [ "$_allsize" -ne "32" ];then
					if [ "$_allsize" -ne "22" ];then
							if [ "$_allsize" -ne "16" ];then
								cp -fR "$_tmpdir/Hedera"/32/misc-icondata "$_tmpdir/Hedera"/$_allsize/
							fi
					fi
			fi
		fi
	done
}


make_indextheme() {
	printf "\nCreating theme index...\n"
	cat <<\EOF > "$_tmpdir/Hedera"/index.theme.xdg
[Icon Theme]
Name=Hedera
Name[ar]=اللبلاب
Name[ca]=Heura
Name[cs]=Břečťan
Name[da]=Vedbend
Name[de]=Efeu
Name[en]=Ivy
Name[el]=Κισσός
Name[es]=Hiedra
Name[fr]=Lierre
Name[gd]=Eidheann
Name[it]=Edera
Name[ja]=ツタ
Name[la]=Hedera
Name[lu]=Wantergréng
Name[nl]=Klimop
Name[pt]=Hera
Name[ru]=Плющ
Name[sv]=Murgröna
Name[zh]=常春藤
Comment=Pure XDG-theme
Example=emblem-distributor
Inherits=hicolor

##Dirs
EOF
	printf "Directories=" >> "$_tmpdir/Hedera"/index.theme.xdg
###dirs!
	for _allsize in $_allsizes; do
		printf "$_allsize/actions,$_allsize/applications,$_allsize/animations,$_allsize/devices,$_allsize/emoticons,$_allsize/folders,$_allsize/international,$_allsize/logos,$_allsize/menus,$_allsize/mimetypes,$_allsize/status,$_allsize/misc,$_allsize/misc-animations,$_allsize/misc-mimetypes,$_allsize/misc-filesystems," >> "$_tmpdir/Hedera"/index.theme.xdg
	done
	for _allsize in $(echo $_allsizes); do
		cat <<EOF >> "$_tmpdir/Hedera"/index.theme.xdg


[$_allsize/actions]
Size=$_allsize
Context=Actions
Type=Fixed

[$_allsize/applications]
Size=$_allsize
Context=Applications
Type=Fixed

[$_allsize/animations]
Size=$_allsize
Context=Animations
Type=Fixed

[$_allsize/menus]
Size=$_allsize
Context=Categories
Type=Fixed

[$_allsize/devices]
Size=$_allsize
Context=Devices
Type=Fixed

[$_allsize/logos]
Size=$_allsize
Context=Emblems
Type=Fixed

[$_allsize/emoticons]
Size=$_allsize
Context=Emotes
Type=Fixed

[$_allsize/mimetypes]
Size=$_allsize
Context=MimeTypes
Type=Fixed

[$_allsize/folders]
Size=$_allsize
Context=Places
Type=Fixed

[$_allsize/status]
Size=$_allsize
Context=Status
Type=Fixed

[$_allsize/international]
Size=$_allsize
Context=International
Type=Fixed

[$_allsize/misc-filesystems]
Size=$_allsize
Context=FileSystems
Type=Fixed

[$_allsize/misc-animations]
Size=$_allsize
Context=Misc
Type=Fixed

[$_allsize/misc-mimetypes]
Size=$_allsize
Context=Misc
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Misc
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Stock
Type=Fixed

[$_allsize/misc-animations]
Size=$_allsize
Context=Animations
Type=Fixed

[$_allsize/misc-mimetypes]
Size=$_allsize
Context=MimeTypes
Type=Fixed
EOF
	done
}

make_indexthemeqt() {
	printf "\nCreating theme index...\n"
	cp "$_tmpdir/Hedera"/index.theme.xdg "$_tmpdir/Hedera"/index.theme
		cat <<EOF >> "$_tmpdir/Hedera"/index.theme

########################################################################
###################### Qt workaround ###################################
########################################################################

EOF
	for _allsize in $(echo $_allsizes); do
		cat <<EOF >> "$_tmpdir/Hedera"/index.theme

[$_allsize/misc]
Size=$_allsize
Context=Actions
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Applications
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Categories
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Devices
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=FileSystems
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Places
Type=Fixed

[$_allsize/misc]
Size=$_allsize
Context=Status
Type=Fixed

EOF
	done
	sed -i 's|Comment=Pure XDG-theme|Comment=Qt/KDE-fix|g' "$_tmpdir/Hedera"/index.theme
	sed -i 's|Inherits=hicolor|Inherits=hicolor,oxygen|g' "$_tmpdir/Hedera"/index.theme
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
    mv "$_tmpdir/Hedera"/$_allsize/misc-icondata/emblem-*.icon "$_tmpdir/Hedera"/$_allsize/logos/
    mv "$_tmpdir/Hedera"/$_allsize/misc-icondata/flag-*.icon "$_tmpdir/Hedera"/$_allsize/international/
    rm -rf "$_tmpdir/Hedera"/$_allsize/misc-icondata
done
cd "$_tmpdir/Hedera"/48/misc-icondata
for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./*.icon"|cut -d/ -f2); do
    cp --remove-destination $(readlink $_symlink) $_symlink
done
for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./emblem-*.icon"|cut -d/ -f2); do
    ln -s ../misc-icondata/$_symlink ../logos/$_symlink
done
for _symlink in $(find . -maxdepth 1 -mindepth 1 -wholename "./flag-*.icon"|cut -d/ -f2); do
    ln -s ../misc-icondata/$_symlink ../international/$_symlink
done
if [ -d ""$_tmpdir/Hedera"" ];then
	rm "$_tmpdir/Hedera"/updatesymlinks.sh
	find "$_tmpdir/Hedera" -mindepth 1 -name "*.svg" -exec rm -rf {} \;
fi
for _allsize in in $(echo $_allsizes); do
	if [ -d "$_tmpdir/Hedera"/$_allsize/pool ];then
		rm -rf "$_tmpdir/Hedera"/$_allsize/pool
	fi
done
cp "$_basedir"/COPYING "$_tmpdir/Hedera"/COPYING
cp "$_basedir"/LICENSE "$_tmpdir/Hedera"/LICENSE
if [ "$USER" = "sixsixfive" ];then
	if [ -d "$_basedir"/../Hedera ];then
		if [ -d "$_basedir"/../Hedera/CP_TO_DATADIRS/icons/Hedera ]; then
			rm -rf "$_basedir"/../Hedera/CP_TO_DATADIRS/icons/Hedera
		fi
		mv "$_tmpdir/Hedera" "$_basedir"/../Hedera/CP_TO_DATADIRS/icons/Hedera
	fi
fi
cd $HOME
