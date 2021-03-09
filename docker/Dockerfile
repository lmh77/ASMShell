FROM alpine

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    ASMShell_DIR=/ASMShell \
    ASMShell_URL=https://github.com/lmh77/ASMShell \
    ASMShell_BRANCH=master \
    Scripts_DIR=/ASMShell/scripts

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk --no-cache add -f git tzdata bash \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && git clone -b ${ASMShell_BRANCH} ${ASMShell_URL} ${ASMShell_DIR} \
    && cp -f ${ASMShell_DIR}/docker/entrypoint.sh /usr/local/bin/entrypoint.sh \
    && chmod 777 /usr/local/bin/entrypoint.sh

WORKDIR ${ASMShell_DIR}

ENTRYPOINT /usr/local/bin/entrypoint.sh

