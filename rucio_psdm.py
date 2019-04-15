#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import zlib

from rucio.client.replicaclient import ReplicaClient
from rucio.client.scopeclient import ScopeClient
from rucio.client.didclient import DIDClient
from rucio.common.exception import DataIdentifierNotFound
from rucio.common.exception import FileAlreadyExists

def adler32(fn):
    data = open(fn).read()
    return "{:>08s}".format(hex(zlib.adler32(data) & 0xffffffff)[2:])

    
def reg_file_list(dids):
    """ add files for a run to rucio.
    attach the files to a run data set:
    filenames:  <scope>:xtc.file.<fn>
    dataset:    <scope>:xtc.runNNNNN
    """

    print("Add files to RUCIO")
    if len(dids) == 0:
        print("No files to add")
        return 0
    
    dids_to_register = []
    scopes = set()
    for did in dids:
        nd = {
            'pfn': "file:{}".format(did['pfn']),
            'bytes': os.path.getsize(did['pfn']),
            'adler32': adler32(did['pfn']),
            'name': did['name'],
            'scope': did['scope']
            }
        dids_to_register.append(nd)
        scopes.add(did['scope'])
        print(nd)

    print(scopes)
    if len(scopes) != 1:
        print("Wrong number of scopes", len(scopes))
        return 2

    # register files to xtc.files
    client = ReplicaClient()
    client.add_replicas('LCLS_REGD', dids_to_register)
    
    # add files to run dataset
    known_run_ds = {}
    client = DIDClient()
    for did in dids:
        run = did['run']
        scope = did['scope']
        if run not in known_run_ds:
            run_ds = "xtc.run%05d" % run
            try:
                client.get_did(scope, run_ds)
            except DataIdentifierNotFound:
                print("Create new dataset", run_ds)
                client.add_dataset(scope, run_ds)
                client.add_datasets_to_container(scope, 'xtc', [{'scope': scope, 'name': run_ds},])   
            known_run_ds[run] = run_ds

        ds = known_run_ds[run]
        try:
            client.attach_dids(scope, run_ds, [{'scope': scope, 'name': did['name']}])
        except FileAlreadyExists:
            print("File already exists", did['name'])
        else:
            print("attached", ds, did['name'])
