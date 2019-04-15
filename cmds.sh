#!/bin/bash




set -x
case ${1:-sync} in
    sync)
        rsync -av --files-from to_sync . rucio-dev:github/psdme-rucio/.
        ;;
esac
