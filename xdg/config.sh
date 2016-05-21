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

change_distroicon() {
	if [ -f /usr/bin/dpkg ]; then
		if [ $(cat /etc/os-release|grep "^ID=debian$") ];then
			#Siduction
			if dpkg --get-selections|grep siduction &>/dev/null;then
				_distributor="siduction"
			else
				_distributor="debian"
			fi
		fi
	else
		printf "Couldn't find a supported distribution!\n
	Would you like to set a custom image? [y/N]\n\n
	Note the icon needs to be in the logos folder!\n"
		read _yn      
		case $yn in
			[yY])
				printf "Please enter the name of the icon:\n"
				read _customiconname
				if [ ! -f 48/logos/emblem-$_customiconname.png ];then
					printf "emblem-$_customiconname.png does not exist - Aborting!"
					exit 1
				else
					_distributor="$_customiconname"
				fi
			;;
		esac
	fi
	for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d));do
		cd $_dir
		cp -fv logos/emblem-$_distributor.png logos/emblem-distributor.png
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

while [ 1 ];do
	clear
	printf "\nWhat would you like to do?:\n
#1: Set distributor icon
#2: Reset distributor icon
#8: Toggle the Qt-workaround (Don't do this if you use Qt applications!)
#9: Exit this script\n\n"
	printf "Make your choice: [1,2,8,9]"
	read _choice
	case $_choice in
		1)
			clear
			change_distroicon
			sleep 5
		;;
		2)
			clear
			reset_distroicon
			sleep 5
		;;
		8)
			clear
			toggleqtworkaround
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
