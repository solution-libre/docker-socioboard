#!/usr/bin/env sh

set -e

# From https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
  curl -s "https://api.github.com/repos/socioboard/Socioboard-4.0/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

PWD=$(pwd)
web_path=/var/www/html

if [ ! -d ${web_path}/app ]; then
  cd /tmp
  curl -s -L -O https://github.com/socioboard/Socioboard-4.0/archive/$(get_latest_release).tar.gz
  tar xzf $(get_latest_release).tar.gz Socioboard-4.0-$(get_latest_release)/socioboard-web-php/
  cd Socioboard-4.0-$(get_latest_release)
  mv socioboard-web-php/* ${web_path}/
  cd - > /dev/null
  rm -rf $(get_latest_release).tar.gz Socioboard-4.0-$(get_latest_release)
fi

if [ ! -f .env ]; then
  cp environmentfile.env .env
  sed -i -e 's/\(APP_KEY\)=.*/\1=JQHhy0QgKxmgKce7NASf3Zg4ezxLidJS/' .env
  sed -i -e "s/\(APP_URL\)=.*/\1=https:\/\/${HOSTNAME}\//" .env
  sed -i -e 's/\(API_URL\)=.*/\1=http:\/\/api:3000\//' .env
  sed -i -e 's/\(API_URL_PUBLISH\)=.*/\1=http:\/\/api:3001\//' .env
  sed -i -e 's/\(API_URL_FEEDs\)=.*/\1=http:\/\/api:3002\//' .env
  sed -i -e 's/\(API_URL_NOTIFY\)=.*/\1=http:\/\/api:3003\//' .env
  sed -i -e "s/\(MAIL_DRIVER\)=.*/\1=${MAIL_DRIVER}/" .env
  sed -i -e "s/\(MAIL_HOST\)=.*/\1=${MAIL_HOST}/" .env
  sed -i -e "s/\(MAIL_PORT\)=.*/\1=$MAIL_PORT/" .env
  sed -i -e "s/\(MAIL_USERNAME\)=.*/\1=${MAIL_USERNAME}/" .env
  sed -i -e "s/\(MAIL_PASSWORD\)=.*/\1=${MAIL_PASSWORD}/" .env
  sed -i -e "s/\(MAIL_ENCRYPTION\)=.*/\1=${MAIL_ENCRYPTION}/" .env
fi

if [ ! -d vendor ]; then
  composer update
fi

chown -R www-data: .

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
