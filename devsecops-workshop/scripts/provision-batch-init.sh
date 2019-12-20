#!/bin/bash

hostname=https://api.cluster-usaf-e381.usaf-e381.example.opentlc.com:6443
password=openshift
username=user
begin=1
count=5
pause=5

function check-hostname() {
 if [[ -z "$hostname" ]]; then
  printf "%s\n" "###############################################################################"
  printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
  printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
  printf "%s\n" "###############################################################################"
  exit 1
 fi
}
