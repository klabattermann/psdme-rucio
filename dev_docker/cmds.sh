#!/bin/bash

delete_rules() {
    
    for rid in $(rucio list-rules --account root | awk ' $2 == "root" && $4 ~ /^OK/ {print $1}') ; do
        rucio  update-rule --lifetime 1 ${rid} 
        rucio delete-rule ${rid}
    done
    sleep 1
    rucio-judge-cleaner --run-once
}

delete_rules
