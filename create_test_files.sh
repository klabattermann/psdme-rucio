#!/bin/bash
# 

set -u
set -e

exper=${1:-mfxte1234}
experpath="/reg/d/psdm/${exper:0:3}/${exper}/xtc"
streams=(3 4)

if [[ ! -e ${experpath} ]] ; then
    mkdir -p ${experpath}
    echo "Created ${experpath}"
else
    echo ${experpath}
fi


for runnr in {3..4} ; do
    for stream in ${streams[@]} ; do
        fn=e_${exper}_$(printf "%04d" ${runnr})_s$(printf "%04d" ${stream}).xtc
        sizekb=$(( 1 + RANDOM % 200 ))
        fpath=${experpath}/${fn}

        [[ -e ${fpath} ]] && echo "exists ${fpath}" && continue
        echo $fn ${sizekb} ${fpath}
        dd if=/dev/urandom of=${fpath} bs=1K count=${sizekb}
    done
done

