FROM php:7.2-fpm-alpine

# Install phpize deps as virtual package
RUN apk add --virtual .phpize-deps --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.6.0 \
    && docker-php-ext-enable xdebug

# libpq is a part of postgresql-libs
# but postgresql-libs couldn't be installed without postgresql-dev
RUN apk --no-cache add postgresql-dev postgresql-libs \
    && docker-php-ext-install pdo_pgsql \
    && apk --no-cache del postgresql-dev

# SOAP
RUN apk --no-cache add libxml2-dev \
    && docker-php-ext-install soap

# Remove phpize deps (saves about 200Mb)
RUN apk --no-cache del .phpize-deps

RUN docker-php-ext-install zip

RUN curl -fsS https://getcomposer.org/installer -o composer-setup.php \
    # There is no sha384sum utility, using PHP implementation
    && php -r "exit(strcmp(hash_file('SHA384', 'composer-setup.php'), '`curl -fs https://composer.github.io/installer.sig`'));" || echo 'Composer installer corrupt' \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && rm composer-setup.php

USER www-data

ENV PATH /home/www-data/.composer/vendor/bin:$PATH
