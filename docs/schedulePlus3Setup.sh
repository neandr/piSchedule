#!/bin/bash
GITdoc='https://neandr.github.io/piSchedule'

NAME='schedulePlus3'
VDATE='2020-10-23_01'
VERSION='3.0.5'

ZIPP=schedulePlus3.zip

  bw=$'\033[1m'                  # bold
  br=$'\033[1;38;5;196m'         # bold red
  ba=$'\033[1;38;5;16;48;5;15m'  # bold black on white
  bg=$'\033[1;38;5;28;48;5;7m'   # bold green on white
  bb=$'\033[1;38;5;21;48;5;7m'   # bold blue on white
  e0=$'\033[0m'                  # reset/normal

T=" ___ schedulePlus3 Setup  #$VERSION     $VDATE ___"
H="
    SYNOPSIS
      schedulePlus3Setup.sh [ARGUMENT]

    DESCRIPTION
      Der 'schedulePlus3' Programm Code ist verfügbar auf Github als ZIP.
      Verfügbare ZIP/Versionen lassen sich mit diesem Script abrufen und
      vor der Installation erfolgt eine SHA256 Prüfsummen Kontrolle.
      Bei Fehler wird die weitere Script Ausführung abgebrochen.

      Das 'schedulePlus3' ZIP wird in das aktuelle Verzeichnis geladen,
      aber in einem übergeordneten 'schedulePlus3/' Verzeichnis gespeichert
      und von dort später ausgeführt.
      Der Verzeichnisbaum sieht so aus:

       ../pi/                      oder ein anderes übergeordnetes Verzeichnis
         |__schedulePlus3.zip      ev. weitere Versionen
         |__schedulePlus3Setup.sh  dieses Script
         |
         |__schedulePlus3/         'schedulePlus3' Programm Code

      Dieses Script installiert ebenfalls die erforderlichen Bibliotheken und
      Funktionen um das Ausführen des 'schedulePlus3' Programm Code zu ermöglichen.
      Schließlich zeigt es den erforderlichen Aufruf (http://<IP>:<port>)
      für die 'schedulePlus3' Ausführung im Browser.

"
A="
    ARGUMENTS
      no argument         Zeigt Version/Datum und momentanes Verzeichnis
      '--help'            Prompt dieses 'Help' Textes

      '-l' '--libs'       Laden der Python/bash Bibliotheken (Python, Bottle etc)
      '-i' '--install'    Installation der 'schedulePlus3' Funktionen mit Auswahl
                            einer ZIP Datei
      '-c' '--configure'  Konfigurieren des 'schedulePlus3' Systems, siehe auch
                            Dokumentation zum Einrichten der individuellen Installation

    Dokumentation  $GITdoc
"


echo "$T"

   xDIR="$(pwd)"
   baseDIR="$(dirname $xDIR)"
   currentDIR="$(basename $xDIR)"

   echo "        xDir: " $xDIR        #  /home/pi
   echo "     baseDIR: " $baseDIR     #  /home
   echo "  currentDIR: " $currentDIR  #  pi
   #echo " Default ZIP: " $ZIPP        #  schedulePlus3
   echo -e

#----------------------------------------------
function install_it ()
{
   echo "   ... install_it  $WHAT"
   INSTALL_STAT=`sudo pip3 install $WHAT`
   IS_STAT=$(( ! $(grep -iq 'satisfied:' <<< "$INSTALL_STAT"; echo $?) ))
   echo "   ...     status  '$IS_STAT' '$INSTALL_STAT'"
}

function LibsLoad ()
{
   echo -e "\n   *** Python libraries loaded for 'schedulePlus3'.\n"

   echo "   ... Install python3-pip ..."
   sudo apt-get install python3-pip

   WHAT='apscheduler'
   install_it $WHAT

   WHAT='bottle'
   install_it $WHAT

   WHAT='python-dateutil'
   install_it $WHAT
}

function SystemInstall ()
{
   # unzip code,
   # if directory already exsist, don't extract /data directory
   #   not to overwrite user data, see /data.org for default etc
   echo -e "\n    ---  Checking for 'schedulePlus3'"
   if [[ -d schedulePlus3 ]] ;  then
      echo -e  "\n!!! ---  'schedulePlus3/' exists already.\n"
      echo -e    "    ---  Code from $ZIPP will be deflated to 'schedulePlus3' directory,"
      echo -e    "    ---  excluding 'schedulePlus3/data' .. so individuel data isn't lost."
      unzip -o $ZIPP -x schedulePlus3/data/* schedulePlus3Setup.sh

    else
      echo -e  "\n!!! ---  'schedulePlus3/' .. Does NOT EXISTS! Will be created.\n"
      if ! mkdir schedulePlus3/ ; then
         echo -e "??? ---  'schedulePlus3/' .. Could not create. Error!'"
         exit 102
      else
         echo -e "    ---  'schedulePlus3' code will be installed from '$ZIPP'."
         unzip -o $ZIPP -x schedulePlus3Setup.sh
      fi
   fi
}

function SystemConfigure()     #Configure schedulePlus
{
   echo -e "   --- Activate 'schedulePlus3'"

   chmod 755 schedulePlus3/piSchedule.sh

   chmod 755 schedulePlus3/piGeoDetails.py
   chmod 755 schedulePlus3/piPrefs.py
   chmod 755 schedulePlus3/piSchedule.py
   chmod 755 schedulePlus3/routerAndMe.py
   chmod 755 schedulePlus3/suntime.py


   #  --- service setup
   if [ -f schedulePlus3/piSchedule.sh ] ; then
     sudo service piSchedule stop 2>/dev/null      # make sure NO schedulePlus is running!

     R='/DIR=/c\DIR='$xDIR/schedulePlus3
     sed -i $R schedulePlus3/piSchedule.sh
   else
     echo -e "\n$br

       NOTE   Missing schedulePlus3 components!
              Check the directory for
              >>schedulePlus3/piSchedule.sh<<
           $e0\n"
     exit 104
   fi

   sudo cp schedulePlus3/piSchedule.sh /etc/init.d/piSchedule
   sudo update-rc.d piSchedule defaults

   port=$(sed 's/, "/\n/g' $xDIR/schedulePlus3/data/piSchedule.prefs.json | egrep "port" | tr -d '":a-zA-Z ')
   addr=$(echo $(hostname -I) | tr -d ' ')

   echo -e "\n

      $ba    Starting 'schedulePlus' now                   $e0

      IMPORTANT if failed ... check with the following commands
      $bg  If not in dir 'schedulePlus3/' change it with:  $e0
      $bw    $ cd $xDIR/schedulePlus3            $e0

        $  service piSchedule status
        $  ./piPrefs.py
        $  ps ax|grep piSchedule

      ... see also 'schedulePlus3' log-files:
        $  cat logs/piInfo.log
        $  cat logs/piSystem.log

      $bw With valid results  'piSchedule'  will start.    $e0
      $bw Startup needs a minute, so wait a little before  $e0
      $bw opening 'piSchedule in the browser with:         $e0

      $ba Press Cntrl and mouse point to this link         $e0
               $bb http://$addr:$port $e0
      $ba 'piSchedule' shows up in your browser  $bg Enjoy ;) $e0
          (Eventually you have to reload the page)

    "
   sudo service piSchedule start
   #sudo service piSchedule status

}


function shatest()
{
   s1=$(cat $ZIPP | sha256sum | head -c 64)
   s2=$(wget  -qO- https://neandr.github.io/piSchedule/$ZIPP.sha)
   echo -e "   !!!  ZIP Datei SHA256 Check\n"\
   "    abgerufene Datei  : $s1"
   echo -e ""\
   "    Prüfsumme auf GIT : $s2"
   if [[ ! $s1 == $s2 ]] ; then
      echo "$br  ZIP Fehler! Checksum nicht übereinstimmend! $e0"
      exit 1
   fi
}


#==============================================

function zipdocs()
{
   wget  https://api.github.com/repos/neandr/piSchedule/contents 2>wget.log
   mv contents gitdocs.txt
   Z=$(cat gitdocs.txt |  sed -n '/"path": "docs",/{n;p;}' | sed -e 's/"sha":/ /;s/,//' | xargs )

   X="https://api.github.com/repos/neandr/piSchedule/git/trees/"$Z
   wget $X 2>>wget.log   # saves to a file named $Z

   # echo "current $Z" #| 2>>wget.log

   mv $Z gitdocs.txt
   cat gitdocs.txt | egrep zip.sha | egrep Plus3 |  sed -e 's/"path"://g;s/[,"]//g;s/.sha//g' > zips.txt
   rm gitdocs.txt

   n=0
   zips=();
   while IFS= read -r line; do
      line0=$(echo $line | xargs )
      echo "       $n : [$line0]"
      ((n=n+1))
      zips+=("$line0")
   done < zips.txt
   rm zips.txt

   read -n 1 -p "      $ba Auswahl für die Installation ?   $e0" No ;

   if [[ $No == ?(-)+([0-9]) && ${zips[$No]} ]] ; then
         ZIPP=$(echo ${zips[$No]} | tr -d ' ')
   else
      echo -e "$br No ZIP selected. Terminating! $e0"
      exit 1
   fi

   echo -e  "\n   ---  ZIP für die Installation:  '$ZIPP'"

   if [ -f $ZIPP ] ; then
     echo -e "      $ba $ZIPP already exists! $e0"
   else
      #echo "  wget  the zip "
      wget https://neandr.github.io/piSchedule/$ZIPP 2>>wget.log
   fi
   shatest
}


function unzip_2_tmp()
{  # --- deflate the requested $ZIPP to a tmp directory ---
   if [ -d tmp/ ] ;  then
      echo -e "!!! ---  '/tmp already exists!"

      read -n 1 -p "*** ---  Overwrite  Y/n? " Qa ;
      echo -e  "\n"
       if [[ ! $Qa == 'Y'  ]] ; then
          echo -e  "\n"
          exit 101
       fi

      rm -R tmp/
   fi

   echo -e "    --- unzipp '$ZIPP' to tmp/ directory "
   unzip -o $ZIPP -d tmp/

 exit 0
}

#==============================================

   # Check not to operate on 'schedulePlus3' directory,
   # should work on it's parent directory!
   if [[ $currentDIR == 'schedulePlus3' ]] ; then
      echo -e "\n!!! ---  Current dir is 'schedulePlus3'"
      echo -e   "!!! ---  Script should not excecuted here!\n"
      exit 1
   fi

   while (( "$#" )); do
     case "$1" in

      --help)
         echo "$H$A"; exit 0
         ;;

      --Z)
         zipdocs
         shift 1
         ;;

      -l|--libs)
         echo "   ... Bibliotheken laden (Python, Bottle etc ..) ";
         cmd=LibsLoad; shift 1
         ;;

      -i|--install)
         zipdocs
         echo "   ... System installieren mit $ZIPP"
         cmd=SystemInstall; shift 1
         ;;

      -c|--configure)
         echo "   ... System konfigurieren";
         #zipdocs
         cmd=SystemConfigure; shift 1
         ;;

      -a|--all)
         echo "   ... Alles ausführen";
         zipdocs
         LibsLoad
         SystemInstall
         SystemConfigure
         exit 0
         ;;

      --zipdocs)
         zipdocs
         exit 0
         ;;
      *)
         echo "$A"; exit 0
         ;;

     esac
   done
   echo "   ... Aufruf '$cmd' mit ZIP '$ZIPP'"
   $cmd
   rm wget.log 2>/dev/null
   exit 0
