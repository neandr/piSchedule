#!/usr/bin/env python
# -*- coding: utf-8 -*-

''' 
    Copyright (C) 2015 gWahl
'''
#  /cVersion/06-09-10/     2016-12-31_1457

piPortDelta = 4         # sets the piSchedulePort to pilightPort + piPortDelta

import platform, logging, os, sys, re, signal, shutil  #, traceback

from bottle import Bottle, run, route, static_file, view, template, \
                   get, post, request, debug


import urllib2

import datetime
from datetime import date
from datetime import datetime
from datetime import timedelta

import time
from time import sleep
from dateutil import parser

import json, random, glob

import sunrise_sunset

from apscheduler.schedulers.background import BackgroundScheduler

sDIR = os.getcwd()

import piPrefs
xP = piPrefs

import piLog
from piLog import logInfo, logERR, logSys

import piGeoDetails
import piDiscover

import piStrings
xS = piStrings.piString()


app = Bottle()
app.install(piLog.logBottle)

sched = BackgroundScheduler()


#===========================================
def prefsRead():
    pass
    try:
        global xP

        with open(xP.prefsJSONfile) as data_file:
            xP.prefs = json.load(data_file)

    except:
        xP.prefs['ssdp'] = " ** NO 'ssdp' connection!"
        xP.prefs['status'] = 9


def prefsSaveJSON(aName, aPref):
    global xP

    try:
        # write a bak copy of current prefs
        f = open((xP.prefsJSONfile + '.bak'), 'w')
        f.write(json.dumps(xP.prefs))
        f.close()
    except:
        pass

    if aPref != None:
        xP.prefs[aName] = aPref

    # write new prefs file 
    f = open(xP.prefsJSONfile, 'w')
    f.write(json.dumps( xP.prefs))
    f.close()


def prefsSetup():
    #try:  
        global xP, piPortDelta
        global cVersion

        cLocale = "EN"
        if 'locale' in xP.prefs:
            if xP.prefs['locale'] != '':
                cLocale = xP.prefs['locale']

        geoprefs = piGeoDetails.geoPrefs(xP.prefs)

        for p in geoprefs:
            xP.prefs[p] = geoprefs[p]


        xP.prefs['locale'] = cLocale
        piStrings.lang = xP.prefs['locale']

        if (type(xP.prefs) is dict): 
            pass
        else:
            xP.prefs['longitude'] = ""
            logInfo(" +++  pilight/piSchedule 'prefs': \033[1m " + xS("piSchedule.noGeoCordinates") + "\033[0m")

        responses = piDiscover.piDiscover("urn:schemas-upnp-org:service:pilight:1");

        xP.prefs['server'] = responses[0]
        xP.prefs['pilightPort'] = responses[1]
        xP.prefs['pilightVersion'] = responses[2]
        xP.prefs['ssdp'] = responses[3]


        if piPortDelta < 2:
            piPortDelta = 4
        cPort = int(xP.prefs['pilightPort'])+ piPortDelta            #<<<<<<<<<< port number setting
        xP.prefs['port'] = cPort

        prefsSaveJSON(None, None)

        return (xP.prefs)

    #except:
    #    logERR(True)


def suntime():
#---------------------------------
#  support Sunrise/Sunset with time values
#  time is calculated for actual day!

    if ('latitude' in xP.prefs) and ('longitude' in xP.prefs):

        rvS = sunrise_sunset.getSunrise_Sunset(xP.prefs['latitude'], xP.prefs['longitude'])
        xP.prefs['sunrise'] = rvS['sunrise']
        xP.prefs['sunset'] = rvS['sunset']

        logSys("&&  check suntime   sunrise:  " + str(xP.prefs['sunrise']))
        logSys("&&  check suntime   sunset:  " + str(xP.prefs['sunset']))

        prefsSaveJSON(None, None)

    else:
         pass


def fire_pilight(arg):
#---------------------------------
    global xP

    message = arg['message']
    info = arg['info']

    url = ('http://' + xP.prefs['server'] + ':' + str(xP.prefs['pilightPort']) + message)

    request = urllib2.Request(url)
    response = urllib2.urlopen(request)

    logSys ("url " + url)
    logInfo ("\n    " + "\033[1m" + "pilight control >" + info + "<" + "\033[0m")
    log2DayFile(False, info)


#===========================================
# support loading of js/ccs with tpl/html pages
@app.route('/static/<filename>')
def server_static(filename):
    return static_file(filename, root= sDIR + '/static')


