#!/bin/bash
ASMShell_DIR=/ASMShell
Scripts_DIR=/ASMShell/scripts
Logs_DIR=/ASMShell/logs

set -e

[ ! -d ${Logs_DIR} ] && mkdir -p ${Logs_DIR}
echo "------------------------------------------------------------------------------------------------"
echo "更新ASMShell..."
cd ${ASMShell_DIR} && git reset --hard && git pull
echo "启动start..."
bash start
/usr/sbin/crond -S -c /var/spool/cron/crontabs -f -L /dev/stdout

