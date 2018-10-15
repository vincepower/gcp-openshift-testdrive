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
## This script has a short URL to make it easier to download in the VM
## $ curl -o tmp.txt https://bit.ly/2REXak9
## Then edit tmp.txt to remove all the HTML around the URL
## $ curl -o run.sh `cat tmp.txt`
## 

#
echo "Make sure you are subscribed, then edit this"
echo "file and remove the 'exit' on the next line."
exit

# Add correct repositories from RHSM
echo "Disabling all repositories not required"
subscription-manager repos --disable="*"

echo "Ensuring required repositories are enabled"
subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.11-rpms" \
    --enable="rhel-7-server-ansible-2.6-rpms" \
    --enable="rhel-7-fast-datapath-rpms" \
    --enable="rh-gluster-3-client-for-rhel-7-server-rpms"

## Adding Google's Cloud repositories that will be used later
echo "Adding Google yum repos"
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
echo "Installing and disabling OpenShift excluders"
yum install -y atomic-openshift-excluder atomic-openshift-docker-excluder
atomic-openshift-excluder unexclude

## Installing required packages
echo "Installing prereqs"
yum install -y wget git net-tools bind-utils yum-utils iptables-services bridge-utils
yum install -y bash-completion kexec-tools sos psacct docker ntp
yum install -y cloud-init cloud-utils-growpart 
yum install -y ansible glusterfs-fuse

## Updating all packages
echo "Updating the OS"
yum update -y

## Create ansible.cfg
echo "Updating ansible.cfg"
cat << EOF > /etc/ansible/ansible.cfg
# ansible.cfg
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
EOF

## Create ansible hosts
echo "Creating ansible/hosts"
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
echo "Updating ssh_config"
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
echo "Updating sshd_config"
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
echo "Enabling and restarting sshd"
systemctl restart sshd
sleep 5

## Docker Storage Setup
echo "Setting docker storage config"
cat << EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdb
VG=docker-pool
EOF

## Making a shared ssh key
echo "Making ssh key"
mkdir /root/.ssh
chmod 0755 /root/.ssh
ssh-keygen -q -t rsa -P "" -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

## Make go's home directory
echo "Creating the golang config"
mkdir -p /root/go/bin
echo "export GOPATH=/root/go" >> /root/.bashrc
echo "export PATH=\$PATH:/root/go/bin" >> /root/.bashrc

# Updating GRUB as per GCP's recommendations
echo "Setting the recommended grub config"
cat << EOF > /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rootdelay=300 console=tty0 console=ttyS0,38400n8d net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
EOF
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Creating script that can be used during an offline install
echo "Creating skelaton script for use to work offline"
cat << EOF > /root/get-redhat-repos.sh
#!/bin/bash

# Unregistering from RHSM
subscription-manager unregister

# Cleaning up yum for a fresh start
yum clean all

# Getting offline repo server
curl -o /etc/yum.repos.d/rhel7ocp311.repo http://repo.server/rhel7ocp311.repo

# Refreshing repository caches
yum repolist
EOF
chmod +x /root/get-redhat-repos.sh

# Creating eth0 config file
echo "Creating eth0 config file"
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE="Ethernet"
BOOTPROTO="dhcp"
DEFROUTE="yes"
PEERDNS="yes"
PEERROUTES="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="no"
NAME="eth0"
DEVICE="eth0"
ONBOOT="yes"
EOF

# Downloading jq (as per Google's request)
echo "Downloading jq"
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
mv jq-linux64 /bin/jq
chmod 755 /bin/jq

# Enabling and configuring ntp
echo "Enabling ntp"
cat << EOF > /etc/ntp.conf
driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict ::1
server 0.north-america.pool.ntp.org
server 1.north-america.pool.ntp.org
server 2.north-america.pool.ntp.org
server 3.north-america.pool.ntp.org
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
EOF
systemctl enable ntpd

# Installing Google Utilities
echo "Installing Google Utilities"
yum install -y python-google-compute-engine google-compute-engine-oslogin google-compute-engine
yum install -y golang google-cloud-sdk

# Sending some commands
echo ""
echo "You could unregister if you have a different ID for the cloud"
echo "  subscription-manager unregister"
echo ""
echo "To erase command line history use:"
echo "  export HISTSIZE=0"
echo ""

# End of script