@app.route('/home')
def home():
    qString = request.query_string.strip()
    logSys("/home  >>" + qString + "<<")  #

    # build 'ini' file menu
    fileList = iniFileMenu('edit')
    fileList += "</li><li role='presentation'><a href='/edit?newSchedule'>" + xS('piMain.newSchedule') + "</a></li>"

    fileList1 = iniFileMenu1('weekScheduleSet')

    rv = combineKeys(xP.prefs, {'pilight':'http://'+xP.prefs['server']+':'+ str(xP.prefs['pilightPort']),

        'Monday': xS("piLogs.Monday"), 'schedule1': getSchedule4Day('Monday'),
        'Tuesday': xS("piLogs.Tuesday"), 'schedule2': getSchedule4Day('Tuesday'),
        'Wednesday': xS("piLogs.Wednesday"), 'schedule3': getSchedule4Day('Wednesday'),
        'Thursday': xS("piLogs.Thursday"), 'schedule4': getSchedule4Day('Thursday'),
        'Friday': xS("piLogs.Friday"), 'schedule5': getSchedule4Day('Friday'),
        'Saturday': xS("piLogs.Saturday"), 'schedule6': getSchedule4Day('Saturday'),
        'Sunday': xS("piLogs.Sunday"), 'schedule0': getSchedule4Day('Sunday')
    })

    page = templateSetup('piMain', rv)
    page = page.replace('&&iniFileList&&',fileList)
    page = page.replace('&&iniFileList1&&',fileList1)

    return page.replace('&&localeList&&',localesMenu())


def getSchedule4Day(day):
    if 'weekSchedule' in xP.prefs:
        weekSchedule = xP.prefs['weekSchedule']
        if day in weekSchedule:
            return weekSchedule[day]

    return "--"


@app.route('/logs')
def logList():
    qString = request.query_string.strip()
    logSys("/logs  >>" + qString + "<<")  #

    selectedDay =  qString.strip()

    now = datetime.now()
    today = now.strftime("%A")
    if selectedDay == "":
        selectedDay = today

    fLog = logFile(selectedDay)


    output = []

    try:
        logss = open(fLog, 'r')

        for line in logss:
          output.append('<li>' + line.replace("\n","") + '</li>')

        output.sort(reverse=True)

        output = '<ul>' + str(output) + '</ul>'
        output = str(output).replace("', '","").replace("']","").replace("['","")

    except:
       msg = " +++  " + xS("piMain.piLogFile") + " "+ fLog + " " + xS("piSchedule.notFound")
       logSys(msg)

    rv = {'logList':output,  'today':today}

    page = templateSetup('piLogs', rv)
    return page.replace("&&currentDay&&",xS("piLogs."+selectedDay))


def renewSchedule():
    if 'iniFile' in xP.prefs:

        daySchedule = getWeekDaySchedule()
        if daySchedule != "--":
            xP.prefs['iniFile'] = daySchedule

        aSchedule = xP.prefs['iniFile']

        sched.remove_all_jobs()

        log2DayFile(True, 'renew Schedule')

        xP.switchTime = datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)+  timedelta(hours=24)

        suntime()
        jobLines = jobsRead(aSchedule)
        jobs2Schedule(jobLines)

        tab = scheduleActive()

        cJob = sched.add_job(renewSchedule, 'date', run_date=str(xP.switchTime), id="renew")

        msg = " renew Schedule  next Switch Time   " + str(xP.switchTime)[:19]
        print(msg)
        log2DayFile(True, msg)
        prefsSaveJSON(None, None)

    else:
        pass
        logERR(False)


@app.route('/weekdaySchedule')
def getWeekDaySchedule():
    weekSchedule = {}
    newSchedule = "--"
    if 'weekSchedule' in xP.prefs:
        weekSchedule = xP.prefs['weekSchedule']
        currentDay = (datetime.now().strftime("%A"))
        logSys(" weekday schedule currentDay >>" + currentDay + "<<")

        if currentDay in weekSchedule:
            newSchedule = weekSchedule[currentDay]

            logSys(" weekday schedule newSchedule >>" + newSchedule + "<<")

            #check if file for 'newSchedule' exists
            try:
                dummy = open(newSchedule, 'r')
            except:
                newSchedule = "--"


    logSys(" weekday schedule is >>" + newSchedule + "<<")
    return newSchedule


@app.route('/updateWeekdaySchedule')
def updateWeekdaySchedule():
    qString = request.query_string.strip(' ,')

    schedules = qString.split(',')
    logSys("/setWeekdaySchedule  >>" + str(schedules) + "<<")
    wDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

    for day in range(0,7):
        xP.prefs['weekSchedule'][wDays[day]] = schedules[day]
    prefsSaveJSON(None, None)


@app.route('/schedule')
def getSchedule():

    caller = request.fullpath[1:]
    if caller != 'schedule':
        qString = ""
    else:
        qString = request.query_string.strip()

    logSys("/schedule  >>" + qString + "<<")

    sched.remove_all_jobs()

    if qString != "":
        aSchedule = qString
    else:
        aSchedule = "Select INI "
        if 'iniFile' in xP.prefs:
            aSchedule = xP.prefs['iniFile']

            renew = True

    xP.switchTime = datetime.now().replace(hour=0,minute=0,second=0,microsecond=0) + timedelta(hours=24)
    #log2DayFile(False, ' .. activated Schedule  .. ' + str(xP.switchTime))

    prefsSaveJSON('iniFile', aSchedule)

    jobLines = jobsRead(aSchedule)
    jobs2Schedule(jobLines)

    cJob = sched.add_job(renewSchedule, 'date', run_date=str(xP.switchTime), id="renew")

    tab = scheduleActive()

    msg = " next SwitchTime  :: " + str(xP.switchTime)
    #print("activated Schedule " + msg)
    #log2DayFile(False, msg)

    fileList = iniFileMenu('schedule')

    newsSchedule, newsStatus, newsDate = getNews(xP.prefs)
    if newsDate != "":
        xP.prefs['newsDate'] = newsDate

    rv = combineKeys(xP.prefs, {'pilight':'http://'+xP.prefs['server']+':'+ str(xP.prefs['pilightPort']),
        'newsDisplay': newsStatus})

    page = templateSetup('piSchedule', rv)
    page = page.replace('&&iniFileList&&',fileList)

    hString = str(datetime.now())[:19]
    page = page.replace('&&datetime&&', hString) 
    page = page.replace('&&timeTable&&', tab)

    page = page.replace('&&newsDate&&', newsDate)
    return page.replace('&&news&&', newsSchedule)


