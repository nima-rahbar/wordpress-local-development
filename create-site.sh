#!/bin/bash

# --- Get Site Information Interactively ---

# Get Site Name
read -p "Enter the site name: " SITE_NAME
if [ -z "$SITE_NAME" ]; then
  echo "Site name cannot be empty."
  exit 1
fi

# Get Domain TLD
read -p "Enter the domain TLD (default: local): " DOMAIN_TLD
DOMAIN_TLD=${DOMAIN_TLD:-local}

# Get Database Prefix
read -p "Enter the database table prefix (default: wp_): " TABLE_PREFIX
TABLE_PREFIX=${TABLE_PREFIX:-wp_}

# Get Plugins
read -p "Enter a space-separated list of plugins to install (e.g., woocommerce elementor): " PLUGINS

# Get Memcached
read -p "Enable Memcached? (y/n, default: n): " USE_MEMCACHED
USE_MEMCACHED=${USE_MEMCACHED:-n}
if [ "$USE_MEMCACHED" = "y" ]; then
  USE_MEMCACHED="true"
else
  USE_MEMCACHED="false"
fi

# Get PHP Memory Limit
read -p "Enter PHP memory limit (default: 256M): " PHP_MEMORY
PHP_MEMORY=${PHP_MEMORY:-256M}

# Get PHP Max Upload Filesize
read -p "Enter PHP max upload filesize (default: 64M): " PHP_UPLOAD
PHP_UPLOAD=${PHP_UPLOAD:-64M}

# Get WP Debug
read -p "Enable WordPress debug mode? (y/n, default: n): " WP_DEBUG
WP_DEBUG=${WP_DEBUG:-n}
if [ "$WP_DEBUG" = "y" ]; then
  WP_DEBUG="true"
else
  WP_DEBUG="false"
fi

# Get Adminer Port
read -p "Enter Adminer port (default: 8080): " ADMINER_PORT
ADMINER_PORT=${ADMINER_PORT:-8080}

# Get Database User
read -p "Enter database username (default: wordpress): " DB_USER
DB_USER=${DB_USER:-wordpress}

# Get Database Password
read -p "Enter database password (default: wordpress): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-wordpress}

# Get Database Name
read -p "Enter database name (default: wordpress): " DB_NAME
DB_NAME=${DB_NAME:-wordpress}

# --- Create Site ---

TEMPLATE_DIR="./wp-template"
SITE_DIR="./$SITE_NAME"

# Create site directory
mkdir -p $SITE_DIR

# Copy template files
cp $TEMPLATE_DIR/.env $SITE_DIR/.env
cp $TEMPLATE_DIR/uploads.ini $SITE_DIR/uploads.ini
cp $TEMPLATE_DIR/setup.sh $SITE_DIR/setup.sh
cp $TEMPLATE_DIR/wp-setup.sh $SITE_DIR/wp-setup.sh

# Copy WordPress core files
cp -r $TEMPLATE_DIR/wordpress/. $SITE_DIR/wordpress/







# Update .env file with site name
sed -i "s/SITE_NAME=.*/SITE_NAME=$SITE_NAME/" $SITE_DIR/.env

# Apply all specified customizations to .env file
sed -i "s/DB_PREFIX=.*/DB_PREFIX=$TABLE_PREFIX/" $SITE_DIR/.env
sed -i "s/DOMAIN_TLD=.*/DOMAIN_TLD=$DOMAIN_TLD/" $SITE_DIR/.env
sed -i "s/DEFAULT_PLUGINS=.*/DEFAULT_PLUGINS=\"$PLUGINS\"/" $SITE_DIR/.env
sed -i "s/USE_MEMCACHED=.*/USE_MEMCACHED=$USE_MEMCACHED/" $SITE_DIR/.env
sed -i "s/PHP_MEMORY_LIMIT=.*/PHP_MEMORY_LIMIT=$PHP_MEMORY/" $SITE_DIR/.env
sed -i "s/PHP_UPLOAD_MAX_FILESIZE=.*/PHP_UPLOAD_MAX_FILESIZE=$PHP_UPLOAD/" $SITE_DIR/.env
sed -i "s/PHP_POST_MAX_SIZE=.*/PHP_POST_MAX_SIZE=$PHP_UPLOAD/" $SITE_DIR/.env
sed -i "s/WP_DEBUG=.*/WP_DEBUG=$WP_DEBUG/" $SITE_DIR/.env
sed -i "s/ADMINER_PORT=.*/ADMINER_PORT=$ADMINER_PORT/" $SITE_DIR/.env
sed -i "s/DB_USER=.*/DB_USER=$DB_USER/" $SITE_DIR/.env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" $SITE_DIR/.env
sed -i "s/DB_NAME=.*/DB_NAME=$DB_NAME/" $SITE_DIR/.env

# Make setup.sh executable
chmod +x $SITE_DIR/setup.sh
chmod +x $SITE_DIR/wp-setup.sh

# Add host entry
HOSTS_ENTRY="127.0.0.1 $SITE_NAME.$DOMAIN_TLD"
echo "Adding host entry: $HOSTS_ENTRY"
echo $HOSTS_ENTRY | sudo tee -a /etc/hosts
echo "Host entry added successfully!"

echo "WordPress site '$SITE_NAME' created in $SITE_DIR"
echo "Next steps:"
echo "1. Navigate to the site directory: cd $SITE_NAME"
echo "2. Generate configuration files: ./setup.sh"
echo "3. Start your site: docker-compose up -d"
echo "4. Configure Nginx Proxy Manager to point to: wp_$SITE_NAME"
