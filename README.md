# Ping Server for Kubernetes

A simple Express.js "ping" server designed to be deployed and scaled on Kubernetes using kind.

## Prerequisites

- Docker Desktop (running)
- kind (`brew install kind` on macOS)
- kubectl (`brew install kubectl` on macOS)
- Node.js and npm

## Quick Start

1. **Setup the environment:**
   ```bash
   chmod +x setup.sh deploy.sh
   ./setup.sh
   ```

2. **Deploy to kind cluster:**
   ```bash
   ./deploy.sh
   ```

3. **Test the service:**
   ```bash
   curl http://localhost:30080/ping
   ```

## Project Structure

```
.
├── server.js              # Express.js server
├── package.json           # Node.js dependencies
├── Dockerfile             # Container image definition
├── kind-config.yaml       # Kind cluster configuration
├── setup.sh              # Environment setup script
├── deploy.sh              # Deployment script
└── k8s/
    ├── deployment.yaml    # Kubernetes deployment
    ├── service.yaml       # Kubernetes services
    └── hpa.yaml          # Horizontal Pod Autoscaler
```

## API Endpoints

- `GET /` - Server information
- `GET /ping` - Returns "pong" with server details
- `GET /health` - Health check endpoint

## Kubernetes Features

- **Horizontal Pod Autoscaler (HPA)**: Automatically scales pods based on CPU/memory usage
- **Health Checks**: Liveness and readiness probes
- **Resource Limits**: CPU and memory constraints
- **Security**: Non-root user, read-only filesystem
- **Multiple Services**: Both ClusterIP and NodePort

## Scaling

The server automatically scales between 2-10 replicas based on:
- CPU usage > 70%
- Memory usage > 80%

Manual scaling:
```bash
kubectl scale deployment ping-server --replicas=5
```

## Monitoring

```bash
# Check pods
kubectl get pods -l app=ping-server

# Check HPA status
kubectl get hpa ping-server-hpa

# View logs
kubectl logs -l app=ping-server --tail=50

# Port forward for local access
kubectl port-forward svc/ping-server-service 8080:80
```

## Cleanup

```bash
# Delete deployment only
kubectl delete -f k8s/

# Delete entire kind cluster
kind delete cluster --name ping-server-cluster
```

## Development

Run locally for development:
```bash
npm install
npm start
# Server runs on http://localhost:3000
```
