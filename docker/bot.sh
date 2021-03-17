if [ hostname==asm1 ];then
  [ ! -d ${Scripts_DIR}/TGShell ] && cd ${ASMShell_DIR} && git clone https://github.com/lmh77/TeleShellBot.git TGShell
  cd ${ASMShell_DIR}/TGShell && npm install && nohup node index.js >${ASMShell_DIR}/logs/.logs 2>&1 &
fi   
