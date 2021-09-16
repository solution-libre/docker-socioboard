#!/usr/bin/env sh

set -e

PWD=$(pwd)
SOCIOBOARD_VERSION='5.1.0'
web_path=/var/www/html

if [ ! -d ${web_path}/app ]; then
  archive_filename="socioboard-${SOCIOBOARD_VERSION}.tar.gz"
  cd /tmp
  curl -s https://codeload.github.com/socioboard/Socioboard-5.0/tar.gz/Socioboard-${SOCIOBOARD_VERSION} -o ${archive_filename}
  tar xzf ${archive_filename} Socioboard-5.0-Socioboard-${SOCIOBOARD_VERSION}/socioboard-web-php/
  cd Socioboard-5.0-Socioboard-${SOCIOBOARD_VERSION}
  mv socioboard-web-php/* ${web_path}/
  cd - > /dev/null
  rm -rf ${archive_filename} Socioboard-5.0-Socioboard-${SOCIOBOARD_VERSION}
fi

cd ${web_path}
if [ ! -f .env ]; then
  cp example.env .env
  sed -i -e 's/\(APP_KEY\)=.*/\1=JQHhy0QgKxmgKce7NASf3Zg4ezxLidJS/' .env
  sed -i -e "s/\(APP_URL\)=.*/\1=https:\/\/${HOSTNAME}\//" .env
  sed -i -e 's/\(API_URL\)=.*/\1=http:\/\/api:3000\//' .env
  sed -i -e 's/\(API_URL_FEEDS\)=.*/\1=http:\/\/api:3001\//' .env
  sed -i -e 's/\(API_URL_PUBLISH\)=.*/\1=http:\/\/api:3002\//' .env
  sed -i -e 's/\(API_URL_UPDATE\)=.*/\1=http:\/\/api:3003\//' .env
  sed -i -e 's/\(API_URL_NOTIFY\)=.*/\1=http:\/\/api:3004\//' .env
  echo 'API_URL_NOTIFICATION=http://api:3004/' >> .env
  sed -i -e "s/\(MAIL_DRIVER\)=.*/\1=${MAIL_DRIVER}/" .env
  sed -i -e "s/\(MAIL_HOST\)=.*/\1=${MAIL_HOST}/" .env
  sed -i -e "s/\(MAIL_PORT\)=.*/\1=$MAIL_PORT/" .env
  sed -i -e "s/\(MAIL_USERNAME\)=.*/\1=${MAIL_USERNAME}/" .env
  sed -i -e "s/\(MAIL_PASSWORD\)=.*/\1=${MAIL_PASSWORD}/" .env
  sed -i -e "s/\(MAIL_ENCRYPTION\)=.*/\1=${MAIL_ENCRYPTION}/" .env
fi

if [ ! -d vendor ]; then
  sed -i -e 's/    "type": "Project",/    "type": "project",/g' composer.json
  composer install
  php artisan key:generate
fi

chown -R www-data: .

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
