#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/sample-services/install-debug-service.sh
  Install debug service to a given namespace and enable istio sidecare injection.

Usage:
  install-debug-service.sh CLUSTER_CONTEXT NAMESPACE
"

EXPECTED_ARGS_COUNT=2
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
NAMESPACE=$2
! vars-are-defined "$CLUSTER_CONTEXT" "$NAMESPACE" && echo "$_HELP" && exit 1

"$(pwd)/scripts/install-services/install-service.sh" \
  "$CLUSTER_CONTEXT" \
  "$NAMESPACE" \
  "$(pwd)/debug-service/k8s/deployment.yaml"
