function build {
  JS_file=${Scripts_DIR}/commands/tasks/unicom/unicom.js
  Taskarray=(`cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\"`)
  for ((i=0;i<${#Taskarray[@]};i++))
  do
    Line=$(sed -n "/\"${Taskarray[$i]}\"/=" ${JS_file})
    printf "#####($(($i+1)))" >> ${ASMShell_DIR}/config/crontab.sh
    cat ${JS_file} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'|sed 's/^/#&/g' >> ${ASMShell_DIR}/config/crontab.sh
    if [ $i>12 ];then 
      min=$(($i*5-$i/12*60))
      hour=$((8+$i/12))
    else 
      min=$(($i*5))
      hour=8
    fi
    echo "$min $hour * * * bash u ${Taskarray[$i]}"  >> ${ASMShell_DIR}/config/crontab.sh
    Task=${Taskarray[$i]}
    if [ -z "$(crontab -l | grep $Task)" ];then
      n_hour="`date +%H`"
      n_minute=$(expr "`date +%M`" + 10)
      echo "新增任务  ${Taskarray[$i]}"
      echo "$n_minute $n_hour * * * bash u ${Taskarray[$i]}"  >> ${ASMShell_DIR}/config/crontab.sh
    fi
  done
  echo "0 15 * * *  bash u all" >> ${ASMShell_DIR}/config/crontab.sh
  echo "0 */3 * * * bash start >>${ASMShell_DIR}/pull.log" >> ${ASMShell_DIR}/config/crontab.sh
  cat ${ASMShell_DIR}/config/diy.sh >> ${ASMShell_DIR}/config/crontab.sh
}
echo "生成crontab.sh文件..."
echo '' >${ASMShell_DIR}/config/crontab.sh
build
echo "写入crontab..."
/usr/bin/crontab ${ASMShell_DIR}/config/crontab.sh
