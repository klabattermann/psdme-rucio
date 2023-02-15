#!/usr/bin/env python
#
# Register a file using LCLS format
#


from rucio.client.replicaclient import ReplicaClient
client = ReplicaClient() 

data = {
    'pfn': "root://xrd1:1094//rucio/test/wk/f12",
    'bytes': 37,
    'adler32': 'b574090f',
    'md5': '75a52fbed4a51c4931151ecaf1788670',
    'name': "wk.wk01.xtc.f12",
    'scope': "wk01",
}

client.add_replicas('PCDS', [data])
