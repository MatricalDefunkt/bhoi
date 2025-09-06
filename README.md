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
   chmod +x setup.sh deploy.sh fix-metrics-server.sh test-autoscaling.sh
   ./setup.sh
   ```

2. **Deploy to kind cluster:**
   ```bash
   ./deploy.sh
   ```

3. **If metrics server has issues (common with kind):**
   ```bash
   ./fix-metrics-server.sh
   ```

4. **Test the service:**
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
├── fix-metrics-server.sh  # Metrics server troubleshooting
├── test-autoscaling.sh    # Autoscaling load test
└── k8s/
    ├── deployment.yaml    # Kubernetes deployment
    ├── service.yaml       # Kubernetes services
    └── hpa.yaml          # Horizontal Pod Autoscaler
```

## API Endpoints

- `GET /` - Server information
- `GET /ping` - Returns "pong" with server details
- `GET /health` - Health check endpoint
- `GET /stress?duration=5000` - CPU stress test for autoscaling (duration in ms, max 30s)

## Autoscaling Features

### Horizontal Pod Autoscaler (HPA)
- **Min Replicas**: 1
- **Max Replicas**: 15
- **CPU Threshold**: 60% average utilization
- **Memory Threshold**: 70% average utilization
- **Scale Up**: Fast (15s stabilization, up to 100% increase)
- **Scale Down**: Conservative (60s stabilization, max 50% decrease)

### Testing Autoscaling
```bash
# Make scripts executable
chmod +x test-autoscaling.sh

# Run load test to trigger autoscaling
./test-autoscaling.sh
```

The load test will:
1. Generate high-frequency ping requests
2. Call CPU stress endpoints
3. Monitor scaling in real-time
4. Save scaling metrics to `scaling_log.csv`

## Scaling

The server automatically scales between 1-15 replicas based on:
- CPU usage > 60%
- Memory usage > 70%

Manual scaling:
```bash
kubectl scale deployment ping-server --replicas=5
```

### Real-time Autoscaling Monitoring
```bash
# Watch HPA status
kubectl get hpa ping-server-hpa --watch

# Monitor pod scaling
watch kubectl get pods -l app=ping-server
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
