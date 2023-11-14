#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/same-network/configure-clusters.sh
  Enable endpoint discovery for Multi-Primary mesh on same network by passing two contexts.

Usage:
  endpoint-discovery.sh CURRENT_CLUSTER_CONTEXT REMOTE_CLUSTER_CONTEXT REMOTE_CLUSTER_KUBE_API_URL
"

EXPECTED_ARGS_COUNT=3
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CURRENT_CLUSTER_CONTEXT=$1
REMOTE_CLUSTER_CONTEXT=$2
REMOTE_CLUSTER_KUBE_API_URL=$3
! vars-are-defined "$CURRENT_CLUSTER_CONTEXT" "$REMOTE_CLUSTER_CONTEXT" "$REMOTE_CLUSTER_KUBE_API_URL" && echo "$_HELP" && exit 1

! programs-are-installed "kubectl" "istioctl" && exit 1

log-message "INFO" "Load context before creating secret"
kubectl config use-context "$CURRENT_CLUSTER_CONTEXT"

log-message "INFO" "Apply remote cluster secret"
istioctl --context="$CURRENT_CLUSTER_CONTEXT" \
    create-remote-secret \
    --context="$REMOTE_CLUSTER_CONTEXT" \
    --server="$REMOTE_CLUSTER_KUBE_API_URL" \
    --name="$REMOTE_CLUSTER_CONTEXT" | \
    kubectl apply -f - --context="$CURRENT_CLUSTER_CONTEXT"
