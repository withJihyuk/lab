```bash
helm install redis bitnami/redis \
  --values override-values.yaml \
  -n redis \
  --create-namespace
```
