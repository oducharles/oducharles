#!/bin/bash

#
# This script should be executed only once:
# just before the laravel container runs for the first time
#

set -e  # Exit on any error

INIT_RUN_FLAG="/init_run.initialization.completed"

# Always work from /site
cd /site

echo "Current directory: $(pwd)"

if [ ! -f "$INIT_RUN_FLAG" ]; then
    echo "First-time setup started..."

    # Verify essential files exist
    if [ ! -f "composer.json" ]; then
        echo "ERROR: composer.json not found in /site"
        echo "Available files:"
        ls -la /
        ls -la /site/
        exit 1
    fi

    if [ ! -f "artisan" ]; then
        echo "ERROR: artisan not found in /site"
        exit 1
    fi

    # Step 1: Composer install
    echo "Step 1: Running composer install..."
    composer install

    if [ ! -f "vendor/autoload.php" ]; then
        echo "ERROR: Composer install failed - autoload.php missing"
        exit 1
    fi
    echo "Composer install completed successfully"

    # Step 2: NPM operations (only if package.json exists)
    if [ -f "package.json" ]; then
        echo "Step 2: Installing and building NPM assets..."

        npm install
        # npm run build
        # npm run prod

        echo "NPM operations completed"
    else
        echo "No package.json found, skipping NPM operations"
    fi

    # Step 3: Wait for database
    echo "Step 3: Waiting for MySQL database..."
    until printf "" > /dev/tcp/${DB_HOST}/3306 2>/dev/null; do
        echo "MySQL is unavailable - sleeping"
        sleep 2
    done
    echo "MySQL is ready!"

    # Step 4: Artisan commands
    echo "Step 4: Running Laravel artisan commands..."
    php artisan key:generate
    php artisan optimize

    # The following work but is not ideal.
    # in dev, php artisan migrate and php artisan seed are safe.
    # but in prod, if the laravel image is new yet the database is not, we can potentially lose data
    php artisan migrate --force
    php artisan db:seed --force

    # Create completion flag
    touch "$INIT_RUN_FLAG"
    echo "First-time setup completed successfully!"
else
    echo "Container already initialized, skipping first-time setup."
fi

# Execute the original command
exec "$@"