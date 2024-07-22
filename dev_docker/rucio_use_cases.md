
# Setup

## Data Flow

    - LCLS file are initially written to the FFB
    - Dedicated mover transfer the files from  the FFB to ANA-FS (Weka sdfdata)
    - Files on ANA-FS are registered to RUCIO
    - xtc and smd.xtc files are registered, in the past we didn't register idx files and they were not archived to tape (could do some tar archive).
    - RUCIO responsibility:
      - archive data to tape at SLAC and NERSC (and possible other archive sites)
      - purge files from disk if space is needed, follow retention rules
      - restore user requersted runs
      - replicate files e.g.: to NERSC for processing, handle lifetime e.g. purge after some time

## Naming

## Scope
   instr.expt or instr/expt (currently not working)

## did xtc

    We could allow usinf slashes in names:
    1) match disk names
        xtc/tst12345-r001-s002-c000.xtc2
        xtc/smalldata/tst12345-r001-s002-c000.smd.xtc2
    2) no subdir
        xtc/tst12345-r001-s002-c000.xtc2
        xtc/tst12345-r001-s002-c000.smd.xtc2

## did names to pfn

    When a file is replicated the did and the destination RSE's prefix will be used to calculate the pfn.
    For a deterministic resource if *identity* is used the did name is just prepended to the RSE prefix (What about the scope??).

    For a non-deterministic resource a surl function is called with the did and scope as arguments that allows a more flexible
    did -> pfn conversion.


# Use cases

## Register new files

    After a file has been copied to ANA-FS it is registered to RUCIO and added to the proper datasets.
    Size and metadata are part of the registration.

## register old files

    Register files and their replicas to RUCIO.
    When migrating from iRods to Rucio all old files need to be registered including their replicas.

## Archive to tape at SLAC

    A replication rule shall copy a file to HPSS at slac. The only IO operations must be only the transfer to tape
    (e.g. using hsi).
    RUCIO itself doesn't support this in an obvious way.  A work around is to have an XrootD archive resource that uses the TPC script
    to copy a file to tape and "fake" the transfer (a TPC transfer will check if the dest file has been created and will stat it periodically).
    Q:
      - can the stat be modified using the oss plugin
      - hpss could be mounted with fuse and the stat would be against it

## Remote archive

    A replication rule shall copy a file to a remote HPSS.
    Current scheme:
    - use xrootd resource to treansfer file to remote sites file system
    - xrootd's frm does the migration to tape
    - FTS will check if file is on disk
    - there should be other checks:
      - checksum got copied to hpss
      - verify checksum (FTS will do it against the disk file)

## replicate disk to disk

    replicate runs/files from one disk resource to another e.g:
        ANA-FS -> PSCRACTH  (perlmutter)

## replicate files/runs:  restore from tape

    Restore a purged run from tape to a dis restore:
    Common use case:
       HPSS@SLAC -> ANA-FS
    Less common:
       HPSS@nersc -> ANA-FS
       HPSS@slac -> nersc (e.g cfs or PSCRATCH)

    Are caches needed ? 

