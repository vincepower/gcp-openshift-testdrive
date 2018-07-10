# Deploying Test Drive on GCP

The scripts in this directory can be zipped up and uploaded to Orbitera as is.

## Required images

Two images are required for this to work. I used image families so I can iterate without changing this script.

* ocp39-base
* ocp39-docker (This is essential an empty disk with a volume group)

The base image will:
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
  * The script will add the data disk needed to configure docker storage


## Run the deployment

```
gcloud deployment-manager deployments create --template install.jinja <deployment_name>
```

This deployment takes 20 minutes and will install and configure a fresh install of OpenShift 3.9.31 and output the console URL, username, and password. It does not install persistent storage, logging, metrics, or the service catalog (persistent storage is are a requirement for these three)

For troubleshooting purposes, the deployment creates 6 files in the /tmp directory. The error ones aren't usually useful, but I'd rather have them than not.

* /tmp/OCP-deploy-time - Mainly reports different steps in the startup-script, useful for high level "where am I" feel
* /tmp/prerequisites.stdout - Standard Out for the prerequisites ansible playbook
* /tmp/prerequisites.stderr - Standard Error for the prerequisites ansible playbook
* /tmp/deploy_cluster.stdout - Standard Out for the deploy_cluster ansible playbook
* /tmp/deploy_cluster.stderr - Standard Error for the deploy_cluster ansible playbook
* /tmp/OCP-stop-time - Mainly reports different steps in the shutdown-script, useful for high level "where am I" feel

### Output of the deployment
```
$ gcloud deployment-manager deployments create --template install.jinja ocptestdrive6
The fingerprint of the deployment is GjqruTycOImRGQWKuQP5iA==
Waiting for create [operation-1531197245908-5709da3ec6420-79574f6e-05d7941f]...done.       
Create operation operation-1531197245908-5709da3ec6420-79574f6e-05d7941f completed successfully.
NAME                              TYPE                          STATE      ERRORS  INTENT
disk-docker-ocptestdrive6-infra   compute.v1.disk               COMPLETED  []
disk-docker-ocptestdrive6-master  compute.v1.disk               COMPLETED  []
disk-docker-ocptestdrive6-node1   compute.v1.disk               COMPLETED  []
disk-docker-ocptestdrive6-node2   compute.v1.disk               COMPLETED  []
fw-rule-ocptestdrive6-default     compute.v1.firewall           COMPLETED  []
fw-rule-ocptestdrive6-infra       compute.v1.firewall           COMPLETED  []
fw-rule-ocptestdrive6-master      compute.v1.firewall           COMPLETED  []
fw-rule-ocptestdrive6-ssh         compute.v1.firewall           COMPLETED  []
ocptestdrive6-network             compute.v1.network            COMPLETED  []
ocptestdrive6-startup-config      runtimeconfig.v1beta1.config  COMPLETED  []
ocptestdrive6-startup-waiter      runtimeconfig.v1beta1.waiter  COMPLETED  []
ocptestdrive6-subnet0             compute.v1.subnetwork         COMPLETED  []
vm-ocptestdrive6-infra            compute.v1.instance           COMPLETED  []
vm-ocptestdrive6-master           compute.v1.instance           COMPLETED  []
vm-ocptestdrive6-node1            compute.v1.instance           COMPLETED  []
vm-ocptestdrive6-node2            compute.v1.instance           COMPLETED  []
OUTPUTS           VALUE
password          testdrive
user              developer
OpenShiftConsole  https://master.yxbve6.gcp.testdrive.openshift.com
```

### Output of /tmp/OCP-deploy-time for reference:
```
[root@vm-ocptestdrive6-master tmp]# cat /tmp/OCP-deploy-time 
START VARS -- Tue Jul 10 04:36:09 UTC 2018
masterIP 35.238.13.43
infraIP 35.184.13.227
randomDnsName yxbve6
dnszone gcp-testdrive-openshift-com
START DNS -- Tue Jul 10 04:36:09 UTC 2018
START PREREQ -- Tue Jul 10 04:36:15 UTC 2018
START DEPLOY -- Tue Jul 10 04:38:35 UTC 2018
START ACCESS -- Tue Jul 10 04:54:01 UTC 2018
END DEPLOY -- Tue Jul 10 04:54:02 UTC 2018
END SCRIPT -- Tue Jul 10 04:54:04 UTC 2018
```

### And the Ansible Hosts files for reference
```
[OSEv3:vars]
ansible_ssh_user=root
openshift_release=v3.9
deployment_type=openshift-enterprise
openshift_master_api_port=443
openshift_master_console_port=443
openshift_disable_check=memory_availability,docker_image_availability
openshift_override_hostname_check=true
openshift_use_dnsmasq=true
openshift_install_examples=true
osm_default_node_selector='region=app'
openshift_router_selector='region=infra'
openshift_registry_selector='region=infra'
openshift_enable_service_catalog=false
openshift_metrics_install_metrics=false
openshift_logging_install_logging=false
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

# This will change every deployment of a Test Drive
openshift_master_default_subdomain=apps.DEPLOYMENT.gcp.testdrive.openshift.com
openshift_master_cluster_public_hostname=master.DEPLOYMENT.gcp.testdrive.openshift.com
openshift_master_cluster_public_vip=MASTEREXTERNALIP

[OSEv3:children]
etcd
masters
nodes

[masters]
master

[etcd]
master

[nodes]
master openshift_node_labels="{'region':'master','zone':'default'}" openshift_hostname=master
infra openshift_node_labels="{'region':'infra','zone':'default'}" openshift_hostname=infra
node1 openshift_node_labels="{'region':'app','zone':'default'}" openshift_hostname=node1
node2 openshift_node_labels="{'region':'app','zone':'default'}" openshift_hostname=node2

```
