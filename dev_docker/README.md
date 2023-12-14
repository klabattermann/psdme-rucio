
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

There are some changes in rucio v33 and the instruction might not work with older versions. 


### Clone rucio clone

```code
  % git clone git@github.com:klabattermann/rucio.git
  #% git checkout feature-lcls
  % git checkout lcls-use-policy
```

The old not-used-anymore *feature-lcls* branch contains the LCLS policies (surl functions in the rucio code) but now we 
are using the POLICY_PACKAGE.

### clone psdme-rucio

```code
  % git clone git@github.com:klabattermann/psdme-rucio.git
  % cd docker_dev
  % ln -s <path-to-rucio-clone-repo>
```

### start/stop container

The LCLSRucioPolicy is read from *psdme-rucio/docker_dev/lcls/*.

cd to psdme-rucio repo and psdme-rucio/docker_dev (this folder must contain a link to the rucio repo).

```code
  # start docker  (if needed)
  % ./docker_start.sh docker

  # start/stop container
  % ./docker_start.sh start|stop
```

## Initialze database and RUCIO resources

Before using RUCIO the database has to be initialized and we are greating a few rucio-storage-elements
(rse). Some rse's are created by the test script that comes with rucio other are created by the
*dev_setup.sh* one: (running in docker: docker exec -it dev_rucio_1 bash).

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
- S3DF
  - disk resource
  - host: xrd2
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
### DIDs and scope 

```code
% rucio list-dids --filter "type=all" wk01:*
% rucio list-file-replicas wk01:xtc.wk01-r00110-s01-c00.xtc2

% rucio  list-scopes 
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

    # rules that failed  (this didn't work)
    % rucio update-rule --stuck <<rule-ID>
    % rucio update-rule --boost-rule <<rule-ID>
    # unstuck the rule and put back to replicating status
    % rucio-judge-repairer --run-once 

    % rucio update-rule --lifetime 1 <rule-ID>
    % rucio-judge-cleaner --run-once
```

## Database

### Connection

```code
    % psql -U postgres
    rucio# set search_path to dev;
```

### Tables

dids:

scope, name, bytes, checksums, many other meta-data

replicas:

scope, name, bytes, checksum, path, rse
A FK references entries in the dids table:
"REPLICAS_LFN_FK" FOREIGN KEY (scope, name) REFERENCES dids(scope, name)

## Notes

adding a file but no replica using the api:  DIDClient().add_did('test', 'wk_test1', 'file', 'root') fails with:
   rucio.common.exception.UnsupportedOperation: The resource doesn't support the requested operation.
   Details: Only collection (dataset/container) can be registered.