@app.route('/removeJob')
def removeJob():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>" + qString + "<<")

    try :
       sched.remove_job(qString)
    except:
       logInfo("Job may have been removed already")

    page = refreshSchedule()
    return page   #.replace('&&language&&', piStrings.getLocale())


@app.route('/reload')
@app.route('/')
@app.route('/refresh')
def refreshSchedule():
    global xP
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>" + qString + "<<")

    tab = scheduleActive()

    fileList = iniFileMenu('schedule')

    newsSchedule, newsStatus, newsDate = getNews(xP.prefs)
    if newsDate != "":
        xP.prefs['newsDate'] = newsDate

    rv = combineKeys(xP.prefs, {'pilight':'http://'+xP.prefs['server']+':'+ str(xP.prefs['pilightPort']),
        'newsDisplay': newsStatus})

    page = templateSetup('piSchedule', rv)

    page = page.replace('&&iniFileList&&',fileList)

    hString = str(datetime.now())[:19]
    page = page.replace('&&datetime&&', hString) 
    page = page.replace('&&timeTable&&', tab)

    page = page.replace('&&newsDate&&', newsDate)
    return page.replace('&&news&&', newsSchedule)


@app.route('/edit')
def edit():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>" + qString + "<<")

    page = templateSetup('piEdit', xP.prefs)

    addJob = False
    fileName  = request.query_string
    if fileName == 'addJob':
       addJob = True

    # build the html list of devices
    devices = pilightConfig('devices')

    #<a role="menuitem" onclick="changeDevice(this)">Haustuer</a>
    deviceList = ""
    for d in devices:
       deviceList += '<a role="menuitem" onclick="changeDevice(this)">'+d+'</a>'

    page = page.replace('&&deviceList&&', deviceList)

    # replace date/time string
    hString = str(datetime.now())[:19]
    page = page.replace('&&datetime&&', hString)


    if addJob == True:
        page = page.replace('&&JOBS&&',"")
        page = page.replace('&&FILE&&',"")

        page = page.replace('&&jobDefEdit&&','display:none')
        page = page.replace('&&jobDefExec&&','display:block')

        page = page.replace('&&displaySchedule&&','display:none')

        page = page.replace('&&jobAdd&&','display:none')
        page = page.replace('&&jobExec&&','display:block')

    else:
        page = page.replace('&&jobDefEdit&&','display:block')
        page = page.replace('&&jobDefExec&&','display:none')

        page = page.replace('&&displaySchedule&&','display:block')

        page = page.replace('&&jobAdd&&','display:block')
        page = page.replace('&&jobExec&&','display:none')


        #  newSchedule
        if fileName == 'newSchedule':
            fileName = 'newDaySchedule.ini'
            f = open(fileName, 'w')
            f.write(' * Define new Schedule')
            f.close()

        if fileName == "" or fileName == None:
            fileName = 'piSchedule.ini'

        # read the selected 'ini' file to textbox
        jobFile = jobsReadFile(fileName, setName=False)

        #logSys("\n$$\n" + str(jobFile) + "\n$$\n")

        jobList = ""
        for line in jobFile:
            jobList = jobList + '<option>' + line +'</option>'

        page = page.replace('&&JOBS&&',str(jobList))

        # set the 'ini' file name  
        page = page.replace('&&FILE&&',str(fileName))

    return (page)


@app.route('/fRead')
def iniRead():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>" + qString + "<<")

    jobLines = jobsRead(qString)
    jobs2Schedule(jobLines)

    output = '<table class="table table-striped table-bordered"><tbody>'
    for job in aJobs:
        #logSys("out: " + str(job))
        if job != []:
            output += "<tr><td> " + str(job[0]) + "</td><td> " + str(job[1]) + "</td><td> " + str(job[2]) + "</td></tr> "

    output += '</tbody></table>'

    return output


@app.route('/fSave')
def fSave():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>\n" + str(qString) + "\n<<")

    qString = json.loads(urllib2.unquote(qString))

    fName = qString[0]['fName']     #file name
    pName = qString[1]['pName']     #placeholder file name
    if fName == "":
      fName = pName

    iniFiles =  glob.glob("*.ini")
    fileList = ""
    for x in iniFiles:
       if fName == x:
           shutil.copy2(fName, fName + '.bak')
           logSys(" Make .bak Copy of >>" +fName + "<<")

    xjobs = qString[2]['jobs'].replace('|','\n')

    f = open(fName, 'w')
    f.write(xjobs)
    f.close()


