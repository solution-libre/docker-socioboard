FROM php:7-apache

ARG HOSTNAME=domain.tld

#ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
#    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
#    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
#    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Installation

## Requirements
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
#                                                  libicu-dev \
                                                   libzip-dev
#                                                  acl

## php extensions
RUN docker-php-ext-install -j$(nproc) \
                                        zip
#                                       intl \
#                                       opcache \
#                                       pdo_mysql

## Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

## Laravel

RUN composer global require laravel/installer

# Configuration

## apache

RUN a2enmod rewrite headers

COPY apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf
COPY apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN sed -i -e "s/domain.tld/${HOSTNAME}/g" /etc/apache2/sites-available/000-default.conf

## php

RUN cd "${PHP_INI_DIR}" \
    && cp php.ini-production php.ini

#COPY php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Clean-up

## Requirements

RUN apt-get purge -y \
#                     libicu-dev \
                     libzip-dev \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]
