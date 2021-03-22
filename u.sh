#!/bin/bash
echo
Logs_DIR=${ASMShell_DIR}/logs
JS_file=${Scripts_DIR}/commands/tasks/unicom/unicom.js
Taskarray=(`cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\"`)

function Run {
    Line=$(sed -n "/\"$1\"/=" ${JS_file})
    cat ${JS_file} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'
    echo 
    node ${Scripts_DIR}/index.js unicom --tasks $1 --tryrun |tee -a ${Logs_DIR}/$1.log
    echo
    }
function tasklist {
  for ((i=0;i<${#Taskarray[@]};i++))
  do
    Line=$(sed -n "/\"${Taskarray[$i]}\"/=" ${JS_file})
    printf "#####($(($i+1)))"
    cat ${JS_file} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'|sed 's/^/#&/g'
    echo "bash u ${Taskarray[$i]}"
  done
}
function tryrun {
    nohup node ${Scripts_DIR}/index.js unicom --tasks $(cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\"|tr "\n" ",") --tryrun > ${Logs_DIR}/.all.txt 2>&1 &
}
if [ -n "$2" ]; then
  echo "输入命令过多..."
else
  if [ ! -n "$1" ]; then
    echo "请输入任务名..."
  else
    echo tasklist | grep -wq "$1" && tasklist && exit
    echo all | grep -wq "$1" &&  echo "后台执行全部任务..." && tryrun && exit
    echo "${Taskarray[@]}" | grep -wq "$1" &&  echo "即将执行任务..." && Run $1 ||  echo "不存在此任务..."
  fi
fi
echo
