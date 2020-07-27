#!/bin/bash -e

HARBOR_SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TKG_LAB_SCRIPTS=$HARBOR_SCRIPTS/../scripts
source $TKG_LAB_SCRIPTS/set-env.sh

if [ ! $# -eq 1 ]; then
  echo "Must supply cluster_name as args"
  exit 1
fi

CLUSTER_NAME=$1

HARBOR_CN=${HARBOR_CN:-$(yq r $PARAMS_YAML harbor.harbor-cn)}
NOTARY_CN=${NOTARY_CN:-$(yq r $PARAMS_YAML harbor.notary-cn)}

mkdir -p generated/$CLUSTER_NAME/harbor

# 01-namespace.yaml
yq read $HARBOR_SCRIPTS/01-namespace.yaml > generated/$CLUSTER_NAME/harbor/01-namespace.yaml

# 02-certs.yaml
yq read $HARBOR_SCRIPTS/02-certs.yaml > generated/$CLUSTER_NAME/harbor/02-certs.yaml
yq write generated/$CLUSTER_NAME/harbor/02-certs.yaml -i "spec.commonName" $HARBOR_CN
yq write generated/$CLUSTER_NAME/harbor/02-certs.yaml -i "spec.dnsNames[0]" $HARBOR_CN
yq write generated/$CLUSTER_NAME/harbor/02-certs.yaml -i "spec.dnsNames[1]" $NOTARY_CN

# harbor-values.yaml
yq read $HARBOR_SCRIPTS/harbor-values.yaml > generated/$CLUSTER_NAME/harbor/harbor-values.yaml
yq write generated/$CLUSTER_NAME/harbor/harbor-values.yaml -i "expose.ingress.hosts.core" $HARBOR_CN
yq write generated/$CLUSTER_NAME/harbor/harbor-values.yaml -i "expose.ingress.hosts.notary" $NOTARY_CN  
yq write generated/$CLUSTER_NAME/harbor/harbor-values.yaml -i "externalURL" https://$HARBOR_CN
