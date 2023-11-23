#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/different-network/configure-metallb.sh
  Configure istio installed in a cluster a primary.

Usage:
  configure-metallb.sh CLUSTER_CONTEXT
"

EXPECTED_ARGS_COUNT=1
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
! vars-are-defined "$CLUSTER_CONTEXT" && echo "$_HELP" && exit 1

! programs-are-installed "kubectl" && exit 1

YAML_FILE="$(pwd)/cluster-config/metallb/$CLUSTER_CONTEXT.yaml"

log-message "INFO" "Check yaml exists"
! files-exist \
    "$YAML_FILE" \
    && exit 1

log-message "INFO" "Create metallb-system namespace"
kubectl --context="${CLUSTER_CONTEXT}" \
  create namespace metallb-system \
  --dry-run=client -o yaml \
  | kubectl apply -f -

log-message "INFO" "Configure metallb on a cluster"
kubectl apply --context="$CLUSTER_CONTEXT" -n metallb-system -f "$YAML_FILE"
