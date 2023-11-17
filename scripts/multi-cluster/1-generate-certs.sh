#!/bin/bash

set -euo pipefail

source "$(pwd)/scripts/utilities.sh"

export _HELP="
scripts/multi-cluster/generate-certs.sh
  Generate cert for using two cluster context names.

Usage:
  generate-certs.sh CLUSTER1_CONTEXT CLUSTER2_CONTEXT
"

EXPECTED_ARGS_COUNT=2
! arg-count-is-correct $# $EXPECTED_ARGS_COUNT && echo "$_HELP" && exit 1

CLUSTER1_CONTEXT=$1
CLUSTER2_CONTEXT=$2
! vars-are-defined "$CLUSTER1_CONTEXT" "$CLUSTER2_CONTEXT" && echo "$_HELP" && exit 1

! programs-are-installed "git" "make" "jq" && exit 1


TMP_DIR=$(mktemp -d)

pushd "${TMP_DIR}"

log-message "INFO" "Downloading istio repo"
git clone https://github.com/istio/istio.git

cd istio
mkdir certs

log-message "INFO" "Generating certs"
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca
make -f ../../istio/tools/certs/Makefile.selfsigned.mk "${CLUSTER1_CONTEXT}-cacerts"
make -f ../../istio/tools/certs/Makefile.selfsigned.mk "${CLUSTER2_CONTEXT}-cacerts"
popd

popd

log-message "INFO" "Moving certs to current path"
cp -R "${TMP_DIR}/istio/certs" ./

log-message "INFO" "Deleting temp folder"
rm -rf "${TMP_DIR}"
