#!/bin/bash 

rucio-admin  rse delete-protocol --scheme root  PSDM_DISK
rucio-admin  rse delete-protocol --scheme root  PSDM_NERSC 

rucio-admin rse add-protocol --hostname psexport06.slac.stanford.edu --scheme root --prefix /psdm/misc/test --port 2076 \
	  --domain-json '{"wan": {"read": 1, "write": 0, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 0, "delete": 0}}' PSDM_DISK 

rucio-admin rse add-protocol --hostname dtn04.nersc.gov --scheme root --prefix /psdm/rucio/test --port 2076 \
	 --domain-json '{"wan": {"read": 1, "write": 1, "third_party_copy": 1, "delete": 0}, "lan": {"read": 1, "write": 1, "delete": 0}}' PSDM_NERSC 

