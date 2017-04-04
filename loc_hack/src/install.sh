#!/bin/sh
#
# $Id: install.sh 6845 2010-09-23 23:11:24Z NiLuJe $
#
# diff OTA patch script

_FUNCTIONS=/etc/rc.d/functions
[ -f ${_FUNCTIONS} ] && . ${_FUNCTIONS}


MSG_SLLVL_D="debug"
MSG_SLLVL_I="info"
MSG_SLLVL_W="warn"
MSG_SLLVL_E="err"
MSG_SLLVL_C="crit"
MSG_SLNUM_D=0
MSG_SLNUM_I=1
MSG_SLNUM_W=2
MSG_SLNUM_E=3
MSG_SLNUM_C=4
MSG_CUR_LVL=/var/local/system/syslog_level

logmsg()
{
    local _NVPAIRS
    local _FREETEXT
    local _MSG_SLLVL
    local _MSG_SLNUM

    _MSG_LEVEL=$1
    _MSG_COMP=$2

    { [ $# -ge 4 ] && _NVPAIRS=$3 && shift ; }

    _FREETEXT=$3

    eval _MSG_SLLVL=\${MSG_SLLVL_$_MSG_LEVEL}
    eval _MSG_SLNUM=\${MSG_SLNUM_$_MSG_LEVEL}

    local _CURLVL

    { [ -f $MSG_CUR_LVL ] && _CURLVL=`cat $MSG_CUR_LVL` ; } || _CURLVL=1

    if [ $_MSG_SLNUM -ge $_CURLVL ]; then
        /usr/bin/logger -p local4.$_MSG_SLLVL -t "ota_install" "$_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT"
    fi

    if [ "$_MSG_LEVEL" != "D" ]; then
      echo "ota_install: $_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT"
      [ -d /mnt/us/localization ] && echo "ota_install: $_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT" >> /mnt/us/localization/install.log
    fi
}

# Hack specific config (name and when to start/stop)
ORIGFOLDER_BOOKLET=/opt/amazon/ebook/booklet
ORIGFOLDER_LIB=/opt/amazon/ebook/lib
DESTFOLDER_BOOKLET=/opt/amazon/ebook/booklet_loc
DESTFOLDER_LIB=/opt/amazon/ebook/lib_loc
KEYBFOLDER=.

[ -n "$(find /mnt/us/ -maxdepth 1 -name '*.keyb')" ] && KEYBFOLDER=/mnt/us

# Unbind folders to original locations
logmsg "I" "update" "uninstall <=0.06 update"
[ -d /opt/amazon/ebook/booklet_ru ] && umount /opt/amazon/ebook/booklet
[ -d /opt/amazon/ebook/lib_ru ] && umount /opt/amazon/ebook/lib
[ -d /opt/amazon/ebook/img/ui_ru ] && umount /opt/amazon/ebook/img/ui
[ -d /opt/amazon/ebook/booklet_ru ] && rm -rf /opt/amazon/ebook/booklet_ru
[ -d /opt/amazon/ebook/lib_ru ] && rm -rf /opt/amazon/ebook/lib_ru
[ -d /opt/amazon/ebook/img/ui_ru ] && rm -rf /opt/amazon/ebook/img/ui_ru
[ -f /opt/amazon/rus-bind ] && rm -f /opt/amazon/rus-bind
[ -f /etc/init.d/rus-init  ] && rm -f /etc/init.d/rus-init
[ -h /etc/rcS.d/S73rus-init  ] && rm -f /etc/rcS.d/S73rus-init
[ -d /mnt/us/rus  ] && rm -rf /mnt/us/rus 

update_progressbar 10

# Unbind folders to original locations
logmsg "I" "update" "restore bindings"
[ -d /opt/amazon/ebook/booklet_loc ] && umount /opt/amazon/ebook/booklet
[ -d /opt/amazon/ebook/lib_loc ] && umount /opt/amazon/ebook/lib
[ -d /opt/amazon/ebook/img/ui_loc ] && umount /opt/amazon/ebook/img/ui
[ -f /opt/amazon/ebook/config_loc/msp_prefs ] && umount /opt/amazon/ebook/config/msp_prefs

logmsg "I" "update" "delete old contents"
[ -d /opt/amazon/ebook/booklet_loc ] && rm -rf /opt/amazon/ebook/booklet_loc
[ -d /opt/amazon/ebook/lib_loc ] && rm -rf /opt/amazon/ebook/lib_loc
[ -f /opt/amazon/ebook/config_loc/msp_prefs ] && rm -f /opt/amazon/ebook/config_loc/msp_prefs
[ -d /opt/amazon/ebook/img/ui_loc ] && rm -rf /opt/amazon/ebook/img/ui_loc

update_progressbar 15

#Create localization dir at user store
[ -d /mnt/us/localization ] || mkdir /mnt/us/localization

logmsg "I" "update" "translate JARs"
# Translate all JARs in 'booklet' and 'lib' folders
update_progressbar 20
/usr/java/bin/cvm -Xms16m -classpath bcel-5.2.jar:K3Translator.jar Translator td $ORIGFOLDER_BOOKLET translation.jar $DESTFOLDER_BOOKLET $KEYBFOLDER >> /mnt/us/localization/install.log 2>&1
update_progressbar 40
/usr/java/bin/cvm -Xms16m -classpath bcel-5.2.jar:K3Translator.jar Translator td $ORIGFOLDER_LIB translation.jar $DESTFOLDER_LIB $KEYBFOLDER >> /mnt/us/localization/install.log 2>&1
update_progressbar 45
/usr/java/bin/cvm -Xms16m -classpath bcel-5.2.jar:K3Translator.jar Translator tprefs /opt/amazon/ebook/config/msp_prefs /opt/amazon/ebook/config_loc/msp_prefs msp_prefs >> /mnt/us/localization/install.log 2>&1

update_progressbar 60

logmsg "I" "update" "copy images"
# Unpack and copy UI images
tar -xvzf ui_loc.tar.gz
[ -d /opt/amazon/ebook/img/ui_loc ] && rm -rf /opt/amazon/ebook/img/ui_loc
mv -f ui_loc /opt/amazon/ebook/img

update_progressbar 65

logmsg "I" "update" "init scripts and standalone files"
# Almost done, copy init scripts and initialize it
# Move init script
mv -f loc-init /etc/init.d/loc-init
# Make it runnable
chmod +x /etc/init.d/loc-init
# Add it to boot time
if [ ! -h /etc/rcS.d/S73loc-init ]
then
   ln -fs /etc/init.d/loc-init /etc/rcS.d/S73loc-init
fi 
mv -f loc-bind /opt/amazon/loc-bind
chmod +x /opt/amazon/loc-bind

/opt/amazon/loc-bind

update_progressbar 70

logmsg "I" "update" "Create dirs"
#Create keyboard support dir at user store
[ -d /mnt/us/keyboard ] || mkdir /mnt/us/keyboard

update_percent_complete 80

logmsg "I" "update" "Copy files"
#in case
if [ -d /opt/amazon/ebook/booklet_loc ]; then
        logmsg "I" "update" "Copy to booklet_loc"
        cp -f physkeyb.jar /opt/amazon/ebook/booklet_loc/physkeyb.jar >> /mnt/us/keyboard/install.log 2>&1
else if [ -d /opt/amazon/ebook/booklet_ru ]; then
                                logmsg "I" "update" "Copy to booklet_ru"
                                cp -f physkeyb.jar /opt/amazon/ebook/booklet_ru/physkeyb.jar >> /mnt/us/keyboard/install.log 2>&1
                 else if [ -d /opt/amazon/ebook/booklet ]; then
                                                        logmsg "I" "update" "Copy to booklet"
                                                        cp -f physkeyb.jar /opt/amazon/ebook/booklet/physkeyb.jar >> /mnt/us/keyboard/install.log 2>&1
                                        fi
                 fi
fi

update_percent_complete 90
logmsg "I" "update" "Copy to /mnt/us/keyboard"
mv -f kindle.kbd /mnt/us/keyboard >> /mnt/us/keyboard/install.log 2>&1
mv -f russian.kbd /mnt/us/keyboard >> /mnt/us/keyboard/install.log 2>&1
mv -f russian_fonetic.kbd /mnt/us/keyboard >> /mnt/us/keyboard/install.log 2>&1

logmsg "I" "update" "done"
update_progressbar 100

return 0
