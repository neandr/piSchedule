#!/bin/bash
cd ~
T=" ___piSchedule Setup        vers.2017-01   __  "
H="
    SYNOPSIS 
       piScheduleSetup.sh [ARGUMENT] 

    DESCRIPTION
       The 'piSchedule' code is stored on a Dropbox account. 
       This script helps to select a specific version, download and install 
       it on a Raspberry/pilight installation.

       Copy the following string and execute it at the RPI prompt:
          cd ~  &&  wget https://neandr.github.io/piSchedule/piScheduleSetup.sh -O piScheduleSetup.sh && bash piScheduleSetup.sh

    ARGUMENT
          no argument   will prompt with available versions.
          'version'     is the 'name' of the piSchedule ZIP file containing the code.
                        The 'name' will be used also to make a dir with that name to hold the code.
                      Note: Multiple installations can be stored on the RPI. However changing
                            between revisions should be done only with:
                               sudo service piSchedule stop
          '--update'    Only load 'piSchedule' code, no Python Libraries
          '--help'      print this help text

"
echo "$T"

DBOXurl='https://neandr.github.io/piSchedule/'
versions='versions.zip.dir'

#set -e
chmod 755 piScheduleSetup.sh

set_piSchedule () 
   {
      echo -e "\n    ...  Check if 'piSchedule.sh.X' exists."
      if [ -a $SCHEDULE7/piSchedule.sh.X ] ; then
         R='s#--DIR--#'$SCHEDULE7'#g'
         sed  $R $SCHEDULE7/piSchedule.sh.X > $SCHEDULE7/piSchedule.sh
      else
         echo -e "\n    ...  NOTE   Make sure piSchedule.sh has the correct directory setting!\n"
      fi
   }


set_service () 
{
   echo -e "\n ** 'service' for pilight and piSchedule ** "
	   sudo service pilight restart
	   sudo service piSchedule stop

   echo -e "\n ** set current piSchedule.sh for 'service' "
      sudo cp $SCHEDULE7/piSchedule.sh /etc/init.d/piSchedule
	   sudo update-rc.d piSchedule defaults

      var=$(grep "DIR=" /etc/init.d/piSchedule) ; 
      echo -e "    ...  Using  'service piSchedule start|stop|status' with: "$var"\n"

   echo -e "\n ** start piSchedule service ** "
	   sudo service piSchedule start
      ps ax|grep piSchedule|grep python

   echo -e " ** check piSchedule status !\n"

}


load_piSchedule_Libs ()
{
   echo  " ** piSchedule -- Python supporting libraries loading."

   sudo apt-get install python-pip

   # pip packages
   echo  "    ...  install 'python-dateutil'"
   sudo pip install python-dateutil

   echo  "    ...  install 'APScheduler'"
   sudo pip install apscheduler

   echo  "    ...  install 'bottle'"
   sudo pip install bottle
}


set_pilight_config () 
   {
      echo -e "    ...  Check if 'pilight.service.d/pilight.conf' exists."
      if [ -a /etc/systemd/system/pilight.service.d/pilight.conf ] ; then
         echo -e "    ...  NOTE   pilight.conf exist !\n"

      else
         echo -e "    ...  NOTE   'pilight.service.d/pilight.conf' does NOT exist! !\n"
         if [ ! -d /etc/systemd/system/pilight.service.d/ ] ; then
             sudo mkdir /etc/systemd/system/pilight.service.d/
             echo -e "    ...  NOTE   'pilight.service.d/ build !\n"
         fi

         echo "[Unit]" > pilight.conf
         echo "Require = network-online.target" >> pilight.conf
         echo "After = network-online.target" >> pilight.conf
         sudo mv pilight.conf /etc/systemd/system/pilight.service.d/pilight.conf
         # sudo service pilight restart
         echo -e "    ...  NOTE   'pilight.conf' was build to ensure ssdp works correct."
      fi
   }


load_pilight ()
{
   echo  " ** pilight  Installing."

   echo -e "    1: pilight Stable (The actual version)" 
   #echo -e "    5: pilight Nightly -- For advance use; Maybe NOT fully supported with piSchedule!"
   #echo -e "    8: pilight Nightly/Development -- For testing only!\n"
   echo -e "    0: pilight REMOVE from system!  \n"

   read -n 1 -p "    Select 'pilight' version to install: " No ; 
   echo -e "\n"

   if [ $No == -8 ] ; then        # disabled
      sudo chmod 666  /etc/apt/sources.list.d/pilight.list
      echo -e "\n  Installing pilight  NIGHTLY  $No  \n "  
      echo    "deb http://apt.pilight.org/ stable main" > /etc/apt/sources.list.d/pilight.list
      echo    "deb http://apt.pilight.org/ nightly main" >> /etc/apt/sources.list.d/pilight.list
      echo    "deb http://apt.pilight.org/ development main" >> /etc/apt/sources.list.d/pilight.list
   else if [ $No == -5 ] ; then   #disabled
      sudo chmod 666  /etc/apt/sources.list.d/pilight.list
      echo -e "\n  Installing pilight  NIGHTLY  $No  \n "  
      echo    "deb http://apt.pilight.org/ stable main" > /etc/apt/sources.list.d/pilight.list
      echo    "deb http://apt.pilight.org/ nightly main" >> /etc/apt/sources.list.d/pilight.list
   else if [ $No == 1 ] ; then
      sudo chmod 666  /etc/apt/sources.list.d/pilight.list
      echo -e "\n  Installing pilight  Stable  $No\n"
      echo    "deb http://apt.pilight.org/ stable main"  > /etc/apt/sources.list.d/pilight.list
   else if [ $No == 0 ] ; then

      echo -e " -- Removing 'pilight' from system! "
      sudo apt-get remove pilight
      exit 1

   else
      echo -e "\n  Wrong selection, terminating! \n"
      exit 9
   fi
   fi
   fi
   fi

   cat /etc/apt/sources.list.d/pilight.list
   sudo chmod 644  /etc/apt/sources.list.d/pilight.list
   echo -e "\n"

   #exit 0

   sudo wget -O - http://apt.pilight.org/pilight.key | apt-key add -

   sudo apt-get update
   sudo apt-get install pilight

   set_pilight_config

   echo " ** pilight start with 'service' "
   sudo service pilight start

   echo -e "\n ** pilight has been installed and started!"
   echo -e "    Check with the browser for successfully operation."
   echo -e "    To setup the pilight configuration see '/etc/pilight/config.json'"
   echo -e "    If that file has to be changed/edited, make sure"
   echo -e "    to stop pilight using:"
   echo -e "       sudo service pilight stop\n"
   echo -e "    After editing/updating the pilight config.jso restart pilight with:"
   echo -e "       sudo service pilight start\n\n"

   echo -e "    To setup  'piSchedule'  re-run this script with"
   echo -e "    selecting a 'piSchedule' version from the menu.\n\n"  
   exit 0
}


