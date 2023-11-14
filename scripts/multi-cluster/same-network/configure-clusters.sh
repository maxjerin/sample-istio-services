#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/same-network/configure-clusters.sh
  Configure istio installed in a cluster a primary.

Usage:
  configure-clusters.sh CLUSTER_CONTEXT
"

EXPECTED_ARGS_COUNT=1
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
! vars-are-defined "$CLUSTER_CONTEXT" && echo "$_HELP" && exit 1

! programs-are-installed "istioctl" && exit 1

YAML_FILE="scripts/multi-cluster/same-network/$CLUSTER_CONTEXT.yaml"

log-message "INFO" "Check yaml exists"
! files-exist \
    "$(pwd)/$YAML_FILE" \
    && exit 1

log-message "INFO" "Configure istio on a cluster as primary"
istioctl install --context="${CLUSTER_CONTEXT}" -f "$YAML_FILE" --set profile=demo -y