@app.get('/fDelete')
def xDelete():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>\n" + str(qString) + "\n<<")

    qString = json.loads(urllib2.unquote(qString))

    fName = qString[0]['fName']     #file name
    pName = qString[1]['pName']     #placeholder file name

    if fName == "":
       fName = pName
    os.remove(fName)


#-------------------------------------------
@app.route("/removeJobs")
def removeJobs():
    #logSys("&& removeJobs" + str(sched.get_jobs()))

    sched.remove_all_jobs()
    return home()


@app.route('/timeline')
def timelineSchedule():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>\n" + str(qString) + "\n<<")


    rv = combineKeys(xP.prefs, 
        {'editJob': xS("piEdit.editJob"),
        'editJobs': xS("piEdit.editJobs"),
        'edit': xS("piEdit.edit"),
        'insert': xS("piEdit.insert"),
        'delete': xS("piEdit.delete"),
        'change': xS("piEdit.change"),
        'close': xS("piEdit.close"),
        'changeRow': xS("piEdit.changeRow"),
        'insertRow': xS("piEdit.insertRow"),
        'help': xS("piEdit.help"),
        'toggleHelp': xS("piEdit.toggleHelp"),
        'advanceEditHelp': xS("piEdit.advanceEditHelp"),
        'timelineEditHelp': xS("piEdit.timelineEditHelp"),
        'legend': xS("piEdit.legend"),

        'scheduleFile': xS("piEdit.scheduleFile")})

    page = templateSetup('piTimeLine', rv)


    fileName = xP.prefs['iniFile']
    jobsList = jobsRead(fileName)

    jobs = ""
    nJ = len(jobsList)

    ni=0
    while ni < nJ:
        if jobsList[ni] != "\n":
            jobs += jobsList[ni] +  "||"
        ni += 1

    page = page.replace('&&FILE&&',str(fileName))
    page = page.replace("&&jobLines&&", jobs.replace("\n",""))


    # build the html list of devices
    #<a role="menuitem" onclick="changeDevice(this)">Haustuer</a>
    devices = pilightConfig('devices')
    deviceList = ""

    firstDevice = ""
    for d in devices:
        if deviceList == "":
            firstDevice = d
        deviceList += '<a role="menuitem" onclick="changeDevice(this)">'+d+'</a>'

    if qString != "":
        firstDevice = qString

    firstDeviceStatus = str(devices[firstDevice]['state'])
    logSys(" device details: "+ firstDevice + "  " + str(devices[firstDevice]['state']))


    page = page.replace('&&firstDevice&&', firstDevice)
    page = page.replace('&&firstDeviceStatus&&', firstDeviceStatus)
    page = page.replace('&&deviceList&&', deviceList)

    page = page.replace('&&sunrise&&',(xP.prefs['sunrise'])[11:])
    page = page.replace('&&sunset&&',(xP.prefs['sunset'])[11:])

    startTime = "10:00:00"
    if 'timelineStart' in xP.prefs :
        startTime = xP.prefs['timelineStart']

    endTime = "24:00:00"
    if 'timelineEnd' in xP.prefs :
        endTime = xP.prefs['timelineEnd']

    page = page.replace('&&endTime&&', endTime)
    page = page.replace('&&startTime&&', startTime)

    return page


#('/onoff?device,state
@app.route('/onoff')
def onoff():
    caller = request.fullpath[1:]
    message = request.query_string.strip()
    logSys(caller + " >>\n" + message + "\n<<")

    device = message.split(",")[0]
    state = message.split(",")[1]

    logSys(" on/off for device: " + device + " with " + state)
    #    http://192.168.178.16:5001/send?{"action":"control","code":{"device":"Bad","state": "on"}}

    message = '/send?{"action":"control","code":{"device":"' + device \
            + '","state":"' + state + '"}}'

    arg = {}
    arg['info'] = ' timeline on/off ' + device + ' state ' +state
    arg['message'] = message

    fire_pilight(arg)

#-------------------------------------------
"""
'send' has to differentiate between pilight versions because api change, see here
http://www.pilight.org/nightly/
  "Greatly improved REST API"
  "Instead of posting arbitrary urlencoded JSON objects, users can know use regular GET and POST methods."
--> this means no backward compatibility!
     vers.7.0/Nightly
        http://x.x.x.x:xx/control?device=studyfloorlamp&state=on
     vers. 6 and 7
        http://192.168.178.16:5001/send?{"action":"control","code":{"device":"Bad","state": "on"}}
"""
@app.route('/send')
def send():
    caller = request.fullpath[1:]
    message = request.query_string.strip()
    logSys(caller + " >>\n" + message + "\n<<")

    arg = {}
    arg['message'] = "/send?" + message

# {%22action%22:%22control%22,%22code%22:{%22device%22:%22Bad%22,%22state%22:%22off%22}}
# {"action":"control","code":{"device":"Bad","state":"off"}}

    info = message
    info = info.replace('%22', '"').replace('/send?','')
    info = info.replace('{"action":"control","code":', '')
    info = info.replace('{', '').replace('}', '').replace('"', '')
    arg['info'] = "/send " + info

    fire_pilight(arg)

    return [info]


