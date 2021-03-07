#!/bin/bash
echo
Logs_DIR=${ASMShell_DIR}/logs
JS_file=${Scripts_DIR}/commands/tasks/unicom/unicom.js
Taskarray=(`cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\"`)

function Run {
    Line=$(sed -n "/\"$1\"/=" ${JS_file})
    cat ${JS_file} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'
    echo 
    node ${Scripts_DIR}/index.js unicom --tasks $1 --tryrun |tee ${Logs_DIR}/$1.log
    echo
    }
    
case $# in
  0)
    echo "请重新输入！"
    ;;
  1)
    echo "${Taskarray[@]}" | grep -wq "$1" \
    &&  echo "即将执行任务..." && Run $1 \
    ||  echo "不存在此任务..."
    ;;
  *)
    echo -e "输入命令过多..."
    ;;
esac
bash start>/dev/null
