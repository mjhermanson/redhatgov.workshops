#!/bin/bash

hostname=https://master.stratcom-d547.open.redhat.com
clusteradmin=opentlc-mgr
clusteradminpass=r3dh4t1!
domain=apps.stratcom-d547.open.redhat.com
prefix=user
begin=1
count=50
ocuserpass=openshift
quayiouser=coreos+rhcp
quayiopassword=L6ZXXVHD9XLQ7PR7HBNRW2FAIZQNJYHREISFGCUBIB45C43WCWYU3DZ0FHJH2AY5

oc login "$hostname" --insecure-skip-tls-verify -u "$clusteradmin" -p "$clusteradminpass"
oc new-project quay-enterprise
oc create -f quay-servicetoken-role-k8s1-6.yaml
oc create -f quay-servicetoken-role-binding-k8s1-6.yaml
oc adm policy add-scc-to-user anyuid -z default

#Install Quay
oc project quay-enterprise
oc create -f quay-enterprise-redis.yml
oc new-app \
-e DATABASE_SERVICE_NAME=mysql \
-e MYSQL_USER=coreosuser \
-e MYSQL_PASSWORD=coreosuser \
-e MYSQL_DATABASE=enterpriseregistrydb \
-e MYSQL_ROOT_PASSWORD=coreosuser \
docker.io/mysql:5.7
oc create secret new-dockercfg coreos-pull-secret --docker-server=quay.io --docker-username="$quayiouser"  --docker-password="$quayiopassword" --docker-email="$quayiouser"
oc create -f quay-enterprise-config-secret.yml
oc create -f quay-enterprise-app-rc.yml
oc create -f quay-enterprise-service.yml
oc expose svc quay-enterprise

#Install Clair
sed 's/<domain>/'$domain'/' <config-template.yaml >config.yaml
oc create secret generic clairsecret --from-file=./config.yaml
oc create -f clair-kubernetes.yaml
oc expose svc clairsvc

#Install Skopeo on Jenkins
for (( i = $begin; i <= $count; i++ )); do
 oc login "$hostname" --insecure-skip-tls-verify -u $prefix${i} -p $ocuserpass
 oc project 'cicd-'$prefix${i}''
 oc process -f jenkins-slave-image-mgmt-template.yml | oc apply -f-
done
