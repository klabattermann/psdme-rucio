#!/bin/bash
#
# Create rucio setup for rte (rucio test experiments)
# Am rse at SLAC and NERSC are created that use xrootd for the data transfer.
# The SLAC rse is used to register files that are on disk.
# A default experiment (scope) is also created.
#

Scope=wk01
Account=root

###################################
# Create SLAC_DATA rse
#

create_rse_NERSC() {
    rse=NERSC
    rucio-admin rse add --non-deterministic ${rse}
    rucio-admin rse set-attribute --rse ${rse} --key istape --value False
    rucio-admin rse set-attribute --rse ${rse} --key fts --value "https://fts:8446"

    rucio-admin rse add-protocol --hostname xrd1 --scheme root --prefix "//rucio" --port 1094 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy_read": 1, "third_party_copy_write": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}' \
                ${rse}
}

create_rse_PCDS() {
    rse=PCDS
    rucio-admin rse add --non-deterministic ${rse}
    rucio-admin rse set-attribute --rse ${rse} --key istape --value False
    rucio-admin rse set-attribute --rse ${rse} --key fts --value "https://fts:8446"

    rucio-admin rse add-protocol --hostname xrd1 --scheme xroot --prefix "//rucio/psdm/pcds" --port 1094 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy_read": 1, "third_party_copy_write": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}' \
                ${rse}
}

set_distance() {
    rucio-admin rse add-distance --distance 1 --ranking 1 PCDS NERSC
    rucio-admin rse add-distance --distance 1 --ranking 1 NERSC PCDS
    rucio-admin rse get-distance PCDS NERSC
    rucio-admin rse get-distance NERSC PCDS
}


set_limits() {
    rucio-admin  account set-limits wilko LCLS_DATA  10TB
    rucio-admin  account set-limits wilko LCLS_NERSC 10TB
}


init1() {
    rucio-admin scope add --scope wk01 --account root
}


case $1 in
    rse_nersc) create_rse_NERSC ;;
    rse_pcds) create_rse_PCDS ;;
    rse_dist) set_distance ;;
    all)
        create_rse_NERSC 
        create_rse_PCDS
        set_distance
        ;;
    *)
        echo "Unknown command $1"
        exit
esac
