#!/bin/sh
if [ ! -t 0 ]; then
##we want a term!
	exit 0
fi
_basedir="$(dirname "$(readlink -f "${0}")")"
cd "$_basedir"

###settings
defaultsizes="16 22 32 48"
scales48="96 144 192 240"
#not really used - mostly only needed for some weird kde/dolphin sizes
scales32="64 80 112 128 160 176 208 224 256"
symlinkdirs="actions apps animations categories devices emblems emotes filesystems misc mimetypes places status intl"
tempdir=/tmp/ivyicons-tmp.$$
sizes="$defaultsizes"
iconname=Ivy
indextheme=index.theme.png


ask_deb() {
	_debmakedeps="dpkg-dev debhelper fakeroot libfile-fcntllock-perl"
	for _debmakedeb in  $(echo $_debmakedeps); do
		dpkg -s "$_debmakedeb" >/dev/null 2>&1 || {
			printf "$_debmakedeb is not installed.\n"
			_missing_debdep=1
			}
	done
	case $_missing_debdep in
		1)
			printf "skipping debian package creation...\n"
			sleep 5;;
		*)
			cat << EOF

= Build a deb package ==================================================

Would you like to build a debian package? [N/y]

EOF
			read _makedeb;;
	esac
}

create_deb() {
	case $_makedeb in
		[Yy])
			cd "${_basedir}"
			install -d "${_basedir}"/deb/debian/source "${_basedir}"/deb/files
			cat <<EOF > "${_basedir}"/deb/debian/control
Source: ivy-icon-theme
Section: x11
Priority: optional
Maintainer: $USER <$USER@$(cat /etc/hostname)>
Build-Depends: debhelper (>= 7)
Standards-Version: 3.9.6

Package: ivy-icon-theme
Architecture: all
Conflicts: 
Replaces: 
Depends: hicolor-icon-theme, tango-icon-theme
Recommends:
Suggests:
Provides:
Description: simple and colorful icon theme for X11 desktops!
EOF
			cat <<EOF > "${_basedir}"/deb/debian/rules
#!/usr/bin/make -f

build: build-arch build-indep
build-arch: build-stamp
build-indep: build-stamp

build-stamp: 
	dh_testdir
	touch build-stamp

clean:
	dh_testdir
	dh_testroot
	rm -f build-stamp 
	dh_clean

install: build
	dh_testdir
	dh_testroot
	dh_prep
	dh_installdirs
	mv "$_basedir"/deb/files/* "$_basedir"/deb/debian/ivy-icon-theme
	
binary-indep: build install
	dh_testdir
	dh_testroot
	dh_installdocs
	dh_installchangelogs 
	dh_fixperms
	dh_compress
	dh_installdeb
	dh_gencontrol
	dh_md5sums
	dh_builddeb
	dh_clean

binary: binary-indep binary-arch
.PHONY: build clean binary-indep binary-arch binary install
EOF
_ivyversiondate=$(date -u +%Y.%m.%d.%H%M)
			case $_dfsg in
				[yY])
					_ivyversion=$_ivyversiondate+dfsg;;
				*)
					_ivyversion=$_ivyversiondate;;
			esac
			cat <<EOF > "${_basedir}"/deb/debian/changelog
ivy-icon-theme ($_ivyversion-1) unstable; urgency=low
   new upsteam release
 -- $USER <$USER@$(cat /etc/hostname)>  $(date '-R')
EOF
			chmod +x "${_basedir}"/deb/debian/rules
			printf "3.0 (native)\n" > "${_basedir}"/deb/debian/source/format
			printf "7\n" > "${_basedir}"/deb/debian/compat
			_dirs="8 16 22 24 32 48 64 80 96 112 128 144 160 176 192 208 224 240 256"
			mkdir -p "${_basedir}"/deb/files/usr/share/icons/Ivy
			for _dir in $_dirs;do
				if [ -d $_dir ];then
					mv $_dir "${_basedir}"/deb/files/usr/share/icons/Ivy
				fi
			done
			_files="COPYING icon-theme.cache index.theme"
			for _file in $_files;do
				if [ -f $_file ];then
				mv $_file "${_basedir}"/deb/files/usr/share/icons/Ivy
			fi
			done
			cd "${_basedir}"/deb
			fakeroot debian/rules binary;;
		*)
			printf "\n";;
	esac
}

###Start here ;)
clean_build
iconcreate_sizes
for scale48 in $scales48; do
	mkdir -p "${_basedir}"/$scale48
done
for scale48 in $scales48; do
	cp -R "${_basedir}"/src/48/pool "${_basedir}"/$scale48
done
sizes=$(echo "$defaultsizes $scales48")
create_mono_symlinks
ask_forqtbug
ask_dfsg
ask_clean
ask_deb
convert_svg2png
convert_symlinks_to_png
copy_symlinks_back_to_theme
create_24px_icons
cd "${_basedir}"
#empty svgs work everywhere
cp -rf "${_basedir}"/src/8 "${_basedir}"/8
cp "${_basedir}"/src/COPYING "${_basedir}"
cp "${_basedir}"/src/"$indextheme" "${_basedir}"/index.theme
workaround_forqtbug43620
make_dfsg
create_icon_cache
create_deb
if [ ! -z "${tempdir}" ]; then
	if [ -d "${tempdir}" ]; then
			rm -drf "${tempdir}"
	fi
fi
clean_theme
###finish
cat << EOF














████████▄   ▄██████▄  ███▄▄▄▄      ▄████████  ██████
███   ▀███ ███    ███ ███▀▀▀██▄   ███    ███  ██████
███    ███ ███    ███ ███   ███   ███    █▀   ██████
███    ███ ███    ███ ███   ███  ▄███▄▄▄      ██████
███    ███ ███    ███ ███   ███ ▀▀███▀▀▀      ██████
███    ███ ███    ███ ███   ███   ███    █▄   
███   ▄███ ███    ███ ███   ███   ███    ███   ████
████████▀   ▀██████▀   ▀█   █▀    ██████████   ████



EOF

case $_makedeb in
	[Yy])
		if [ -f "${_basedir}/ivy-icon-theme_$_ivyversion-1_all.deb" ];then
			if [ -d "${_basedir}"/deb ];then
				rm -rf "${_basedir}"/deb
			fi
			if [ -f "${_basedir}"/build.sh ];then
				rm -f "${_basedir}"/build.sh
			fi
			cat << EOF

Debian package creation successful and you should be able to
install it with:

su -c "dpkg -i ivy-icon-theme_$_ivyversion-1_all.deb && apt-get install -f"
EOF
		else
			printf "Debian package creation failed - sorry ;(\n"
			printf "removing all files pls re-checkout..\n"
			if [ -d "${_basedir}"/deb ];then
				rm -rf "${_basedir}"/deb
			fi
			if [ -f "${_basedir}"/build.sh ];then
				rm -f "${_basedir}"/build.sh
			fi
		fi;;
	*)
		cat << EOF
You might want to copy(or symlink) this folder to your:

Local icon dirs: ($HOME/.local/share/icons, $HOME/.icons $HOME/.kde/share/icons)

or

System icon dir: (`getconf PATH | sed -e 's/\/bin//g' -e 's/://g'`/share/icons)

EOF
;;
esac
sleep 5
exit 0
