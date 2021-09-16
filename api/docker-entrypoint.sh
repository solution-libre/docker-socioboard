#!/usr/bin/env sh

set -e

PWD=$(pwd)
SOCIOBOARD_VERSION='5.1.0'
api_path=/opt/socioboard-api

if [ ! -d ${api_path}/User ]; then
  archive_filename="socioboard-${SOCIOBOARD_VERSION}.tar.gz"
  cd /tmp
  wget -q https://codeload.github.com/socioboard/Socioboard-5.0/tar.gz/Socioboard-${SOCIOBOARD_VERSION} -O ${archive_filename}
  tar xzf ${archive_filename} Socioboard-5.0-Socioboard-${SOCIOBOARD_VERSION}/socioboard-api/
  cd Socioboard-5.0-Socioboard-${SOCIOBOARD_VERSION}
  mv socioboard-api/* ${api_path}/
  cd - > /dev/null
  rm -rf ${archive_filename} Socioboard-5.0-Socioboard-${SOCIOBOARD_VERSION}
fi


folders='User Feeds Common Update Publish Notification'
for folder in $folders; do
  absolute_path=${api_path}/${folder}
  cd ${absolute_path}

  if [ ! -d node_modules ]; then
    npm i
    #npm audit fix
  fi

  if [ -d resources ]; then
    cd resources
    # https://github.com/socioboard/Socioboard-5.0/issues/263
    if [ ! -d Log ]; then
      ln -s log Log
    fi
    # https://github.com/socioboard/Socioboard-5.0/issues/264
    if [ -d views ]; then
      cd views
      if [ ! -f swagger-api-view.json ]; then
        cp ${api_path}/Notification/resources/views/swagger-api-view.json .
      fi
    fi
  fi

  if [ -d config ]; then
    cd config
    if [ "$(jq -r .mongo.username development.json)" = '<< username >>' ]; then
      jq ".mongo.username=\"${MONGO_USERNAME}\"
        | .mongo.password=\"${MONGO_PASSWORD}\"
        | .mongo.db_name=\"${MONGO_DB}\"
        | .mongo.host=\"${MONGO_HOST}\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "${folder}" = 'User' ]; then
      # https://github.com/socioboard/Socioboard-5.0/issues/262
      grep -r '/unauthorized' ../core ../resources | grep import | cut -d ':' -f 1 | xargs sed -i 's:/unauthorized:/unAuthorized:g'

      if [ "$(jq -r .twilio.account_sid development.json)" = '<< twilio account_sid >>' ]; then
        jq '.twilio.account_sid=AC' development.json > development.json.tmp && mv development.json.tmp development.json
      fi

      #if [ $(jq .payment.base_path development.json) = null ]; then
      #  jq ".payment.base_path=\"../../media\"
      #    | .payment.payment_path=\"../../media/payments\"
      #    | .payment.template=\"public/template/paymentTemplate.html\"" development.json > development.json.tmp && mv development.json.tmp development.json
      #fi
    fi
  fi
done

cd ${api_path}/Common/Sequelize-cli/config
if [ "$(jq -r .development.password config.json)" = '<< password >>' ]; then
  jq ".development.username=\"${DB_USERNAME}\"
    | .development.password=\"${DB_PASSWORD}\"
    | .development.database=\"${DB_NAME}\"
    | .development.host=\"${DB_HOST}\"" config.json > config.json.tmp && mv config.json.tmp config.json
  cd ..
  npx sequelize-cli db:migrate
  cd seeders/
  seed=$(ls *-initialize_application_info.js)
  cd - > /dev/null
  sequelize-cli db:seed --seed "${seed}" &
fi

cd $PWD

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"
