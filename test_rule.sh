#!/bin/bash


fn=rtel00119:xtc.files.e_rtel00119_r00013_s0001.xtc


ruleid=$(rucio list-rules --account root | awk '/rtel001/  {print $1}')
#rucio list-rules --account root | awk 'rtel' | awk '{print $1}'
#ruleid=$1
echo "RuleID $ruleid"
[[ -z ${ruleid} ]] && exit 2

rucio update-rule --lifetime 1 ${ruleid} 

rucio-judge-cleaner  --run-once
sleep 1
rucio list-rules --account root

rucio add-rule ${fn} 1 LCLS_NERSC 
sleep 1
rucio list-rules --account root

