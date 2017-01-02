#!/usr/bin/env python
# -*- coding: utf-8 -*-

''' 
    Copyright (C) 2015 gWahl
'''
#  /cVersion/06-09-06_1500/

import piPrefs
xP = piPrefs


import logging, traceback, os, signal
import logging.handlers

from functools import wraps
from datetime import datetime

from bottle import request, response
import sys

# create formatter and add it to the handlers
formatter = logging.Formatter('#%(process)s %(asctime)s - %(message)s\033[0m',"%H:%M:%S")


# Logger for 'error' messages
# Detail log info goes to piSystem.log
def logERR(close):

    stack = traceback.extract_stack()
    filename, codeline, funcName, text = stack[-3]

    sFuncName = (funcName + '   ERROR').ljust(28," ")
    loggerX.error("\033[1;31m{0} \033[0m #{1} \n{2}".format(sFuncName, codeline, traceback.format_exc().replace("\n    ", "   ")))

    if close == True:
        logInfo("*** Error Terminate ***")
        sys.exit(99)

loggerX = logging.getLogger('cPiS')
loggerX.setLevel(logging.INFO)  # normal setting at which level logging starts

fh = logging.handlers.RotatingFileHandler(
              xP.logSysName, maxBytes=50000, backupCount=2)
fh.setFormatter(formatter)

loggerX.addHandler(fh)
#----------------

# Logger for System Messages goes to piSystem.log
def logSys(msg, color='35'):   # magenta
    loggerS.info(logString(msg, color))


loggerS = logging.getLogger('cSys')
loggerS.setLevel(logging.INFO)  # normal setting at which level logging starts

# f1 = SingleLevelFilter(logging.INFO, False)         # define which level should be written
# fh.addFilter(f1)

fh = logging.handlers.RotatingFileHandler(
              xP.logSysName, maxBytes=50000, backupCount=2)
fh.setFormatter(formatter)

loggerS.addHandler(fh)
#----------------



# Logger for Info Messages
def logInfo(msg, color='32'):   # green
    loggerI.info(logString(msg, color))

loggerI = logging.getLogger('cInfo')
loggerI.setLevel(logging.INFO)  # normal setting at which level logging starts

# f1 = SingleLevelFilter(logging.INFO, False)         # define which level should be written
# fh.addFilter(f1)

fh = logging.handlers.RotatingFileHandler(
              xP.logInfoName, maxBytes=50000, backupCount=2)
fh.setFormatter(formatter)

loggerI.addHandler(fh)
#----------------


def logString(msg, color):   # green
    global prefs

    stack = traceback.extract_stack()
    filename, codeline, funcName, text = stack[-3]

    head, tail = os.path.split(filename)
    root, ext = os.path.splitext(tail)

    if funcName == "_logBottle":
        funcName = "bottle"

    sFuncName = (root + " " + funcName + " #" + str(codeline)).ljust(28," ")

    return ("\033[1;"+ color + "m" + sFuncName +"\033[0m " + msg)




def logBottle(fn):
    '''
    Wrap a Bottle request so that a log line is emitted after it's handled.
    (This decorator can be extended to take the desired logger as a param.)
    '''
    @wraps(fn)
    def _logBottle(*args, **kwargs):
        request_time = datetime.now()
        actual_response = fn(*args, **kwargs)
        # modify this to log exactly what you need:

#2015-06-29 14:32:43,563 - INFO - piWeb - 192.168.178.30 GET http://192.168.178.16:5003/prefs 200 OK

        logSys('%s %s %s %s' % (request.remote_addr,
                                        #request_time,
                                        request.method,
                                        request.url,
                                        response.status), '35') # magenta
        return actual_response
    return _logBottle


def main():
    pass
