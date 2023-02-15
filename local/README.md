
# Running RUCIO dev environment

## Installation and running

The RUCIO docker dev environemnt of the RUICO repo is used for locally
testing the LCLS setup. Running the container requires two repositories:

1) rucio.git
   A clone of the rucio repository that contains the LCLS specific code changes
   and docker files.
2) klabattermann/psdme-rucio
   Configuration that are used by the running rucio daemons
   and tools to configure RUCIO.

### Clone rucio clone

```code
  % git clone git@github.com:klabattermann/rucio.git
  % git checkout feature-lcls
```

### clone psdme-rucio

```code
  % git clone git@github.com:klabattermann/psdme-rucio.git
  % cd docker_dev
  % ln -s <path-to-rucio-clone-repo>
```

### start/stop container

cd to psdme-rucio repo and psdme-rucio/docker_dev (this folder must contain a link to the rucio repo).

```code
  # start docker  (if needed)
  % ./dev_start.sh docker

  # start/stop container
  % ./dev_start.sh cont [start|stop]
```

## Initialze database and RUCIO resources

Before using RUCIO the database has to be initialized and we are greating a few rucio-storage-elements (rse).
Some rse's are created by the test script that comes with rucio other are created by the *dev_setup.sh* one:

```code
    % cd /opt/rucio
    % ./tools/run_tests_docker.sh -ir
    DON'T forget the -ir otherwise many tests will be run

    % cd /home
    % ./dev_setup.sh  resc
    % ./dev_setup.sh files
```

## Created Resources

After the above initialization the following resources exists: 

- XRD1, XRD2, XRD2 (rse's and container)
  These three container run xrootd using the defaut configuration. They standard xrootd servers 
  the allow to read/write files.
- XRD4 (container and rse)
  This xrootd server is configured as an tape interface. It is started with *start_xrd.sh* and use the 
  configuration *xrootd_tape.cf*:
  - configure the prepare so the FTS is-on-tape is handled properly using the *preppgm* script
  - Use a special TPC command that will avoid transferring the file as it already exists in the file 
    system. 
- NERSC
  - disk resource
  - host: xrd1 
- STAPE
  - host xrd4
  - istape: True
  - rse_type: DISK

- TTAPE
  - host: xrd4
  - istape: True
  - rse_type: TAPE

## Commands

### Container

```code
% echo 'flush_all' | nc localhost 11211 && httpd -k graceful
% httpd -k graceful
% docker run -it --entrypoint /bin/bash  rucio/xrootd
% docker  image inspect e1c56c459340
% docker-compose --file etc/docker/dev/docker-compose-storage-wk.yaml  restart xrd4
```

### RSE 

```code
    % rucio-admin rse list
    % rucio-admin rse info NERSC
```
### DIDs

```code
% rucio list-dids --filter "type=all" wk01:*
% rucio list-file-replicas wk01:wk.wk01.xtc.f12
```

### Rules and Replication

```code
    % rucio add-rule wk01:wk.wk01.xtc.f12 1 NERSC
    % rucio add-rule --source-replica-expression XRD3  test:file3 1 NERSC
    % rucio list-rules --account root

    # the conveyor daemons need to run to execute rules 
    % rucio-conveyor-submitter --run-once
    % rucio-conveyor-poller --run-once --older-than 1
    % rucio-conveyor-finisher --run-once


    % rucio update-rule --lifetime 1 <rule-ID>
    % rucio update-rule --lifetime 1 <rule-The script assumes that the docker file is at
    % rucio-judge-cleaner --run-onceThe script assumes that the docker file is at
```
