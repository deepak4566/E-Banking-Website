# Use an official PHP image with Laravel support
FROM php:7.4-laravel

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        unzip \
        git \
        && docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install zip \
        && docker-php-ext-install mysqli

# Set the working directory to /app
WORKDIR /app

# Copy the application code
COPY . .

# Install Composer dependencies
RUN composer install

# Install Node.js and npm
RUN apt-get update && apt-get install -y nodejs npm

# Install frontend dependencies
RUN npm install

# Build the frontend assets
RUN npm run build

# Copy the Apache configuration file
COPY public_html/apache.conf /etc/apache2/sites-available/000-default.conf

# Expose the port
EXPOSE 80

# Start the MySQL server
RUN apt-get update && apt-get install -y mysql-server && \
    service mysql start && \
    mysql -uroot -e "CREATE DATABASE ebanking; GRANT ALL PRIVILEGES ON ebanking.* TO 'ebanking'@'%' IDENTIFIED BY 'ebanking'; FLUSH PRIVILEGES;"

# Start the Apache server
CMD ["apache2-foreground"]

