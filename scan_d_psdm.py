#!/usr/bin/env python
#
# Scan /reg/d/psdm experiment folders and register xtc files 
#

from __future__ import print_function

import os
import sys

from rucio.client.replicaclient import ReplicaClient
from rucio.client.scopeclient import ScopeClient
from rucio.client.didclient import DIDClient

import rucio_psdm as rp


def scan_experiment_directory(path):
    """ Register all xtc file in a directory to RUCIO """

    exper_per_scope = True
    
    token = os.path.normpath(path).strip('/').split('/')
    instr, exper, dtype = token[3:6]

    # get all known dids
    known_dids = set()
    cl = DIDClient()
    if exper_per_scope:
        scope = exper
        ds = "xtc"
    else:
        scope = 'xtc'
        ds = '{}.{}'.format(instr,exper)

    for did in cl.list_content(scope, ds):
        known_dids.add(did['name'])
        #print(type(did['name']), did['name'])
    print("Know dids for ", scope, ds, known_dids)

    to_add = []
    for fn in os.listdir(path):
        try:
            _, name, runtok, streamtok = os.path.splitext(fn)[0].split('_')
        except ValueError:
            print("Wrong file format", fn)
            continue

        if exper_per_scope:
            name = "xtc.{}".format(fn)                   # xtc.e_mfxte1234_0002_s0002.xtc
        else:
            name = "{}.{}.{}".format(instr, exper, fn)  # mfx.mfxte1234.e_mfxte1234_0002_s0002.xtc

        if name in known_dids:
            print("File alredy in dataset")
            continue
        
        run_number = int(runtok[1:])
        stream = int(streamtok[1:])
        to_add.append( {
            'pfn': os.path.join(path, fn), 
            'scope': scope, 'name': name, 'run': run_number,
        })
    return to_add


def scan():

    to_add = scan_experiment_directory(sys.argv[1])
    print(to_add)
    rp.reg_file_list(to_add)
    #print(to_add)
    
    #to_add = []
    #for pfn in sys.argv[1:]:
    #    if os.path.isdir(pfn):
    #        to_add.extend(scan_directory(pfn))
    #    else:
    #        print("Not implemented", pfn)
    #wk.reg_file_list(to_add)

        
if __name__ == "__main__":

    scan()
    #wk.list_dids()
    #main()
