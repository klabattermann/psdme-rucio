

def construct_surl_LCLS_SLAC(dsn, filename):

    instr, expt, fld, remain = filename.split('.', 3)
    #print(fields, instr, expt, fld, remain)

    if fld == 'xtc' and filename.endswith('smd.xtc'):
        return '/%s/%s/xtc/smalldata/%s' % (instr, expt, remain)

    return '/%s/%s/%s/%s' % (instr, expt, fld, remain)

    

if __name__ == "__main__":

    filename = "rte.rte01.xtc.rte01-r0002-s02-c00.xtc"
    dsn = "rte.rte01.xtc.run0002"

    pfn = construct_surl_LCLS_SLAC(dsn, filename)
    print(pfn)


    filename = "rte.rte01.xtc.rte01-r0002-s02-c00.smd.xtc"
    pfn = construct_surl_LCLS_SLAC(dsn, filename)
    print(pfn)
