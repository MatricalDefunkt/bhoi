#!/bin/bash

# Build and Deploy Ping Server to Kubernetes

set -e

echo "🔨 Building Docker image..."
docker build -t ping-server:latest .

echo "📦 Loading image into kind cluster (if using kind)..."
# Uncomment the next line if you're using kind
kind load docker-image ping-server:latest

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
echo "  - External (NodePort): http://<node-ip>:30080"
echo ""
echo "🔍 Useful commands:"
echo "  - Check logs: kubectl logs -l app=ping-server --tail=50"
echo "  - Scale manually: kubectl scale deployment ping-server --replicas=5"
echo "  - Port forward: kubectl port-forward svc/ping-server-service 8080:80"
echo "  - Delete all: kubectl delete -f k8s/"
