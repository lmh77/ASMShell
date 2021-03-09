#!/bin/sh
set -e
echo "<1>------------------------------------------------------------------------------------------------"
echo "更新ASMShell..."
cd ${ASMShell_DIR}/docker && git reset --hard && git pull
echo "启动startup..."
bash start startup
/usr/sbin/crond -S -c /var/spool/cron/crontabs -f -L /dev/stdout
