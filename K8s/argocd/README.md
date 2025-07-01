## Ingress 적용

```shell
kubectl apply -f argocd-ingress-controller
```

```shell
kubectl get configmap argocd-cmd-params-cm  -n argocd -o yaml > argocd-cmd-params-cm.yaml
```

이후, `argocd-cmd-params-cm.yaml` 파일에서 `metadata`와 같은 depth에 아래 라인을 추가 해준다.

```yaml
data:
  server.insecure: "true"
```

```shell
kubectl rollout restart deployment argocd-server -n argocd
```

이후, 캐시 삭제 후 접속하면 된다.

## 계정 추가

```shell
kubectl edit configmap argocd-cm -n argocd
```

이후, `data` 란에 `elice`가 추가 할 계정이라면

```yaml
data:
  accounts.elice: apiKey, login
  accounts.elice.enabled: "true"
```

```shell
argocd login argocd-server.argocd
# y / 관리자 계정 로그인
argocd account update-password --account elice --new-password '새 비밀번호'
# 관리자 비밀번호 입력
# Password updated 라고 뜨면 성공이다.
```

아래는 권한 부여이다. [Argocd RBAC](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/)를 따라 아래처럼 값을 수정 해주면 된다.

```shell
kubectl get configmap argocd-rbac-cm -n argocd -o yaml > argocd-rbac-latest.yaml
```

이후, `argocd-rbac-latest.yaml` 파일에서 `metadata`와 같은 depth에 아래 라인을 추가 해준다.  
본인의 필요에 따라 수정 해주면 된다.

```yaml
data:
  policy.csv: |
    p,role:custom-sync,applications,sync,default/motung-prod,allow
    p,role:custom-sync,projects,get,default,allow
    p,role:custom-sync,logs,get,default/motung-prod,allow
    g,motunge,role:custom-sync
    p,role:anonymous-viewer,applications,get,*,allow
    p,role:anonymous-viewer,logs,get,*,deny
    g,anonymous,role:anonymous-viewer
  policy.default: role:anonymous-viewer
metadata:
```

## 익명 접근 허용 & Bedge 사용

포트폴리오 목적으로, 외부에 `Applications Status`를 노출 하고 싶었다.

```shell
kubectl get configmap argocd-cm -n argocd -o yaml > argocd-cm-latest.yaml
```

이후, `argocd-cm-latest.yaml` 파일에서 `metadata`와 같은 depth에 아래 라인을 추가 해준다.  
본인의 필요에 따라 수정 해주면 된다.

```yaml
data:
  users.anonymous.enabled: "true" # 익명 접근
  statusbadge.enabled: "true" # 뱃지
```
