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

## Version of OpenShift
export VERSION=v3.11.16

## Installing OpenShift rpms
yum install -y openshift-ansible* atomic* *-openshift-* google-cloud-sdk* cockpit*
yum update -y

## Cleanup yum
yum clean all
rm -f /var/cache/yum
yum repolist

## Downloading all the containers
docker pull registry.redhat.io/openshift3/apb-base:$VERSION
docker pull registry.redhat.io/openshift3/apb-tools:$VERSION
docker pull registry.redhat.io/openshift3/automation-broker-apb:$VERSION
docker pull registry.redhat.io/openshift3/csi-attacher:$VERSION
docker pull registry.redhat.io/openshift3/csi-driver-registrar:$VERSION
docker pull registry.redhat.io/openshift3/csi-livenessprobe:$VERSION
docker pull registry.redhat.io/openshift3/csi-provisioner:$VERSION
docker pull registry.redhat.io/openshift3/grafana:$VERSION
docker pull registry.redhat.io/openshift3/image-inspector:$VERSION
docker pull registry.redhat.io/openshift3/mariadb-apb:$VERSION
docker pull registry.redhat.io/openshift3/mediawiki:$VERSION
docker pull registry.redhat.io/openshift3/mediawiki-apb:$VERSION
docker pull registry.redhat.io/openshift3/mysql-apb:$VERSION
docker pull registry.redhat.io/openshift3/ose-ansible:$VERSION
docker pull registry.redhat.io/openshift3/ose-ansible-service-broker:$VERSION
docker pull registry.redhat.io/openshift3/ose-cli:$VERSION
docker pull registry.redhat.io/openshift3/ose-cluster-autoscaler:$VERSION
docker pull registry.redhat.io/openshift3/ose-cluster-capacity:$VERSION
docker pull registry.redhat.io/openshift3/ose-cluster-monitoring-operator:$VERSION
docker pull registry.redhat.io/openshift3/ose-console:$VERSION
docker pull registry.redhat.io/openshift3/ose-configmap-reloader:$VERSION
docker pull registry.redhat.io/openshift3/ose-control-plane:$VERSION
docker pull registry.redhat.io/openshift3/ose-deployer:$VERSION
docker pull registry.redhat.io/openshift3/ose-descheduler:$VERSION
docker pull registry.redhat.io/openshift3/ose-docker-builder:$VERSION
docker pull registry.redhat.io/openshift3/ose-docker-registry:$VERSION
docker pull registry.redhat.io/openshift3/ose-efs-provisioner:$VERSION
docker pull registry.redhat.io/openshift3/ose-egress-dns-proxy:$VERSION
docker pull registry.redhat.io/openshift3/ose-egress-http-proxy:$VERSION
docker pull registry.redhat.io/openshift3/ose-egress-router:$VERSION
docker pull registry.redhat.io/openshift3/ose-haproxy-router:$VERSION
docker pull registry.redhat.io/openshift3/ose-hyperkube:$VERSION
docker pull registry.redhat.io/openshift3/ose-hypershift:$VERSION
docker pull registry.redhat.io/openshift3/ose-keepalived-ipfailover:$VERSION
docker pull registry.redhat.io/openshift3/ose-kube-rbac-proxy:$VERSION
docker pull registry.redhat.io/openshift3/ose-kube-state-metrics:$VERSION
docker pull registry.redhat.io/openshift3/ose-metrics-server:$VERSION
docker pull registry.redhat.io/openshift3/ose-node:$VERSION
docker pull registry.redhat.io/openshift3/ose-node-problem-detector:$VERSION
docker pull registry.redhat.io/openshift3/ose-operator-lifecycle-manager:$VERSION
docker pull registry.redhat.io/openshift3/ose-pod:$VERSION
docker pull registry.redhat.io/openshift3/ose-prometheus-config-reloader:$VERSION
docker pull registry.redhat.io/openshift3/ose-prometheus-operator:$VERSION
docker pull registry.redhat.io/openshift3/ose-recycler:$VERSION
docker pull registry.redhat.io/openshift3/ose-service-catalog:$VERSION
docker pull registry.redhat.io/openshift3/ose-template-service-broker:$VERSION
docker pull registry.redhat.io/openshift3/ose-web-console:$VERSION
docker pull registry.redhat.io/openshift3/postgresql-apb:$VERSION
docker pull registry.redhat.io/openshift3/registry-console:$VERSION
docker pull registry.redhat.io/openshift3/snapshot-controller:$VERSION
docker pull registry.redhat.io/openshift3/snapshot-provisioner:$VERSION
docker pull registry.redhat.io/rhel7/etcd:3.2.22
docker pull registry.redhat.io/openshift3/metrics-cassandra:$VERSION
docker pull registry.redhat.io/openshift3/metrics-hawkular-metrics:$VERSION
docker pull registry.redhat.io/openshift3/metrics-hawkular-openshift-agent:$VERSION
docker pull registry.redhat.io/openshift3/metrics-heapster:$VERSION
docker pull registry.redhat.io/openshift3/oauth-proxy:$VERSION
docker pull registry.redhat.io/openshift3/ose-logging-curator5:$VERSION
docker pull registry.redhat.io/openshift3/ose-logging-elasticsearch5:$VERSION
docker pull registry.redhat.io/openshift3/ose-logging-eventrouter:$VERSION
docker pull registry.redhat.io/openshift3/ose-logging-fluentd:$VERSION
docker pull registry.redhat.io/openshift3/ose-logging-kibana5:$VERSION
docker pull registry.redhat.io/openshift3/ose-metrics-schema-installer:$VERSION
docker pull registry.redhat.io/openshift3/prometheus:$VERSION
docker pull registry.redhat.io/openshift3/prometheus-alert-buffer:$VERSION
docker pull registry.redhat.io/openshift3/prometheus-alertmanager:$VERSION
docker pull registry.redhat.io/openshift3/prometheus-node-exporter:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-openshift-postgresql:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-openshift-memcached:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-openshift-app-ui:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-openshift-app:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-openshift-embedded-ansible:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-openshift-httpd:$VERSION
docker pull registry.redhat.io/cloudforms46/cfme-httpd-configmap-generator:$VERSION
docker pull registry.redhat.io/rhgs3/rhgs-server-rhel7:$VERSION
docker pull registry.redhat.io/rhgs3/rhgs-volmanager-rhel7:$VERSION
docker pull registry.redhat.io/rhgs3/rhgs-gluster-block-prov-rhel7:$VERSION
docker pull registry.redhat.io/rhgs3/rhgs-s3-server-rhel7:$VERSION
docker pull registry.redhat.io/jboss-amq-6/amq63-openshift:$VERSION
docker pull registry.redhat.io/jboss-datagrid-7/datagrid71-openshift:$VERSION
docker pull registry.redhat.io/jboss-datagrid-7/datagrid71-client-openshift:$VERSION
docker pull registry.redhat.io/jboss-datavirt-6/datavirt63-openshift:$VERSION
docker pull registry.redhat.io/jboss-datavirt-6/datavirt63-driver-openshift:$VERSION
docker pull registry.redhat.io/jboss-decisionserver-6/decisionserver64-openshift:$VERSION
docker pull registry.redhat.io/jboss-processserver-6/processserver64-openshift:$VERSION
docker pull registry.redhat.io/jboss-eap-6/eap64-openshift:$VERSION
docker pull registry.redhat.io/jboss-eap-7/eap70-openshift:$VERSION
docker pull registry.redhat.io/jboss-webserver-3/webserver31-tomcat7-openshift:$VERSION
docker pull registry.redhat.io/jboss-webserver-3/webserver31-tomcat8-openshift:$VERSION
docker pull registry.redhat.io/openshift3/jenkins-2-rhel7:$VERSION
docker pull registry.redhat.io/openshift3/jenkins-agent-maven-35-rhel7:$VERSION
docker pull registry.redhat.io/openshift3/jenkins-agent-nodejs-8-rhel7:$VERSION
docker pull registry.redhat.io/openshift3/jenkins-slave-base-rhel7:$VERSION
docker pull registry.redhat.io/openshift3/jenkins-slave-maven-rhel7:$VERSION
docker pull registry.redhat.io/openshift3/jenkins-slave-nodejs-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/mongodb-32-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/mysql-57-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/perl-524-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/php-56-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/postgresql-95-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/python-35-rhel7:$VERSION
docker pull registry.redhat.io/redhat-sso-7/sso70-openshift:$VERSION
docker pull registry.redhat.io/rhscl/ruby-24-rhel7:$VERSION
docker pull registry.redhat.io/redhat-openjdk-18/openjdk18-openshift:$VERSION
docker pull registry.redhat.io/redhat-sso-7/sso71-openshift:$VERSION
docker pull registry.redhat.io/rhscl/nodejs-6-rhel7:$VERSION
docker pull registry.redhat.io/rhscl/mariadb-101-rhel7:$VERSION

