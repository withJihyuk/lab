<div align=center>

## 🚀 Docker composes

제 서버에서 실제로 사용되는 `docker-compose.yml` 파일들 입니다.  
최근엔 서버의 SPOF 지점을 방지하기 위해, 3-NODES-K3S로 운영중에 있습니다.

본 도커들은 모두 개발용으로만 사용하며, Tailscale로 접근됩니다.

</div>

```shell
export CLOUDFLARED_TOKEN=(본인의 값)
export DB_PASSWORD=(본인의 값)
docker-compose up -d
```
