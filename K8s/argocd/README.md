```shell
kubectl apply -f argocd-ingress-controller
```

```shell
kubectl get configmap argocd-cmd-params-cm  -n argocd -o yaml > argocd-cmd-params-cm.yaml
```

이후, `argocd-cmd-params-cm.yaml` 파일의 `metadata`와 같은 depth에 아래 라인을 추가 해준다.

```yaml
data:
  server.insecure: "true"
```
