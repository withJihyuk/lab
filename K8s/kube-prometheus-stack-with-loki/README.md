```bash
helm pull prometheus-community/kube-prometheus-stack
tar xvfz kube-prometheus-stack-(version).tgz
helm install kube-prometheus -f my-values.yaml . -n monitoring
```

- 내가 잘 못 알고 있는진 몰라도, Longhorn StorageClass에서 replicas count를 바꾸어도 적용이 되지 않는다.
  - 같은 문제가 발생한다면 `longhorn 웹` -> `volumes` -> `update replicas count` -> `1` 으로 직접 바꿔줄 수 있다.
- 초기 비밀번호는 `prom-operator`로, 변경이 필요하다.