# pilight version 7/Nightly
#http://x.x.x.x:xx/control?device=studyfloorlamp&state=on
@app.route('/control')
def control():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /" + caller + "  >>\n" + str(qString) + "\n<<")

    jobs2Schedule([qString])
    tab = scheduleActive()
    return "<br> >>" + caller  + "::" + str(qString) + "<<<br><br>"


@app.route('/timelineEnd')
@app.route('/timelineStart')
@app.route('/newsDate')
@app.route('/geo')
@app.route('/location')
@app.route('/latitude')
@app.route('/longitude')
@app.route('/iniFile')
@app.route('/locale')
def setPrefs():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /"+caller + "  >>" + qString + "<<")

    if qString != "":
        xP.prefs[caller] = qString

        prefsSaveJSON(caller, qString)
        prefsSetup()

    #if caller == 'newsDate':
    #    qString = caller  + "::" + xP.prefs[caller]

    if caller in xP.prefs:
        qString = caller  + "::" + xP.prefs[caller]

    return getSchedule()


@app.route('/prefs')
def listPrefs():
    caller = request.fullpath[1:]
    qString = request.query_string.strip()
    logSys("  /"+caller + "  >>" + qString + "<<", '36')  #36mCyan"

    prefsRead()
    showPrefs = (json.dumps(xP.prefs, sort_keys=True, indent=3).decode('unicode_escape'))
    showPrefs = showPrefs.replace(",",",<br>")

    return [showPrefs]


#-------------------------------------------
@app.route('/about')
def about():
    caller = request.fullpath[1:]
    message = request.query_string.strip()

    logSys(str(caller) + " >>" + str(platform.uname()) + "<<")

    rv = {'about': xS("piMain.about"),
        'gotoMain': xS("piPrefs.gotoMain"),
        'back': xS("piEdit.back"),

        'version': xP.prefs['version'],
        'pilightVersion': xP.prefs['pilightVersion'],
        'server': xP.prefs['server'],
        'port': xP.prefs['port'],
        'iniFile': xP.prefs['iniFile'],
        'locale': xP.prefs['locale'],
        'geo': xP.prefs['geo'],
        'platform': str(platform.platform()).replace("'","")
    }

    return templateSetup('piAbout', rv)


#-------------------------------------------
@app.route('/close')
def close():
    caller = request.fullpath[1:]
    message = request.query_string.strip()
    logInfo(caller)

    os.kill(os.getpid(), signal.SIGTERM)


#===========================================
def combineKeys(rv1, rv2):
    try:
        keys = {key: value for (key, value) in (rv1.items() + rv2.items())}
    except:
        keys = rv1
    return keys


def templateSetup(templ, rv):
    locale = piStrings.getLocale()

    try:
        textStr = piStrings.xS[templ][locale]
        keys = {key: value for (key, value) in (rv.items() + textStr.items())}
    except:
        keys = rv

    #textStr = piStrings.xS[templ][piStrings.getLocale()]
    #keys = {key: value for (key, value) in (rv.items() + textStr.items())}
    thisTemplate = template(templ, keys)
    # special formatting character replacement 
    thisTemplate = thisTemplate.replace("{P}","<br>").replace("{i}","<i>").replace("{/i}","</i>")

    return thisTemplate


def getNews(xpPrefs):
# ---------------------------
    global xP
    response = ""
    newsStatus = ""
    newsDate = ""

    try:

        global xP
        url = xpPrefs['news']

        request = urllib2.Request(url)
        response = urllib2.urlopen(request).read()

        newsStatus = "color: gray;" #'display:none'
        nLine = 0
        lines = response.split('\n')
        for line in lines:
            if nLine == 0:
                # first line holds 'newsDate', compare with 'newsDate' in prefs
                # and enable news link if news date newer
                logSys("  ..  getNews >>" + lines[nLine].strip() + "<<")
                newsDate = lines[nLine].strip()
                if 'newsDate' in xpPrefs and newsDate > xpPrefs['newsDate']:
                    newsStatus = "color: blue;" #'display:block'
                else:
                    xP.prefs['newsDate'] = newsDate
                    newsDate = ""

                lines[nLine] = "<div align='right' style=\'margin-bottom:-5px;padding-right: 100px;\'> \
                        <b>" + lines[nLine] + "</b></div><p style='margin:0;padding-left: 50px;padding-right: 100px;'>"


            if lines[nLine][0:3] == "** " :
                lines[nLine] = "<b> " + lines[nLine][3:] + "</b>"

            if lines[nLine][0:3] == "   " : 
                lines[nLine] = "<span style='margin-left:20px;'>" + lines[nLine][3:] + "</span>"

            if lines[nLine][0:3] == "|| " : 
                lines[nLine] = "<blockquote style='margin-top:-10px;margin-left:35px;'><small><tt>" + lines[nLine][3:] + "</tt></small></blockquote>"


            if lines[nLine][0:3] == "__ ":
                lines[nLine] = "<u> " + lines[nLine][3:] + "</u>"

            if lines[nLine][0:3] == "===":
                lines[nLine] = "</p><hr style='margin-top: -5px; margin-bottom: 0px;'><p style='padding-left: 50px;padding-right: 100px;'>"

            cLine = lines[nLine]
            linkA = cLine.find(" [")
            if linkA != -1:
                linkM = cLine.find("](", linkA)
                if linkM != -1:
                   linkE = cLine.find(")", linkM)
                   if linkE != -1:
                       linkDesc = cLine[(linkA+2):linkM]
                       link =     cLine[(linkM+2):linkE]
                       cLink =  "<a href='" + link + "'>" + linkDesc + "</a>"
                       lines[nLine] = lines[nLine].replace(lines[nLine][(linkA+1):(linkE+1)], cLink)
            lines[nLine] = lines[nLine].replace("   ", " &nbsp; &nbsp; &nbsp;")
            nLine = nLine +1
    
        response = "<br>".join(lines)
    except:
        logSys ("--- getNews failed from: " + url)
        response = []

    return  response, newsStatus, newsDate


