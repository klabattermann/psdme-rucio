#!/bin/bash

set -u

json_rse='{"wan": {"read": 1, "write": 1, "third_party_copy_read": 1, "third_party_copy_write": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}'

init_resources() {

    # NERSC disk resource
    rucio-admin rse add --non-deterministic NERSC
    rucio-admin rse set-attribute --rse NERSC --key istape --value False
    rucio-admin rse set-attribute --rse NERSC --key fts --value "https://fts:8446"
    rucio-admin rse add-protocol --hostname xrd1 --scheme root --prefix "//rucio/nersc" --port 1094 \
                --impl 'rucio.rse.protocols.xrootd.Default' --domain-json "${json_rse}" NERSC

    # tape resource, rse_type Disk 
    rucio-admin rse add --non-deterministic STAPE
    rucio-admin rse set-attribute --rse STAPE --key istape --value True
    rucio-admin rse set-attribute --rse STAPE --key archive_timeout --value 600
    rucio-admin rse set-attribute --rse STAPE --key fts --value "https://fts:8446"
    rucio-admin rse add-protocol --hostname xrd4 --scheme root --prefix "//rucio/tape/psdm" --port 1097 \
                --impl 'rucio.rse.protocols.xrootd.Default' --domain-json "${json_rse}" STAPE


    rucio-admin rse add --non-deterministic TTAPE
    rucio-admin rse update --setting rse_type --value TAPE --rse TTAPE 
    rucio-admin rse set-attribute --rse TTAPE --key istape --value True
    rucio-admin rse set-attribute --rse TTAPE --key archive_timeout --value 600
    rucio-admin rse set-attribute --rse TTAPE --key fts --value "https://fts:8446"
    rucio-admin rse add-protocol --hostname xrd4 --scheme root --prefix "//rucio/tapet/psdm" --port 1097 \
                --impl 'rucio.rse.protocols.xrootd.Default' --domain-json "${json_rse}" TTAPE

    # setup distances
    rucio-admin rse add-distance --distance 1 --ranking 1 NERSC STAPE
    rucio-admin rse add-distance --distance 1 --ranking 1 STAPE NERSC

    rucio-admin rse add-distance --distance 1 --ranking 1 NERSC TTAPE
    rucio-admin rse add-distance --distance 1 --ranking 1 TTAPE NERSC

    # The XRD resource are created by the run_tests_docker.sh
    for xrd_rse in XRD1 XRD2 XRD3 XRD4 ; do
        rucio-admin rse add-distance --distance 1 --ranking 1 NERSC ${xrd_rse}
        rucio-admin rse add-distance --distance 1 --ranking 1 ${xrd_rse} NERSC
    done

    # test scope and dataset
    rucio-admin scope add --scope wk01 --account root
    rucio add-dataset wk01:xtc
}

init_files() {
    # create files and upload to NERSC rse
    for i in {10..20} ; do
        cnt=$(( ($RANDOM % 30)  + 2 ))
        dd if=/dev/urandom of=/tmp/f1 bs=512K count=${cnt} &> /dev/null
        fn="wk01-r00${i}-s01-c00.xtc2"
        pfn="root://xrd1:1094//rucio/nersc/wk/wk01/xtc/${fn}"
        rucio upload --scope wk01 --rse NERSC --pfn ${pfn} --name ${fn} /tmp/f1
        rucio attach wk01:xtc wk01:${fn}
    done
}

init_misc() {

    #rucio add-rule test:file1 1 NERSC
    rucio upload --scope wk01 --rse XRD1 --name wk01-r001-s01-c00.xtc2  /tmp/f1

    dd if=/dev/urandom of=/tmp/f1 bs=1M count=12
    rucio upload --scope wk01 --rse XRD1 --name wk.wk01.xtc.f12  /tmp/f1

    # data sets
    rucio attach wk01:xtc wk01:wk01-r001-s002-c01.xtc2
}


#echo "${json_rse}" 
case ${1:-none} in
    resc) init_resources ;;
    files) init_files ;;
    *)
        echo "Use ./dev_setup.sh resc|files"
        exit
esac
