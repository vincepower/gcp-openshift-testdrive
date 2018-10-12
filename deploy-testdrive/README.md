# Deploying Test Drive on GCP

The scripts in this directory can be zipped up and uploaded to Orbitera as is.

## Required images

Two images are required for this to work. I used image families so I can iterate without changing this script.

* ocp310-base
* ocp310-docker (This is essential an empty disk with a volume group)

The base image needs to have prepared by the prepare-initial-images scripts/documentation.

## Run the deployment

```
gcloud deployment-manager deployments create --template install.jinja --async <deployment_name>
```

This deployment takes 30 minutes and will install and configure a fresh install of OpenShift 3.11. Describe the deployment to get the output of the console URL, username, and password. GCP has a hard limit of 20 minutes waiting for an interactive response. (It does not install logging or metrics.)

For troubleshooting purposes, the deployment creates 6 files in the /tmp directory. The error ones aren't usually useful, but I'd rather have them than not.

* /tmp/OCP-startup-time - Reports different steps in the startup-script, useful for high level "where am I" feel
* /tmp/prerequisites.stdout - Standard Out for the prerequisites ansible playbook
* /tmp/prerequisites.stderr - Standard Error for the prerequisites ansible playbook
* /tmp/deploy_cluster.stdout - Standard Out for the deploy_cluster ansible playbook
* /tmp/deploy_cluster.stderr - Standard Error for the deploy_cluster ansible playbook
* /tmp/OCP-shutdown-time - Reports different steps in the shutdown-script, useful for high level "where am I" feel

### Output of the deployment
```
$ gcloud deployment-manager deployments create --template install.jinja --async ocptest2
The fingerprint of the deployment is z4XzSxDUMt6-_8_oeIGfYg==
NAME                                                     TYPE    STATUS   TARGET    ERRORS  WARNINGS
operation-1533157371327-572660480b218-597044ce-baab2dd4  insert  PENDING  ocptest2  []      []
$ gcloud deployment-manager deployments list
NAME      LAST_OPERATION_TYPE  STATUS   DESCRIPTION  MANIFEST  ERRORS
ocptest2  insert               RUNNING                         []
$ gcloud deployment-manager deployments describe ocptest2
---
fingerprint: z4XzSxDUMt6-_8_oeIGfYg==
id: '1427601089385963796'
insertTime: '2018-08-01T14:02:51.565-07:00'
name: ocptest2
operation:
  name: operation-1533157371327-572660480b218-597044ce-baab2dd4
  operationType: insert
  progress: 0
  startTime: '2018-08-01T14:02:51.732-07:00'
  status: RUNNING
  user: vpower@redhat.com
update:
  manifest: https://www.googleapis.com/deploymentmanager/v2/projects/openshift-test-drive/global/deployments/ocptest2/manifests/manifest-1533157371568
NAME                         TYPE                          STATE        INTENT
disk-docker-ocptest2-infra   compute.v1.disk               COMPLETED
disk-docker-ocptest2-master  compute.v1.disk               COMPLETED
disk-docker-ocptest2-node1   compute.v1.disk               COMPLETED
disk-docker-ocptest2-node2   compute.v1.disk               COMPLETED
disk-docker-ocptest2-node3   compute.v1.disk               COMPLETED
fw-rule-ocptest2-default     compute.v1.firewall           COMPLETED
fw-rule-ocptest2-infra       compute.v1.firewall           COMPLETED
fw-rule-ocptest2-master      compute.v1.firewall           COMPLETED
fw-rule-ocptest2-ssh         compute.v1.firewall           COMPLETED
ocptest2-network             compute.v1.network            COMPLETED
ocptest2-startup-config      runtimeconfig.v1beta1.config  COMPLETED
ocptest2-startup-waiter      runtimeconfig.v1beta1.waiter  PENDING      CREATE_OR_ACQUIRE
ocptest2-subnet0             compute.v1.subnetwork         COMPLETED
vm-ocptest2-infra            compute.v1.instance           COMPLETED
vm-ocptest2-master           compute.v1.instance           COMPLETED
vm-ocptest2-node1            compute.v1.instance           COMPLETED
vm-ocptest2-node2            compute.v1.instance           COMPLETED
vm-ocptest2-node3            compute.v1.instance           COMPLETED
OUTPUTS           VALUE
password          testdrive
user              developer
OpenShiftConsole  https://master.fkcst2.gcp.testdrive.openshift.com
$
```