def pilightConfig(typ):
# ---------------------------
    message = 'config'
    url = ('http://' + xP.prefs['server'] + ':' + str(xP.prefs['pilightPort']) + '/'  + message)

    request = urllib2.Request(url)
    response = urllib2.urlopen(request).read()
    return  json.loads(urllib2.unquote(response))[typ]


def iniFileMenu(mode):
    # build 'ini' file menu
    fHtml = '<li role="presentation"><a href="/' + mode + '?&&fName&&">&&fName&&</a></li>'

    iniFiles =  sorted(glob.glob("*.ini"))

    fileList = ""  #<a role='menuitem' >&nbsp;&nbsp; " + xS('piMain.editSchedule') + "... </a>"
    for x in iniFiles:
       fileList += fHtml.replace('&&fName&&',x)

    return fileList

def iniFileMenu1(mode):
    # build 'ini' file menu
    fHtml = '<a style="cursor:pointer;" onclick="' + mode + '(this)">&&fName&&</a>'

    iniFiles =  sorted(glob.glob("*.ini"))

    fileList = '<a style="cursor:pointer;" onclick="' + mode + '(this)">--</a>'  #<a role='menuitem' >&nbsp;&nbsp; " + xS('piMain.editSchedule') + "... </a>"
    for x in iniFiles:
       fileList += fHtml.replace('&&fName&&',x)

    return fileList


def localesMenu():
    # build 'ini' file menu
    fHtml = '<a role="menuitem"  style="cursor:pointer;" onclick="setLocale(%%lang%%)"  >&nbsp; %%langName%% &nbsp;</a>'

    # build locale menu 
    locales = piStrings.getAllLocales()
    #logSys("&& supported locales: " + locales)

    langList = ""  #  '<a role="menuitem"  style="cursor:pointer;" onclick="setLocale('DE')"  >&nbsp; Deutsch &nbsp;</a>
    localeSets = locales.split(";")

    for x in localeSets:
        cLocale = x.split(",")
        langList += fHtml.replace('%%lang%%',"'"+cLocale[0]+"'").replace("%%langName%%", cLocale[1])
    return langList


def jobsReadFile(message, setName=True):
#---------------------------------
# message   fileName or a 
    jobLines = ""
    if message != None:

        try:
            if '.ini' in message:
                jobFile = open(message, 'r')
                jobLines = jobFile.readlines()
                if setName == True:
                    xP.prefs['iniFile'] = message
        except:
            pass

    return jobLines


def jobsRead(cIniFile = 'piSchedule.ini'):
    if cIniFile == "":
        cIniFile = 'piSchedule.ini'

    jobLines = ""
    try:
        msg = "read INI Jobs file >> " + cIniFile + "<<"

        jobLines = jobsReadFile(cIniFile)
        logSys (msg + "\n" + str(jobLines))
        logInfo (msg)

    except:
        pass            #if fails get 'piSchedule.ini' or initialize it
        logERR(True)

    return jobLines


def jobs2Schedule(jobLines):
#---------------------------------
    '''  lampe2; on
        lampe2; on,22:50;off,+:10
        lampe2; on,+:02;  off,+:03:00
          * text/comment
        lampe2; on,+:02;off,+:03:00
        lampe2; on,+01:02,sunrise;off,-01:30,sunset;on,~:10,18:00;off,~:15,21:05
    '''
    global xP

    #now = datetime.now()
    #logSys("&& jobs2Schedule xP.switchTime A: " + str(xP.switchTime))

    for cJobs in jobLines:
        cJobs = cJobs.strip()
        # strip out empty or comment lines 
        if len(cJobs) == 0 or cJobs[0] == '*':
            continue

        logInfo ('\n-->>{0}<<'.format(cJobs))

        cJob = cJobs.split(";")
        cJobLen = len(cJob)
        if cJobLen >  1 :
            actualDevice = cJob[0].strip().replace("%20", "")
        now = datetime.now()

        n = 1
        while n < (cJobLen):
            currentSwitch = cJob[n].strip().replace("%20", "")
            logInfo("\ncurrentSwitch   " + str(currentSwitch))
            # inkrement now to ensure to have a 1 sec delta to the previous switchtime
            now =  now + timedelta(hours=0, minutes=0, seconds=n)
            now, currentJob, xP.switchTime = scheduleSet(now, actualDevice, currentSwitch, xP.switchTime)
            #logSys ("&& currentJob:" + str(currentJob) +  "  rNow:" + str(now))
            n += 1

    #logSys("&& jobs2Schedule xP.switchTime E: " + str(xP.switchTime))

    return 



