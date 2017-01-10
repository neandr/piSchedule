#!/usr/bin/env python
# -*- coding: utf-8 -*-

#  /cVersion/06-09-08_15/


import sys, traceback, json, os

xColor = '32'

prefs = {}

'''
  Checking installed 'pilight' version 
    prefs['pilightVersion']  :: the current installed pilight version
    prefs['pilightExpected'] :: describes the expected pilight version

    The nightly has the same base version but an subversion added. E.g.:
    Stable: 7.0
    Nightly: 7.0-1-gadue123 
'''

prefs['version'] = "0.7.5.1"
prefs['pilightVersion'] = ''
prefs['pilightExpected'] = '7.0'

prefs['pilightPort'] = 0
prefs['ssdp'] = ''

prefs['server'] = ''
prefs['port'] = ''

# point to GITHUB --------------
prefs['piDBox'] = "https://neandr.github.io/piSchedule/"
prefs['piScheduleDoc'] = ""

prefs['piDocs'] = prefs['piDBox']

prefs['news'] = prefs['piDocs'] + 'news751.txt'


# point to local installation of  piSchedule ------------
prefs['piScheduleHome'] = str(os.getcwd())          #  "/home/pi/piSchedule751",

logInfoName = prefs['piScheduleHome'] + "/logs/piInfo.log"
logSysName =  prefs['piScheduleHome'] + "/logs/piSystem.log"
prefsJSONfile =  prefs['piScheduleHome'] + '/piSchedule.prefs.json'


# users data ---------------------
prefs['locale'] = 'EN'
prefs['location'] = 'Kassel'
prefs['latitude'] = '51.2558'
prefs['longitude'] = '6.9705'

prefs['sunset'] = '2015-07-16 21:00:30.00000'
prefs['sunrise'] = '2015-07-16 05:00:04.00000'

prefs['switchTime'] = 0

prefs['iniFile'] = 'newDaySchedule.ini'
prefs['weekSchedule'] = {}
prefs['newsDate'] = ''


piPortDelta = 4

def main():
    global prefsJSONfile, piPortDelta
    xprefs= {}

    status = 0
    info = ""
    try:
        with open(prefsJSONfile) as data_file:
           xprefs = json.load(data_file)
    except:
        status = 1
        info = " ** piSchedule prefs:  defaults loaded."

    if ('port' not in xprefs) and ('pilightPort' in xprefs):
        cPort = int(prefs['pilightPort'])+ piPortDelta            #<<<<<<<<<< port number setting
        xprefs['port'] = cPort


    for p in prefs:
        if p not in xprefs:
            xprefs[p] = prefs[p]

    if ('ssdp' in xprefs) and (xprefs['ssdp']) != "OK": xprefs['status'] = 2

    # write updated prefs file 
    f = open(prefsJSONfile, 'w')
    f.write(json.dumps(xprefs))
    f.close()
    return info, xprefs

#-------------------------------------------
if __name__ == '__main__':

    info, prefs =  main()

    list = (json.dumps(prefs, sort_keys=True, indent=0).decode('unicode_escape')).split("\n")
    lenList = len(list)
    n = 0
    pinfo = ""
    while n < lenList:
        #print (n, listLn, list[n])
        cList = list[n].replace(',', ' ').split(": ")
        if len(cList) > 1:
            pinfo += ("\n     {item:18s} : {value:12s} ".format(item=cList[0], value=cList[1])).replace('"','')
        n= n+1

    xinfo = " ** piSchedule prefs ** " + pinfo
    if ('server' in prefs) and ('port' in prefs): info += "\n ** piSchedule  {server}:{port} " + prefs['server'] +':' + str(prefs['port'])
    if ('ssdp' in prefs): info += " >>" + prefs['ssdp'] + "<<" 
    if ('status' in prefs): info += "\n ** piSchedule.prefs  status:" + str(prefs['status'])
    xinfo += "\n" + info
    print(xinfo)

    if prefs['ssdp'] != "OK":
        print ("\n ** NO 'ssdp' connection! ")
        sys.exit (prefs['ssdp'])


    sys.exit (prefs['status'])

