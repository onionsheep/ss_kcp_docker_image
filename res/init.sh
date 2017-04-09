#!/usr/bin/env bash

# use only ipv4 for dnf
echo "ip_resolve=4" >> /etc/dnf/dnf.conf 

# update all packages
dnf clean all && dnf upgrade -y 

# install openssh
dnf install -y openssh-server 
rm -f /etc/ssh/ssh_*_key 
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key 
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key 
ssh-keygen -A 

# install openssh-clients for scp
dnf install -y openssh-clients 

# install ps
dnf install -y procps 

# install tornado
pip3 install tornado 

# upgrade all python packages
pip3 install --upgrade pip 
for pkg in `pip3 list --format=columns | awk 'NR > 2 {print $1}'`; do
    pip3 install --upgrade $pkg;
done  

# install vim
# some times, vim-minimal conflicts with vim-common, so remove it and install vim
dnf remove -y vim-minimal && dnf install -y vim  

# install iproute
dnf install -y iproute  

# install python
dnf install -y python  

# install cymysql only needed by ssr multi-user mode
# RUN pip install cymysql

# install git
dnf install -y git

# install shadowsocksR
cd && git clone -b manyuser https://github.com/breakwa11/shadowsocks.git  
cd ~/shadowsocks && bash initcfg.sh 
cd ~/shadowsocks/shadowsocks 

# prepare dir for webui
chmod +x /opt/*
chmod +x /root/run.sh
chmod -R +x /root/webui/*.py