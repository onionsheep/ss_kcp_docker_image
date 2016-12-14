FROM fedora:latest
MAINTAINER Liu Cong <onion_sheep@163.com>

# use only ipv4 for dnf
RUN echo "ip_resolve=4" >> /etc/dnf/dnf.conf

# update all packages
RUN dnf clean all && dnf upgrade -y

# install openssh
RUN dnf install -y openssh-server && \
rm -f /etc/ssh/ssh_*_key && \
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \
ssh-keygen -A

# install openssh-clients for scp
RUN dnf install -y openssh-clients

# install ps
RUN dnf install -y procps

# install tornado
RUN pip3 install tornado

# upgrade all python packages
RUN pip3 install --upgrade pip
RUN for pkg in `pip3 list --format=columns | awk 'NR > 2 {print $1}'`; do pip3 install --upgrade $pkg; done

# install vim
# some times, vim-minimal conflicts with vim-common, so remove it and install vim
RUN dnf remove -y vim-minimal && dnf install -y vim

# install iproute
RUN dnf install -y iproute

# install python
RUN dnf install -y python

# install cymysql only needed by ssr multi-user mode
# RUN pip install cymysql

# install git
RUN dnf install -y git

# install shadowsocksR
RUN cd && git clone -b manyuser https://github.com/breakwa11/shadowsocks.git
RUN cd ~/shadowsocks && bash initcfg.sh
RUN cd ~/shadowsocks/shadowsocks

COPY ./res/shadowsocks-server /opt/shadowsocks-server
COPY ./res/kcptun-server /opt/kcptun-server
RUN chmod +x /opt/*

COPY ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

RUN mkdir -p /root/webui
COPY ./tool/ /root/webui/
RUN chmod -R +x /root/webui/*.py

# ADD tool/parse_arukas_json.py /root/webui/parse_arukas_json.py

# install nginx
# RUN dnf install -y nginx

# echo machine app.arukas.io > /root/.netrc
# echo "    login #{ARUKAS_JSON_API_TOKEN}" >> /root/.netrc
# echo "    password #{ARUKAS_JSON_API_SECRET}" >> /root/.netrc

EXPOSE 8888
EXPOSE 22
EXPOSE 4000
EXPOSE 4001
EXPOSE 4002

CMD ["/root/run.sh"]
