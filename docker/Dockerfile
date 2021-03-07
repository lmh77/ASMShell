FROM node:lts-alpine
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    ASMShellURL=https://github.com/lmh77/ASMShell.git \
    ASMShellDIR=/ASMShell 
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
                             coreutils \
                             moreutils \
                             git \
                             wget \
                             curl \
                             tzdata \
                             perl \
                             openssl \
                             openssh \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && git clone ${ASMShellURL} ${ASMShellDIR}

RUN chmod +x ${ASMShellDIR}/docker/*.sh
WORKDIR ${ASMShellDIR}
ENTRYPOINT ${ASMShellDIR}/docker/entrypoint.sh
