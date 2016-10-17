FROM fedora:latest
MAINTAINER Liu Cong <onion_sheep@163.com>

# rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
#     ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
#     ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
#     sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
#     sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config &&\

# RUN yum -y install epel-release && \
#     yum -y install openssh-server pwgen vim wget gzip tmux&& \

ADD setup_ssserver.sh /setup_ssserver.sh
ADD run.sh /run.sh
ADD res/shadowsocks-server /opt/shadowsocks-server
ADD res/kcptun-server /opt/kcptun-server
RUN chmod +x /*.sh && \
    bash /setup_ssserver.sh && \
    uname -a

CMD ["/run.sh"]