#!/bin/sh
if [ $1 ]; then
  ls -l ${Scripts_DIR}/commands>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    rm -rf ${Scripts_DIR}/*
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
echo "------------------------------------------------------------------------------------------------"
echo "更新ASM......"
cd ${Scripts_DIR} && git pull
#后续补充需求
ln -sf ${ASMShell_DIR}/bak/all.sh /usr/local/bin/all
ln -sf ${ASMShell_DIR}/docker/buildcron.sh /usr/local/bin/buildcron
ln -sf ${ASMShell_DIR}/docker/u.sh /usr/local/bin/u
bash buildcron
#多账号并发容器指定配置文件
echo "软链接${config_env}配置至.env"
ln -sf ${ASMShell_DIR}/config/${config_env} ${Scripts_DIR}/config/.env
echo "代码及配置更新完毕..."
echo "启动完毕..."
echo "------------------------------------------------------------------------------------------------"
