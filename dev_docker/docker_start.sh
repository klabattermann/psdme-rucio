#!/bin/bash

set -u

docker_start() {
    for srv in  docker.service containerd.service ; do
        sudo systemctl start ${srv}
        echo "${srv}: $(systemctl is-active ${srv})"
    done
}


start_stop_container() {
    case $1 in
        start) docker-compose --file ${DEV_YAML} up -d  ;;
        stop)  docker-compose --file ${DEV_YAML} down ;;
    esac
    docker ps
}


#DEV_YAML="rucio/etc/docker/dev/docker-compose-storage-wk129.yaml"
DEV_YAML="rucio/etc/docker/dev/docker-compose-storage-wk.yaml"

# PATH to bind to /home wihin containers
export PSDME_DIR=$(pwd -P)/

case $1 in
    dock*) docker_start ;;
    cont*)
        [[ ! -e ${DEV_YAML} ]] && echo "not found ${DEV_YAML} -> exit" && exit 2
        start_stop_container $2
        ;;
    *)
        echo "Unknown cmd $1"
        exit
esac
