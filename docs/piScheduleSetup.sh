#!/bin/bash
cd ~
T=" ___piSchedule Setup        vers.2017-02   __  "
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

   read -n 1 -p "    Select installation option: " No ; 
   echo -e "\n"

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

# only use first part to identify 'version'
set junk $VERSION
shift
VERSION=$1

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


echo -e "\n    ...  Check if 'piSchedule.sh.X' exists."
if [ -a $SCHEDULE7/piSchedule.sh.X ] ; then
   R='s#--DIR--#'$SCHEDULE7'#g'
   sed  $R $SCHEDULE7/piSchedule.sh.X > $SCHEDULE7/piSchedule.sh
else
   echo -e "\n    ...  NOTE   Make sure piSchedule.sh has the correct directory setting!\n"
fi


chmod 755 $SCHEDULE7/piSchedule.sh

chmod 755 $SCHEDULE7/piSchedule.py
chmod 755 $SCHEDULE7/piDiscover.py
chmod 755 $SCHEDULE7/piPrefs.py
chmod 755 $SCHEDULE7/sunrise_sunset.py
chmod 755 $SCHEDULE7/setScheduleService.sh

sudo rm piSchedule.prefs.json



   echo -e "\n ** set piSchedule  for 'service' "
      sudo cp $SCHEDULE7/piSchedule.sh /etc/init.d/piSchedule
	   sudo update-rc.d piSchedule defaults

      var=$(grep "DIR=" /etc/init.d/piSchedule) ; 
      echo -e "    ...  Using  'service piSchedule start|stop|status' with: "$var"\n"

# sudo service piSchedule status

echo -e "\n
     *** piSchedule - ready to start     ***
     *** Use                             ***
           $  sudo service piSchedule start

     *** Check with                      ***
           $  sudo service piSchedule status

         The listing needs a line with a valid
         addressing for server:port
            ** piSchedule  {server}:{port} : >><<
 
         If failed, check with the following commands:
           $  cd ~/$VERSION

           $  sudo service piSchedule restart
           $  sudo service piSchedule status
           $  sudo  $SCHEDULE7/piPrefs.py


     *** With valid results move over to your browser  ***
     *** and start the 'piSchedule' home page using    ***
     *** the prompted {server}:{port}                  ***

     "

exit 0

