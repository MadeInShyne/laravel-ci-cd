#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set proper ownership and permissions for Laravel storage and cache directories
chown -R application:application /var/www/html/storage
chown -R application:application /var/www/html/bootstrap/cache
chown -R application:application /var/log/nginx

# Set permissions to 775 to secure the application
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache
chmod -R 775 /var/log/nginx

# Ensure log file exists and has correct permissions
touch /var/www/html/storage/logs/laravel.log
chmod 664 /var/www/html/storage/logs/laravel.log
chown application:application /var/www/html/storage/logs/laravel.log

php artisan key:generate

# Clear and rebuild Laravel caches
echo "Clearing and rebuilding Laravel caches..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Execute the main entrypoint script with all provided arguments
exec /opt/docker/bin/entrypoint.sh "$@"