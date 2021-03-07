#!/bin/sh
if [ $1 ]; then
  apk --no-cache add -f coreutils moreutils nodejs npm perl openssl openssh-client libav-tools libjpeg-turbo-dev libpng-dev libtool libgomp tesseract-ocr graphicsmagick
  npm config set registry https://registry.npm.taobao.org
  echo "配置仓库更新密钥..."
  mkdir -p /root/.ssh
  echo -e ${KEY} >/root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
  ssh-keyscan github.com >/root/.ssh/known_hosts
  echo "容器启动，拉取脚本仓库代码..."
  if [ -f "${ASMShell_DIR}/scripts/AutoSignMachine.js" ]; then
    echo "仓库已经存在，跳过clone操作..."
  else
    git clone -b ${Script_BRANCH} ${Script_URL} ${Script_DIR}
fi

echo "git pull拉取最新代码..."
cd ${Script_DIR}
git pull

echo "npm install 安装最新依赖"
npm install -s --prefix ${ASMShell_DIR}/scripts >/dev/null
function buildcron {
  JS_file=${Scripts_DIR}/commands/tasks/unicom/unicom.js
  Taskarray=(`cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\"`)
  for ((i=0;i<${#Taskarray[@]};i++))
  do
    Line=$(sed -n "/\"${Taskarray[$i]}\"/=" ${JS_file})
    printf "#####($(($i+1)))"
    cat ${JS_file} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'|sed 's/^/#&/g'
    if [ $i>12 ];then 
      min=$(($i*5-$i/12*60))
      hour=$((8+$i/12))
    else 
      min=$(($i*5))
      hour=8
    fi
    echo "$min $hour * * * bash u ${Taskarray[$i]}"
  done
}
echo "------------------------------------------------------------------------------------------------"
echo "生成cron列表..."
buildcron>${ASMShell_DIR}/config/crontab.sh
echo "0 18 * * *  node ${Scripts_DIR}/index.js unicom --tryrun --tasks  $(echo ${Taskarray[@]}|tr "\ " ",") |ts>> /ASMShell/logs/all.txt 2>&1 &">>${ASMShell_DIR}/config/crontab.sh
echo "0 */4 * * * bash start">>${ASMShell_DIR}/config/crontab.sh
echo "0 0 */3 * * rm -rf ${ASMShell_DIR}/logs/*.log">>${ASMShell_DIR}/config/crontab.sh
echo "指定cron配置${crontab_file}"
/usr/bin/crontab ${ASMShell_DIR}/config/crontab.sh
echo "复制${env_file}配置至.env"
cp -f ${ASMShell_DIR}/config/${env_file} ${Scripts_DIR}/config/.env
echo "程序启动完毕..."
/usr/sbin/crond -S -c /var/spool/cron/crontabs -f -L /dev/stdout

echo "------------------------------------------------------------------------------------------------"
