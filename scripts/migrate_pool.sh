#!/bin/bash
# Brett Kelly, 45Drives 2018
# https://ceph.com/geen-categorie/ceph-pool-migration/
# --------------------
# This script is used to migrate all objects from one pool to another while keeping the same pool name.
# Useful when needing to change an unchangeable parameter on an exiting pool such as.
# - Migrate from EC to replicated or vice versa
# - Change EC profile (ex from 4+2 to 8+4)
# - Change number of PGs 


usage() {
        cat << EOF
Usage:
    sh migrate_pool.sh POOLNAME PG POLICY RULE APPLICATION
    ORDER OF INPUT MATTERS !!!
        POOLNAME = name of pool to be migrated
        PG = # number of PG for new pool
        POLICY = erasure or replicated
        RULE = crush rule name
        APPLICATION = application of the new pool  
EOF
        exit 0
}

POOL=$1 # name of pool to be migrated
PG=$2 # number of PG for new pool
POLICY=$3 #erasure or replicated
RULE=$4 #crush rule name
APPLICATION=$5 # application of the new pool   

if [ -z $POOL ];then
    echo "Input required"
    usage
    exit 1
elif ceph osd lspools | grep -wq "$POOL$" ;then
    :
else
    echo "$POOL is not present on cluster"
    exit 1
fi

ceph osd pool create $POOL.new $PG $PG $POLICY $RULE
rados cppool $POOL $POOL.new
ceph osd pool rename $POOL $POOL.old
ceph osd pool rename $POOL.new $POOL
if [ ! -z $APPLICATION ];then
    ceph osd pool application enable $POOL $APPLICATION
fi

