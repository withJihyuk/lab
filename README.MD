<div align=center>

## 🚀 Docker composes

제 서버에서 실제로 사용되는 파일들 입니다.  
최근엔 oke + nginx-ingress-controller 조합으로 전환중입니다.

모두 운영 + 개발용으로 사용하며, 외부로 접근됩니다.

</div>


```shell
# docker
export CLOUDFLARED_TOKEN=(본인의 값)
export DB_PASSWORD=(본인의 값)
cd (실행할 컨테이너)
docker-compose up -d

# k8s
kubectl apply -f (파일)
```
