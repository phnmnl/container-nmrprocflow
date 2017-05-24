#!/bin/bash

INI=/srv/shiny-server/conf/global.ini
[ ! -f $INI ] && echo "ERROR: File $INI does not exist" && exit 1

for e in `env`; do 
    k=`echo $e | cut -d'=' -f1`
    grep -E "^$k=" $INI 1>/dev/null 2>/dev/null
    [ $? -eq 0 ] && sed -i -e "s/^$k=.*$/$e/" $INI
done


DATADIR=`cat $INI | grep DATASETS | cut -d'=' -f2 | tr -d "\n"`
[ ! -d $DATADIR ] && echo "ERROR: It seems that the DATASETS folder declared in $INI does not exist" && exit 1
[ -d $DATADIR ] && chmod 777 $DATADIR
[ ! -d $DATADIR/conf ] && mkdir $DATADIR/conf
[ ! -d $DATADIR/conf ] && echo "ERROR: It seems you have not the right privileges to the DATASETS folder declared in $INI" && exit 1
[ -d $DATADIR/conf ] && chmod 777 $DATADIR/conf

DEFPURGESESSIONS=2
PURGESESSIONS=`cat $INI | grep PURGESESSIONS | cut -d'=' -f2 | tr -d "\n"`
PURGESESSIONS=${PURGESESSIONS:-$DEFPURGESESSIONS}

V=$(expr $PURGESESSIONS \* 1440)
DELAYMIN=$(echo $V | tr -d "\n")

echo -n "Purge sessions with no activities since $PURGESESSIONS days ..."
NB=$(find ${DATADIR}/_* -type d 2>/dev/null | wc -l | tr -d "\n" 2>/dev/null)
echo -n "Before: $NB ..."
if [ $NB -gt 0 ]; then
   find ${DATADIR}/_* -type d -mmin +$DELAYMIN -exec rm -rf {} \; 2>/dev/null
   NB=$(find ${DATADIR}/_* -type d 2>/dev/null | wc -l | tr -d "\n" 2>/dev/null)
   echo -n "After: $NB  "
fi
echo "OK"

if [ $NB -gt 0 ]; then
   for d in `find ${DATADIR}/_* -type d`; do s=`basename $d`; grep $s ${DATADIR}/conf/accesslist; done
fi

prog=shiny-server
logfile=/var/log/${prog}.log
lockfile=/var/run/${prog}.pid

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

echo -n "Starting shiny-server:"
exec $prog --daemon "--pidfile=$lockfile" >> $logfile 2>&1 &
if [ $? -eq 0 ]; then
   echo "OK"
else
   echo "Failed"
fi

set -e

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

echo "Starting apache2 server ..."
exec apache2 -DFOREGROUND

