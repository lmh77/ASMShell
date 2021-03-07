#!/usr/bin/env bash
git fetch
git reset --hard origin/master
git pull

echo "设定远程仓库地址..."
mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && cd /root/.ssh \
    && echo -e $KEY > /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa \
    && ssh-keyscan github.com > /root/.ssh/known_hosts
[ ! -d ${ASMDIR}/.git ] && echo "git clone克隆最新代码..." && git clone -b ${ASMBRANCH} ${ASMURL} ${ASMDIR}
cd  ${ASMDIR} && echo "git pull最新代码..." && git pull
echo "npm install 安装最新依赖"
npm config set registry https://registry.npm.taobao.org 
npm install -s --prefix ${ASMDIR} >/dev/null
echo "------------------------------------------------------------------------------------------------"
echo "生成任务列表..."
cat ${ASMDIR}/commands/tasks/unicom/unicom.js | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\">${ASMShellDIR}/config/task.list
echo "已指定计划任务配置${crontab_file}，将直接使用该文件"
/usr/bin/crontab ${crontab_file}
echo "复制配置文件..."
cp -f ${ASMShellDIR}/config/${envfile} ${ASMDIR}/config/.env
echo "程序启动完毕..."
/usr/sbin/crond -S -c /var/spool/cron/crontabs -f -L /dev/stdout
crond
echo "------------------------------------------------------------------------------------------------"
