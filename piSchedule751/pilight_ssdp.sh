#!/bin/bash
cd ~

set_pilight () 
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
         sudo service pilight restart
         echo -e "    ...  NOTE   'pilight' was restarted with using 'pilight.conf'."
      fi
   }

echo -e "
    ***     pilight - 'ssdp' special setup     ***
    "

set_pilight

echo -e "
    ***               DONE                     ***
    "

exit 0

