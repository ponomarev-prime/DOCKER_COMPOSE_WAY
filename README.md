# DOCKER COMPOSE WAY

Just for fun!

Practice in docker compose.

## DRAFT

```
  app:
    build: .
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      - DB_HOST=db
      - DB_NAME=postgres
      - DB_USER=postgres
      - DB_PASSWORD=password
```
## COMPOSE

```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker-compose version
docker-compose version 1.29.2, build 5becea4c
docker-py version: 5.0.0
CPython version: 3.9.0
OpenSSL version: OpenSSL 1.1.1g  21 Apr 2020
```
```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker compose version
Docker Compose version v2.15.1
```

```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker compose ps
NAME                           IMAGE               COMMAND                  SERVICE             CREATED             STATUS              PORTS
docker_compose_way-adminer-1   adminer             "entrypoint.sh php -…"   adminer             5 minutes ago       Up 31 seconds       0.0.0.0:8080->8080/tcp
docker_compose_way-db-1        postgres            "docker-entrypoint.s…"   db                  5 minutes ago       Up 31 seconds       5432/tcp
docker_compose_way-nginx-1     nginx               "/docker-entrypoint.…"   nginx               33 seconds ago      Up 30 seconds       80/tcp, 0.0.0.0:8081->8081/tcp
docker_compose_way-py-1        python:3.11         "python app/app.py"      py                  5 minutes ago       Up 30 seconds
docker_compose_way_app_1       python:3.11         "python app/app.py"      app                 24 minutes ago      Up 24 minutes
```

Ваш файл docker-compose.yml выглядит правильным, но есть несколько замечаний:

В разделе nginx порт 8081 привязан только к локальной машине. Если вы хотите, чтобы контейнер был доступен извне, замените "8081:8081" на "0.0.0.0:8081:8081".
 - В разделе certbot необходимо заменить example.com и www.example.com на ваши реальные домены, чтобы сертификат мог быть получен для этих доменов.
 - В разделе certbot вместо опции --non-interactive можно использовать --agree-tos --register-unsafely-without-email, чтобы не вводить электронную почту, но в этом случае вы не получите уведомлений о проблемах с вашим сертификатом.
 - Я не уверен, что certbot должен зависеть от nginx. Если certbot использует веб-корневой каталог, определенный в nginx, то nginx должен быть запущен и работать, но это не означает, что certbot должен зависеть от него.
В целом, если вы убедились, что файл app/app.py запущен и работает в контейнере py, а также настроили файл default.template для nginx, то контейнеры adminer, nginx, и certbot не должны завершаться с ошибками.

```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker-compose ps  
            Name                          Command                State     Ports
--------------------------------------------------------------------------------
docker_compose_way_adminer_1   entrypoint.sh php -S [::]: ...   Exit 0
docker_compose_way_certbot_1   certbot certonly --webroot ...   Exit 1
docker_compose_way_db_1        docker-entrypoint.sh postgres    Exit 0
docker_compose_way_nginx_1     /docker-entrypoint.sh /bin ...   Exit 1
docker_compose_way_py_1        python app/app.py                Exit 137
```

Ошибки Exit 0 и Exit 137 означают, соответственно, успешное завершение и завершение с ошибкой. Ошибка Exit 1 означает, что процесс завершился с ошибкой, но без каких-либо дополнительных сведений.

Похоже, что контейнер docker_compose_way_nginx_1 завершился с ошибкой. Вы можете проверить журналы контейнера с помощью команды docker logs docker_compose_way_nginx_1 для получения дополнительной информации о том, что вызвало ошибку.

Если вы не можете выяснить причину ошибки из журналов контейнера, проверьте конфигурационный файл Nginx, чтобы убедиться, что он правильно настроен для вашего приложения и взаимодействует правильно с другими контейнерами в вашем приложении.

Кроме того, контейнер docker_compose_way_certbot_1 также завершился с ошибкой. Возможно, вам нужно убедиться, что ваш сервер имеет правильные настройки для запросов сертификатов Let's Encrypt, или что вы используете правильную версию Certbot. Снова проверьте журналы контейнера и настройки вашего приложения, чтобы убедиться, что они правильны.

## NGINX

```
PS C:\Users\ponom\Documents\CODE\DOCKER_COMPOSE_WAY> docker logs docker_compose_way_nginx_1
/bin/bash: line 1: /etc/nginx/conf.d/default.template: No such file or directory
```

default.template - это шаблон конфигурации по умолчанию, который используется при создании контейнера Nginx в Docker. Чтобы настроить Nginx для вашего приложения, вы можете создать свой собственный файл конфигурации и заменить default.template.

Ниже пример конфигурационного файла Nginx, который может быть использован для настройки обратного прокси для вашего приложения:

```
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://your_app:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Этот конфигурационный файл привязывает сервер Nginx к порту 80 и настраивает обратный прокси для вашего приложения, запущенного на порту 8000. Вы должны заменить example.com на доменное имя вашего сайта, а your_app - на имя контейнера, в котором запущено ваше приложение.

Сохраните этот файл как default.conf и поместите его в директорию ./nginx/conf.d/ внутри вашего проекта Docker, чтобы он был автоматически загружен при запуске контейнера Nginx. После этого перезапустите свой проект Docker, чтобы изменения вступили в силу.

---

Это секция volumes в вашем файле docker-compose.yml. Она определяет, какие директории на вашем хост-компьютере будут смонтированы в контейнеры Docker для сохранения данных между запусками.

Конкретно, здесь определены следующие тома:

certbot_etc и certbot_var используются контейнером Certbot для хранения сертификатов Let's Encrypt, полученных в результате автоматического запроса сертификатов.
nginx_conf используется контейнером Nginx для хранения конфигурационных файлов Nginx.
nginx_html используется контейнером Nginx для хранения статических файлов, таких как файлы HTML, CSS, JS и т.д.
Эти тома создаются автоматически при запуске контейнеров, если их еще не существует, и будут сохраняться между запусками контейнеров, если они не будут удалены.

Чтобы посмотреть, какие тома сейчас существуют на вашей системе, вы можете выполнить команду docker volume ls.

---


```
server {
    listen 80;
    server_name *:8081;

    location / {
        proxy_pass http://adminer:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
Данный конфигурационный файл для Nginx позволяет проксировать запросы с любого домена на порт 8080 контейнера adminer.

Здесь server_name *:8081 указывает, что сервер должен обрабатывать запросы с любого домена на порту 8081. Далее, мы используем директиву location /, чтобы указать Nginx на то, как обрабатывать запросы. В данном случае, мы используем proxy_pass http://adminer:8080, чтобы указать Nginx на то, что он должен проксировать запросы на порт 8080 контейнера adminer. Директивы proxy_set_header Host $host и proxy_set_header X-Real-IP $remote_addr используются для передачи соответствующих заголовков в запросах.