FROM node:lts-alpine

ENV NODE_ENV=development

RUN apk add --update-cache jq \
  && rm -rf /var/cache/apk/*

RUN npm i -g \
             nodemon \
             mysql2 \
             sequelize-cli sequelize \
  && npm cache clean --force

COPY docker-entrypoint.sh /usr/local/bin/

COPY docker-cmd.sh /usr/local/bin/
CMD ["docker-cmd.sh"]

EXPOSE 3001

# vim:set ft=dockerfile:
