#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import zlib

from rucio.client.replicaclient import ReplicaClient
from rucio.client.scopeclient import ScopeClient
from rucio.client.didclient import DIDClient


def adler32(fn):
    data = open(fn).read()
    return "{:>08s}".format(hex(zlib.adler32(data) & 0xffffffff)[2:])

    
def reg_file_list(dids):
    print("Add files to RUCIO")
    
    if len(dids) == 0:
        print("No files to add")
        return 0
    
    dids_format = []
    scopes = set()
    for did in dids:
        nd = {
            'pfn': "file:{}".format(did['pfn']),
            'bytes': os.path.getsize(did['pfn']),
            'adler32': adler32(did['pfn']),
            'name': did['name'],
            'scope': did['scope']
            }
        dids_format.append(nd)
        scopes.add(did['scope'])
        print(nd)

    print(scopes)
    if len(scopes) != 1:
        print("Wrong number of scopes", len(scopes))
        return 2
        
    # register files
    client = ReplicaClient()
    client.add_replicas('PSDM_DISK', dids_format)
    
    client = DIDClient()
    # add to dataset
    scope = scopes.pop()
    client.attach_dids(scope, 'xtc', dids_format)
    # Set runnumber 
    for did in dids:
        scope, name, run = did['scope'], did['name'], did['run']
        print(scope, name, run)
        client.set_metadata(scope, name, 'run_number', run)
