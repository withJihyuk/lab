```shell
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set defaultSettings.defaultDataPath=/mnt/longhorn
```

- cloudinit 스크립트만 노드풀에 넣어주고, 나머지 설정은 관련 블로그 글에서 보고 했다.
- [참고글 1](https://sftblw.tistory.com/123) / [참고글 2](https://smale.codes/posts/oracle-longhorn-fixes/)