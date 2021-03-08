#!/bin/sh
set -e
echo "< 1>------------------------------------------------------------------------------------------------"
echo "git 拉取 ASMShell 最新代码..."
cd ${ASMShell_DIR}/docker && git reset --hard && git pull
echo "启动startup..."
bash start startup
/usr/sbin/crond -S -c /var/spool/cron/crontabs -f -L /dev/stdout
