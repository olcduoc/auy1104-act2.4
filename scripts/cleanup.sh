#!/usr/bin/env bash
# Borra deployments y services creados por cualquier estrategia
set -e

echo "Limpiando deployments..."
kubectl delete deployment \
  app-rolling app-recreate \
  app-blue app-green \
  app-stable app-canary \
  --ignore-not-found=true

echo "Limpiando services (esto libera los LoadBalancers)..."
kubectl delete service \
  svc-rolling svc-recreate svc-bluegreen svc-canary \
  --ignore-not-found=true

echo "Esperando a que los ELBs se desprovisionen (~30-60s)..."
sleep 5
kubectl get svc,deploy
