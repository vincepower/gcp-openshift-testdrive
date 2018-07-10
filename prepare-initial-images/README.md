# Preparing Test Drive Images

The version really matters when setting the RHEL repositories.

## Required image

One image is required for this to work. I used image families so I can iterate without changing this script. This base image has all the prep work done to it already, except setting up storage, making sure the / disk is big enough, and subscribing to RHSM for entitlements.

* rhel7ocp3

The image has 
* RHEL 7.5 or higher 
* Needs access to the following RHEL repositories
  - rhel-7-server-rpms
  - rhel-7-server-extras-rpms
  - rhel-7-fast-datapath-rpms
  - rhel-7-server-ansible-2.4-rpms (or rhel-7-server-ansible-2.5-rpms)
  - rhel-7-server-ose-3.9-rpms
* Be be deployed using an n1-standard-2 (2 vCPUs, 7.5 GB memory) Virtual Machine instance
* Have two partitions
  - 500MB+ /boot
  - 40GB+ / (root is only 3.5GB in the image)
* Need a data disk added and configured for docker storage


## Deploy instances

This image will be used to finish all prep work between making an image and what will be used in the actual Test Drive, like docker-storage, sizing the disk, subscribing to RHSM, etc. If you use this deployment and look in root's home directory (/root), it should be a fairly quick process to finish the prep then make the two final images from this instance.

To launch:
```gcloud deployment-manager deployments create --template install.jinja <deployment_name>```
