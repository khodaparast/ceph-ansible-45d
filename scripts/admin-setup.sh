#!/bin/bash
# This script will set up an ansible enviroment for a 45drives ceph cluster
# This must be run from the root of the ceph-ansible-45d folder
# It checks for "RELEASE-45D.rst", if not found it will fail.

if [[ ! -a RELEASE-45D.rst ]]; then
	echo "Cant find RELEASE-45D.rst"
	echo "Are you in the right directory ?"
	exit 1
fi

dir=$(pwd)

yum install epel-release -y
yum install python-pip python-devel -y
pip install --upgrade pip
pip install -r requirements.txt
sed -i '/\[base\]/a exclude=ansible*' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/\[extras\]/a exclude=ansible*' /etc/yum.repos.d/CentOS-Base.repo
mkdir /etc/ansible 2>/dev/null
if [ -z "$(ls -A /etc/ansible)" ]; then
	ln -s $dir/* /etc/ansible/
	if [ $?  -eq 0 ]; then
		echo "All done"
	else
		echo "Failed to link files ot /etc/ansible"
	fi
else
	echo ""
	echo "/etc/ansible is not empty. Not linking files"
	exit 1
fi