NOTE: The startup-waiter will not be completed until the startup/install script finishes.

### Output of /tmp/OCP-startup-time for reference:
```
# cat /tmp/OCP-startup-time 
START VARS -- Wed Aug  1 21:05:05 UTC 2018
masterIP 
infraIP 35.224.190.198
masterNode vm-ocptest2-master.c.openshift-test-drive.internal
infraNode vm-ocptest2-infra
appNode1 vm-ocptest2-node1
appNode2 vm-ocptest2-node2
appNode3 vm-ocptest2-node3
randomDnsName fkcst2
dnszone gcp-testdrive-openshift-com
START DNS -- Wed Aug  1 21:05:05 UTC 2018
Transaction started [transaction.yaml].
Record addition appended to transaction at [transaction.yaml].
Record addition appended to transaction at [transaction.yaml].
Executed transaction [transaction.yaml] for managed-zone [gcp-testdrive-openshift-com].
Created [https://www.googleapis.com/dns/v1/projects/openshift-test-drive/managedZones/gcp-testdrive-openshift-com/changes/3340].
START PREREQ -- Wed Aug  1 21:05:12 UTC 2018
START DEPLOY -- Wed Aug  1 21:08:17 UTC 2018
START ACCESS -- Wed Aug  1 21:35:58 UTC 2018
END DEPLOY -- Wed Aug  1 21:35:58 UTC 2018
END SCRIPT -- Wed Aug  1 21:36:00 UTC 2018
```

### And the Ansible Hosts files for reference

The startup-script set in openshift.jinja replaces placeholders before running the installer.

```
[OSEv3:vars]
# OpenShift version
openshift_release=v3.11
deployment_type=openshift-enterprise

# Default console port (works best when they match)
openshift_master_api_port=443
openshift_master_console_port=443

# System Settings
ansible_ssh_user=root
openshift_override_hostname_check=true
openshift_use_dnsmasq=true
openshift_install_examples=true
openshift_disable_check=memory_availability,docker_image_availability

# Identity
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

# Disable Metrics
openshift_metrics_install_metrics=false

# Disable Logging
openshift_logging_install_logging=false

# General GlusterFS Storage
openshift_storage_glusterfs_namespace=app-storage
openshift_storage_glusterfs_storageclass=true
openshift_storage_glusterfs_storageclass_default=false
openshift_storage_glusterfs_block_deploy=true
openshift_storage_glusterfs_block_host_vol_size=100
openshift_storage_glusterfs_block_storageclass=true
openshift_storage_glusterfs_block_storageclass_default=false

# This will change every deployment of a Test Drive
openshift_master_default_subdomain=apps.DEPLOYMENTNAME.gcp.testdrive.openshift.com
openshift_master_cluster_public_hostname=master.DEPLOYMENTNAME.gcp.testdrive.openshift.com
openshift_master_cluster_public_vip=MASTEREXTERNALIP

[OSEv3:children]
etcd
masters
nodes
glusterfs

[masters]
MASTERNODE

[glusterfs]
# General Storage
APPNODE1 glusterfs_devices='["/dev/sdc"]'
APPNODE2 glusterfs_devices='["/dev/sdc"]'
APPNODE3 glusterfs_devices='["/dev/sdc"]'

[etcd]
MASTERNODE

[nodes]
MASTERNODE openshift_node_group_name='node-config-master'
INFRANODE openshift_node_group_name='node-config-infra'
APPNODE1 openshift_node_group_name='node-config-compute'
APPNODE2 openshift_node_group_name='node-config-compute'
APPNODE3 openshift_node_group_name='node-config-compute'
```
