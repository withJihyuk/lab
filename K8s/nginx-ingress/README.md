# NGINX Ingress Controller for OCI

## Overview
NGINX Ingress Controller with Oracle Cloud Infrastructure (OCI) LoadBalancer configuration.

## Configuration
- **LoadBalancer Type**: OCI Flexible Shape
- **Bandwidth**: ~50 Mbps (max)

## Installation

### Using Helm (Recommended)
```bash
# Add Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install with OCI-specific configuration
helm install ingress-nginx ingress-nginx/ingress-nginx \
  -f nginx-ingress-values.yaml \
  -n ingress-nginx \
  --create-namespace
```