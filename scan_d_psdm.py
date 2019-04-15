#!/usr/bin/env python
"""
Scan /reg/d/psdm experiment folders and register the found xtc files 

Usage:
   scan_d_psdm.py path [load]
with: 
   path: the root directory to start the scan
   by default only the found files are listed. with
  *load* as second argument the files are loaded to rucio 
Example:
   Show only found files:
   % ./scan_d_psdm.py  /reg/d/psdm/rte/rtel00119/xtc
   Load to rucio
   % ./scan_d_psdm.py  /reg/d/psdm/rte/rtel00119/xtc load
"""

from __future__ import print_function

import os
import sys
import os.path as op

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
    scope = exper
    ds = "xtc"

    for did in cl.list_dids(scope,{'name': "xtc.files.*"},type='file'):
        print(did)
        known_dids.add(did)
        #print(type(did['name']), did['name'])
    print("Know dids for ", scope, ds, known_dids)

    to_add = []
    for fn in os.listdir(path):
        if not op.isfile(op.join(path, fn)):
            print("not a file, skip", fn)
            continue
        try:
            _, name, runtok, streamtok = os.path.splitext(fn)[0].split('_')
        except ValueError:
            print("Wrong file format", fn)
            continue

        name = "xtc.files.{}".format(fn)                   # xtc.e_mfxte1234_0002_s0002.xtc
        smdname = "xtc.files.{}".format(fn.replace('.xtc','.smd.xtc'))
    
        if name in known_dids:
            print("File alredy in dataset")
            continue
        
        run_number = int(runtok[1:])
        stream = int(streamtok[1:])
        to_add.append( {
            'pfn': os.path.join(path, fn), 
            'scope': scope, 'name': name, 'run': run_number,
        })
        smdpfn = op.join(path, 'smalldata', fn.replace('.xtc', '.smd.xtc'))
        to_add.append( {
            'pfn': smdpfn, 
            'scope': scope, 'name': smdname, 'run': run_number,
        })        
    return to_add


def scan():

    to_add = scan_experiment_directory(sys.argv[1])
    print(to_add)
    
    if len(sys.argv) > 2 and sys.argv[2] == 'load':
        rp.reg_file_list(to_add)
    else:
        print("Don't add to rucio")
        
if __name__ == "__main__":

    scan()
    #wk.list_dids()
    #main()
