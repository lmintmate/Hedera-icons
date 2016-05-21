#!/bin/sh
case
if [ -f /usr/bin/dpkg ]; then
    if [ $(cat /etc/os-release|grep "^ID=debian$") ];then
        if [ $(dpkg --get-selections|grep siduction|head -n1 &>/dev/null) ];then
            _distrologo="siduction"
        else
            _distrologo="debian"
    fi
fi
