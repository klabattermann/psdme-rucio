#!/bin/bash

set -u

docker_start() {
    for srv in  docker.service containerd.service ; do
        sudo systemctl start ${srv}
        echo "${srv}: $(systemctl is-active ${srv})"
    done
}



start_stop_container() {
    cd /home/wilko/gitrepos/github/klabattermann/rucio/
    case $1 in
        start) docker-compose --file ${DEV_YAML} up -d  ;;
        stop)  docker-compose --file ${DEV_YAML} down ;;
    esac
    docker ps
}


#DEV_YAML="etc/docker/dev/docker-compose-storage-wk.yaml"
DEV_YAML="etc/docker/dev/docker-compose-storage-wk129.yaml"

case $1 in
    dock*) docker_start ;;
    cont*)
        # ./startup cont stop|start
        start_stop_container $2 ;;
    *)
        echo "Unknown cmd $1"
        exit
esac
