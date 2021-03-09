#!/bin/sh
if [ $1 ]; then
  #仅第一次启动拉取代码和依赖
  #后续新增则手动执行相应命令
  node -v>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "第一次启动容器..."
    echo "下载软件包......."
    apk update && apk --no-cache add -f coreutils moreutils nodejs npm perl openssl openssh-client libav-tools libjpeg-turbo-dev libpng-dev libtool libgomp tesseract-ocr graphicsmagick >/dev/null 2>&1
    git config --global pull.ff only
    npm config set registry https://registry.npm.taobao.org
    echo "配置仓库更新密钥..."
    mkdir -p /root/.ssh
    echo -e ${KEY} >/root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    ssh-keyscan github.com >/root/.ssh/known_hosts
    echo "拉取脚本仓库代码..."
    git clone -b ${Scripts_BRANCH} ${Scripts_URL} ${Scripts_DIR}
    echo "npm安装依赖........"
    npm install -s --prefix ${Scripts_DIR} >/dev/null 2>&1
  fi
fi
cat /etc/hosts | grep github || echo "13.250.177.223 github" >>/etc/hosts && echo "52.74.223.119 github" >>/etc/hosts
echo "<2>------------------------------------------------------------------------------------------------"
echo "更新ASM......"
cd ${Scripts_DIR} && git pull

#后续补充需求
ln -sf ${ASMShell_DIR}/docker/all.sh /usr/local/bin/all
ln -sf ${ASMShell_DIR}/docker/buildcron.sh /usr/local/bin/buildcron
ln -sf ${ASMShell_DIR}/docker/u.sh /usr/local/bin/u
ln -sf ${ASMShell_DIR}/docker/start.sh /usr/local/bin/start


bash buildcron

#多账号并发指定配置文件
echo "复制${env_file}配置至.env"
cp -f ${ASMShell_DIR}/config/${env_file} ${Scripts_DIR}/config/.env
echo "代码及配置更新完毕..."
echo "启动完毕..."
echo "<3>------------------------------------------------------------------------------------------------"
