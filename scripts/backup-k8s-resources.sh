#!/usr/bin/env sh
set -eu

NAMESPACE="${1:-cloudmart-prod}"
OUTPUT_DIR="${2:-backups/k8s}"

mkdir -p "${OUTPUT_DIR}"

kubectl get namespace "${NAMESPACE}" -o yaml > "${OUTPUT_DIR}/${NAMESPACE}-namespace.yaml"
kubectl get all,configmap,secret,ingress,networkpolicy,hpa,serviceaccount -n "${NAMESPACE}" -o yaml > "${OUTPUT_DIR}/${NAMESPACE}-resources.yaml"

echo "Backed up ${NAMESPACE} Kubernetes resources to ${OUTPUT_DIR}"
