#!/bin/bash
set -euo pipefail

k3d cluster create --k3s-server-arg '--no-deploy=traefik'
kubectl config use-context k3d-k3s-default
kubectl cluster-info

istioctl operator init
kubectl apply -f istiooperator.yaml
while [[ $(kubectl get -n istio-system istiooperator istiocontrolplane -o 'jsonpath={.status.status}') != "HEALTHY" ]]; do echo "waiting for operator" && sleep 5; done
kustomize build . | kubectl apply -f -

echo
echo "Test with token (JWT secret is 'secret'):"
echo '  token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXRoIjoiTDJobFlXUmxjbk09IiwibmJmIjoxNTAwMDAwMDAwLCJleHAiOjE5MDAwMDAwMDB9.9yl8LcZdq-5UpNLm0Hn0nnoBHXXAnK4e8RSl9vn6l98"'
echo 'Allowed:'
echo '  curl http://localhost:8080/httpbin/ip'
echo '  curl -H "Authorization: Bearer $token" http://localhost:8080/httpbin/headers'
echo '  curl --user "JWT:$token" http://localhost:8080/podinfo/headers'
echo 'Denied:'
echo '  curl http://localhost:8080/httpbin/headers'
echo '  curl http://localhost:8080/podinfo/headers'
echo '  curl -H "Authorization: Bearer $token" http://localhost:8080/httpbin/'
echo '  curl --user "JWT:$token" http://localhost:8080/podinfo/'
echo 'OPA REST API (unauthenticated):'
echo '  curl http://localhost:8080/opa/'
echo

kubectl port-forward -n istio-system service/istio-ingressgateway 8080:80
