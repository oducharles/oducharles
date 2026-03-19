FROM php:7.4-fpm-alpine

# 1. Install persistent runtime dependencies (these stay in the image)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    make \
    unzip \
    jq \
    nano \
    nodejs \
    npm \
    libxml2 \
    libzip \
    libjpeg-turbo \
    libpng \
    freetype \
    icu-libs \
    oniguruma\
    mariadb-connector-c \
    fontconfig \
    ttf-dejavu

# 2. Install build dependencies, compile extensions, and cleanup in ONE layer
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    autoconf \
    libxml2-dev \
    libzip-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    freetype-dev \
    icu-dev \
    mariadb-connector-c-dev \
    oniguruma-dev \
    curl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        exif \
        zip \
        bcmath \
        intl \
        opcache \
        mbstring \
        pcntl \
        gd \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Setup Application - working directory inside the container
WORKDIR /site

# 5. Copy composer.lock and composer.json first to leverage Docker cache
COPY src/composer.* /site

# 6. Copy application code (excluding .git, vendor, etc., via .dockerignore)
COPY src/ /site

# 7. Setup Entrypoint
COPY docker/.init-run.entrypoint.sh  /usr/local/bin/init-run.entrypoint.sh
RUN chmod +x /usr/local/bin/init-run.entrypoint.sh

# 8. Set appropriate permissions for the storage and cache directories
    # This step is crucial for the www-data user to write logs/cache/sessions at runtime

RUN chown -R www-data:www-data /site/storage /site/bootstrap/cache \
   && chmod -R 775 /site/storage /site/bootstrap/cache

# 9. Verify PHP extensions are loaded
RUN php -m | grep -E 'intl|zip|gd|pdo_mysql'

# Expose the FPM port (standard for PHP-FPM)
EXPOSE 9000

# Set the custom entrypoint script as the default command to execute at RUNTIME
# This ensures DB_HOST is available for the database wait loop.
ENTRYPOINT ["/usr/local/bin/init-run.entrypoint.sh"]

# Start PHP-FPM
CMD ["php-fpm"]