def scheduleSet(onTime, actualDevice, currentSwitch, switchTime):
#---------------------------------

    ''' lampe2; on,+:02
        actualDevice=    lampe2; 
        currentSwitch=   on,+:02
    '''
    actualSwitch = currentSwitch.strip().replace("%20", "").split(",")

    if ('on' in actualSwitch or 'off' in actualSwitch) == False:
        return xS("piSchedule.noState")  # ERROR: no on/off

    if xP.prefs['pilightVersion'] > '7.0':     # for 7.0 Nightly
        #http://x.x.x.x:xx/control?device=studyfloorlamp&state=on
        message = "/control?device=" + actualDevice + "&state=" + str(actualSwitch[0])
    else:
        message = '/send?{"action":"control","code":{"device":"' + actualDevice \
            + '","state":"' + str(actualSwitch[0]) + '"}}'


    # piSchedule direct on/off switching 
    if len(actualSwitch) == 1:
        arg = {}
        arg['message'] = message
        info = '{0:12} {1:15}'.format(actualDevice[0:12], currentSwitch.replace(',', ' '))
        arg['info'] = info
        fire_pilight(arg)
        #sleep(2)  # for testing .. delay between directly switching
        jmsg = [str(onTime)[0:19], actualDevice, currentSwitch]
        return [onTime, jmsg, switchTime]

    xTime = onTime
    deltaTime = "*"

    # check xTime if valid and process different time options
    # xTime = '2014-04-17 22:06:00'  NEED secs, even if ':00'

    for nSwitch in actualSwitch:
        nSwitch = nSwitch.strip()

        # have dateTime or sunrise or sunset
        if nSwitch == 'sunrise':
            xTime = parser.parse(xP.prefs['sunrise'])
        elif nSwitch == 'sunset':
            xTime = parser.parse(xP.prefs['sunset'])

        # --- use deltaTime          
        # '+' add or '-' subtract time value
        # '~' add or '~-' subtract 'random' time value
        elif nSwitch[0] == '+' or nSwitch[0] == "-"  \
         or nSwitch[0] == "~":
            h = 0
            min = 0
            sec = 0

            random_subtract = False
            if nSwitch[0:2] == "~-":  #  subtract random time 
                random_subtract = True
                delta = nSwitch[2:]
            else:
                delta = nSwitch[1:]

            xDelta = delta.split(":")
            nDelta = len(xDelta)
            if nDelta >= 1:
                h = 0 if xDelta[0] == '' else int(xDelta[0])
            if nDelta >= 2:
                min = 0 if xDelta[1] == '' else int(xDelta[1])
            if nDelta == 3:
                sec = 0 if xDelta[2] == '' else int(xDelta[2])
            deltaTime = timedelta(hours=h, minutes=min, seconds=sec)

            if nSwitch[0] == '+':  # # add timedelta
                logInfo ("   delta + : " + nSwitch)
                xTime = xTime + deltaTime           #++++++++

            if nSwitch[0] == '-':  # # substract timedelta
                logInfo ("   delta - : " + nSwitch)
                deltaTime = -deltaTime
                xTime = xTime + deltaTime           #++++++++

            elif nSwitch[0] == '~':  # # add random minutes  
                rMin = h * 60 + min
                if random_subtract:
                    deltaTime = -timedelta(minutes=random.randrange(rMin))
                else:
                    deltaTime = timedelta(minutes=random.randrange(rMin))
                logInfo ("   random  : " + nSwitch + " --> deltaTime  : " + str(deltaTime))
                xTime = xTime + deltaTime           #++++++++

               # ... use deltaTime

        elif nSwitch == 'on' or nSwitch == "off" or nSwitch == "time" :
                pass
        else:
            # check for absolute time not to be 24:00 and any other unknown format
            try: 
                if (nSwitch == "24:00"):
                    nSwitch = "23:59"  
                xTime = parser.parse(nSwitch)
            except: 
                nSwitch = 'err:' + str(nSwitch)
                logInfo(" +++ " + xS("piSchedule.unknownString") + ">>" + nSwitch + "<<")

        logInfo(" +++++ check  nSwitch >>" + str(nSwitch) +"<<   xTime >>" + str(xTime) + "<<")


    xTime = xTime + timedelta(seconds=random.randrange(60))

    logInfo ("  baseTime + delta : " + str(xTime)[0:19])

    # remember 'on' state time
    wasOnTime = onTime
    onTime = xTime
    jmsg = []

    # check if xTime is before actual time
    if (xTime < datetime.now()):
        logInfo (" +++  SKIP : " + str(xTime)[0:19] + "  :: "
         + currentSwitch.strip() + "   +++ " + xS("piSchedule.beforeTime") + " +++")
    else:
        logInfo (" ..set Job : " + str(xTime)[0:19] + "  :: " + actualDevice + "  :: " + currentSwitch)

        jmsg = [str(xTime)[0:19], actualDevice, currentSwitch]
        jobName = str(int(time.time() * 1000))[6:]
        info = ('{0:12} {1:15} '.format(actualDevice[0:12], currentSwitch.replace(',', ' ')))

        if 'off' in actualSwitch:
            info = info + "  (on: " + str(wasOnTime)[11:16] + ")"

        cJob = (sched.add_job(fire_pilight, 'date', run_date=str(xTime), args=[{'message':message, 'info':info}], id=jobName))

        logSys("  .. Job to be appended to jobs    id=jobName " + jobName + "\n " + str(cJob) + "\n"+ str([{'message':message, 'info':info}]))
        logSys("&&   xTime " + str(xTime) + " switchT " + str(switchTime))

        if xTime > switchTime:
            switchTime = xTime

    return [onTime, jmsg, switchTime]


