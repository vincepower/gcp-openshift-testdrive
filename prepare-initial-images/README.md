# Preparing Test Drive Images

The version really matters when setting the RHEL repositories.

## Required image

One image is required for this to work. I used image families so I can iterate without changing this script.

* rhel7ocp3

The image will 
* Run RHEL 7.5 or higher 
* Be able to access the following RHEL repositories
  - rhel-7-server-rpms
  - rhel-7-server-extras-rpms
  - rhel-7-fast-datapath-rpms
  - rhel-7-server-ansible-2.4-rpms (or rhel-7-server-ansible-2.5-rpms)
  - rhel-7-server-ose-3.9-rpms
* Be be deployed using an n1-standard-2 (2 vCPUs, 7.5 GB memory) Virtual Machine instance
* Have two partitions
  - 500MB+ /boot
  - 40GB+ / (root)


## Deploy instances

This deployment will create the base instances that will be used to create the five required instances used in the Test Drive. Once it is deployed then install OpenShift Container Platform, and create an image for each boot disk and one docker disk from a node will be an "golden" docker image.

To launch:
```gcloud deployment-manager deployments create --template install.jinja <deployment_name>```

