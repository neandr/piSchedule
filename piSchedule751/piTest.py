#!/usr/bin/env python
# -*- coding: utf-8 -*-

# /cVersion/16-02-02_16/

xColor = '34'

import socket
import struct
import re
import json



def piDiscover(service, timeout=2, retries=1):
#---------------------------------
    global xP
    try:
        prefsFile = open(xP.prefsJSONfile, 'r')
        fPrefs = json.loads(prefsFile.read())
    except:
        fPrefs = {}

    group = ("239.255.255.250", 1900)
    message = "\r\n".join([
        'M-SEARCH * HTTP/1.1',
        'HOST: {0}:{1}'.format(*group),
        'MAN: "ssdp:discover"',
        'ST: {st}','MX: 3','',''])

    responses = {}

    try:
        server =  str(fPrefs['server'])
    except:
        server = ""
    port = ''
    error = 'OK'

    i = 0;
    for _ in range(retries):
        i += 1
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVTIMEO, struct.pack('LL', 0, 10000));
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
        sock.sendto(message.format(st=service), group)
        while True:
            try:
                responses[i] = sock.recv(1024);
                break;
            except socket.timeout:
                error = 'timeout'
                break;
            except:
                error = 'no pilight ssdp connections found'
                break;

    r = responses.values()

    print(str(responses))

    if len(r) > 0:
       locationsrc = re.search('Location:([0-9.]+):(.*)', str(r[0]), re.IGNORECASE)
       if locationsrc:
           server = locationsrc.group(1).strip()
           port = locationsrc.group(2).strip()


    configFile = '/etc/pilight/config.json'
    piPrefs = {}
    try:
        prefsFile = open(configFile, 'r')
        piPrefs = json.loads(prefsFile.read())

        if  'webserver-http-port' in piPrefs['settings']:
            port = piPrefs['settings']['webserver-http-port']
        if  'webserver-port' in piPrefs['settings']:
            port = piPrefs['settings']['webserver-port']

    except:
        logERR(True)    # will terminate / quiet

    pilightVersion = str(piPrefs['registry']['pilight']['version']['current'])

    rv = [server, port, pilightVersion, error]

    #print (" ** piDiscover  pilight (v." + version + ") **\n" 
    #       + (str(responses)).replace("\\x00","").replace("\\r\\n","\n"))

    logInfo (" ** piDiscover  pilight " + str(rv), xColor)
    logSys  (" ** piDiscover  pilight " + str(rv), xColor)

    return rv


if __name__ == "__main__":
    responses = piDiscover("urn:schemas-upnp-org:service:pilight:1");
    print(" ** piDiscover pilight " + str(responses))
