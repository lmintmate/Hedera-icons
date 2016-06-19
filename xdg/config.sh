#!/bin/sh
set -e
if [ ! -t 0 ]; then
	if type x-terminal-emulator &>/dev/null; then
		x-terminal-emulator -e "$0"
		exit 0
	else
		exit 1
	fi
fi
_basedir="$(dirname "$(readlink -f "${0}")")"
cd $_basedir
if [ ! -f ./icon-theme.cache ];then
	printf "You have to build the theme fist!\n"
	sleep 5
	exit 1
fi

auto_distroicon() {
	if [ $(cat /etc/os-release|grep "^ID=debian$") ];then
		if dpkg --get-selections|grep siduction &>/dev/null;then
			_distributor="siduction"
		else
			_distributor="debian"
		fi
	elif [ $(cat /etc/os-release|grep "^ID=devuan$") ];then
		_distributor="devuan"
	elif [ $(cat /etc/os-release|grep "^ID=opensuse$") ];then
		_distributor="suse"
	elif [ $(cat /etc/os-release|grep "^ID=chakra$") ];then
		_distributor="chakra"
	fi
	if [ -f /etc/manjaro-release ];then
		_distributor="manjaro"
	fi
	if [ -f 48/logos/distributor-$_distributor.png ];then
		for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d));do
			cd $_dir
			cp -fv logos/distributor-$_distributor.png logos/emblem-distributor.png
			cd $_basedir
		done
	fi
}

custom_distroicon() {
	printf "Please enter the name of the icon(eg: kde for emblem-kde.png)\n\n"
	read _customiconname
	if [ ! -f 48/logos/distributor-$_customiconname.png ];then
		printf "\ndistributor-$_customiconname.png does not exist - Aborting!\n"
		exit 1
	else
		_distributor="$_customiconname"
	fi
	for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d));do
		cd $_dir
		cp -fv logos/distributor-$_distributor.png logos/emblem-distributor.png
		cd $_basedir
	done
}

reset_distroicon() {
	for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d));do
		cd $_dir
		cp -fv logos/emblem-ivy.png logos/emblem-distributor.png
		cd $_basedir
	done
}

toggleqtworkaround() {
	if [ -f index.theme.xdg ];then
		printf "disabling Qt-workaround\n"
		mv -v index.theme index.theme.qt
		mv -v index.theme.xdg index.theme
	fi
	if [ -f index.theme.qt ];then
		printf "enabling Qt-workaround\n"
		mv -v index.theme index.theme.xdg
		mv -v index.theme.qt index.theme
	fi
}

