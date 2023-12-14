#!/bin/bash
#
# 

# exec /usr/bin/xrdcp --server "$@"

fn="${@: -1}"

echo $* > /tmp/wkwk_1
echo "$fn" >> /tmp/wkwk_1

truncate -s 4194304 "$fn"
#truncate -s 4194304 /rucio/tapet/psdm//wk0/wk01/xtc/wk01-r0011-s01-c00.xtc2_1 
#truncate -s 4194304 /rucio/tapet/psdm//wk0/wk01/xtc/wk01-r0011-s01-c00.xtc2
