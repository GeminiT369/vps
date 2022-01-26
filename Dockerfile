FROM ubuntu:latest
MAINTAINER geminit369
ENV LANG C.UTF-8

RUN apt update &&\
    apt install ssh wget unzip screen gzip vim -y &&\
    mkdir -p /run/sshd /usr/share/caddy &&\
    wget https://codeload.github.com/ripienaar/free-for-dev/zip/master -O /usr/share/caddy/index.html &&\
    unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ &&\
    mv /usr/share/caddy/*/* /usr/share/caddy/ &&\
    echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config &&\
    echo root:xwybest|chpasswd &&\
    touch /root/.hushlogin
	
ADD https://caddyserver.com/api/download?os=linux&arch=amd64 caddy
ADD https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 ttyd
ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared
ADD https://github.com/jpillora/chisel/releases/latest/download/chisel_1.7.6_linux_amd64.gz chisel.gz
RUN gzip -d chisel.gz && chmod +x caddy ttyd cloudflared chisel && mv caddy ttyd cloudflared chisel -t /usr/bin/

ADD Caddyfile .

EXPOSE 8888
CMD /usr/sbin/sshd -D & chisel server --port 7777 --host 127.0.0.1 & ttyd -p 8001 -c root:123456 bash & cloudflared tunnel --name dvps --bastion & caddy run -config Caddyfile
