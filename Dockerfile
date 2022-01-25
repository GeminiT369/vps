FROM ubuntu:latest
MAINTAINER geminit369
ENV LANG C.UTF-8

RUN apt update && apt install ssh wget unzip screen git vim -y &&\
    mkdir -p /run/sshd /usr/share/caddy &&\
    wget https://codeload.github.com/ripienaar/free-for-dev/zip/master -O /usr/share/caddy/index.html &&\
    unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ &&\
    mv /usr/share/caddy/*/* /usr/share/caddy/ &&\
    echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config &&\
    echo root:xwybest|chpasswd
	
ADD https://github.com/erebe/wstunnel/releases/latest/download/wstunnel-x64-linux wstunnel
ADD https://caddyserver.com/api/download?os=linux&arch=amd64 caddy
ADD https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 ttyd
ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared
RUN chmod +x wstunnel caddy ttyd cloudflared && mv wstunnel caddy ttyd cloudflared -t /usr/bin/

ADD Caddyfile .

EXPOSE 8888
CMD /usr/sbin/sshd -D & wstunnel --server 127.0.0.1:8090 & ttyd -p 8001 -c root:123456 bash & caddy run -config Caddyfile
