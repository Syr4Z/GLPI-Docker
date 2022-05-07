FROM alpine:latest

LABEL maintainer="Sam Ronvaux <samronvaux@gmail.com>"

ENV VERSION 10.0.0
#ENV MARIADB_HOST 127.0.0.1
#ENV MARIADB_PORT 3306
#ENV MARIADB_DATABASE glpi
#ENV MARIADB_USER glpi
#ENV MARIADB_PASSWORD 1P4ssW0rdV3ryS3cur3

########### INSTALL PACKAGES ###########
RUN apk --no-cache add \
    php8 \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-gd \
    php8-iconv \
    php8-intl \
    php8-mbstring \
    php8-mysqli \
    php8-opcache \
    php8-openssl \
    php8-pecl-imagick \
    php8-pecl-redis \
    php8-phar \
    php8-session \
    php8-simplexml \
    php8-soap \
    php8-xml \
    php8-xmlreader \
    php8-zip \
    php8-zlib \
    php8-pdo \
    php8-xmlwriter \
    php8-tokenizer \
    php8-pdo_mysql \
    php8-pdo_sqlite \
    php8-sodium \
    php8-bz2 \
    php8-ldap \
    php8-fpm \
    nginx \
    tzdata \
    openssl \
    supervisor \
    curl \
    tar

########### SETUP SYSTEM ###########
RUN cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    echo "Europe/Brussels" > /etc/timezone && \
    apk del tzdata && \
    mkdir -p /etc/ssl/private/
VOLUME ["/www/files", "/www/plugins", "/www/config"]

########### ADD CA CERTIFICATES ###########
COPY files/ca/* /usr/local/share/ca-certificates/
RUN apk --no-cache add ca-certificates && \
    update-ca-certificates

########### SETUP NGINX ###########
RUN ln -s /usr/bin/php8 /usr/bin/php
COPY files/config/nginx.conf /etc/nginx/nginx.conf
COPY files/config/fastcgi_params.conf /etc/nginx/fastcgi_params
RUN mkdir /www

########### SETUP PHP-FPM ###########
COPY files/config/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY files/config/php.ini /etc/php8/conf.d/glpi.ini

########### SETUP SUPERVISOR ###########
COPY files/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

########### PATCH DIRECTORIES OWNER ###########
RUN chown -R nobody.nobody /www && \
    chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/log/nginx

########### SWITCH USER ###########
USER nobody

########### SETUP GLPI ###########
WORKDIR /www
COPY --chown=nobody:nobody /files/glpi.tgz /tmp
RUN tar -xf /tmp/glpi.tgz -C /tmp/ && \
    mv /tmp/glpi/* /www/ && \
    chown -R nobody.nobody /www && \
    rm -rf /www/install

########### SETUP GLPI DATABASE ###########
COPY --chown=nobody:nobody --chmod=0600 files/config/config_db.php /www/config/config_db.php
COPY --chown=nobody:nobody --chmod=0700 files/glpi-config-db.sh /glpi-config-db.sh

########### INSTALL GLPI PLUGINS ###########
COPY files/plugins/* /www/plugins/
RUN cd /www/plugins && \
    rm remove.txt && \
    for f in /www/plugins/*.t*; do tar -xf "$f"; done && \
    rm -f *.t*

########### EXPOSE TO 8080 ###########
EXPOSE 8080/tcp

########### START WEBSERVER ###########
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

########### ADD HEALTHCHECK ###########
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping