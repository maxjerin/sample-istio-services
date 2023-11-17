#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/different-network/expose-services.sh
  Configure istio installed in a cluster a primary.

Usage:
  expose-services.sh CLUSTER_CONTEXT
"

EXPECTED_ARGS_COUNT=1
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
! vars-are-defined "$CLUSTER_CONTEXT" && echo "$_HELP" && exit 1

! programs-are-installed "istioctl" "git" && exit 1

YAML_FILE="$(pwd)/cluster-config/multi-cluster/different-network/expose-services.yaml"

log-message "INFO" "Expose services between two clusters"
kubectl apply --context="$CLUSTER_CONTEXT" -n istio-system -f "$YAML_FILE"
