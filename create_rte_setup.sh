#!/bin/bash
#
# Create rucio setup for rte (rucio test experiments) 
# Am rse at SLAC and NERSC are created that use xrootd for the data transfer.
# The SLAC rse is used to register files that are on disk. 
# A default experiment (scope) is also created.
#

set -u

Scope=rte01
Account=root

Fts="https://134.79.129.252:8446"

# domain in json format
djson='--domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy_read": 1, "third_party_copy_write": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}''

create_scope() {
    rucio-admin scope add --account ${Account} --scope ${Scope}
    rucio-admin scope list --account ${Account}
}

create_rse_S3DF() {
    rse=S3DF
    rucio-admin rse add --non-deterministic ${rse}
    rucio-admin rse set-attribute --rse ${rse} --key istape --value False
    rucio-admin rse set-attribute --rse ${rse} --key fts --value "${Fts}"
    rucio-admin rse add-protocol --hostname psexport02.slac.stanford.edu --scheme root --prefix "//psdm/rucio" --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' --domain-json "${djson}" ${rse}
}


create_rse_LCLS_NERSC() {
    rse=NERSC
    rucio-admin rse add --non-deterministic ${rse}
    rucio-admin rse set-attribute --rse ${rse} --key istape --value False
    rucio-admin rse set-attribute --rse ${rse} --key fts --value "${Fts}"
    rucio-admin rse add-protocol --hostname dtn04.nersc.gov --scheme root --prefix "//psdm/rucio" --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' --domain-json "${djson}" ${rse}
}

set_distance() {
    rucio-admin rse add-distance --distance 1 --ranking 1 PCDS NERSC
    rucio-admin rse add-distance --distance 1 --ranking 1 NERSC PCDS
    rucio-admin rse get-distance PCDS NERSC
    rucio-admin rse get-distance NERSC PCDS
}

set_limits() {
    rucio-admin  account set-limits wilko PCDS  10TB
    rucio-admin  account set-limits wilko NERSC 10TB
}


#create_rse_S3DF
#create_rse_NERSC
#set_distance
#set_limits

