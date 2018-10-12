#!/bin/bash
##
## RUN AS ROOT
##
## This script will take care of setting up ansible.cfg, ssh, and docker
##
## This script requires a golden image of RHEL to run on that is
## subscribed to RHSM or a Satelite Server and should be run before
## uploading to GCP.
##

# Add correct repositories from RHSM
subscription-manager repos --disable="*"

subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.10-rpms" \
    --enable="rhel-7-server-ansible-2.5-rpms" \
    --enable="rhel-7-fast-datapath-rpms" \
    --enable="rh-gluster-3-client-for-rhel-7-server-rpms"

## Adding Google's Cloud repositories that will be used later
cat << EOF > /etc/yum.repos.d/google-cloud.repo
[google-cloud-compute]
name=Google Cloud Compute
baseurl=https://packages.cloud.google.com/yum/repos/google-cloud-compute-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

## Exposing exclusioned packages
yum install -y atomic-openshift-excluder atomic-openshift-docker-excluder
atomic-openshift-excluder unexclude

## Installing required packages
yum install -y wget git net-tools bind-utils yum-utils iptables-services bridge-utils
yum install -y bash-completion kexec-tools sos psacct docker golang
yum install -y cloud-utils-growpart ansible glusterfs-fuse
yum install -y python-google-compute-engine google-compute-engine-oslogin google-compute-engine

## Updating all packages
yum update -y

## Create ansible.cfg
echo "# ansible.cfg
[defaults]
library        = /usr/share/ansible/openshift-ansible/roles/lib_utils/library/
forks          = 10
roles_path    = /etc/ansible/roles:/usr/share/ansible/roles
host_key_checking = False
stdout_callback = skippy
[inventory]
[privilege_escalation]
[paramiko_connection]
pty=False
[ssh_connection]
control_path = %(directory)s/%%h-%%r
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]
" > /etc/ansible/ansible.cfg

## Create ansible hosts
cat << EOF > /etc/ansible/hosts
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
EOF

## Create ssh_config
cat << EOF > /etc/ssh/ssh_config
# ssh_config for OCP on GCP
Host *
    Port 22
    Protocol 2
    ForwardAgent no
    ForwardX11 no
    HostbasedAuthentication no
    StrictHostKeyChecking no
    Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
    Tunnel no
    ServerAliveInterval 420
EOF

## Create sshd_config
cat << EOF > /etc/ssh/sshd_config
# sshd_config for OCP on GCP
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
PermitRootLogin yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
AllowTcpForwarding yes
X11Forwarding no
ClientAliveInterval 180
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem sftp  /usr/libexec/openssh/sftp-server
EOF

## Restart ssh daemon and wait for a few seconds before continuing
systemctl restart sshd
sleep 5

## Docker Storage Setup
cat << EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdb
VG=docker-pool
EOF

## Make go's home directory
mkdir -p /root/go/bin
echo "export GOPATH=/root/go" >> /root/.bashrc
echo "export PATH=\$PATH:/root/go/bin" >> /root/.bashrc

# Updating GRUB as per GCP's recommendations
cat << EOF > /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rootdelay=300 console=tty0 console=ttyS0,38400n8d net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
EOF
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Creating script that can be used during an offline install
cat << EOF > /root/get-redhat-repos.sh
#!/bin/bash
echo "====================================="
# Cleaning up yum for a fresh start
yum clean all
# Getting offline repo server
curl -o /etc/yum.repos.d/rhel7ocp311.repo http://repo.server/rhel7ocp310.repo
# Refreshing repository caches
yum repolist
EOF
chmod +x /root/get-redhat-repos.sh


# End of script

