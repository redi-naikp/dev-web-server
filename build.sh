#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
BUILD_DIR=${SCRIPT_DIR}/build

HELM_REPO=${HELM_REG:-https://artifactory.rdti.com/artifactory/helm-local}
HELM_USR=${HELM_USR:-admin}
HELM_PSW=${HELM_PSW:-password}

usage () {
    cat << END_USAGE

${SCRIPT_NAME} - Script for building the Helm chart

Usage: ./${SCRIPT_NAME} <options>

--pack_helm         : [optional] Pack helm chart
--push_helm         : [optional] Push the the helm chart
--helm_repo         : [optional] The helm repository to push to
--helm_usr          : [optional] The user for uploading to the helm repository
--helm_psw          : [optional] The password for uploading to the helm repository
-h | --help         : Show this usage
END_USAGE

    exit 1
}

# Packing the helm chart
packHelmChart() {
    echo -e "\nPacking Helm chart"

    [ -d ${BUILD_DIR}/helm ] && rm -rf ${BUILD_DIR}/helm
    mkdir -p ${BUILD_DIR}/helm

    helm package -d ${BUILD_DIR}/helm ${SCRIPT_DIR}/helm/acme || errorExit "Packing helm chart ${SCRIPT_DIR}/helm/acme failed"
}

# Pushing the Helm chart
# Note - this uses the Artifactory API. You can replace it with any other solution you use.
pushHelmChart() {
    echo -e "\nPushing Helm chart"

    local chart_name=$(ls -1 ${BUILD_DIR}/helm/*.tgz 2> /dev/null)
    echo "Helm chart: ${chart_name}"

    [ ! -z "${chart_name}" ] || errorExit "Did not find the helm chart to deploy"
    curl -u${HELM_USR}:${HELM_PSW} -T ${chart_name} "${HELM_REPO}/$(basename ${chart_name})" || errorExit "Uploading helm chart failed"
    echo
}

processOptions () {
    if [ $# -eq 0 ]; then
        usage
    fi

    while [[ $# > 0 ]]; do
        case "$1" in
            --build)
                BUILD="true"; shift
            ;;
            --push)
                PUSH="true"; shift
            ;;
            --pack_helm)
                PACK_HELM="true"; shift
            ;;
            --push_helm)
                PUSH_HELM="true"; shift
            ;;
            --helm_repo)
                HELM_REPO=${2}; shift 2
            ;;
            --helm_usr)
                HELM_USR=${2}; shift 2
            ;;
            --helm_psw)
                HELM_PSW=${2}; shift 2
            ;;
            -h | --help)
                usage
            ;;
            *)
                usage
            ;;
        esac
    done
}

main () {
    echo -e "\nRunning"

    echo "HELM_REPO:    ${HELM_REPO}"
    echo "HELM_USR:     ${HELM_USR}"

    # Cleanup
    rm -rf ${BUILD_DIR}

    # Pack and push helm chart if needed
    if [ "${PACK_HELM}" == "true" ]; then
        packHelmChart
    fi
    if [ "${PUSH_HELM}" == "true" ]; then
        pushHelmChart
    fi
}

############## Main

processOptions $*
main
