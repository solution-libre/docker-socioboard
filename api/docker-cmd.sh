#!/usr/bin/env sh

set -e

api_path=/opt/socioboard-api

folders='User Feeds Publish Notification Update'
for folder in $folders; do
  absolute_path=${api_path}/${folder}
  cd ${absolute_path}
  if [ "${folder}" = 'Notification' ]; then
    server_prefix_filename='notify'
  else
    server_prefix_filename=$( echo $folder | tr [:upper:] [:lower:])
  fi
  pm2 start "${server_prefix_filename}.server.js"
done

pm2 logs
