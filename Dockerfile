FROM composer:1.6.5 as build

WORKDIR /app
COPY . /app
RUN composer install

FROM php:7.2-apache

RUN apt-get update \
    && apt-get install -y cron gnupg2 graphviz icu-devtools libicu-dev libssl-dev unzip vim zlib1g-dev nasm libjpeg62-turbo-dev libpng-dev libwebp-dev libxpm-dev libfreetype6-dev libsasl2-dev libssl-dev zlib1g-dev
RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir \
    && docker-php-ext-install intl pdo_mysql zip gd \
    && docker-php-ext-enable opcache \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

EXPOSE 80
COPY --from=build /app /app
COPY vhost.conf /etc/apache2/sites-available/000-default.conf
RUN chown -R www-data:www-data /app \
    && a2enmod rewrite
