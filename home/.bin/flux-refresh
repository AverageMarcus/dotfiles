#!/usr/bin/env bash

source .utils

set -e

VERBOSE=""
TARGET_RESOURCE="all"
NAMESPACES="-A"

print_usage() {
  blue "flux-refresh - Refresh all flux resources"
  echo " "
  underline "Usage:"
  echo "flux-refresh [options]"
  echo " "
  underline "Options:"
  echo "-t, --type            the resource type to target. Valid options: gitrepo, helmrepository, kustomization, helmrelease & all. Default: all"
  echo "-n, --namespace       the namespace resources belong in. Default: all namespaces"
  echo "    --verbose         show full verbose output"
  echo "-h, --help            show this help text"
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      print_usage
      exit 0
      ;;
    -t|--type)
      shift
      TARGET_RESOURCE=$1
      shift
      ;;
    -n|--namespace)
      shift
      NAMESPACES="-n $1"
      shift
      ;;
    --verbose)
      VERBOSE="true"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [[ "${TARGET_RESOURCE}" == "all" || "${TARGET_RESOURCE}" == "gitrepo" ]]; then
  GITREPOS=$(kubectl get gitrepo ${NAMESPACES} -o json | jq -r '.items[] | "\(.metadata.namespace)/\( .kind)/\( .metadata.name)"')
fi
if [[ "${TARGET_RESOURCE}" == "all" || "${TARGET_RESOURCE}" == "helmrepository" ]]; then
  HELMREPOS=$(kubectl get helmrepository ${NAMESPACES} -o json | jq -r '.items[] | "\(.metadata.namespace)/\( .kind)/\( .metadata.name)"')
fi
if [[ "${TARGET_RESOURCE}" == "all" || "${TARGET_RESOURCE}" == "kustomization" ]]; then
  KUSTOMIZATIONS=$(kubectl get kustomization ${NAMESPACES} -o json | jq -r '.items[] | "\(.metadata.namespace)/\( .kind)/\( .metadata.name)"')
fi
if [[ "${TARGET_RESOURCE}" == "all" || "${TARGET_RESOURCE}" == "helmrelease" ]]; then
  HEALMRELEASES=$(kubectl get helmrelease ${NAMESPACES} -o json | jq -r '.items[] | "\(.metadata.namespace)/\( .kind)/\( .metadata.name)"')
fi

if [[ "${GITREPOS}" != "" ]]; then
  blue "Refreshing GitRepositories"
  for RESOURCE in ${GITREPOS}
  do
    PARTS=($(echo ${RESOURCE} | tr '[:upper:]' '[:lower:]' | tr "/" "\n"))
    printf "${PARTS[0]}/${PARTS[2]}"
    if [[ "${VERBOSE}" == "true" ]]; then
      echo ""
      flux reconcile source git -n ${PARTS[0]} ${PARTS[2]} || true
    else
      flux reconcile source git -n ${PARTS[0]} ${PARTS[2]} &> /dev/null || true
      printf " ✅"
    fi
    echo ""
  done
fi

if [[ "${HELMREPOS}" != "" ]]; then
  blue "Refreshing HelmRepositories"
  for RESOURCE in ${HELMREPOS}
  do
    PARTS=($(echo ${RESOURCE} | tr '[:upper:]' '[:lower:]' | tr "/" "\n"))
    printf "${PARTS[0]}/${PARTS[2]}"
    if [[ "${VERBOSE}" == "true" ]]; then
      echo ""
      flux reconcile source helm -n ${PARTS[0]} ${PARTS[2]} || true
    else
      flux reconcile source helm -n ${PARTS[0]} ${PARTS[2]} &> /dev/null || true
      printf " ✅"
    fi
    echo ""
  done
fi

if [[ "${KUSTOMIZATIONS}" != "" ]]; then
  blue "Refreshing Kustomizations"
  for RESOURCE in ${KUSTOMIZATIONS}
  do
    PARTS=($(echo ${RESOURCE} | tr '[:upper:]' '[:lower:]' | tr "/" "\n"))
    printf "${PARTS[0]}/${PARTS[2]}"
    if [[ "${VERBOSE}" == "true" ]]; then
      echo ""
      flux reconcile kustomization -n ${PARTS[0]} ${PARTS[2]} || true
    else
      flux reconcile kustomization -n ${PARTS[0]} ${PARTS[2]} &> /dev/null || true
      printf " ✅"
    fi
    echo ""
  done
fi

if [[ "${HEALMRELEASES}" != "" ]]; then
  blue "Refreshing HelmReleases"
  for RESOURCE in ${HEALMRELEASES}
  do
    PARTS=($(echo ${RESOURCE} | tr '[:upper:]' '[:lower:]' | tr "/" "\n"))
    printf "${PARTS[0]}/${PARTS[2]}"
    if [[ "${VERBOSE}" == "true" ]]; then
      echo ""
      flux reconcile helmrelease -n ${PARTS[0]} ${PARTS[2]} || true
    else
      flux reconcile helmrelease -n ${PARTS[0]} ${PARTS[2]} &> /dev/null || true
      printf " ✅"
    fi
    echo ""
  done
fi
