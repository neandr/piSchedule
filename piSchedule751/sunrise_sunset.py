#!/usr/bin/env python
# -*- coding: utf-8 -*-

#  /cVersion/06-03-29_1726/

import calendar, time, datetime
from math import cos, sin, acos as arccos, asin as arcsin, tan as tg, degrees, radians
import sys, json

def mod(a,b):
   return a % b


def isLeapYear(year):
   return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0


def getHHMMSS(h):
    hh = int(h)
    mm = (h - hh) * 60
    ss = int(0.5 + (mm - int(mm)) * 60)
    return "{0:02d}:{1:02d}:{2:02d}" . format(hh, int(mm), ss)


def getDayNumber(year, month, day):
    cnt = 0
    for t in range(1900,year):
        if isLeapYear(t):
            cnt += 366
        else:
            cnt += 365

    for t in range(1,month):
        cnt += calendar.monthrange(year, t)[1]

    return cnt + day + 1


def getSunrise_Sunset(lat, lon):
    year = datetime.datetime.now().year
    month = datetime.datetime.now().month
    day = datetime.datetime.now().day

    dst = time.localtime().tm_isdst

    if dst == 0:
       offset = -time.timezone/60
    else:
       offset = -time.altzone/60

    localtime = 12.00
    b2 = float(lat)
    b3 = float(lon)
    b4 = dst
    b5 = localtime / 24
    b6 = year
    d30 = getDayNumber(year, month, day)
    e30 = b5
    f30 = d30 + 2415018.5 + e30 - b4 / 24
    g30 = (f30 - 2451545) / 36525
    q30 = 23 + (26 + ((21.448 - g30 * (46.815 + g30 * (0.00059 - g30 * 0.001813)))) / 60) / 60
    r30 = q30 + 0.00256 * cos(radians(125.04 - 1934.136 * g30))
    j30 = 357.52911 + g30 * (35999.05029 - 0.0001537 * g30)
    k30 = 0.016708634 - g30 * (0.000042037 + 0.0000001267 * g30)
    l30 = sin(radians(j30)) * (1.914602 - g30 * (0.004817 + 0.000014 * g30)) + sin(radians(2 * j30)) * (0.019993 - 0.000101 * g30) + sin(radians(3 * j30)) * 0.000289
    i30 = mod(280.46646 + g30 * (36000.76983 + g30 * 0.0003032), 360)
    m30 = i30 + l30
    p30 = m30 - 0.00569 - 0.00478 * sin(radians(125.04 - 1934.136 * g30))
    t30 = degrees(arcsin(sin(radians(r30)) * sin(radians(p30))))
    u30 = tg(radians(r30 / 2)) * tg(radians(r30 / 2))
    v30 = 4 * degrees(u30 * sin(2 * radians(i30)) - 2 * k30 * sin(radians(j30)) + 4 * k30 * u30 * sin(radians(j30)) * cos(2 * radians(i30)) - 0.5 * u30 * u30 * sin(4 * radians(i30)) - 1.25 * k30 * k30 * sin(2 * radians(j30)))
    w30 = degrees(arccos(cos(radians(90.833)) / (cos(radians(b2)) * cos(radians(t30))) - tg(radians(b2)) * tg(radians(t30))))
    x30 = (720 - 4 * b3 - v30 +  offset) / 1440
    x30 = (720 - 4 * b3 - v30 +  offset) / 1440
    y30 = (x30 * 1440 - w30 * 4) / 1440
    z30 = (x30 * 1440 + w30 * 4) / 1440
    sunrise = y30 * 24
    sunset = z30 * 24
    status = 0

    tDate = "{0:04d}-{1:02d}-{2:02d} " . format(year, month, day)
    sr = tDate + getHHMMSS(sunrise)
    ss = tDate + getHHMMSS(sunset)

    return {'sunrise': sr, 'sunset': ss, 'status': status}


#---------------------------------
if __name__ == "__main__":
    if (len(sys.argv) != 3)  or (sys.argv[1] == "--help"):
        print (""" Get Sunrise and Sunset time values - Python module
    sunrise_sunset.py [arguments]  Returns for given latitude/longitude and 
       a selected date the time values for sunrise and sunset.
       Day light saving (DST) will be respected for the requested date.
       Use --help argument to get help listing
    
    arguments: 
        lat = latitude
        lon = longitude 

    return:  json format with {'sunrise': HHMMSS, 'sunset':HHMMSS, 'status': statusNum}
        statusNum:   0 = OK
                    -1 = date parameter missing, need [year month day]
                    -2 = wrong date parameter
    Based on
          http://www.srrb.noaa.gov/highlights/sunrise/calcdetails.html
          http://michelanders.blogspot.de/2010/12/calulating-sunrise-and-sunset-in-python.html
    """)
        if sys.argv[1] == "--help":
            exit()

    status = 0

    lat = float(sys.argv[1])   #51.2558   
    lon = float(sys.argv[2])   #6.9705    


    rv = getSunrise_Sunset(lat, lon)
    print(json.dumps(rv, sort_keys=True, indent=3).decode('unicode_escape'))

    rv = getSunrise_Sunset(lat, lon)

