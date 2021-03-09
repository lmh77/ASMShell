function build {
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
echo "生成crontab.sh.sample文件..."
rm -rf ${ASMShell_DIR}/config/crontab.sh.sample
build>${ASMShell_DIR}/config/crontab.sh.sample
echo "0 15 * * *  bash <(bash all)">>${ASMShell_DIR}/config/crontab.sh.sample
echo "0 */4 * * * bash start">>${ASMShell_DIR}/config/crontab.sh.sample
echo "0 0 */3 * * rm -rf ${ASMShell_DIR}/logs/*.log">>${ASMShell_DIR}/config/crontab.sh.sample

#判断......
function decide {
  if [ -f "${ASMShell_DIR}/config/crontab.sh" ]; then
    echo "仓库已经存在crontab.sh..."
    diff ${ASMShell_DIR}/config/crontab.sh ${ASMShell_DIR}/config/crontab.sh.sample > /dev/null
    if [ $? == 0 ]; then
        echo "crontab配置文件一致..."
    else
        echo "crontab配置文件不一致..."
        echo "备份原配置..."
        cp -f ${ASMShell_DIR}/config/crontab.sh ${ASMShell_DIR}/config/crontab.sh.bak
        echo "生成新配置..."
        cp -f ${ASMShell_DIR}/config/crontab.sh.sample ${ASMShell_DIR}/config/crontab.sh
    fi
  else
    echo "仓库没有crontab.sh..."
    echo "复制sample生成crontab.sh..."
    cp -f ${ASMShell_DIR}/config/crontab.sh.sample ${ASMShell_DIR}/config/crontab.sh
  fi
}
decide
echo "指定cron配置为crontab.sh"
/usr/bin/crontab ${ASMShell_DIR}/config/crontab.sh
