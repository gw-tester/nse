#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c)
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset
if [[ "${DEBUG:-true}" == "true" ]]; then
    set -o xtrace
fi

function info {
    _print_msg "INFO" "$1"
}

function error {
    _print_msg "ERROR" "$1"
    exit 1
}

function _print_msg {
    echo "$(date +%H:%M:%S) - $1: $2"
}

function assert_equals {
    local input=$1
    local expected=$2

    if [ "$input" != "$expected" ]; then
        error "Go $input expected $expected"
    fi
}

function assert_non_empty {
    local input=$1

    if [ -z "$input" ]; then
        error "Empty input value"
    fi
}

info "Deploy client and endpoint testing pods"
make deploy-test
trap "kubectl delete -k test/" EXIT

info "Wait for pod's readiness"
for pod in client endpoint; do
    kubectl wait --for=condition=ready pods "$pod" --timeout=3m
done

info "Validating Client's links"
assert_equals "$(kubectl exec -c instance client -- ip l | grep -c LOWER_UP )" "4"

info "Validating Client's routes"
assert_non_empty "$(kubectl exec -c instance client -- ip r | grep "10.0.3.0/24" )"
