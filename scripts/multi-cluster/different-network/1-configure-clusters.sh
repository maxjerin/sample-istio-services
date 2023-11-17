#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/different-network/configure-clusters.sh
  Configure istio installed in a cluster a primary.

Usage:
  configure-clusters.sh CLUSTER_CONTEXT NETWORK
"

EXPECTED_ARGS_COUNT=2
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
NETWORK=$2
! vars-are-defined "$CLUSTER_CONTEXT" "$NETWORK" && echo "$_HELP" && exit 1

! programs-are-installed "istioctl" "git" && exit 1

YAML_FILE_1="$(pwd)/cluster-config/multi-cluster/different-network/$CLUSTER_CONTEXT.yaml"
YAML_FILE_2="$(pwd)/cluster-config/multi-cluster/different-network/gateway-$CLUSTER_CONTEXT.yaml"

log-message "INFO" "Check yaml exists"
! files-exist \
    "$(pwd)/$YAML_FILE_1" \
    "$(pwd)/$YAML_FILE_2" \
    && exit 1

kubectl --context="$CLUSTER_CONTEXT" \
  label namespace istio-system \
  topology.istio.io/network="$NETWORK"

log-message "INFO" "Configure istio on a cluster as primary"
istioctl install --context="$CLUSTER_CONTEXT"  -f "$YAML_FILE_2" -f "$YAML_FILE_1" --set profile=demo -y
