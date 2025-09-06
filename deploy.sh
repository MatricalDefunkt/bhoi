#!/bin/bash

# Build and Deploy Ping Server to Kubernetes with kind

set -e

echo "� Checking if kind cluster exists..."
if ! kind get clusters | grep -q "ping-server-cluster"; then
    echo "� Creating kind cluster..."
    kind create cluster --config=kind-config.yaml
else
    echo "✅ Kind cluster 'ping-server-cluster' already exists"
fi

echo "🔧 Setting kubectl context to kind cluster..."
kubectl cluster-info --context kind-ping-server-cluster

echo "📊 Installing metrics server for HPA..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch metrics server for kind (insecure TLS)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

echo "⏳ Waiting for metrics server to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s

echo "🔨 Building Docker image..."
docker build -t ping-server:latest .

echo "📦 Loading image into kind cluster..."
kind load docker-image ping-server:latest --name ping-server-cluster

echo "🚀 Deploying to Kubernetes..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/ping-server

echo "📊 Applying HPA (Horizontal Pod Autoscaler)..."
kubectl apply -f k8s/hpa.yaml

echo "✅ Deployment complete!"
echo ""
echo "📍 Service Information:"
kubectl get svc ping-server-service ping-server-nodeport

echo ""
echo "🎯 Pod Information:"
kubectl get pods -l app=ping-server

echo ""
echo "📈 HPA Status:"
kubectl get hpa ping-server-hpa

echo ""
echo "🌐 Access your application:"
echo "  - Internal (ClusterIP): http://ping-server-service"
echo "  - External (NodePort): http://localhost:30080"
echo ""
echo "🔍 Useful commands:"
echo "  - Check logs: kubectl logs -l app=ping-server --tail=50"
echo "  - Scale manually: kubectl scale deployment ping-server --replicas=5"
echo "  - Port forward: kubectl port-forward svc/ping-server-service 8080:80"
echo "  - Test ping: curl http://localhost:30080/ping"
echo "  - Delete deployment: kubectl delete -f k8s/"
echo "  - Delete kind cluster: kind delete cluster --name ping-server-cluster"
