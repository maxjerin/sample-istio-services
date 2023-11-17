#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/apply-certs.sh
  Apply certs to a given cluster context.

Usage:
  apply-certs.sh CLUSTER_CONTEXT
"

EXPECTED_ARGS_COUNT=1
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER_CONTEXT=$1
! vars-are-defined "$CLUSTER_CONTEXT" && echo "$_HELP" && exit 1

! programs-are-installed "kubectl" "istioctl" && exit 1

log-message "INFO" "Check certs folder exists"
! folders-exist \
    "$(pwd)/certs" \
    "$(pwd)/certs/$CLUSTER_CONTEXT" \
    && exit 1

log-message "INFO" "Check all certs exists"
! files-exist \
    "$(pwd)/certs/$CLUSTER_CONTEXT/ca-cert.pem" \
    "$(pwd)/certs/$CLUSTER_CONTEXT/ca-key.pem" \
    "$(pwd)/certs/$CLUSTER_CONTEXT/root-cert.pem" \
    "$(pwd)/certs/$CLUSTER_CONTEXT/cert-chain.pem" \
    && exit 1

log-message "INFO" "Create istio-system namespace"
kubectl --context="${CLUSTER_CONTEXT}" \
  create namespace istio-system \
  --dry-run=client -o yaml \
  | kubectl apply -f -

log-message "INFO" "Create secret in cluster"
kubectl --context="${CLUSTER_CONTEXT}" \
    create secret generic cacerts -n istio-system \
    --from-file="$(pwd)/certs/$CLUSTER_CONTEXT/ca-cert.pem" \
    --from-file="$(pwd)/certs/$CLUSTER_CONTEXT/ca-key.pem" \
    --from-file="$(pwd)/certs/$CLUSTER_CONTEXT/root-cert.pem" \
    --from-file="$(pwd)/certs/$CLUSTER_CONTEXT/cert-chain.pem"
