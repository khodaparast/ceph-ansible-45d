#!/bin/bash
ceph osd crush rule create-replicated ssd default host ssd
ceph osd crush rule create-replicated hdd default host hdd