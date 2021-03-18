#!/usr/bin/env sh

set -e

api_path=/opt/socioboard-api

folders='user publish feeds notification'
for folder in $folders; do
  absolute_path=${api_path}/${folder}
  cd ${absolute_path}
  nodemon app.js &
done

wait
