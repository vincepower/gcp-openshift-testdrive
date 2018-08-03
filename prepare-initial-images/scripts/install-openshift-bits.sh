#!/bin/bash
##
## RUN AS ROOT
##
## Run this after setting up docker storage, registering with RHSM, 
## and the other initial setup stuff
##

## Version of OpenShift
export VERSION=v3.10.14

## Make go's home directory
mkdir -p /root/go/bin
echo "export PATH=\$PATH:/root/go/bin" >> /root/.bashrc

## Starting docker daemon
systemctl start docker

## Installing OpenShift rpms
yum install -y openshift-ansible* atomic* *-openshift-* google-cloud-sdk*

## Cleanup yum
yum clean all
rm -f /var/cache/yum
yum repolist

## Downloading all the containers
docker pull registry.access.redhat.com/cloudforms46/cfme-httpd-configmap-generator
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-app
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-app-ui
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-embedded-ansible
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-httpd
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-memcached
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-postgresql
docker pull registry.access.redhat.com/jboss-amq-6/amq63-openshift
docker pull registry.access.redhat.com/jboss-datagrid-7/datagrid71-client-openshift
docker pull registry.access.redhat.com/jboss-datagrid-7/datagrid71-openshift
docker pull registry.access.redhat.com/jboss-datavirt-6/datavirt63-driver-openshift
docker pull registry.access.redhat.com/jboss-datavirt-6/datavirt63-openshift
docker pull registry.access.redhat.com/jboss-decisionserver-6/decisionserver64-openshift
docker pull registry.access.redhat.com/jboss-eap-6/eap64-openshift
docker pull registry.access.redhat.com/jboss-eap-7/eap70-openshift
docker pull registry.access.redhat.com/jboss-processserver-6/processserver64-openshift
docker pull registry.access.redhat.com/jboss-webserver-3/webserver30-tomcat7-openshift:1.1
docker pull registry.access.redhat.com/jboss-webserver-3/webserver30-tomcat7-openshift:latest
docker pull registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat7-openshift
docker pull registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat8-openshift
docker pull registry.access.redhat.com/openshift3/apb-base:$VERSION
docker pull registry.access.redhat.com/openshift3/apb-tools:$VERSION
docker pull registry.access.redhat.com/openshift3/csi-attacher:$VERSION
docker pull registry.access.redhat.com/openshift3/csi-driver-registrar:$VERSION
docker pull registry.access.redhat.com/openshift3/csi-livenessprobe:$VERSION
docker pull registry.access.redhat.com/openshift3/csi-provisioner:$VERSION
docker pull registry.access.redhat.com/openshift3/efs-provisioner:$VERSION
docker pull registry.access.redhat.com/openshift3/image-inspector:$VERSION
docker pull registry.access.redhat.com/openshift3/jenkins-1-rhel7
docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7
docker pull registry.access.redhat.com/openshift3/jenkins-agent-maven-35-rhel7:$VERSION
docker pull registry.access.redhat.com/openshift3/jenkins-agent-nodejs-8-rhel7:$VERSION
docker pull registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7
docker pull registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7
docker pull registry.access.redhat.com/openshift3/jenkins-slave-nodejs-rhel7
docker pull registry.access.redhat.com/openshift3/local-storage-provisioner:$VERSION
docker pull registry.access.redhat.com/openshift3/logging-auth-proxy:$VERSION
docker pull registry.access.redhat.com/openshift3/logging-curator:$VERSION
docker pull registry.access.redhat.com/openshift3/logging-elasticsearch:$VERSION
docker pull registry.access.redhat.com/openshift3/logging-eventrouter:$VERSION
docker pull registry.access.redhat.com/openshift3/logging-fluentd:$VERSION
docker pull registry.access.redhat.com/openshift3/logging-kibana:$VERSION
docker pull registry.access.redhat.com/openshift3/manila-provisioner:$VERSION
docker pull registry.access.redhat.com/openshift3/mariadb-apb:$VERSION
docker pull registry.access.redhat.com/openshift3/mediawiki-apb:$VERSION
docker pull registry.access.redhat.com/openshift3/metrics-cassandra:$VERSION
docker pull registry.access.redhat.com/openshift3/metrics-hawkular-metrics:$VERSION
docker pull registry.access.redhat.com/openshift3/metrics-hawkular-openshift-agent:$VERSION
docker pull registry.access.redhat.com/openshift3/metrics-heapster:$VERSION
docker pull registry.access.redhat.com/openshift3/metrics-schema-installer:$VERSION
docker pull registry.access.redhat.com/openshift3/mysql-apb:$VERSION
docker pull registry.access.redhat.com/openshift3/oauth-proxy:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-ansible-service-broker:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-ansible:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-cli:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-cluster-capacity:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-control-plane:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-deployer:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-descheduler:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-docker-builder:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-docker-registry:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-egress-dns-proxy:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-egress-http-proxy:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-egress-router:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-f5-router:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-haproxy-router:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-hyperkube:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-hypershift:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-keepalived-ipfailover:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-node-problem-detector:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-node:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-pod:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-recycler:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-service-catalog:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-template-service-broker:$VERSION
docker pull registry.access.redhat.com/openshift3/ose-web-console:$VERSION
docker pull registry.access.redhat.com/openshift3/postgresql-apb:$VERSION
docker pull registry.access.redhat.com/openshift3/prometheus-alert-buffer:$VERSION
docker pull registry.access.redhat.com/openshift3/prometheus-alertmanager:$VERSION
docker pull registry.access.redhat.com/openshift3/prometheus-node-exporter:$VERSION
docker pull registry.access.redhat.com/openshift3/prometheus:$VERSION
docker pull registry.access.redhat.com/openshift3/registry-console:$VERSION
docker pull registry.access.redhat.com/openshift3/snapshot-controller:$VERSION
docker pull registry.access.redhat.com/openshift3/snapshot-provisioner:$VERSION
docker pull registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
docker pull registry.access.redhat.com/redhat-sso-7/sso70-openshift
docker pull registry.access.redhat.com/redhat-sso-7/sso71-openshift
docker pull registry.access.redhat.com/rhel7/etcd
docker pull registry.access.redhat.com/rhgs3/rhgs-gluster-block-prov-rhel7
docker pull registry.access.redhat.com/rhgs3/rhgs-s3-server-rhel7
docker pull registry.access.redhat.com/rhgs3/rhgs-server-rhel7
docker pull registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7
docker pull registry.access.redhat.com/rhscl/mariadb-101-rhel7
docker pull registry.access.redhat.com/rhscl/mongodb-32-rhel7
docker pull registry.access.redhat.com/rhscl/mysql-57-rhel7
docker pull registry.access.redhat.com/rhscl/nodejs-6-rhel7
docker pull registry.access.redhat.com/rhscl/perl-524-rhel7
docker pull registry.access.redhat.com/rhscl/php-56-rhel7
docker pull registry.access.redhat.com/rhscl/postgresql-95-rhel7
docker pull registry.access.redhat.com/rhscl/python-35-rhel7
docker pull registry.access.redhat.com/rhscl/ruby-24-rhel7
