#!/usr/bin/env python
#
# Register a file using LCLS format
#


from rucio.client.replicaclient import ReplicaClient
from rucio.client.didclient import DIDClient
client = ReplicaClient() 

data = {
    'pfn': "root://xrd1:1094//rucio/test/wk/f12",
    'bytes': 37,
    'adler32': 'b574090f',
    'md5': '75a52fbed4a51c4931151ecaf1788670',
    'name': "wk.wk01.xtc.f12",
    'scope': "wk01",
}

data = {
    'pfn': "posix:///home/data/f1",
    'bytes': 37,
    'md5': '217b326c52ae1fda54a6e6d0423f429b',
    'name': "h.f1",
    'scope': "wk01",
}

client.add_replicas('S3DF', [data])


# Does not work 
#rcl = DIDClient()
#rcl.add_did('test', 'wk_test1', 'file', 'root')


