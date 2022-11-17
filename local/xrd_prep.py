#!/bin/env python




import json 

resp = {}
resp["request_id"] = "fd714986-b223-4ea3-8033-aa452c6a5db7"
resp["responses"] = []

for id in range(8):
    fn = {"path": "/rucio/nersc/tape/f{}".format(id)}
    fn["path_exists"] = True
    fn["on_tape"] = False 
    fn["error_text"] = "No migrated yet"
    resp["responses"].append(fn)

print json.dumps(resp)
