```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
kubectl apply -f prometheus-additional-scrape-configs.yaml
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
    -f my-values.yaml \
    -n monitoring
```

- 내가 잘 못 알고 있는진 몰라도, Longhorn StorageClass에서 replicas count를 바꾸어도 적용이 되지 않는다.
  - 같은 문제가 발생한다면 `longhorn 웹` -> `volumes` -> `update replicas count` -> `1` 으로 직접 바꿔줄 수 있다.
- 초기 비밀번호는 `prom-operator`로, 변경이 필요하다.