LIBload=1
if  [ "$1" == --update ] ; then 
    echo " ** UPDATE 'piSchedule' code only; *NO* library load! "
    let LIBload=0
    shift
fi

if [ -z "$1" ] ; then
   xurl=$DBOXurl/$versions

   echo -e " ** piSchedule Setup -- Loading [version] list! " #\n   "$xurl
   sudo wget --output-file=wget.log $xurl -O $versions
   if  grep '404 Not Found'  wget.log ; then
      echo "                     - Missing [version] argument OR '$versions' from remote system !"
      echo "    ...  For more details type  piScheduleSetup.sh --help" 
      exit 1
   fi

   echo "      0: Update Python Libraries only" 

   N=1
   while read line
      do if [ $line ] ; then 
         export "$line"
         echo "     " $N": " ${line:3}
         ((N++))
      fi
   done < $versions ;

   echo -e "    0: Python  - Libraries loading/updating only" 
   echo -e "    9: pilight - Download and install vers.7 \n" 

   read -n 1 -p "    Select installation option: " No ; 
   echo -e "\n"

   if [ $No == 9 ] ; then
      load_pilight
      exit 0
   fi

   if [ $No == 0 ] ; then
      load_piSchedule_Libs
      exit 0
   fi

   x=Z$No;  VERSION=${!x}
   sudo rm wget.log
   
else
   #  cmd was --help  or a version was entered
   if  [ "$1" == --help ] ; then 
       echo "$H"; exit 0; fi

   VERSION=$1
fi

if [ -z $VERSION ] ; then
      echo -e "\n ** piSchedule -- Missing [version] argument OR '$versions' from remote system!\n"
      echo "$H"; exit 0
fi

echo -e "\n ** piSchedule Setup -- Version  >>"$VERSION"<<  " 


if [ $LIBload = 1 ] ; then
    load_piSchedule_Libs
fi

SCHEDULE7=$HOME/$VERSION

if [ -d $SCHEDULE7/ ] ;  then
     echo "                      - "$SCHEDULE7/" exists already."
  else
     echo "                      - "$SCHEDULE7/" does NOT EXISTS!"
     echo "                      - "$SCHEDULE7/" will be created."
     mkdir $SCHEDULE7/
fi
cd $SCHEDULE7/


DBOXzip=$DBOXurl/$VERSION'.zip -O piScheduleX.zip'

echo " ** piSchedule Setup -- Get ZIP >>"$DBOXzip"<<" 


sudo wget --output-file=wget.log $DBOXzip
#cat wget.log

if  grep '404 Not Found'  wget.log ; then
   echo "   ERROR  404  : can't get ZIP" 
   exit 1
fi

if  grep ' saved ' wget.log ; then
   echo " ** piSchedule Setup -- ZIP OK"
fi
sudo rm wget.log


# setup files and service
unzip -o piScheduleX.zip -d $SCHEDULE7/ 
set_piSchedule

chmod 755 $SCHEDULE7/piSchedule.sh

chmod 755 $SCHEDULE7/piSchedule.py
chmod 755 $SCHEDULE7/piDiscover.py
chmod 755 $SCHEDULE7/piPrefs.py
chmod 755 $SCHEDULE7/sunrise_sunset.py
chmod 755 $SCHEDULE7/setScheduleService.sh

sudo rm piSchedule.prefs.json

set_service
# sudo  $SCHEDULE7/piDiscover.py

echo -e "\n
     *** piSchedule - Check Installation ***
         Only with a valid pilight/piSchedule {server}:{port} notation and 
         'version=xx >>OK<<' the piSchedule installation was successful.
 
         If failed, check with the following commands:
            cd ~/$VERSION
            sudo service pilight restart
            sudo service piSchedule restart
            sudo service piSchedule status
     "

echo "
     *** Start 'piSchedule' using 
            sudo service piSchedule start
         Check with
            sudo service piSchedule status

     *** Move over to your browser and start the 'piSchedule' home page
         using the 'piSchedule {server}:{port}' as prompted above

     *** For more detailed information see also
         DE:   $DBOXurl/DE/piScheduleOverview.html
         EN:   $DBOXurl/EN/piScheduleOverview.html
     "
sudo service piSchedule status
exit 0

