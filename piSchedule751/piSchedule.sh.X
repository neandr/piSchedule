#!/bin/bash

### BEGIN INIT INFO
# Provides:          piSchedule
# Required-Start:    $remote_fs $syslog $all
# Required-Stop:     $remote_fs $syslog
# Should-Start:      pilight
# Default-Start:     3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start|Stop service for piSchedule
# Description:       Start|Stop service for piSchedule
### END INIT INFO

# 17-01-23_20

set -e

#  
#  The next line should have been updated by the installing process so 
#  the correct DIR and piSchedule version can be started!
#  
DIR=--DIR--
cd $DIR

DAEMON=$DIR/piSchedule.py
DAEMON_NAME=piSchedule


# Add any command line options for your daemon here
DAEMON_OPTS=""

# This next line determines what user the script runs as.
# Root generally not recommended but necessary if you are using the Raspberry Pi GPIO from Python.
DAEMON_USER=root

# The process ID of the script when it runs is stored here:
PIDFILE=/var/run/$DAEMON_NAME.pid


. /lib/lsb/init-functions

do_start () {
    log_daemon_msg "Starting system $DAEMON_NAME daemon"
    start-stop-daemon --start --verbose --background --pidfile $PIDFILE --make-pidfile \
    --user $DAEMON_USER --chuid $DAEMON_USER --startas $DAEMON --chdir $DIR
    log_end_msg $?
    ./piPrefs.py

    status_of_proc "$DAEMON_NAME" "$DAEMON"
}

do_stop () {
    log_daemon_msg "Stopping system $DAEMON_NAME daemon"
    start-stop-daemon --stop --pidfile $PIDFILE --retry 10
    log_end_msg $?
}

case "$1" in

    start|stop)
        do_${1}
        ;;

    restart|reload|force-reload)
        do_stop
        do_start
        ;;


    status)
        $DIR/piPrefs.py
        status_of_proc "$DAEMON_NAME" "$DAEMON"
        ps ax|grep piSchedule|grep python
        exit 0 || exit $?
        ;;


    *)
        echo "Usage: /etc/init.d/$DAEMON_NAME {start|stop|restart|status}"
        exit 1
        ;;

esac
exit 0
