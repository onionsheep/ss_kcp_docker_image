FROM fedora:latest
MAINTAINER Liu Cong <onion_sheep@163.com>

# rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
#     ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
#     ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
#     sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
#     sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config &&\

# RUN yum -y install epel-release && \
#     yum -y install openssh-server pwgen vim wget gzip tmux&& \

ADD run.sh /run.sh
ADD res/shadowsocks-server /opt/shadowsocks-server
ADD res/kcptun-server /opt/kcptun-server
RUN chmod +x /*.sh
# RUN bash /setup_ssserver.sh

# change to tuna repo
RUN mv /etc/yum.repos.d /etc/yum.repos.d.bak
RUN mkdir /etc/yum.repos.d
ADD res/fedora-tuna.repo /etc/yum.repos.d/fedora.repo
ADD res/fedora-updates-tuna.repo /etc/yum.repos.d/fedora-updates.repo

# install openssh
RUN dnf install -y openssh-server
RUN rm -f /etc/ssh/ssh_*_key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -A

# install nginx
RUN dnf install -y nginx

CMD ["/run.sh"]