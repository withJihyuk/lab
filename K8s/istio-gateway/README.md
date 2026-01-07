# Istio Gateway API

nginx-ingress를 Istio Gateway API로 마이그레이션

## Prerequisites

- Kubernetes 1.25+
- cert-manager
- istioctl CLI

## 마이그레이션 순서

### 1. Gateway API CRD 설치

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
```

### 2. Istio 설치

```bash
# istioctl 설치 (macOS)
brew install istioctl

# Istio 설치 (minimal profile + Gateway API 지원)
istioctl install --set profile=minimal --set values.pilot.env.PILOT_ENABLE_GATEWAY_API=true -y

# 설치 확인
kubectl get pods -n istio-system
```

### 3. 와일드카드 인증서 및 Gateway 배포

```bash
kubectl apply -f tls/wildcard-certificate.yaml
kubectl apply -f gateway.yaml
```

### 4. 인증서 발급 확인

```bash
kubectl get certificate -n istio-system wildcard-mya-ong
```

### 5. 기존 Ingress 삭제 후 HTTPRoute 적용

```bash
# ArgoCD
kubectl delete ingress argocd-server-ingress -n argocd
kubectl apply -f httproutes/argocd-route.yaml

# Grafana
kubectl delete ingress loki-stack-grafana-ingress -n monitoring
kubectl apply -f httproutes/grafana-route.yaml

# Potato API
kubectl delete ingress potato-image-backend-ingress -n potato
kubectl apply -f httproutes/potato-api-route.yaml

# Potato 4Cut (prod)
kubectl delete ingress potato-4-cut-ingress -n danuri-prod
kubectl apply -f httproutes/potato-4cut-prod-route.yaml

# Potato 4Cut (stage)
kubectl delete ingress potato-4-cut-ingress -n danuri-stage
kubectl apply -f httproutes/potato-4cut-stage-route.yaml
```

### 6. DNS 업데이트

새 Gateway LoadBalancer IP로 DNS 레코드 업데이트:

```bash
kubectl get svc -n istio-system istio-gateway
```

### 7. nginx-ingress 제거

```bash
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

## 파일 구조

```
istio-gateway/
├── README.md
├── gateway.yaml
├── tls/
│   └── wildcard-certificate.yaml
└── httproutes/
    ├── argocd-route.yaml
    ├── grafana-route.yaml
    ├── potato-api-route.yaml
    ├── potato-4cut-prod-route.yaml
    └── potato-4cut-stage-route.yaml
```

## Troubleshooting

```bash
# Gateway 상태 확인
kubectl get gateway -A
kubectl describe gateway istio-gateway -n istio-system

# HTTPRoute 상태 확인
kubectl get httproute -A
kubectl describe httproute <name> -n <namespace>

# Istio 로그 확인
kubectl logs -n istio-system -l app=istiod

# 인증서 상태 확인
kubectl get certificate -n istio-system
kubectl describe certificate wildcard-mya-ong -n istio-system
```
