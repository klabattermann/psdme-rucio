#!/bin/bash
#
# Create fake xtc and smd.xtc files for an experiment
#
# The files are created in /reg/d/psdm/<instr>/<exper> using a name template:
#   e_<exper>_rNNNNN_sMMMM.xtc and  e_<exper>_rNNNNN_sMMMM.smd.xtc
# where <exper> is the experiment name and <instr> is the instrument name (first three
# letters of experiment).
#
# Usage: 
#    create_test_files.sh [-T]  run-nr exper  [streamNr-1] [streamNR-2] .. [streamNr-N]
# by default three streams with id=(1 2 4) will be create if none are specified on the
# command line.
# Options:
#     -T: print the dd command that is used to create the files but don't run it.
#
# Example:
#  % create_test_files.sh 12 rtel00119 1 4
#    will create the files:
#     /reg/d/psdm/rte/rtel00119/xtc/e_rtel00119_r00012_s0001.xtc
#     /reg/d/psdm/rte/rtel00119/xtc/smalldata/e_rtel00119_r00012_s0001.smd.xtc
#     /reg/d/psdm/rte/rtel00119/xtc/e_rtel00119_r00012_s0004.xtc
#     /reg/d/psdm/rte/rtel00119/xtc/smalldata/e_rtel00119_r00012_s0004.smd.xtc
#

set -u
set -e
TEST=
while getopts :T OPT; do
    case $OPT in
        T|+T) TEST="echo" ;;
        *)
            sed -n -e '2,/^[^#]\|^$/ s/^#//p' $0
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1

runnr=${1:?}
exper=${2:?}
shift 2

experpath="/reg/d/psdm/${exper:0:3}/${exper}/xtc"
if [[ $# -ge 1 ]] ; then 
    streams=( $@ )
else
    streams=(1 2 4)
fi
echo "Use ${#streams[@]} Streams with ids: ${streams[@]} for ${experpath}"

if [[ ! -e ${experpath} ]] ; then
    mkdir -p ${experpath}/smalldata
    echo "Created ${experpath}/smalldata"
fi

for stream in ${streams[@]} ; do
    fn=e_${exper}_r$(printf "%05d" ${runnr})_s$(printf "%04d" ${stream}).xtc
    sizekb=$(( 10 + RANDOM % 200 ))
    fpath=${experpath}/${fn}
    
    [[ -e ${fpath} ]] && echo "exists ${fpath}" && continue
    echo $fn ${sizekb} ${fpath}
    ${TEST} dd if=/dev/urandom of=${fpath} bs=1K count=${sizekb}
        
    smdpath=$(dirname $fpath)/smalldata/$(basename $fpath)
    smdpath=${smdpath%.xtc}.smd.xtc
    [[ -e ${smdpath} ]] && echo "exists ${smdpath}" && continue
    echo $fn ${sizekb} ${smdpath}
    ${TEST} dd if=/dev/urandom of=${smdpath} bs=1 count=${sizekb}
done


