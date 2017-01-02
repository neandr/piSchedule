#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

# /cVersion/16-02-12_16/ 

from urllib2 import urlopen
from contextlib import closing
import urllib
import json
import sys

#import ephem 
import sunrise_sunset 
from datetime import date
from datetime import datetime

import piLog
from piLog import logInfo, logERR, logSys

color = '34'

GEOCODE_BASE_URL = 'https://maps.googleapis.com/maps/api/geocode/json'
IP_BASE_URL = 'http://ip-api.com/json/'


# Automatically geolocate the connecting IP 
def ipApi():
    gPrefs = {}

    with closing(urlopen(IP_BASE_URL)) as response:
        rv = json.loads(response.read())

        if (type(rv) is dict):

            if rv['status'] != 'success':
                gPrefs['status'] = "ipApi 'no success': " + rv['status']
                return gPrefs

            gPrefs['location'] = str(rv['city'].encode('utf-8'))
            gPrefs['longitude'] = str(rv['lon'])
            gPrefs['latitude'] = str(rv['lat'])
            gPrefs['locale'] = str(rv['countryCode'])
            gPrefs['geo'] = 'ip'
            gPrefs['status'] = response.getcode()

        else:
            gPrefs['status'] = " --- piGeoDetails (ip) failed to deliver location of IP used with HTTP RC %s" % (response.getcode())

        return gPrefs


# Geolocation via Google
def gMapsApi(address, **geo_args):
    geo_args.update({
        'address': address
    })

    gPrefs = {}

    if (address == ""):
        gPrefs["status"] = "  *** piGeoDetails 'gmaps' needs a location string!"
        return gPrefs


    url = GEOCODE_BASE_URL + '?' + urllib.urlencode(geo_args)

    with closing(urlopen(url)) as response:
        rv = json.loads(response.read())
        #logInfo("\n" + str(rv).replace("u'", "'"))
        logSys("\n" + str(rv).encode('utf-8').replace("u'", "'"))

        '''
        #19498 19:13:01 - piGeoDetails gMapsApi #69    
        {'status': 'ZERO_RESULTS', 'results': []}
        '''

        if (type(rv) is dict):
            status = rv['status']
            if status != "OK":
                gPrefs['status'] = (" *** Request failed  for %s with %s. (HTTP code  %s)" % (str(geo_args), status, response.getcode()))
                gPrefs['location'] = 'Location :: ' + str(status)
                return gPrefs

            gPrefs['latitude'] = rv['results'][0]['geometry']['location']['lat']
            gPrefs['longitude'] = rv['results'][0]['geometry']['location']['lng']

            gPrefs['address'] = rv['results'][0]['formatted_address'].encode('utf-8')

            for s in rv['results'][0]['address_components']:
                for d in s:
                    if s[d][0] == 'locality':
                        #gPrefs ["location"] = s['short_name']
                        gPrefs ["location"] = s['long_name'].encode('utf-8')

                    if s[d][0] == 'country':
                        gPrefs ["locale"] = s['short_name'].encode('utf-8')

            gPrefs['geo'] = 'gmaps'
            gPrefs['status'] = response.getcode() #"200"

        else:
            #&&---- print ("  *** piGeoDetails (gmaps) failed to deliver location for >>%s<<" % (str(address)))
            gPrefs['status'] = " *** gmaps ERROR ***"

        return gPrefs


def geoPrefs(xPrefs):

    info = " ** Geolocation details."

    cLocation = ""
    if 'location' in xPrefs:
        cLocation = xPrefs['location'].encode('utf-8')

    rv = {}
    if 'geo' not in xPrefs:
        xPrefs['geo'] = 'ip'

    if xPrefs['geo'] == 'fix':
            rv['latitude'] = xPrefs['latitude']
            rv['longitude'] = xPrefs['longitude']
            info += "  GeoCoordinates fixed!"

    if (xPrefs['geo']  == "-ip") or (xPrefs['geo']  == "ip"):
        rv = ipApi()

        # testing purpose only
        #print ("ipApi " + str(rv))
        #rv['location'] = ""
        #rv = {}

        if (('location' in rv) == False) or (rv['location'] == ""):
            #logInfo("  *** piGeoDetails (ip) failed, try (gmaps) *** \n", '31') # red
            logSys("  *** piGeoDetails (ip) failed, try (gmaps) *** \n", '31') # red
            xPrefs['geo'] = "-gmaps"


    if (xPrefs['geo'] == "-gmaps") or (xPrefs['geo'] == "gmaps"):
        rv = gMapsApi(cLocation)
        logSys(" geo gmaps status: " + str(rv['status']))

        if rv['status'] != 200:
            return rv

    rvS =  sunrise_sunset.getSunrise_Sunset(rv['latitude'], rv['longitude']) 

    rv['sunset'] = rvS['sunset']
    rv['sunrise'] = rvS['sunrise']
    rv['status'] = rvS['status']

    #print(" ***&&&  GeoDetails: " + str(rv))
    return rv


def ini():
   return


def main():
    #if len(sys.argv) == 1:
    #    return      # Initialized only

    try:
        calling = sys.argv[1]
    except:
        calling = "-ip"

    if (calling == "-help"):
        print ("""  --- piGeoDetails Help
    piGeoDetails returns the geolocation (city, locale code, latitude, longitude)
    based on the current IP or a given location. 
    Call:   piGeoDetails.py [argument] 
      arguments are:
        -ip     uses IP based search
        -gmaps  uses Google Maps, needs location data 
        -help

    Note:
        With using IP based search (-ip) and the return string for 'city' is empty,
        an alternative Google Maps search will run if the 'location' was 
        passed also.
    """)
        exit()


    location = ""
    if (len(sys.argv) == 3):
        location = (sys.argv[2]).encode('utf-8')   # address="San+Francisco"

    rv = geoPrefs(calling, location)

    if rv['status'] != 200:
        logInfo (json.dumps(rv, sort_keys=True, indent=3).decode('unicode_escape'), color)
    else:
        logSys (json.dumps(rv, sort_keys=True, indent=3).decode('unicode_escape'), color)

    return rv

#---------------------------------
if __name__ == "__main__":

    rv = main()
    print(json.dumps(rv, sort_keys=True, indent=3).decode('unicode_escape'))
