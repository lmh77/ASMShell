#!/bin/sh

ASMShell_DIR=/ASMShell
Scripts_DIR=/ASMShell/scripts
Logs_DIR=/ASMShell/logs
JS_file=/ASMShell/scripts/commands/tasks/unicom/unicom.js
echo "------------------------------------------------------------------------------------------------"
function CloneScripts() {
    echo "配置仓库更新密钥..."
    mkdir -p /root/.ssh
    echo -e ${KEY} >/root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    ssh-keyscan github.com >/root/.ssh/known_hosts
    echo "拉取脚本仓库代码..."
    git clone -b ${Scripts_BRANCH} ${Scripts_URL} ${Scripts_DIR}
}

function PullScripts() {
    echo "更新仓库代码..."
    cd ${Scripts_DIR}
    git reset --hard
    git -C ${Scripts_DIR} pull --rebase
    git checkout ${Scripts_BRANCH}
}

function Npm_Install() {
    cd ${Scripts_DIR}
    if [[ "${OldPackageList}" != "$(cat ${Scripts_DIR}/package.json)" ]]; then
        echo "运行 npm install..."
        npm install --registry=https://registry.npm.taobao.org
        if [ $? -ne 0 ]; then
            echo "npm install 运行不成功，删除${Scripts_DIR}/node_modules重试..."
            rm -rf ${Scripts_DIR}/node_modules
        fi
    fi
    if [ ! -d ${Scripts_DIR}/node_modules ]; then
        echo "运行 npm install..."
        npm install --registry=https://registry.npm.taobao.org
        if [ $? -ne 0 ]; then
            echo "npm install 运行不成功，删除${Scripts_DIR}/node_modules重试..."
            echo "稍后记得手动执行 npm install..."
            rm -rf ${Scripts_DIR}/node_modules
        fi
    fi
}

function Build_Cron() {
    function build() {
        Taskarray=($(cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d' | sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\"" | cut -f2 -d\"))
        for ((i = 0; i < ${#Taskarray[@]}; i++)); do
            Line=$(sed -n "/\"${Taskarray[$i]}\"/=" ${JS_file})
            printf "#####($(($i + 1)))" >>${ASMShell_DIR}/config/`hostname`_crontab.sh
            cat ${JS_file} | sed -n $(($Line - 3)),$(($Line - 2))p | grep \/\/ | sed 's/[ \t]*//g' | sed 's/[\/\/\t]*//g' | sed 's/^/#&/g' >>${ASMShell_DIR}/config/`hostname`_crontab.sh
            if [ $i ] >12; then
                min=$(($i * 5 - $i / 12 * 60))
                hour=$((8 + $i / 12))
            else
                min=$(($i * 5))
                hour=8
            fi
            echo "$min $hour * * * bash u ${Taskarray[$i]}" >>${ASMShell_DIR}/config/`hostname`_crontab.sh
            if [ ! $startup ]; then
                Task=${Taskarray[$i]}
                if [ -z "$(crontab -l | grep $Task)" ]; then
                    n_hour="$(date +%H)"
                    n_minute=$(expr "$(date +%M)" + 10)
                    echo "新增任务  ${Taskarray[$i]}"
#                     echo "$n_minute $n_hour * * * bash u ${Taskarray[$i]}" >>${ASMShell_DIR}/config/`hostname`_crontab.sh
                fi
            fi
        done
        echo "0 0 */2 * *  rm -rf ${ASMShell_DIR}/config/logs/*.log" >>${ASMShell_DIR}/config/`hostname`_crontab.sh
        echo "0 15 * * *  bash u all" >>${ASMShell_DIR}/config/`hostname`_crontab.sh
        echo "0 */3 * * * bash start >>${ASMShell_DIR}/logs/.start.txt" >>${ASMShell_DIR}/config/`hostname`_crontab.sh
        if [ $diycron ]; then
            cat ${ASMShell_DIR}/config/diy.sh >>${ASMShell_DIR}/config/`hostname`_crontab.sh
        fi
    }
    if [ ! -f ${ASMShell_DIR}/config/`hostname`_crontab.sh ]; then
        startup=1
        echo "检测到无`hostname`_crontab.sh文件..."
    fi
    echo "生成`hostname`_crontab.sh文件..."
    echo ''>${ASMShell_DIR}/config/`hostname`_crontab.sh
    build
    echo "写入crontab..."
    /usr/bin/crontab ${ASMShell_DIR}/config/`hostname`_crontab.sh

}

[ -f ${Scripts_DIR}/package.json ] && OldPackageList=$(cat ${Scripts_DIR}/package.json)
[ -d ${Scripts_DIR}/.git ] && PullScripts || CloneScripts
Npm_Install
Build_Cron
echo "复制${config_env}配置至.env"
ln -sf ${ASMShell_DIR}/config/${config_env} ${Scripts_DIR}/config/.env
echo "所有配置及脚本更新完毕..."
echo "------------------------------------------------------------------------------------------------"
ln -sf ${ASMShell_DIR}/u.sh /usr/local/bin/u

