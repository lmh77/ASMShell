#!/bin/sh
if [ $1 ]; then
  #仅第一次启动拉取代码和依赖
  #后续新增则手动执行相应命令
  node -v>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then                                 
    apk update
    apk --no-cache add -f coreutils moreutils nodejs npm perl openssl openssh-client libav-tools libjpeg-turbo-dev libpng-dev libtool libgomp tesseract-ocr graphicsmagick >/dev/null 2>&1
    git config --global pull.ff only
    echo "13.250.177.223 github" >>/etc/hosts
    npm config set registry https://registry.npm.taobao.org
    echo "配置仓库更新密钥..."
    mkdir -p /root/.ssh
    echo -e ${KEY} >/root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    ssh-keyscan github.com >/root/.ssh/known_hosts
    echo "拉取脚本仓库代码..."
    git clone -b ${Scripts_BRANCH} ${Scripts_URL} ${Scripts_DIR}
    echo "npm install安装依赖"
    npm install -s --prefix ${Scripts_DIR} >/dev/null
  fi
fi

echo "------------------------------------------------------------------------------------------------"
echo "git pull拉取ASM更新..."
cd ${Scripts_DIR} && git pull

#后续补充需求
ln -sf ${ASMShell_DIR}/docker/all.sh /usr/local/bin/all
ln -sf ${ASMShell_DIR}/docker/buildcron.sh /usr/local/bin/buildcron


bash buildcron

#多账号并发指定配置文件
echo "复制${env_file}配置至.env"
cp -f ${ASMShell_DIR}/config/${env_file} ${Scripts_DIR}/config/.env
echo "更新代码及配置完毕..."
echo "------------------------------------------------------------------------------------------------"
