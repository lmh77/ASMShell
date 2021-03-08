#!/bin/sh
if [ $1 ]; then
  apk update
  apk --no-cache add -f coreutils moreutils nodejs npm perl openssl openssh-client libav-tools libjpeg-turbo-dev libpng-dev libtool libgomp tesseract-ocr graphicsmagick
  npm config set registry https://registry.npm.taobao.org
  echo "配置仓库更新密钥..."
  mkdir -p /root/.ssh
  echo -e ${KEY} >/root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
  ssh-keyscan github.com >/root/.ssh/known_hosts
  echo "容器启动，拉取脚本仓库代码..."
  if [ -f "${ASMShell_DIR}/scripts/AutoSignMachine.js" ]; then
    echo "仓库已经存在，跳过clone操作..."
  else
    git clone -b ${Scripts_BRANCH} ${Scripts_URL} ${Scripts_DIR}
    echo "npm install 安装最新依赖"
    npm install -s --prefix ${Scripts_DIR} >/dev/null
  fi
fi

echo "git pull拉取最新代码..."
cd ${Scripts_DIR}
git pull
echo "------------------------------------------------------------------------------------------------"
#补充
ln -sf ${ASMShell_DIR}/docker/all.sh /usr/local/bin/all
ln -sf ${ASMShell_DIR}/docker/buildcron.sh /usr/local/bin/buildcron

bash buildcron

echo "复制${env_file}配置至.env"
cp -f ${ASMShell_DIR}/config/${env_file} ${Scripts_DIR}/config/.env
echo "程序启动完毕..."
echo "------------------------------------------------------------------------------------------------"