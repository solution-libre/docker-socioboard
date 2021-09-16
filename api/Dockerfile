FROM node:lts-alpine

ENV NODE_ENV=development

RUN apk add --update-cache jq \
  && rm -rf /var/cache/apk/*

RUN npm i -g \
             nodemon \
             mysql2 \
             pm2 \
             sequelize-cli sequelize \
  && npm cache clean --force

COPY docker-entrypoint.sh /usr/local/bin/

COPY docker-cmd.sh /usr/local/bin/
CMD ["docker-cmd.sh"]

EXPOSE 3000
EXPOSE 3001
EXPOSE 3002
EXPOSE 3003
EXPOSE 3004

# vim:set ft=dockerfile:
