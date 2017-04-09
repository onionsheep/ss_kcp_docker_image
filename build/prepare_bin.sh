#!/usr/bin/env bash

cd `dirname $0`

[ -z ${working_dir} ] && export working_dir=../res

[ -z ${ss_gzip} ] && export ss_gzip=shadowsocks-server.tar.gz
[ -z ${kcp_targz} ] && export kcp_targz=kcptun-linux-amd64.tar.gz

[ -z ${ss_bin} ] && export ss_bin=${working_dir}/shadowsocks-server
[ -z ${kcp_bin} ] && export kcp_bin=${working_dir}/kcptun-server

ssserver_url="https://github.com/shadowsocks/shadowsocks-go/releases/download/1.2.1/shadowsocks-server.tar.gz"
kcptun_url="https://github.com/xtaci/kcptun/releases/download/v20170329/kcptun-linux-amd64-20170329.tar.gz"

cd ${working_dir}
if [ ! -f ${ss_bin} ]; then
    if [ ! -f ${ss_gzip} ]; then
        curl -L ${ssserver_url} > ${ss_gzip}
    fi
    tar -xf ${ss_gzip}
fi

if [ ! -f ${kcp_bin} ]; then
    if [ ! -f ${kcp_targz} ]; then
        curl -L ${kcptun_url} > ${kcp_targz}
    fi
    tar -xf ${kcp_targz}
    rm -f client_linux_amd64
    mv server_linux_amd64 ${kcp_bin}
fi
