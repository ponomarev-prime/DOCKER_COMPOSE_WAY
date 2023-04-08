# DOCKER COMPOSE WAY

Just for fun!

Practice in docker compose.

**PYTHON + POSTGRE + ADMINER + NGINX + CERTBOT**

## Commands

```
docker stop $(docker ps -aq)

docker compose up --build
docker compose up
docker compose down
```


## COMPOSE

Разница `docker-compose` и `docker compose`:
```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker-compose version
docker-compose version 1.29.2, build 5becea4c
docker-py version: 5.0.0
CPython version: 3.9.0
OpenSSL version: OpenSSL 1.1.1g  21 Apr 2020
```
::
```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker compose version
Docker Compose version v2.15.1
```
---

Вначале я запустил все контейнеры "как есть". Они были доступны по портам:
```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker compose ps
NAME                           IMAGE                   COMMAND                  SERVICE             CREATED              STATUS              PORTS
docker_compose_way-adminer-1   adminer                 "entrypoint.sh php -…"   adminer             10 minutes ago       Up About a minute   0.0.0.0:8080->8080/tcp
docker_compose_way-db-1        postgres                "docker-entrypoint.s…"   db                  10 minutes ago       Up About a minute   5432/tcp
docker_compose_way-nginx-1     nginx                   "/docker-entrypoint.…"   nginx               About a minute ago   Up About a minute   80/tcp, 0.0.0.0:8081->8081/tcp
docker_compose_way-py-1        docker_compose_way-py   "uvicorn main:app --…"   py                  About a minute ago   Up About a minute   0.0.0.0:8000->8000/tcp
```

Далее я добавил внутреннюю сеть: `my-network`, изменил `nginx.conf`, а ещё изменил порты. Таким образом, снаружи есть доступ только в `NGINX`, а уже он проксирует запросы в разные сервисы:
```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker compose ps
NAME                           IMAGE                   COMMAND                  SERVICE             CREATED             STATUS              PORTS
docker_compose_way-adminer-1   adminer                 "entrypoint.sh php -…"   adminer             4 minutes ago       Up 28 seconds       8080/tcp
docker_compose_way-db-1        postgres                "docker-entrypoint.s…"   db                  4 minutes ago       Up 2 minutes        5432/tcp
docker_compose_way-nginx-1     nginx                   "/docker-entrypoint.…"   nginx               30 seconds ago      Up 27 seconds       0.0.0.0:80->80/tcp
docker_compose_way-py-1        docker_compose_way-py   "uvicorn main:app --…"   py                  30 seconds ago      Up 28 seconds
```
Web-приложение работает на `localhost`:
```
http://127.0.0.1/ - главная - отдётся `json` от unvicorn
http://127.0.0.1/adminer - adminer
http://127.0.0.1/static/jinsung-lim-img-3189.jpg - статическое изображение
```
 

## NGINX


```
docker logs docker_compose_way_nginx_1
```

`nginx.conf`:
```
worker_processes 1;

events { worker_connections 1024; }

http {

    upstream py {
        server py:8000;
    }

    upstream adminer {
        server adminer:8080;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://py;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /adminer {
            proxy_pass http://adminer;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /static {
            alias /usr/share/nginx/html/;
            expires 1h;
            add_header Cache-Control public;
        }

#        location /favicon.ico {
#            alias /usr/share/nginx/html/favicon.ico;
#        }
    }
}
```

## Переменные окружения

`.env`:
```
SECRET_KEY='secret key'

DB_HOST='db'
DB_NAME='postgres'
DB_USER='postgres'
DB_PASSWORD='password'
```