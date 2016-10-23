#!/usr/bin/env bash

# rsync -e "ssh -p 31879 -i ~/.ssh/id_rsa" -aP \
rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_icat" -aP \
--exclude=.idea \
--exclude=.git \
--exclude=venv \
. \
root@192.168.9.23:/root/ssserver/

#
# --exclude=res/*.gz \
# --exclude=build \
# --exclude=res \

#root@seaof-153-125-239-140.jp-tokyo-25.arukascloud.io:/root/ssserver
# export arukas_token=f2eb9259-88bb-4698-9909-c524ad205267
# export arukas_secret=tlt2mkwXDhAIS4WYkWnTHYiR77H62lZh6mh47jPau7MRamW6y6lIRi3fe08Gp1q8
