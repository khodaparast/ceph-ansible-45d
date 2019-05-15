#!/bin/bash

## VARIBLES
HOME=$(pwd)

## DEPENDENCIES
yum install -y -q -e 0 pyparsing python-kmod python-gobject python-urwid \
    python-rados python-rbd python-netaddr python-netifaces \
    python-crypto python-requests python-flask pyOpenSSL git



## DOWNLOAD SOURCE PACKAGES
git clone https://github.com/open-iscsi/tcmu-runner
git clone https://github.com/open-iscsi/rtslib-fb.git
git clone https://github.com/open-iscsi/configshell-fb.git
git clone https://github.com/open-iscsi/targetcli-fb.git
git clone https://github.com/ceph/ceph-iscsi.git

## TCMU-RUNNER
cd $HOME
cd tcmu-runner
sed -e '/glusterfs-api/ s/^#*/#/' -i extra/install_dep.sh
sh extra/install_dep.sh
cmake -Dwith-glfs=false -Dwith-qcow=false -DSUPPORT_SYSTEMD=ON -DCMAKE_INSTALL_PREFIX=/usr
make
make install
systemctl daemon-reload
systemctl enable tcmu-runner
systemctl start tcmu-runner

## rtslib-fb
cd $HOME
cd rtslib-fb
python setup.py install --record uninstall.txt

## configshell-fb
cd $HOME
cd configshell-fb
python setup.py install --record uninstall.txt

## targetcli-fb
cd $HOME
cd targetcli-fb
sed -i '/\[base\]/a exclude=targetcli*' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/\[updates\]/a exclude=targetcli*' /etc/yum.repos.d/CentOS-Base.repo
python setup.py install --record uninstall.txt
mkdir /etc/target
mkdir /var/target

## ceph-iscsi
cd $HOME
cd ceph-iscsi
python setup.py install --record uninstall.txt
cp usr/lib/systemd/system/rbd-target-gw.service /lib/systemd/system
cp usr/lib/systemd/system/rbd-target-api.service /lib/systemd/system



cat << EOF > /etc/ceph/iscsi-gateway.cfg
[config]
# Name of the Ceph storage cluster. A suitable Ceph configuration file allowing
# access to the Ceph storage cluster from the gateway node is required, if not
# colocated on an OSD node.
cluster_name = ceph

# Place a copy of the ceph cluster's admin keyring in the gateway's /etc/ceph
# drectory and reference the filename here
gateway_keyring = ceph.client.admin.keyring

# API settings.
# The API supports a number of options that allow you to tailor it to your
# local environment. If you want to run the API under https, you will need to
# create cert/key files that are compatible for each iSCSI gateway node, that is
# not locked to a specific node. SSL cert and key files *must* be called
# 'iscsi-gateway.crt' and 'iscsi-gateway.key' and placed in the '/etc/ceph/' directory
# on *each* gateway node. With the SSL files in place, you can use 'api_secure = true'
# to switch to https mode.
# To support the API, the bear minimum settings are:
api_secure = false

# Additional API configuration options are as follows, defaults shown.
# api_user = admin
# api_password = admin
# api_port = 5001
# trusted_ip_list = 192.168.0.10,192.168.0.11
EOF

systemctl daemon-reload
systemctl enable tcmu-runner ; systemctl start tcmu-runner
systemctl enable rbd-target-gw ; systemctl start rbd-target-gw 
systemctl enable rbd-target-api ; systemctl start rbd-target-api
