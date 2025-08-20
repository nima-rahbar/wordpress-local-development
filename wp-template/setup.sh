#!/bin/bash

# Load environment variables
source .env

# Create wordpress directory if it doesn't exist
mkdir -p ./wordpress

# Get host UID and GID
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

# Create docker-compose.yml with proper configurations
cat > docker-compose.yml << EOL
version: '3'

services:
  wordpress:
    image: wordpress:php8.1-apache
    container_name: wp_${SITE_NAME}
    restart: unless-stopped
    user: "${HOST_UID}:${HOST_GID}"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
      WORDPRESS_TABLE_PREFIX: ${DB_PREFIX}
      WORDPRESS_DEBUG: ${WP_DEBUG}
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_ENVIRONMENT_TYPE', 'development');
    volumes:
      - ./wordpress/:/var/www/html
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
    networks:
      - proxy-network
      - internal-network
    depends_on:
      - db

  db:
    image: mariadb:10.6
    container_name: db_${SITE_NAME}
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - internal-network
      - proxy-network

  # WP-CLI for plugin installation and site setup
  wp-cli:
    image: wordpress:cli
    container_name: wpcli_${SITE_NAME}
    restart: "no"
    volumes:
      - ./wordpress/:/var/www/html
      - ./wp-setup.sh:/wp-setup.sh
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
      INSTALL_DEFAULT_PLUGINS: ${INSTALL_DEFAULT_PLUGINS}
      DEFAULT_PLUGINS: "${DEFAULT_PLUGINS}"
      AUTO_ACTIVATE_PLUGINS: ${AUTO_ACTIVATE_PLUGINS}
      USE_MEMCACHED: ${USE_MEMCACHED}
    networks:
      - internal-network
    depends_on:
      - wordpress
      - db
    entrypoint: ["sh", "/wp-setup.sh"]
EOL

# Add memcached service if enabled
if [ "$USE_MEMCACHED" = "true" ]; then
  cat >> docker-compose.yml << EOL
  memcached:
    image: memcached:latest
    container_name: memcached_${SITE_NAME}
    restart: unless-stopped
    networks:
      - internal-network
    profiles:
      - memcached
EOL
fi

# Finish the docker-compose.yml file
cat >> docker-compose.yml << EOL

networks:
  proxy-network:
    external: true
  internal-network:
    driver: bridge

volumes:
  db_data:
EOL

# Create PHP uploads.ini file
cat > uploads.ini << EOL
file_uploads = On
memory_limit = ${PHP_MEMORY_LIMIT}
upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}
post_max_size = ${PHP_POST_MAX_SIZE}
max_execution_time = ${PHP_MAX_EXECUTION_TIME}
EOL

echo "Configuration files have been generated successfully!"