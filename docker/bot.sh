if [ hostname==asm1 ];then
  ls -l ${Scripts_DIR}/TGShell/index.js>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    cd ${ASMShell_DIR} && git clone https://github.com/lmh77/TeleShellBot.git TGShell
  fi
  cd ${ASMShell_DIR}/TGShell && npm install && nohup node index.js >${ASMShell_DIR}/logs/.logs
fi   
