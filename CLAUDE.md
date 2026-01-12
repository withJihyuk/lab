# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains infrastructure code for managing a Kubernetes cluster using ArgoCD with GitOps methodology. Applications are deployed hierarchically using the App of Apps pattern.

## Architecture

### Hierarchical App of Apps Pattern

```
root.yaml
├── system/application.yaml (sync-wave: 1)
│   ├── cert-manager/application.yaml
│   ├── cluster-secrets/application.yaml
│   ├── doppler-operator/application.yaml
│   ├── istio-base/application.yaml
│   └── istiod/application.yaml
├── networking/application.yaml (sync-wave: 2)
│   └── istio-gateway/application.yaml
├── observability/application.yaml (sync-wave: 3)
│   └── datadog/application.yaml
└── projects/application.yaml (sync-wave: 4)
    └── potato-image-upload/application.yaml
```

- `root.yaml`: Root Application that discovers category-level App of Apps
- Each category (`system/`, `networking/`, `observability/`, `projects/`) has its own `application.yaml` that discovers child applications
- `sync-wave` annotations control deployment order between categories

### Directory Structure

```
.
├── root.yaml                  # Root ArgoCD Application
├── bootstrap/                 # Initial cluster setup
│   └── argocd/               # Install ArgoCD via Helmfile
├── system/                    # Core system components (sync-wave: 1)
│   ├── application.yaml      # System App of Apps
│   ├── cert-manager/
│   ├── cluster-secrets/
│   ├── doppler-operator/
│   ├── istio-base/
│   └── istiod/
├── networking/                # Networking resources (sync-wave: 2)
│   ├── application.yaml      # Networking App of Apps
│   └── istio-gateway/
├── observability/             # Monitoring and observability (sync-wave: 3)
│   ├── application.yaml      # Observability App of Apps
│   └── datadog/
└── projects/                  # Application projects (sync-wave: 4)
    ├── application.yaml      # Projects App of Apps
    └── potato-image-upload/
```

## Common Commands

### Bootstrap (Initial Cluster Setup)

```bash
# 1. Install ArgoCD
cd bootstrap/argocd && helmfile apply

# 2. Deploy Root Application
kubectl apply -f root.yaml

# 3. Create Doppler service tokens
# k8s-configuration: cluster-wide secrets (Cloudflare, Datadog, etc.)
kubectl create secret generic k8s-configuration \
  --namespace doppler-operator-system \
  --from-literal=serviceToken=<your-doppler-service-token>

# Project-specific secrets
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
- `applicationset.yaml`: Multi-environment deployment using ApplicationSet
- `helmfile.yaml`: Helm chart deployment using Helmfile (bootstrap only)

## Application Structure

All applications use the `directory.exclude` pattern - resources are placed in the same folder as `application.yaml`:

```
<app-name>/
├── application.yaml    # ArgoCD Application (excluded from sync)
├── resource1.yaml      # Kubernetes manifests
└── resource2.yaml
```

### Category App of Apps

Each category discovers child applications recursively:

```yaml
source:
  path: <category>
  directory:
    recurse: true
    include: "{**/application.yaml,**/applicationset.yaml}"
```

### Individual Applications

Each application excludes its own `application.yaml`:

```yaml
source:
  path: <category>/<app-name>
  directory:
    exclude: application.yaml
```

### Multi-source Applications (Helm + manifests)

```yaml
sources:
  - repoURL: https://helm.example.com
    chart: example-chart
    targetRevision: 1.0.0

  - repoURL: https://github.com/withjihyuk/homelab.git
    targetRevision: HEAD
    path: <category>/<app-name>
    directory:
      exclude: application.yaml
```

## Secret Management

Cluster-wide secrets are managed via Doppler through `system/cluster-secrets/`:

- **Doppler Project**: `k8s-configuration`
- **Config**: `prd`
- **Keys**:
  - `CLOUDFLARE_API_TOKEN` - Cloudflare API token for cert-manager DNS01 challenge
  - `DATADOG_API_KEY` - Datadog API key
  - `DATADOG_APP_KEY` - Datadog App key

DopplerSecret resources sync secrets from Doppler to target namespaces.

## Sync Policy

All applications use the following policies by default:

- `automated.prune: true` - Automatically delete removed resources
- `automated.selfHeal: true` - Automatically fix configuration drift
- `CreateNamespace=true` - Automatically create namespaces
- `SkipDryRunOnMissingResource=true` - Skip dry run for CRDs not yet installed
- `retry` - Automatic retry with exponential backoff for dependency resolution
