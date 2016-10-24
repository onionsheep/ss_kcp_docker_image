#!/usr/bin/env bash

[ -z ${rootpass} ] && export rootpass="12345679"
echo "root:$rootpass" | chpasswd
echo "password for root (env:rootpass) is : ${rootpass} "

[ -z ${arukas_token} ] && export arukas_token=""
[ -z ${arukas_secret} ] && export arukas_secret=""
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
cat <<EOF
shadowsocks config:
    password (env:sspassword) : ${sspassword}
    encryption (env:ssencryption) : ${ssencryption}
    port (env:ssport) : ${ssport}
    timeout (env:sstimeout) : ${sstimeout}
EOF

[ -z ${kcpport} ] && export kcpport=4001
[ -z ${kcpsndwnd} ] && export kcpsndwnd=1024
[ -z ${kcprcvwnd} ] && export kcprcvwnd=1024
[ -z ${kcpmode} ] && export kcpmode=fast2
[ -z ${kcpdatashard} ] && export kcpdatashard=10
[ -z ${kcpparityshard} ] && export kcpparityshard=3
cat <<EOF
kcptun config:
    port (env:kcpport) : ${kcpport}
    sndwnd (env:kcpsndwnd) : ${kcpsndwnd}
    rcvwnd (env:kcprcvwnd) : ${kcprcvwnd}
    mode (env:kcpmode) : ${kcpmode}
    datashard (env:kcpdatashard) : ${kcpdatashard}
    parityshard (env:kcpparityshard) : ${kcpparityshard}
EOF

core_num=`cat /proc/cpuinfo | grep processor | wc -l`

sscmd="${ssserver_bin} -core ${core_num} -k ${sspassword} -m ${ssencryption} \
-p ${ssport} -t ${sstimeout}"
kcpcmd="${kcptun_bin} -t "127.0.0.1:${ssport}" -l ":${kcpport}" \
--sndwnd ${kcpsndwnd} --rcvwnd ${kcprcvwnd} --mode ${kcpmode} \
--datashard ${kcpdatashard} --parityshard ${kcpparityshard}"

chmod +x ${ssserver_bin} ${kcptun_bin}

/root/webui/parse_arukas_json.py &
/usr/sbin/sshd -D &
${sscmd} &
${kcpcmd}

