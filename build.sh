#!/bin/bash
set -euo pipefail

k3d cluster create --k3s-server-arg '--no-deploy=traefik'
kubectl config use-context k3d-k3s-default
kubectl cluster-info

istioctl operator init
kubectl apply -f istiooperator.yaml
while [[ $(kubectl get -n istio-system istiooperator istiocontrolplane -o 'jsonpath={.status.status}') != "HEALTHY" ]]; do echo "waiting for operator" && sleep 5; done
kustomize build . | kubectl apply -f -

cat <<"EOF"
Test with token (JWT secret is 'secret'):
  token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXRoIjoiTDJobFlXUmxjbk09IiwibmJmIjoxNTAwMDAwMDAwLCJleHAiOjE5MDAwMDAwMDB9.9yl8LcZdq-5UpNLm0Hn0nnoBHXXAnK4e8RSl9vn6l98"
Allowed:
  curl http://localhost:8080/httpbin/ip
  curl -H "Authorization: Bearer $token" http://localhost:8080/httpbin/headers
  curl --user "JWT:$token" http://localhost:8080/podinfo/headers
Denied:
  curl http://localhost:8080/httpbin/headers
  curl http://localhost:8080/podinfo/headers
  curl -H "Authorization: Bearer $token" http://localhost:8080/httpbin/
  curl --user "JWT:$token" http://localhost:8080/podinfo/
OPA REST API (unauthenticated):
  http://localhost:8080/opa/
EOF

kubectl port-forward -n istio-system service/istio-ingressgateway 8080:80
