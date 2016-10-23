#!/usr/bin/env bash
#docker run --privileged=true -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 80:80 local/ssserver
# -p 22:22 -p 4000:4000 -p 4001:4001 -p 8888:8888
docker run -d -p 10022:22 -p 14000:4000 -p 14001:4001 -p 18888:8888 \
--env rootpass=liucong \
--env arukas_token=f2eb9259-88bb-4698-9909-c524ad205267 \
--env arukas_secret=tlt2mkwXDhAIS4WYkWnTHYiR77H62lZh6mh47jPau7MRamW6y6lIRi3fe08Gp1q8 \
--env arukas_domain=sskcp-dev-1023-1334 onionsheep/ss_kcp