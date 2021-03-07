#!/bin/bash
echo
Logs_DIR=${ASMShellDIR}/logs
JS_DIR=${ASMDIR}/commands/tasks/unicom/unicom.js
TaskList=(`cat ${ASMShellDIR}/config/task.list`)

function Run {
    crontab ${crontab_file}
    cp -f ${ASMShellDIR}/config/${envfile} ${ASMDIR}/config/.env
    Line=$(sed -n "/\"$1\"/=" ${JS_DIR})
    cat ${JS_DIR} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'
    echo 
    node ${ASMDIR}/index.js unicom --tasks $1 --tryrun |tee ${Logs_DIR}/$1.log
    }
    
case $# in
  0)
    echo "请重新输入！"
    ;;
  1)
    echo "${TaskList[@]}" | grep -wq "$1" \
    &&  echo "即将执行任务...$1" && Run $1 \
    ||  echo "不存在此任务..."
    ;;
  *)
    echo -e "输入命令过多..."
    ;;
esac
