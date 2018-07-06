# Google Cloud Platform OpenShift TestDrive for v3.9 and higher
The version really matters when setting the RHEL repositories.

## Required images

Four images are required for this to work. I used image families so I can iterate without changing this script.

* ocp39-master
* ocp39-infra
* ocp39-node1
* ocp39-node2

Each image will 
* Run RHEL 7.5 or higher 
* Be able to access the following RHEL repositories
  - rhel-7-server-rpms
  - rhel-7-server-extras-rpms
  - rhel-7-fast-datapath-rpms
  - rhel-7-server-ansible-2.4-rpms (or rhel-7-server-ansible-2.5-rpms)
  - rhel-7-server-ose-3.9-rpms
* Be be deployed using an n1-standard-2 (2 vCPUs, 7.5 GB memory) Virtual Machine instance
* Have three partitions
  - 500MB+ /boot
  - 40GB / (root)
  - 10GB+ assigned as a docker volume group and not mounted


