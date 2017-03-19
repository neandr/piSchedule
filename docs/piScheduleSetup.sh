#!/bin/bash
T=" ___ piSchedule Setup  #2.4      vers.2017-03-14_17  ___"
H="
    SYNOPSIS 
       piScheduleSetup.sh [ARGUMENT] 

    DESCRIPTION
       Script for setup 'piSchedule' on a Raspberry/pilight installation.
       The 'piSchedule' code is provide as ZIP and can be stored on Github or locally. 

       This script helps to select a specific version, download and install it.

       To setup from Github copy the following string and execute it at 
       the RPI prompt:
          cd ~  &&  wget https://neandr.github.io/piSchedule/piScheduleSetup.sh -O piScheduleSetup.sh && bash piScheduleSetup.sh

       To setup from local storage call this script with --local.
          Note:   For 'local setup' call this script from ~/ directory which has
                  to hold also the 'version.dir' and the ZIP file(s) 

    ARGUMENT
       no argument   Will prompt for setup with available versions from Github.

       '--local'     Install with local version detail file  (~/version.dir)
       '--update'    Only load 'piSchedule' code, no Python Libraries

       '--help'      Print this help text
"
echo "$T"

   GHurl='https://neandr.github.io/piSchedule'

   versions='versions.dir'
   xurl=$GHurl/$versions

   xDIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
   sourceDIR="$(basename $xDIR)"
   baseDIR="$(dirname $xDIR)"

   ## echo "    baseDIR: " $baseDIR
   ## echo "       xDir: " $xDIR
   ## echo "  sourceDIR: " $sourceDIR

   fg=$'\033[48;5;120m';
   fw=$'\033[48;5;123m';
   fr=$'\033[48;5;196m';
   ef=$'\033[0m'

#cd ~
#ls -lt

   #  -- help --
   if  [ "$1" == "--help" ] ; then 
       echo "$H"; 
       exit 0;
   fi


load_piSchedule_Libs ()
{
   echo -e " ** piSchedule loading Python libraries. **\n"

   sudo apt-get install python-pip

   # pip packages
   echo  "    ...  install 'python-dateutil'"
   sudo pip install python-dateutil

   echo  "    ...  install 'APScheduler'"
   sudo pip install apscheduler

   echo  "    ...  install 'bottle'"
   sudo pip install bottle
}


## ----------- ---- ----------------------------------

   LIBload=1
   if  [ "$1" == --update ] ; then 
       echo -e "    ---  UPDATE 'piSchedule' code only; *NO* library load! "
       let LIBload=0
       shift
   fi


   if  [ "$1" == --local ] ; then
      GHurl=''
      versions=$xDIR/$versions

      echo "    ---  Use local 'versions'  >>$versions<< "

      if [ -f $versions ] ; then
         echo "    "
      else 
         echo "    ---  NO such local 'versions'  >>$versions<< "
         exit 88
      fi

   else 
      echo "    ---  Use remote '$xurl'"
      sudo wget --output-file=wget.log $xurl -O $versions
      #cat  wget.log

      if  grep '404 Not Found'  wget.log ; then
         echo -e "\n    ---  Missing '$versions' from remote system !"
         echo      "    ---  For more details type  piScheduleSetup.sh --help" 
         exit 1
      fi
   fi


# --- Build the selection list --- 
   echo "   0: Update Python Libraries only" 

   N=1
   while read -r line
      do
        if [ -n "$line" ] ; then
           export "$line"
           echo "     " $N": " ${line:3}
           ((N++))
        fi
   done < $versions ;

   read -n 1 -p "    Select installation option: " No ;
   echo -e  "\n"

   x=Z$No ; set junk ${!x} ; shift

   #  ---Only lib loading ---
   if [ $No == 0 ] ; then
      load_piSchedule_Libs
      exit 0
   fi


   x=Z$No;  VERSION=${!x}
   VERSION=$1

   if [ -z $VERSION.zip ] ; then
         echo -e "\n ** piSchedule -- Missing [version] argument OR '$versions' from remote system!\n"
         echo "$H"; exit 0
   fi

   if ! [ -f $VERSION.zip ] ; then
         echo -e "\n ** piSchedule -- Missing ZIP  '$VERSION.zip'!\n"
         echo "$H"; exit 0
   fi

   echo -e "\n ** piSchedule Setup for Version  >>"$VERSION"<<  Load Libs: " $LIBload 


   SCHEDULE7=$HOME/$VERSION

