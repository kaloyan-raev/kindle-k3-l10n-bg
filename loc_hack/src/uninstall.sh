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

    [ "$_MSG_LEVEL" != "D" ] && echo "ota_install: $_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT"
}

# Unbind folders to original locations
logmsg "I" "update" "restore bindings"
[ -d /opt/amazon/ebook/booklet_loc ] && umount /opt/amazon/ebook/booklet
update_progressbar 10
[ -d /opt/amazon/ebook/lib_loc ] && umount /opt/amazon/ebook/lib
update_progressbar 20
[ -d /opt/amazon/ebook/img/ui_loc ] && umount /opt/amazon/ebook/img/ui
update_progressbar 30
[ -d /opt/amazon/ebook/booklet_loc ] && rm -rf /opt/amazon/ebook/booklet_loc
update_progressbar 40
[ -d /opt/amazon/ebook/lib_loc ] && rm -rf /opt/amazon/ebook/lib_loc
[ -f /opt/amazon/ebook/config_loc/msp_prefs ] && umount /opt/amazon/ebook/config/msp_prefs
[ -f /opt/amazon/ebook/config_loc/msp_prefs ] && rm -f /opt/amazon/ebook/config_loc/msp_prefs
update_progressbar 50
[ -d /opt/amazon/ebook/img/ui_loc ] && rm -rf /opt/amazon/ebook/img/ui_loc
update_progressbar 60
[ -f /opt/amazon/loc-bind ] && rm -f /opt/amazon/loc-bind
update_progressbar 70
[ -f /etc/init.d/loc-init  ] && rm -f /etc/init.d/loc-init
update_progressbar 80
[ -h /etc/rcS.d/S73loc-init  ] && rm -f /etc/rcS.d/S73loc-init
update_progressbar 90
[ -d /mnt/us/localization  ] && rm -rf /mnt/us/localization
update_progressbar 95
[ -d /mnt/us/keyboard ] && rm -rf /mnt/us/keyboard

logmsg "I" "update" "done"
update_progressbar 100

return 0
