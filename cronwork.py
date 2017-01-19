#!/usr/bin/env python
# -*- coding: utf-8 -*-
#任务计划实现
from pytz import utc
from apscheduler.schedulers.background import BackgroundScheduler
sched = BackgroundScheduler(timezone=utc)
from Model import *
from pony.orm import *
import time
import Config
import urllib
import json

@db_session
def cronwork1():
    url = Config.get('StudentInfo_update_url')
    s = urllib.urlopen(url).read()[3:] #Windows下返回的json需要去掉前三位
    a = json.loads(s)
    for row in a:
        s = StudentInfo(StudentID=str(row['StudentID']))
        if s:
            s.set(**row)
        else:
            StudentInfo(**row)
        commit()

sched.add_job(cronwork1, 'interval', days=1)

def start():
    sched.start()
    print 'cronwork started'