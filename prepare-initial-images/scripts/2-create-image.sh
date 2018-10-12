#!/bin/bash

##
## This script is used to upload the prepared image to gcp
##
## It assumes a storage account exists, and you are running
## on a Mac that has Virtual Box and has GNU tar installed
## (home brew is your friend if you need gtar)
##

GCPSTORAGE=vpdiskimages

if [ "$1" == "" ]
then
  echo "Usage: $0 <version_number>"
  exit 1
fi

echo "== Cleaning up any previous partial runs"
rm -f disk.raw /tmp/compressed-image.tar.gz

echo "== Exporting to RAW"
VBoxManage clonehd gcp.vdi disk.raw --format RAW

echo "== Compressing the disk"
gtar -Sczf /tmp/compressed-image.tar.gz disk.raw && rm -f disk.raw

echo "== Uploading the disk"
gsutil cp /tmp/compressed-image.tar.gz gs://$GCPSTORAGE && rm -f /tmp/compressed-image.tar.gz

echo "== Creating the image"
gcloud compute images create rhel7ocp311-v$1 --description="RHEL 7.5 Image for OCP 3.11 (Cloud Access)" --family=rhel7ocp311 --source-uri=gs://$GCPSTORAGE /compressed-image.tar.gz

echo "== Final clean-up"
rm -f disk.raw /tmp/compressed-image.tar.gz

