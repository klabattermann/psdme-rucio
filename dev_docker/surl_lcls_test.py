#
# test the LCLS surl function  (./common/utils.py)
#

import hashlib

def construct_surl_LCLS(dsn: str, scope: str, filename: str) -> str:
    """
    Defines relative SURL for replicas. This method uses the LCLS convention
    for xtc files. To be used for non-deterministic sites.

    @param: dsn as dataset name of format <instrument>.<experiment>.xtc.<run-nr>
    @return: relative SURL for new replica.
    @rtype: str
    """
    #print("WKWK surl dsn:", dsn, "scope:", scope, "fn:", filename)

    # If we have a dataset, assume standard data path. 
    if dsn == "xtc":
        if dsn == 'xtc' and filename.find('smd.xtc') > 0:
            return '/%s/%s/%s/smalldata/%s' % (scope[:3], scope, dsn, filename)
        return '/%s/%s/%s/%s' % (scope[:3], scope, dsn, filename)

    try:
        instr, expt, fld, remain = filename.split('.', 3)
    except ValueError:
        use_hash = True
    else:
        use_hash = False if fld in ('xtc', 'hdf5') else True

    if use_hash:
        md5 = hashlib.md5(filename.encode()).hexdigest()
        return '/hash/%s/%s' % (md5[:3], filename)
    else:
        if fld == 'xtc' and filename.endswith('smd.xtc'):
            return '/%s/%s/xtc/smalldata/%s' % (instr, expt, remain)
        return '/%s/%s/%s/%s' % (instr, expt, fld, remain)


if __name__ == "__main__":

    dsn = "other"
    scope = "wk01"
    fn =  "wk.wk01.xtc.f12"

    tests = []
    tests.append(("other", "wk01", "wk.wk01.xtc.f12"))
    tests.append(("other", "wk01", "xtc.f12"))
    tests.append(("xtc", "wk01", "f12"))
    tests.append(("xtc", "wk01", "f12.smd.xtc"))

    for tst in tests:
        print(construct_surl_LCLS(*tst), " INPUT", " ".join(map(str, reversed(tst))))

