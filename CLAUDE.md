# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains infrastructure code for managing a Kubernetes cluster using ArgoCD with GitOps methodology. Applications are deployed hierarchically using the App of Apps pattern.

## Architecture

### App of Apps Pattern

- `root.yaml`: The root ArgoCD Application that automatically discovers `_application.yaml` files and creates child applications
- Each directory's `_application.yaml` manages applications within that directory

### Sync Wave Order

Applications are deployed in the following order (based on `argocd.argoproj.io/sync-wave` annotation):

1. **Wave 1**: `system/` - Core system components
   - cert-manager, external-dns, doppler, metrics-server, reloader, argo-rollouts
2. **Wave 2**: `platform/` - Database and platform services
   - nothing at this time
3. **Wave 3**: `observability/` - Monitoring and logging
   - datadog
4. **Wave 4**: `networking/` - Networking components
   - istio gateway
5. **Wave 5**: `projects/` - Projects
   - potato-image-upload

### Directory Structure

```
.
├── bootstrap/         # Initial cluster setup
│   └── argocd/          # Install ArgoCD via Helmfile
├── system/            # System-level components
├── platform/          # Data platform
├── observability/     # Monitoring stack
├── networking/        # Networking resources
└── projects/          # Projects (potato-image-upload.. etc)
```

## Common Commands

### Bootstrap (Initial Cluster Setup)

```bash
# Install ArgoCD
cd bootstrap/argocd && helmfile apply

# Install Cilium CNI
cd bootstrap/cilium && helmfile apply

# Deploy Root Application (everything else will be deployed automatically)
kubectl apply -f root.yaml
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

- `_application.yaml`: Meta application that groups child applications in the App of Apps pattern
- `application.yaml`: Individual ArgoCD Application definition
- `applicationset.yaml`: Multi-environment deployment using ApplicationSet (e.g., dev/prod)
- `helmfile.yaml`: Helm chart deployment using Helmfile (used in bootstrap phase)

## ApplicationSet Pattern

ApplicationSet is used to template and deploy resources across multiple environments (dev/prod), as seen in `platform/postgres/applicationset.yaml`.

- Define environment-specific configurations in `generators.list.elements`
- Generate resources using Go template syntax in `template`
- Place actual Kubernetes manifests in environment-specific directories (`dev/`, `prod/`)

## Multi-source Applications

Some applications combine Helm charts with additional manifests:

- First source: Helm chart (from official repository)
- Second source: Additional resources (from directories in this repository)

Example: `system/cert-manager/application.yaml`

## Sync Policy

All applications use the following policies by default:

- `automated.prune: true` - Automatically delete removed resources
- `automated.selfHeal: true` - Automatically fix configuration drift
- `CreateNamespace=true` - Automatically create namespaces
