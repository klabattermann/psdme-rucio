#!/usr/bin/env python
#
# Create PSDM rse that is used to register psdm files in the
# /reg/d/psdm path

import os

from rucio.api.scope import add_scope
from rucio.api.rse import add_rse
from rucio.core.account_limit import set_account_limit
from rucio.core.rse import add_protocol, get_rse_id, add_rse_attribute


def create_rse_psdm():
    prefix = "/reg/d/psdm"

    if not os.path.exists(prefix):
        os.makedirs(prefix)

    params = {
        'scheme': 'file',
        'prefix': prefix,
        'impl': 'rucio.rse.protocols.posix.Default',
        'domains': {"lan": {"read": 1,
                            "write": 1,
                            "delete": 1},
                    "wan": {"read": 1,
                            "write": 1,
                            "delete": 1}}}
    add_rse('PSDM_DISK', 'root', deterministic=False)
    add_protocol('PSDM_DISK', params)
    add_rse_attribute(rse='PSDM_DISK', key='istape', value='False')


def create_scope(scope):
    add_scope(scope, 'root', 'root')
    set_account_limit('root', get_rse_id('PSDM_DISK'), 100000000000)


if __name__ == '__main__':
    create_rse_psdm()
    create_scope('rtel12318')
