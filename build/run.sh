#!/usr/bin/env bash
#docker run --privileged=true -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 80:80 local/ssserver
# -p 22:22 -p 4000:4000 -p 4001:4001 -p 8888:8888
docker run -d onionsheep/ss_kcp