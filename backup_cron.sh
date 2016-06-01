#!/bin/sh

/bin/bash /home/pi/Backup/backup_typecho.sh /home/wwwroot/www.bitbite.cn 2>&1 1>&"/home/pi/Backup/log-`date +%F%T`.txt"