# --- build the setup directory if not exist ---
   if [ -d $SCHEDULE7/ ] ;  then
        echo -e "\n    ---  $SCHEDULE7/ exists already.\n"
     else
        echo -e "\n    ---  $SCHEDULE7/ does NOT EXISTS! Will be created.\n"
        mkdir $SCHEDULE7/
   fi

# --- setup files and service ---

   unzip -o $VERSION.zip -d $SCHEDULE7  

   chmod 755 $SCHEDULE7/piSchedule.sh

   chmod 755 $SCHEDULE7/piSchedule.py
   chmod 755 $SCHEDULE7/piDiscover.py
   chmod 755 $SCHEDULE7/piPrefs.py
   chmod 755 $SCHEDULE7/sunrise_sunset.py
   chmod 755 $SCHEDULE7/setScheduleService.sh
   chmod 755 $SCHEDULE7/piScheduleSetup.sh

   sudo rm $SCHEDULE7/piSchedule.prefs.json

# --- Setup selected lib  --------
   if [ $LIBload == 1 ] ; then
      load_piSchedule_Libs
   fi

   #  --- service setup for installed version ---

   if [ -f $xDIR/$VERSION/piSchedule.sh.X ] ; then
      sudo service piSchedule stop      # make sure NO piSchedule isn't running!

      R='s#--DIR--#'$xDIR/$VERSION'#g'
      sed  $R $xDIR/$VERSION/piSchedule.sh.X > $xDIR/$VERSION/piSchedule.sh

   else
       echo -e "\n
     $fr                                                       $ef
     $fr    NOTE   Missing piSchedule components!              $ef
     $fr           Check the directory for                     $ef
            >>$VERSION/piSchedule.sh.X<<
     \n"
      exit 9

   fi

   sudo cp $xDIR/$VERSION/piSchedule.sh /etc/init.d/piSchedule
   sudo update-rc.d piSchedule defaults


# ------------ START & HELP DETAILS-----------------------

   service pilight status > status.log
   rv=$?
   if ! [ "$rv" == "0" ] ; then
      echo -e "
     $fr                                                       $ef
     $fr  pilight  *** NOT working correctly! ***              $ef
     $fr                                                       $ef
     $fr  pilight needs to be running for piSchedule!          $ef
     $fr                                                       $ef
      \n"

      read -n 1 -p "           $fw    Start pilight ?  (Y/n)   ${ef} " A
      echo -e  "\n"

      if [ $A == 'Y' ] ; then
         sudo service pilight start
      fi

   fi

   # rm status.log

   cd ~/$VERSION
   ./piDiscover.py

echo -e "\n
     $fg  piSchedule - HOW to START !                   $ef
     $fg                                                $ef
     $fg  Check above 'piDiscover pilight'              $ef
     $fg  ['server', 'port', 'pilight', 'sspd status']  $ef
     $fg                                                $ef
     $fw  Start piSchedule with                         $ef
     $fw    $  sudo service piSchedule start            $ef
     $fw                                                $ef
     $fg                                                $ef
     $fg  If failed, check with the following commands, $ef
     $fg  IMPORTANT: change to current piSchedule dirc  $ef
            $  cd ~/$VERSION  

     $fg    $  service piSchedule status                $ef
     $fg    $  sudo ./piPrefs.py                        $ef
     $fg    $  ./piDiscover.py                          $ef
     $fg    $  ps ax|grep piSchedule                    $ef
     $fg                                                $ef
     $fg  See also log-file:                            $ef
     $fg    $  cat logs/piInfo.log                      $ef
     $fg    $  cat logs/piSystem.log                    $ef
     $fg                                                $ef
     $fw                                                $ef
     $fw  With valid results move over to your browser  $ef
     $fw  and start the 'piSchedule' home page using    $ef
     $fw  the prompted {server}:{port}                  $ef
     $fw                                                $ef
     \n"

     sudo service piSchedule start
     sudo service piSchedule status

exit 0