def scheduleActive():
#---------------------------------
    tablebody = '<table class="table table-striped table-bordered"><tbody>'
    output = []

    button = ("  <button class='btn btn-default btn-sm dropdown-toggle  pull-right'"
       + "id='removeJob' onclick='action(this)' title='" + xS('piSchedule.removeJob') + "'"
       + " type='button'>"
       + " <img title='help details' src='/static/gminus.png' style='width:18px'>"
       + "</button>")

    sON = xS("piSchedule.on")    #'AN'
    sOFF = xS("piSchedule.off")  #'AUS'

    aJobs = sched.get_jobs()
    if len(aJobs) == 0:
        pass 

    else:
        n = 0
        cDay = datetime.now().day
        while n < len(sched.get_jobs()):

            schTime = str(sched.get_jobs()[n].trigger).replace("date", '')
            
            sTime = (sched.get_jobs()[n].trigger).run_date
            if sTime.day != cDay:
                schTime = '> ' + s2(sTime.hour)+ ":" + s2(sTime.minute) + ":" + s2(sTime.second)
            else:
                schTime = s2(sTime.hour) + ":" + s2(sTime.minute) + ":" + s2(sTime.second)

            if (sched.get_jobs()[n].name) == 'fire_pilight':
                info = str(sched.get_jobs()[n].args[0]['info'])
            else:
                info = sched.get_jobs()[n].name

            if  len(info.split(' off ')) == 2:
                onOff = sOFF
                cinfo = info.split(' off ')

            if  len(info.split(' on ')) == 2:
                onOff = sON
                cinfo = info.split(' on ')

            if (sched.get_jobs()[n].id) == 'renew':
                button = ""
                cinfo = {}
                cinfo[0] = "renew"
                cinfo[1] = ""
                onOff = ""

            newAppend = ("<tr><td> " + schTime + "</td>"
                         + "<td>" + cinfo[0] + "</td>"
                         + "<td>" + onOff + "</td>"
                         + "<td  id='" + str(sched.get_jobs()[n].id)+ "'> " + cinfo[1] 
                         + button + "</td></tr> ")

            output.append(newAppend)

            n += 1

        output.sort()
    return (tablebody + ' '.join(output) + '</tbody></table>')


def s2(v):
    if v < 10:
        return '0'+str(v)
    return str(v)


def log2DayFile(new=False, info='xnewx'):
    sDay = datetime.now()
    logF = logFile(sDay.strftime("%A"))

    logInfo("log2DayFile " + logF)

    if new == True:
        try:
            os.remove(logF)
        except:
            pass

    now = datetime.now()
    f = open(logF, 'a')
    f.write(str(now)[0:19] + " : " + info + "\n")
    f.close()


def logFile(sDay):
    x =  sDay + '.log'
    return x 


def logPrefsDetails(prefs):
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

    info = " ** piSchedule prefs ** " + pinfo \
        + "\n\n ** piSchedule  {server}:{port} " + prefs['server'] +":" + str(prefs['port']) \
        + " >>" + prefs['ssdp'] + "<<" \
        + "\n ** piSchedule.prefs  status:" + str(prefs['status'])
    return info

#===========================================
def main():
    global xP, piPortDelta

    try:
        logInfo('\n________Started   piSchedule  (cMain)________')
        logSys ('\n________Started   piSchedule  (cMain)________')

        debug(mode=False)        # Bottle debug mode <<<<<<<<<<<<<<<<<

        xP.switchTime = datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)+  timedelta(hours=24)

        prefsRead()
        xP.prefs = prefsSetup()            # includes geoDetails, suntime

        info = logPrefsDetails(xP.prefs)
        print(info)
        logInfo(info)

        if xP.prefs['ssdp'] != "OK":
            print ("\n ** NO 'ssdp' connection! **")
            return xP.prefs['ssdp']

        if (len(sys.argv) == 2) and sys.argv[1] == "-prefs":
            return 0

        #x= 1/0            # logERR Testing only

        sched.start()    # start the scheduler
        renewSchedule()  # if iniFile is set, load jobList of it

        # starting bottle with web page
        app.run(host = xP.prefs['server'], port = xP.prefs['port'], reloader=False)

    except:
        logERR(True)


    logInfo('Finished Main\n')
    logSys('Finished Main\n')


#-------------------------------------------
if __name__ == '__main__':

    rcode = main()

