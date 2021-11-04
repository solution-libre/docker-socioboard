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
      cd ..
    fi
    cd ..
  fi

  if [ -d config ]; then
    cd config
    if [ "$(jq -r .mongo development.json)" != null ]; then
      jq ".mongo.username=\"${MONGO_USERNAME}\"
        | .mongo.password=\"${MONGO_PASSWORD}\"
        | .mongo.db_name=\"${MONGO_DB}\"
        | .mongo.host=\"${MONGO_HOST}\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "$(jq -r .facebook_api development.json)" != null ]; then
      jq ".facebook_api.app_id=\"${FACEBOOK_APP_ID}\"
        | .facebook_api.secret_key=\"${FACEBOOK_SECRET_KEY}\"
        | .facebook_api.redirect_url=\"https://${HOSTNAME}/facebook-callback\"
        | .facebook_api.fbprofile_add_redirect_url=\"https://${HOSTNAME}/facebook/callback\"" development.json > development.json.tmp && mv development.json.tmp development.json
        #| .facebook_api.page_scopes=\"publish_pages,manage_pages,read_insights\"
    fi
    if [ "$(jq -r .profile_add_redirect_url development.json)" != null ]; then
      jq ".profile_add_redirect_url=\"https://${HOSTNAME}/facebook/callback\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "$(jq -r .profile_page_redirect_url development.json)" != null ]; then
      jq ".profile_page_redirect_url=\"https://${HOSTNAME}/facebook-page/callback\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "$(jq -r .google_api development.json)" != null ]; then
      jq ".google_api.client_id=\"${GOOGLE_CLIENT_ID}\"
        | .google_api.client_secrets=\"${GOOGLE_CLIENT_SECRETS}\"
        | .google_api.api_key=\"${GOOGLE_API_KEY}\"
        | .google_api.youtube_webhook_url=\"https://api-02.${HOSTNAME}/v1/webhooks/youtube\"
        | .google_api.redirect_url=\"https://${HOSTNAME}/google-callback\"
	| .google_api.youtube_redirect_url=\"https://${HOSTNAME}/youtube/callback\"
        | .google_api.google_profile_add_redirect_url=\"https://${HOSTNAME}/youtube/callback\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "$(jq -r .instagram_business_api development.json)" != null ]; then
      jq ".instagram_business_api.client_id=\"${FACEBOOK_APP_ID}\"
        | .instagram_business_api.client_secret=\"${FACEBOOK_SECRET_KEY}\"
        | .instagram_business_api.business_redirect_url=\"https://${HOSTNAME}/instagram-business/callback\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "$(jq -r .twitter_api development.json)" != null ]; then
      jq ".twitter_api.api_key=\"${TWITTER_API_KEY}\"
        | .twitter_api.secret_key=\"${TWITTER_SECRET_KEY}\"
        | .twitter_api.app_name=\"${TWITTER_APP_NAME}\"
        | .twitter_api.webhook_url=\"https://api-02.${HOSTNAME}/v1/webhooks/twitter\"
        | .twitter_api.redirect_url=\"https://${HOSTNAME}/twitter/callback\"
        | .twitter_api.login_redirect_url=\"https://${HOSTNAME}/twitter-callback\"" development.json > development.json.tmp && mv development.json.tmp development.json
    fi
    if [ "${folder}" = 'User' ]; then
      # https://github.com/socioboard/Socioboard-5.0/issues/262
      set +e
      src_files="$(grep -r '/unauthorized' ../core ../resources | grep import)"
      set -e
      if [ -n "${src_file}" ]; then
         echo ${src_files} | cut -d ':' -f 1 | xargs sed -i 's:/unauthorized:/unAuthorized:g'
      fi

      if [ "$(jq -r .twilio.account_sid development.json)" = '<< twilio account_sid >>' ]; then
        jq '.twilio.account_sid="AC"' development.json > development.json.tmp && mv development.json.tmp development.json
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
  seed=$(ls *-initialize_application_informations.cjs)
  cd ..
  npx sequelize-cli db:seed --seed "${seed}" &
fi

cd $PWD

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"
