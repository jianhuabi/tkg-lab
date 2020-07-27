#!/bin/bash -e

TKG_LAB_SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $TKG_LAB_SCRIPTS/set-env.sh

CLUSTER_NAME=$(yq r params.yaml shared-services-cluster.name)
GITLAB_BASE_FQDN="$(yq r params.yaml shared-services-cluster.ingress-fqdn)"
GITLAB_BASE_FQDN=${GITLAB_BASE_FQDN:2}
IAAS=$(yq r params.yaml iaas)
LETS_ENCRYPT_EMAIL=$(yq r params.yaml lets-encrypt-acme-email)
mkdir -p generated/$CLUSTER_NAME/gitlab/

cp $TKG_LAB_SCRIPTS/../gitlab/values-gitlab.yaml generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml

# Grab the external IP or name
if [ "$IAAS" = "aws" ];
 then
   EXT_NAME=`kubectl get svc envoy -n tanzu-system-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
 else
   EXT_NAME=`kubectl get svc envoy -n tanzu-system-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
 fi

if [ `uname -s` = 'Darwin' ]; 
then
  sed -i '' -e "s/GITLAB_BASE_FQDN/$GITLAB_BASE_FQDN/g" generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml
  sed -i '' -e "s/EXTERNAL_LB_IPN/$EXT_NAME/g" generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml
  sed -i '' -e "s/CERT_MANAGER_EMAIL/$LETS_ENCRYPT_EMAIL/g" generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml
else
  sed -i -e "s/GITLAB_BASE_FQDN/$GITLAB_BASE_FQDN/g" generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml
  sed -i -e "s/EXTERNAL_LB_IP/$EXT_NAME/g" generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml
  sed -i -e "s/CERT_MANAGER_EMAIL/$LETS_ENCRYPT_EMAIL/g" generated/$CLUSTER_NAME/gitlab/values-gitlab.yaml
fi
