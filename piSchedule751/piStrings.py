#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
 piStrings   description
    Supports language text strings for different subsystems: 
      -- bottle with 'template' and {{string}} replacement
      -- JS/HTML replacement

    'lang' (eg. DE or EN) controls the return of the language string, if asked 
     with unknown code, returns default (EN) string  

 "piStrings.json" Details:
    See objects like 'piSchedule' which holds json noted  "stringName:stringValue"
    to be used with the bottle function 'templateSet(template, rv)'.
    {{stringName}} in the passed 'template' with the 'stringValue'.

      'template' name is like 'piEdit'  of 'piEdit.tpl' 
      'rv' json data with "stringName:stringValue" grouped by supported locale
'''
#  /cVersion/06-01-21_1743/

import json

lang = ""

xS = ""
piStringsJSON = "piStrings.json"
if xS == "":
    xfileJSON = open(piStringsJSON, 'r')
    xS = json.loads(xfileJSON.read())


def getLocale():
    global lang
    try:
        x = xS['piPrefs'][lang]
    except:
        lang = 'EN'
        xS['piPrefs'][lang] = 'EN'
    return lang


def piString():
#---------------------------------
    global lang, xS

    def get(n):
        getLocale()

        if n is None:
            return ""
        else:
            strings = n.split(".")

            try:
                return xS[strings[0]][lang][strings[1]]
            except:
                return xS[strings[0]]['EN'][strings[1]]

    return get

def getAllLocales():
    global lang, xS
    try:
        x = xS['locales']
    except:
        x = 'locals return error'
    return x
