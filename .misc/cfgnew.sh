#!/bin/sh
_basedir="$(dirname "$(readlink -f "${0}")")"
cd $_basedir
if [ -f  ./icon-theme.cache ];then
    exit 1
fi

change_distroicon() {
if [ -f /usr/bin/dpkg ]; then
    if [ $(cat /etc/os-release|grep "^ID=debian$") ];then
        if [ $(dpkg --get-selections|grep siduction|head -n1 &>/dev/null) ];then
            _distributor="siduction"
        else
            _distributor="debian"
    fi
else
    _distributor="ivy"
fi
###the change
for _dir in $(find -maxdepth 1 -mindepth 1 -type d);do
    cd _dir
    cp -f logos/emblem-$_distributor.png logos/emblem-distributor.png
    cd $_basedir
done
cp 48/misc-icondata/emblem-$_distributor.icon 48/misc-icondata/emblem-distributor.icon
}

change_distroicon
