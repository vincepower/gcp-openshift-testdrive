# Deploying Test Drive on GCP

The version really matters when setting the RHEL repositories.

## Required images

Five images are required for this to work. I used image families so I can iterate without changing this script.

* ocp39-master
* ocp39-infra
* ocp39-node1
* ocp39-node2
* ocp39-docker (This is essential an empty disk with a volume group)

Each image will 
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

## Run the deployment

```gcloud deployment-manager deployments create --template install.jinja <deployment_name>```

