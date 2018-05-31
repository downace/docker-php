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

# Remove phpize deps (saves about 200Mb)
RUN apk --no-cache del .phpize-deps
