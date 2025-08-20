#!/bin/bash

# Check if site name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <site-name>"
  exit 1
fi

SITE_NAME=$1
SITE_DIR="./$SITE_NAME"

# Make sure the site directory exists
if [ ! -d "$SITE_DIR" ]; then
  echo "Error: Site directory $SITE_DIR does not exist"
  exit 1
fi

# Start the containers
cd $SITE_DIR
docker-compose up -d
cd ..

# Set correct permissions for wp-content
if [ -d "$SITE_DIR/wp-content" ]; then
  echo "Setting permissions for $SITE_DIR/wp-content"
  find "$SITE_DIR/wp-content" -type d -exec chmod 755 {} \;
  find "$SITE_DIR/wp-content" -type f -exec chmod 644 {} \;
fi

echo "Site $SITE_NAME has been started with correct permissions"