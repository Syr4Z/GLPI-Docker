#!/bin/bash
VerifyKey () {
  if [ ! -e /www/config/glpicrypt.key ]
  then
    php -c /etc/php8/conf.d/glpi.ini bin/console glpi:security:change_key --no-interaction
    echo "[glpi-config-db] Key updated"
  fi
}
updateDb () {
    sed -ie "s/#DBHOST#/${MARIADB_HOST}/g;s/#DBPORT#/${MARIADB_PORT}/g;s/#DBUSER#/${MARIADB_USER}/g;s/#DBPASSWORD#/${MARIADB_PASSWORD}/g;s/#DBDEFAULT#/${MARIADB_DATABASE}/g;" /www/config/config_db.php
    echo "[glpi-config-db] DB updated"
}
updateDb
VerifyKey
return 0