#!/bin/bash
T=" ___Set piSchedule Service        vers.2016-01-31 __"
H="
    SYNOPSIS 
       setScheduleService.sh 

    DESCRIPTION
       The 'piSchedule' is handled as a 'service'
       with:  sudo service piSchedule start|restart|stop

       This script sets the specific version stored in the same directory
       and prepares it for the 'service'

       Always run the script for a version change.  

    ARGUMENT
          no arguments   
"
echo -e "\n$T"

set_piSchedule () 
   {
      echo -e "\n    ...  Check if 'piSchedule.sh.X' exsists."
      if [ -a $SCHEDULE7/piSchedule.sh.X ] ; then
         R='s#--DIR--#'$SCHEDULE7'#g'
         sed  $R $SCHEDULE7/piSchedule.sh.X > $SCHEDULE7/piSchedule.sh
      else
         echo -e "\n    ...  NOTE   Make sure piSchedule.sh has the correct directory setting!\n"
      fi
   }

getDirs () 
{
   PRG_DIR=`dirname "$0"`
   OLD_PWD=`pwd`
   cd "$PRG_DIR"
   export CND_DIR=`pwd`
   cd "$OLD_PWD"

   #echo  "  PRG_DIR " $PRG_DIR
   #echo  "  OLD_PWD " $OLD_PWD
}


   set_piSchedule

   echo -e "\n ** set current piSchedule.sh for 'service' "
      sudo service piSchedule stop
      sudo cp piSchedule.sh /etc/init.d/piSchedule
      sudo update-rc.d piSchedule defaults

      var=$(grep "DIR=" /etc/init.d/piSchedule) ; 
      echo -e "\n    ...  Using  'service piSchedule start|stop|status' with: "$var

   echo -e "\n ** start piSchedule service ** "
      sudo service piSchedule start
      ps ax|grep piSchedule|grep python

   echo -e "\n **  check piSchedule status **  \n"

