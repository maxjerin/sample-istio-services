#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/sample-services/install-callme-service-remote-cluster.sh
  Install callme service Service instance in remote server for DNS resolution.

Usage:
  install-callme-service-remote-cluster CLUSTER_CONTEXT NAMESPACE
"

EXPECTED_ARGS_COUNT=2
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
NAMESPACE=$2
! vars-are-defined "$CLUSTER_CONTEXT" "$NAMESPACE" && echo "$_HELP" && exit 1

"$(pwd)/scripts/install-services/install-service.sh" \
  "$CLUSTER_CONTEXT" \
  "$NAMESPACE" \
  "$(pwd)/callme-service/k8s/deployment-remote-cluster.yaml"
