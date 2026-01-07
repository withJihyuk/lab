# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains infrastructure code for managing a Kubernetes cluster using ArgoCD with GitOps methodology. Applications are deployed hierarchically using the App of Apps pattern.

## Architecture

### App of Apps Pattern

- `root.yaml`: The root ArgoCD Application that automatically discovers `application.yaml` and `applicationset.yaml` files and creates child applications
- Each application directory contains an `application.yaml` that defines the ArgoCD Application

### Directory Structure

```
.
├── root.yaml                  # Root ArgoCD Application
├── bootstrap/                 # Initial cluster setup
│   └── argocd/               # Install ArgoCD via Helmfile
├── system/                    # Core system components
│   ├── cert-manager/         # TLS certificate management
│   ├── doppler-operator/     # Secret management
│   ├── istio-base/           # Istio CRDs
│   └── istiod/               # Istio control plane
├── networking/                # Networking resources
│   └── istio-gateway/        # Istio Gateway configuration
└── projects/                  # Application projects
    └── potato-image-upload/
```

## Common Commands

### Bootstrap (Initial Cluster Setup)

```bash
# 1. Install ArgoCD
cd bootstrap/argocd && helmfile apply

# 2. Deploy Root Application
kubectl apply -f root.yaml

# 3. Create required secrets
kubectl create secret generic cloudflare-api-token-secret \
  --namespace cert-manager \
  --from-literal=api-token=<your-cloudflare-api-token>

kubectl create secret generic potato-image-upload \
  --namespace doppler-operator-system \
  --from-literal=serviceToken=<your-doppler-service-token>
```

### ArgoCD Management

```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Check all application status
kubectl get applications -n argocd

# Check specific application sync status
kubectl get application <app-name> -n argocd -o yaml
```

## File Patterns

- `application.yaml`: ArgoCD Application definition
- `applicationset.yaml`: Multi-environment deployment using ApplicationSet (e.g., dev/prod)
- `helmfile.yaml`: Helm chart deployment using Helmfile (used in bootstrap phase)
- `manifests/`: Directory containing raw Kubernetes manifests for each application

## Application Structure

Each application follows this structure:
```
<app-name>/
├── application.yaml    # ArgoCD Application definition
└── manifests/          # Kubernetes manifests (optional, for raw manifests)
```

## Multi-source Applications

Some applications combine Helm charts with additional manifests (e.g., `system/cert-manager`):

- First source: Helm chart (from official repository)
- Second source: Additional resources (from `manifests/` directory)

## Sync Policy

All applications use the following policies by default:

- `automated.prune: true` - Automatically delete removed resources
- `automated.selfHeal: true` - Automatically fix configuration drift
- `CreateNamespace=true` - Automatically create namespaces
- `SkipDryRunOnMissingResource=true` - Skip dry run for CRDs not yet installed
- `retry` - Automatic retry with exponential backoff for dependency resolution
