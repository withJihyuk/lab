```bash
helm install loki-stack grafana/loki-stack --values loki-stack-values.yaml -n monitoring
```

```
longhorn volumes -> update replicas count -> 1
```

```bash
kubectl get secret --namespace monitoring loki-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
