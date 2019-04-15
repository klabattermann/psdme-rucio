#!/usr/bin/env python

from rucio.db.sqla import session,models

fn = 'xtc.files.e_rtel00119_r00006_s0001.xtc'
scope = "rtel00119"

#fn = "tests:test.16325.automatix_stream.recon.AOD.201"
#scope = "tests"

print scope, fn
q = session.get_session().query(models.Request).filter_by(scope=scope, name=fn)
print q.count()
print q.first().__dict__



