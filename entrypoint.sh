#!/bin/bash
ASMShell_DIR=/ASMShell
Scripts_DIR=/ASMShell/scripts
Logs_DIR=/ASMShell/logs

set -e

[ ! -d ${Logs_DIR} ] && mkdir -p ${Logs_DIR}
echo "------------------------------------------------------------------------------------------------"
echo "更新ASMShell..."
cd ${ASMShell_DIR} && git reset --hard && git pull
crond
echo "启动start..."
bash start
echo

