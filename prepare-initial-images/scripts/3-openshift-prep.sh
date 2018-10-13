#!/bin/bash
##
## RUN AS ROOT
##
## Run this once the VM is running in GCP, after the
## data disk is attached, repositories enabled, and
## the other initial setup stuff
##

## Grow Root File System
echo "====================================="
echo $(date) " - Grow Root FS"
rootdev=`findmnt --target / -o SOURCE -n`
rootdrivename=`lsblk -no pkname $rootdev`
rootdrive="/dev/"$rootdrivename
name=`lsblk  $rootdev -o NAME | tail -1`
part_number=${name#*${rootdrivename}}
growpart $rootdrive $part_number -u on
xfs_growfs $rootdev

## Run the dockers setup
echo "====================================="
echo $(date) " - Docker Storage Setup"
docker-storage-setup

## Enable Docker Service
systemctl enable docker

## Start Docker Service
systemctl start docker

## Installing OpenShift rpms
yum install -y openshift-ansible* atomic* *-openshift-* google-cloud-sdk* cockpit*
yum update -y

## Cleanup yum
yum clean all
rm -f /var/cache/yum
yum repolist

