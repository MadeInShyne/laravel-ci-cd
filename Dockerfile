# Use the base image
FROM webdevops/php-nginx:8.2

# Allow Composer to run as superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install Composer and dos2unix
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get update \
    && apt-get install -y dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Set the working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Create necessary set permissions. "application:application" is the user used by the webdevops/php-nginx image
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/log/nginx \
    && chown -R application:application /var/log/nginx

# Copy the environment example file
COPY .env.example .env

# Remove composer.lock file if it exists
RUN rm -f composer.lock

# Install Composer dependencies. "--no-dev" not to install packages in the “dev” section of the composer.json file
RUN composer install --optimize-autoloader --no-dev

# Copy custom entrypoint script
COPY custom-ep.sh /usr/local/bin/
RUN dos2unix /usr/local/bin/custom-ep.sh \
    && chmod +x /usr/local/bin/custom-ep.sh

# Use custom entrypoint script
ENTRYPOINT ["/usr/local/bin/custom-ep.sh"]
CMD ["supervisord"]