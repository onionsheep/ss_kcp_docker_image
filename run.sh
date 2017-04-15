#!/usr/bin/env bash

export rootpass=${rootpass}

export arukas_token=${arukas_token}
export arukas_secret=${arukas_secret}
export arukas_domain=${arukas_domain}

export sspassword=${sspassword}
export ssencryption=${ssencryption}
export ssport=${ssport}
export sstimeout=${sstimeout}

export kcpport=${kcpport}
export kcpkey=${kcpkey}
export kcpcrypt=${kcpcrypt}
export kcpsndwnd=${kcpsndwnd}
export kcprcvwnd=${kcprcvwnd}
export kcpmode=${kcpmode}
export kcpdatashard=${kcpdatashard}
export kcpparityshard=${kcpparityshard}

export enable_ssr=${enable_ssr}
export ssrpassword=${ssrpassword}
export ssrencryption=${ssrencryption}
export ssrport=${ssrport}
export ssrtimeout=${ssrtimeout}
export ssrprotocol=${ssrprotocol}
export ssrobfs=${ssrobfs}
export ssrfast_open=${ssrfast_open}


[ -z ${rootpass} ] && export rootpass="12345679"
echo "root:$rootpass" | chpasswd
echo "password for root (env:rootpass) is : ${rootpass} "

# sed -ri "s/#\{ARUKAS_JSON_API_TOKEN\}/${arukas_token}/g" /root/.netrc
# sed -ri "s/#\{ARUKAS_JSON_API_SECRET\}/${arukas_secret}/g" /root/.netrc
echo "arukas_token(env:arukas_token) is : ${arukas_token} "
echo "arukas_secret(env:arukas_secret) is : ${arukas_secret} "

echo "arukas_domain(arukas_domain:arukas_domain) is ${arukas_domain} "

export working_dir=/opt
export ssserver_bin=${working_dir}/shadowsocks-server
export kcptun_bin=${working_dir}/kcptun-server

[ -z ${sspassword} ] && export sspassword="12345679"
[ -z ${ssencryption} ] && export ssencryption="aes-256-cfb"
[ -z ${ssport} ] && export ssport=4000
[ -z ${sstimeout} ] && export sstimeout=300

echo  "shadowsocks config:                                "
echo  "    password (env:sspassword) : ${sspassword}      "
echo  "    encryption (env:ssencryption) : ${ssencryption}"
echo  "    port (env:ssport) : ${ssport}                  "
echo  "    timeout (env:sstimeout) : ${sstimeout}         "

[ -z "${enable_ssr}" ] && export enable_ssr="no"
[ -z "${ssrpassword}" ] && export ssrpassword=${sspassword}
[ -z "${ssrencryption}" ] && export ssrencryption=${ssencryption}
[ -z "${ssrport}" ] && export ssrport=4002
[ -z "${ssrtimeout}" ] && export ssrtimeout=300
[ -z "${ssrprotocol}" ] && export ssrprotocol="auth_aes128_md5"
[ -z "${ssrobfs}" ] && export ssrobfs="tls1.2_ticket_auth"
[ -z "${ssrfast_open}" ] && export ssrfast_open="true"

# 传入key，获得value
function get_ssr_config(){
    local ssr_config=/root/shadowsocks/user-config.json
    local key=$1
    grep ${key} ${ssr_config} | cut -d : -f 2 | sed 's/[,"]//g' | tr -d [:space:]
}

# 传入 key value 更新之
function update_ssr_config(){
    local ssr_config=/root/shadowsocks/user-config.json
    local key=$1
    local new_value=$2
    old_value=`get_ssr_config ${key}`
    if [ -n "${old_value}" ]; then
        sed -ri "s/(${key}.*)${old_value}/\1${new_value}/g" ${ssr_config}
    else
        sed -ri "s/(${key}.*)\"\"/\1"${new_value}"/g" ${ssr_config}
    fi
}

if [ -n "${enable_ssr}" ] && [ "${enable_ssr}" != "no" ]; then
    # 根据参数确定是否启用SSR
    update_ssr_config password ${ssrpassword}
    update_ssr_config method ${ssrencryption}
    update_ssr_config server_port ${ssrport}
    update_ssr_config timeout ${ssrtimeout}
    update_ssr_config protocol ${ssrprotocol}
    update_ssr_config obfs ${ssrobfs}
    update_ssr_config fast_open ${ssrfast_open}

    echo "shadowsocksR config:"
    cat /root/shadowsocks/user-config.json
fi

[ -z "${kcpport}" ] && export kcpport=4001
[ -z "${kcpkey}" ] && export kcpkey=12345679
[ -z "${kcpcrypt}" ] && export kcpcrypt=aes
[ -z "${kcpsndwnd}" ] && export kcpsndwnd=1024
[ -z "${kcprcvwnd}" ] && export kcprcvwnd=1024
[ -z "${kcpmode}" ] && export kcpmode=fast
[ -z "${kcpdatashard}" ] && export kcpdatashard=10
[ -z "${kcpparityshard}" ] && export kcpparityshard=3

echo "kcptun config:                                              "
echo "    port (env:kcpport) : ${kcpport}                         "
echo "    key (env:kcpkey) : ${kcpkey}                            "
echo "    crypt (env:kcpcrypt) : ${kcpcrypt}                      "
echo "    sndwnd (env:kcpsndwnd) : ${kcpsndwnd}                   "
echo "    rcvwnd (env:kcprcvwnd) : ${kcprcvwnd}                   "
echo "    mode (env:kcpmode) : ${kcpmode}                         "
echo "    datashard (env:kcpdatashard) : ${kcpdatashard}          "
echo "    parityshard (env:kcpparityshard) : ${kcpparityshard}    "

core_num=`cat /proc/cpuinfo | grep processor | wc -l`

sscmd="${ssserver_bin} \
    -core ${core_num} \
    -k ${sspassword} \
    -m ${ssencryption} \
    -p ${ssport} \
    -t ${sstimeout}"

kcpcmd="${kcptun_bin} \
    -t 127.0.0.1:${ssport} \
    -l :${kcpport} \
    --key ${kcpkey} \
    --crypt ${kcpcrypt} \
    --sndwnd ${kcpsndwnd} \
    --rcvwnd ${kcprcvwnd} \
    --mode ${kcpmode} \
    --datashard ${kcpdatashard} \
    --parityshard ${kcpparityshard} \
    --log /var/log/kcptun.log"

#ssrcmd="python server.py -p ${ssrport} -k ${ssrpassword} -m ${ssrencryption} \
#-O ${ssrprotocol} -o ${ssrobfs} -d start"
if [ -n "${enable_ssr}" ] && [ "${enable_ssr}" != "no" ]; then
    ssrcmd="python /root/shadowsocks/shadowsocks/server.py -c /root/shadowsocks/user-config.json"
    nohup ${ssrcmd} 2>&1 > /var/log/shadowsocksR.log &
fi

chmod +x ${ssserver_bin} ${kcptun_bin}

nohup /root/webui/parse_arukas_json.py 2>&1 > /var/log/parse_arukas_json.py.log &
nohup ${sscmd} 2>&1 > /var/log/shadowsocks.log &
nohup ${kcpcmd} &
/usr/sbin/sshd -D 2>&1 > /var/log/sshd.log

