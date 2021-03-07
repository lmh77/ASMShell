#!/bin/sh
set -e
echo "git 拉取 ASMShell 最新代码..."
cd ${ASMShell_DIR}/docker
git reset --hard
git pull
echo "启动startup..."
bash start startup

