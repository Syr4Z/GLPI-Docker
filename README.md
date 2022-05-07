![Logo GLPI](https://glpi-project.org/wp-content/uploads/2021/06/GLPI_by_Teclib.png)
# GLPI on Docker

## What is GLPI
GLPI (Gestionnaire Libre de Parc Informatique) is a free and open software for asset, soft and license management.
GLPI can also be used as ITIL service desk features.

[Github GLPI](https://github.com/glpi-project/glpi) - [Website GLPI](https://glpi-project.org/)

## What is this image
This image is a basis for deploying a glpi instance via Docker.
It has been designed to run on unprivileged environments such as Kubernetes.

## How to Deploy
Load the database dump on your Maria db server.
```
$ mysql -u glpi -p glpidb < files/sql/dump.sql
```


### **With Docker run**
Start a container based on this image.
```
$ docker run -d --name glpi \
-e MARIADB_HOST=sql.example.com \
-e MARIADB_PORT=3306 \
-e MARIADB_DATABASE=glpidb \
-e MARIADB_USER=glpi \
-e MARIADB_PASSWORD=1P4ssW0rdV3ryS3cur3 \
syr4z/glpi:latest
```

### **With Docker compose**
```
version: "10.0.0"
services:
    glpi:
        image: syr4z/glpi:latest
        restart: unless-stopped
        volumes:
            - glpi-files:/www/files:rw
            - glpi-plugins:/www/plugins:rw
            - glpi-config:/www/config:rw
        environment:
            MARIADB_HOST: sql.example.com
            MARIADB_PORT:3306
            MARIADB_DATABASE:glpidb
            MARIADB_USER:glpi
            MARIADB_PASSWORD:1P4ssW0rdV3ryS3cur3
        ports:
            - 8080:8080
volumes:
    glpi-files:
    glpi-plugins:
    glpi-config
```