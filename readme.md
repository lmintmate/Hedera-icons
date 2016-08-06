<p align="center">
  <img src="https://raw.githubusercontent.com/sixsixfive/Hedera-icons/master/.preview.png">
</p>
A classic icon theme in the spirit of [Tango!](http://tango.freedesktop.org/Tango_Desktop_Project).

Features:

* Colorful
* Icons with borders
* optimized for speed
* Includes ~800 icons in 4 different main sizes
* supports more than 4200 common icons in the most common sizes
* works on KDE3/4, Plasma 5, Xfce 4.12, LXQt/LXDE, MATE & Enlightenment

## Install

#### Prebuild version:

1) Open term and navigate into your icon themes directory eg:

    cd $HOME/.local/share/icons

2) Checkout just the icon theme with Subversion:

    svn co https://github.com/sixsixfive/Hedera/trunk/CP_TO_DATADIRS/icons/Hedera Hedera

you can also execute the included config script to set a distributor icon etc.

PS: You could also install/download the full (WIP) [Hedera theme](https://github.com/sixsixfive/Hedera).

#### Build from source:

You can also build it from source (req. SED, AWK, Inkscape & Convert {GNU parallel is strongly recommended!})

1) Open term and navigate into your icon themes directory eg:

    https://github.com/sixsixfive/Hedera-icons.git Hedera

2) run the build script:

    cd Hedera && sh build-xdg.sh

once finished the Icon theme should be inside your /tmp dir! - you can also execute the included config script to set a distributor icon etc.

## Links
* [Icon FAQ](https://github.com/sixsixfive/Hedera-icons/tree/master/faq.md)
* [Sailfish OS Port](https://openrepos.net/content/dfstorm/ivy-icon-theme)
