#!/bin/bash
DASHBOARD_PASSWORD='admin'
DASHBOARD_PORT='8443'
RGW_ACCESS_KEY='admin'
RGW_SECRET_KEY='pr0t0case'
RGW_HOST='rgw3.45lab.com' #DNS name of Rados Gateway, if using multiple rgws and load balancing this would be the DNS of the load balancer not the indivual RGW hosts
RGW_PORT='80' #Port that RGW servers https requests on
RGW_API_SCHEME='http' #http and https supported

ceph dashboard create-self-signed-cert
ceph dashboard ac-user-create admin $DASHBOARD_PASSWORD administrator 
ceph config set mgr mgr/dashboard/server_port $DASHBOARD_PORT
radosgw-admin user create --uid=admin --display-name=RGWadmin --access-key=$RGW_ACCESS_KEY --secret=$RGW_SECRET_KEY --system
ceph dashboard set-rgw-api-access-key $RGW_ACCESS_KEY
ceph dashboard set-rgw-api-secret-key $RGW_SECRET_KEY
ceph dashboard set-rgw-api-host $RGW_HOST
ceph dashboard set-rgw-api-port 80
ceph mgr module disable dashboard
ceph mgr module enable dashboard
sleep 4
ceph mgr services
