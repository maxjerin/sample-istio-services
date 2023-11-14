#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/sample-services/install-service.sh
  Install caller service to a given namespace and enable istio sidecare injection.

Usage:
  install-service.sh CLUSTER_CONTEXT NAMESPACE YAML1 YAML2 ...
"

CLUSTER_CONTEXT=$1;
NAMESPACE=$2;
shift; shift;
! vars-are-defined "$CLUSTER_CONTEXT" "$NAMESPACE" && echo "$_HELP" && exit 1

! programs-are-installed "kubectl" && exit 1

log-message "INFO" "Create namespace"
kubectl --context="$CLUSTER_CONTEXT" \
  create namespace "$NAMESPACE" \
  --dry-run=client -o yaml \
  | kubectl apply -f -

log-message "INFO" "Enable istio injection"
kubectl --context="$CLUSTER_CONTEXT" \
    label --overwrite namespace "$NAMESPACE" \
     istio-injection=enabled

log-message "INFO" "Installing services"
for YAML in "$@";
do
  echo "$YAML"
  ! files-exist "$YAML" && exit 1
  kubectl --context="$CLUSTER_CONTEXT" apply -f "$YAML"
done
