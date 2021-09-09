#!/bin/bash
#
# Create rucio setup for rte (rucio test experiments) 
# Am rse at SLAC and NERSC are created that use xrootd for the data transfer.
# The SLAC rse is used to register files that are on disk. 
# A default experiment (scope) is also created.
#

Scope=rtel00119
Account=root
LCLS_regd=LCLS_REGD
NERSC_dtn=LCLS_NERSC


qq() {
    rucio-admin rse add-protocol --hostname psexport06.slac.stanford.edu --scheme root --prefix /psdm/misc/test --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 0, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 0, "delete": 0}}' \
                ${LCLS_regd}
}


create_scope() {
    rucio-admin scope add --account ${Account} --scope ${Scope}
    rucio-admin scope list --account ${Account}
}


################################### 
# Create SLAC_DATA rse
#
create_rse_LCLS_DATA() {
    rse=LCLS_DATA
    
    #rucio-admin rse add --non-deterministic ${rse}
    #rucio-admin rse set-attribute --rse ${rse} --key istape --value False
    #rucio-admin rse set-attribute --rse ${rse} --key fts --value "https://rucio-dev.slac.stanford.edu:8446"
    
    #rucio-admin rse add-protocol --hostname localhost --scheme file --prefix /reg/d/psdm --impl "rucio.rse.protocols.posix.Default" \
    #            --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy": 0, "delete": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' \
    #            ${rse}
    
    rucio-admin rse add-protocol --hostname 134.79.103.90 --scheme root --prefix "//psdm/rucio" --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}' \
                ${rse}
}


create_rse_LCLS_NERSC() {
    rse=LCLS_NERSC
    
    rucio-admin rse add --non-deterministic ${rse}
    rucio-admin rse set-attribute --rse ${rse} --key istape --value False
    rucio-admin rse set-attribute --rse ${rse} --key fts --value "https://134.79.129.252:8446"
        
    rucio-admin rse add-protocol --hostname 128.55.205.21 --scheme root --prefix "//psdm/rucio" --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}' \
                ${rse}
}



create_rse() {
    # ${LCLS_regd}
    rucio-admin rse add --non-deterministic ${LCLS_regd}
    rucio-admin rse set-attribute --rse ${LCLS_regd} --key istape --value False
    rucio-admin rse set-attribute --rse ${LCLS_regd} --key fts --value "https://rucio-dev.slac.stanford.edu:8446"

    rucio-admin rse add-protocol --hostname localhost --scheme file --prefix /reg/d/psdm --impl "rucio.rse.protocols.posix.Default" \
                --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy": 0, "delete": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' \
                ${LCLS_regd}
    
    rucio-admin rse add-protocol --hostname psexport06.slac.stanford.edu --scheme root --prefix /psdm/misc/test --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 0, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 0, "delete": 0}}' \
                ${LCLS_regd}
    
    # ${NERSC_dtn}
    rucio-admin rse add --non-deterministic ${NERSC_dtn}
    rucio-admin rse set-attribute --rse ${NERSC_dtn} --key istape --value False
    rucio-admin rse set-attribute --rse ${NERSC_dtn} --key fts --value "https://rucio-dev.slac.stanford.edu:8446"
    
    rucio-admin rse add-protocol --hostname dtn04.nersc.gov --scheme root --prefix /psdm/test/rucio --port 2076 \
                --impl 'rucio.rse.protocols.xrootd.Default' \
                --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}' \
                ${NERSC_dtn}

    rucio-admin  account set-limits root ${NERSC_dtn} 1TB
    rucio-admin  account set-limits root ${LCLS_regd} 1TB
}


info_all() {
    case "${1:-all}" in
        account|all)
            rucio-admin  account get-limits ${Account} ${LCLS_regd}
            rucio-admin  account get-limits ${Account} ${NERSC_dtn}
            ;;&
        scope|all)
            rucio-admin  scope list --account ${Account}
            ;;&
        dist|all)
            rucio-admin rse get-distance  ${LCLS_regd} ${NERSC_dtn}
            rucio-admin rse get-distance  ${NERSC_dtn} ${LCLS_regd}
            ;;&
        rse|all)
            rucio-admin rse info ${LCLS_regd}
            rucio-admin rse info ${NERSC_dtn}
            ;;&
    esac
}


create_exper_container() {
    echo "Create container"
    rucio add-container ${Scope}:xtc
}


set_distance() {
    rucio-admin rse add-distance --distance 1 --ranking 1 LCLS_DATA LCLS_NERSC
    rucio-admin rse add-distance --distance 1 --ranking 1 LCLS_NERSC LCLS_DATA
    rucio-admin rse get-distance LCLS_DATA LCLS_NERSC
    rucio-admin rse get-distance LCLS_NERSC LCLS_DATA
}


set_limits() {
    rucio-admin  account set-limits wilko LCLS_DATA  10TB
    rucio-admin  account set-limits wilko LCLS_NERSC 10TB
}



#create_rse_LCLS_DATA
#create_rse_LCLS_NERSC
#set_distance
set_limits


#mode=${1:?}
#shift 1 
#case "${mode}" in
#    scope) create_scope ;;
#    rse) create_rse ;;
#    ds) create_exper_container ;;
#    distance) set_distance ;;
#    qq) qq ;;
#    *) info_all "$@" ;;
#esac
