#!/usr/bin/env python

from rucio.client.replicaclient import ReplicaClient

client = ReplicaClient() 


#data = {
#    'pfn': "root://134.79.103.90:2076//psdm/rucio/rte/rte01/xtc/rte01-r0001-s01-c00.xtc",
#    'bytes': 104857600,
#    'md5': 'bfec14dd0fd2e733df4a7d00511f5a0c',
#    'name': "xtc.file.rte01-r0001-s01-c00.xtc",
#    'scope': "rte01",
#}


data = {
    'pfn': "root://134.79.103.90:2076//psdm/rucio/rte/rte01/xtc/rte01-r0002-s02-c00.xtc",
    'bytes': 1073741824,
    'adler32': '897ea592',
    'md5': 'a0c84f769c76989f87a44b59409d73ea',
    'name': "rte.rte01.xtc.rte01-r0002-s02-c00.xtc",
    'scope': "psdm",
}


client.add_replicas('LCLS_DATA', [data])
