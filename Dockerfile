FROM fedora:latest
MAINTAINER Liu Cong <onion_sheep@163.com>


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
RUN for pkg in `pip3 list|cut -d ' ' -f 1`; do pip3 install --upgrade $pkg; done

# install vim
RUN dnf install -y vim-enhanced

# install iproute
RUN dnf install -y iproute

COPY ./run.sh /root/run.sh
COPY ./res/shadowsocks-server /opt/shadowsocks-server
COPY ./res/kcptun-server /opt/kcptun-server
RUN chmod +x /*.sh

RUN mkdir -p /root/webui
COPY ./tool/ /root/webui/
RUN chmod -R +x /root/webui/*.py

# ADD tool/parse_arukas_json.py /root/webui/parse_arukas_json.py

# install nginx
# RUN dnf install -y nginx

# echo machine app.arukas.io > /root/.netrc
# echo "    login #{ARUKAS_JSON_API_TOKEN}" >> /root/.netrc
# echo "    password #{ARUKAS_JSON_API_SECRET}" >> /root/.netrc

EXPOSE 22
EXPOSE 4000
EXPOSE 4001
EXPOSE 8888

CMD ["/root/run.sh"]