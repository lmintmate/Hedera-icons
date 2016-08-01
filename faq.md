* [Set the Icon Theme](#set-the-icon-theme)
* [FAQ](#faq)
	* [Missing Icons](#missing-icons)
* [Limitations and Bugs](#limitations-and-bugs)

### Set the icon theme

Also make sure the icon theme is installed in $SYSPREFIX/$DATADIR/icons!

###### GTK2

Add or change the icon theme in $HOME/.gtkrc-2.0

```
gtk-icon-theme-name="Hedera"
gtk-fallback-icon-theme="tango"
```

###### GTK3

Add or change the icon theme in $XDG_CONFIG_HOME/gtk-3.0/settings.ini

```
[Settings]
gtk-menu-images=true
gtk-icon-theme-name=Hedera
```

###### KDE

Add or change the icon theme in $XDG_CONFIG_HOME/kdeglobals($HOME/.kde/share/config/kdeglobals for KDE4)

```
[Icons]
Theme=Hedera
```

###### Qt4

_works by setting the icon theme in your GTK2 gtkrc(see above)_

you also need to set your DESKTOP_SESSION to gnome eg:

```
printf "export DESKTOP_SESSION=gnome" >>~/.profile
```

_you can also use KDE4 plugin by setting the desktop session to KDE and adding:_


```
[Icons]
Theme=Hedera
```
to your KDE4 kdeglobals

###### Qt5

You need to change the qt5 style plugin so you need at least one of the following:

* [Qt5ct](http://sourceforge.net/projects/qt5ct)
* [KDE5(kstyle)](https://www.kde.org/)
* [LXQt(qtplugin)](http://lxqt.org/)

eg: If KDE5 is installed and the icon theme is set to ivy(see kde above), you can use kde's platform plugin(same goes for lxqt or qt5ct):

```
printf "export QT_QPA_PLATFORMTHEME=kde" >>~/.profile
```

### FAQ

#### Missing icons

##### Missing symbolic icons

There is an experimental config script included that will create fake symboic icons to workaround this issue.

This works only if the GTK3 theme doesn't modify the icon design!

##### Inherit other themnes

Since the icon theme is not yet complete you might need to let it inherit some desktop specifc themes.

generally the Tango icon theme is recommended due its similiar icon style and some missing device/weather & mail icons.

to inherit another icon theme open the "index.theme" file with a text editor and add/replace your wanted icon theme for example to inherit KDEs Oxygen icon set change:

```
Inherits=hicolor
```

to:

```
Inherits=hicolor,oxygen
```
###### Xfce, LXDE/LXQt, Enlightenment

nothing needed

###### KDE

Oxygen/maybe breeze for plasma5

###### MATE

Menta/Mate

###### Cinnamon/GNOME3 etc.

Adwaita

#### Why no SVG icon theme:

* poor support by both GTK(has issues with masks) and Qt(supports only SVG tiny 1.1).
* PNGs require more space but the performance is alot better since everything is already prerendered

#### Limitations and Bugs:

* some smaller icons are fuzzy cause they are scaled down from other sizes(sry, but I don't have plenty of time but someday they will be complete I guess ;)
* some icons are still missing (thats an endless task) 
* Due Xfce bug [10126](https://bugzilla.xfce.org/show_bug.cgi?id=10126) it's impossible to select symbolic links in the built-in *.desktop editor (a Workaround would be to convert all symlinks to real files - however this would blow the filesize!)
* Due Qt-bug [33123](https://bugreports.qt.io/browse/QTBUG-33123) & [43620](https://bugreports.qt.io/browse/QTBUG-43620) all extra folders are ignored (Workaround available)
