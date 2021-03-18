#!/usr/bin/env sh

set -e

# From https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
  wget -O- -q "https://api.github.com/repos/socioboard/Socioboard-4.0/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

PWD=$(pwd)
api_path=/opt/socioboard-api

if [ ! -d ${api_path}/user ]; then
  cd /tmp
  wget -q https://github.com/socioboard/Socioboard-4.0/archive/$(get_latest_release).tar.gz
  tar xzf $(get_latest_release).tar.gz Socioboard-4.0-$(get_latest_release)/socioboard-api/
  cd Socioboard-4.0-$(get_latest_release)
  mv socioboard-api/* ${api_path}/
  cd - > /dev/null
  rm -rf $(get_latest_release).tar.gz Socioboard-4.0-$(get_latest_release)
fi

folders='user publish feeds notification library'
for folder in $folders; do
  absolute_path=${api_path}/${folder}
  cd ${absolute_path}
  if [ ! -d node_modules ]; then
    npm i
    npm audit fix
  fi
  if [ -d config ]; then
    cd config
    if [ "$(jq .mongo.username development.json)" = '"<<Mongo User name>>"' ]; then
      jq ".mongo.username=\"${MONGO_USERNAME}\"
        | .mongo.password=\"${MONGO_PASSWORD}\"
        | .mongo.db_name=\"${MONGO_DB}\"
        | .mongo.host=\"${MONGO_HOST}\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "${folder}" = 'user' -a $(jq .payment.base_path development.json) = null ]; then
      jq ".payment.base_path=\"../../media\"
        | .payment.payment_path=\"../../media/payments\"
        | .payment.template=\"public/template/paymentTemplate.html\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
  fi
done

cd ${api_path}/library/sequelize-cli/config
if [ $(jq .development.password config.json) = null ]; then
  jq ".development.username=\"${DB_USERNAME}\"
    | .development.password=\"${DB_PASSWORD}\"
    | .development.database=\"${DB_NAME}\"
    | .development.host=\"${DB_HOST}\"" config.json > config.json.tmp && mv config.json.tmp config.json
  cd ..
  sequelize db:migrate
  cd seeders
  seed=$(ls *-initialize_application_info.js)
  cd - > /dev/null
  sequelize db:seed --seed $seed &
fi

cd $PWD

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"
