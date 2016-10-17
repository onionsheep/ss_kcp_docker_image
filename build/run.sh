#!/usr/bin/env bash
#docker run --privileged=true -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 80:80 local/ssserver
docker run -d -p 22:22 local/ssserver