#!/bin/bash

# Wait for the database to be ready
until mariadb-admin ping -h db --silent; do
  echo "Waiting for database..."
  sleep 2
done

# Install default plugins if specified
if [ "$INSTALL_DEFAULT_PLUGINS" = "true" ] && [ -n "$DEFAULT_PLUGINS" ]; then
  echo "Installing default plugins..."
    wp plugin install $DEFAULT_PLUGINS --activate
fi

# Activate all plugins if specified
if [ "$AUTO_ACTIVATE_PLUGINS" = "true" ]; then
  echo "Activating all plugins..."
    wp plugin activate --all
fi

# Install Memcached plugin if enabled
if [ "$USE_MEMCACHED" = "true" ]; then
  echo "Installing Memcached plugin..."
    wp plugin install memcached --activate
fi

echo "WordPress setup is complete."