createsymbolicsymlinks() {
	cd $_basedir
	unset "_tmpicons"
	if [ -d /usr/share/icons ];then
		_prefix=/usr
	elif [ -d $(getconf PATH| sed -e 's/\/bin//g' -e 's/://g')/share/icons ];then
		_prefix=$(getconf PATH| sed -e 's/\/bin//g' -e 's/://g')
	else
		printf "couldn't find prefix"
	fi
	if [ -d $_prefix/share/icons/[Gg]nome ]; then
		_tmpicons="$_tmpicons\n$(find $_prefix/share/icons/[Gg]nome -mindepth 1 -type f -iname "*symbolic*" -printf "%f\n"|sed 's/.svg/.png/g')"
	else
		printf "The Gnome theme isn't installed you will probably miss some icons"
		sleep 3
	fi
	if [ -d $_prefix/share/icons/[Aa]dwaita ]; then
		_tmpicons="$_tmpicons\n$(find $_prefix/share/icons/[Aa]dwaita -mindepth 1 -type f -iname "*symbolic*" -printf "%f\n"|sed 's/.svg/.png/g')"
	else
		printf "The Adwaita theme isn't installed you will probably miss some icons"
		sleep 3
	fi
	if [ -d $_prefix/share/icons/[Hh]icolor ]; then
		_tmpicons="$_tmpicons\n$(find $_prefix/share/icons/[Hh]icolor -mindepth 1 -type f -iname "*symbolic*" -printf "%f\n"|sed 's/.svg/.png/g')"
	fi
	printf "$_tmpicons" > symboliclinks
	sort symboliclinks|uniq > icons
	cd 16
	if [ ! -f $_basedir/pre_symbolicicons ];then
		find misc-symbolic >$_basedir/pre_symbolicicons
	fi
	if [ ! -d misc-symbolic ];then
		mkdir misc-symbolic
	fi
	for _icon in $(cat ../icons); do
		if [ -f "misc/$(echo "$_icon"|sed 's/-symbolic.symbolic.png/.png/')" ];then
			if [ ! -L misc-symbolic/$_icon ]; then
				ln -sv ../misc/$(echo $_icon|sed 's/-symbolic.symbolic.png/.png/') misc-symbolic/$_icon
			fi
		fi
		if [ -f "misc/$(echo "$_icon"|sed 's/-symbolic.png/.png/')" ];then
			if [ ! -L misc-symbolic/$_icon ]; then
				ln -sv ../misc/$(echo $_icon|sed 's/-symbolic.png/.png/') misc-symbolic/$_icon
			fi
		fi
	done
	cd $_basedir
	rm symboliclinks icons
	for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d)|sed 's#./16##');do
			cp -r 16/misc-symbolic $_dir
	done
}

removesymbolicsymlinks() {
	cd $_basedir
	cd 16
	find misc-symbolic >$_basedir/post_symbolicicons
	_createdicons=$(diff $_basedir/pre_symbolicicons $_basedir/post_symbolicicons|grep "[<>]"|sort|sed 's/^[<>] //'|uniq -u)
	cd $_basedir
	for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d)|sed 's#./16##');do
		cd $_dir
		for _createdicon in $(echo $_createdicons); do
			if [ -f $_createdicon ];then
				rm -vf $_createdicon
			fi
		done
		cd $_basedir
	done
	rm -f $_basedir/pre_symbolicicons $_basedir/post_symbolicicons
}

rebuildgtkiconcache() {
	rm -rf $_basedir/icon-theme.cache
	if type gtk-update-icon-cache &>/dev/null; then
		gtk-update-icon-cache $_basedir
	elif type gtk-update-icon-cache-3.0 &>/dev/null; then
		gtk-update-icon-cache-3.0 $_basedir
	fi
	if [ ! -f $_basedir/icon-theme.cache ]; then
		printf "\nIcon cache creation failed!, is gtk-update-icon-cache installed?\n\n"
	fi
}

while [ 1 ];do
	clear
	printf "\nWhat would you like to do?:\n
#1: Try to automatically set the distributor icon
#2: Set a custom distributor icon
#3: Reset distributor icon
#4: Create/Update GTK3 fake symbolic icons (only GTK3<=3.16) 
#5: Remove GTK3 fake symbolic icons
#7: Toggle the Qt-workaround
#8: Rebuild GTK+ icon cache
#9: Exit this script\n\n"
	printf "Make your choice: [1,2,3,4,5,7,8,9]"
	read _choice
	case $_choice in
		1)
			clear
			auto_distroicon
			sleep 5
		;;
		2)
			clear
			custom_distroicon
			sleep 5
		;;
		3)
			clear
			reset_distroicon
			sleep 5
		;;
		4)
			clear
			createsymbolicsymlinks
			sleep 5
		;;
		5)
			clear
			removesymbolicsymlinks
			sleep 5
		;;
		7)
			clear
			toggleqtworkaround
			sleep 5
		;;
		8)
			clear
			rebuildgtkiconcache
			sleep 5
		;;
		9)
			printf "\nbye\n"
			sleep 5
			exit 0
			break
		;;
		*)
			printf '\nnothing more here\n'
		;;
	esac
done
