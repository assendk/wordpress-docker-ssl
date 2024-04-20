#!/bin/bash

#Install the plugins from the list

# Define plugins directory and plugins list file
PLUGINS_DIR="wp-app/wp-content/plugins"
PLUGINS_FILE="plugins.txt"

# Create plugins directory if it doesn't exist
mkdir -p "$PLUGINS_DIR"

# Read from plugins list and download each plugin
while IFS= read -r plugin_slug; do
  PLUGIN_DIR="$PLUGINS_DIR/$plugin_slug"

  # Check if the plugin directory already exists
  if [ -d "$PLUGIN_DIR" ]; then
    echo "Plugin $plugin_slug already exists. Skipping download."
    continue
  fi

  echo "Downloading plugin: $plugin_slug"

  # Download plugin ZIP file to temporary location
  TMP_ZIP="${PLUGINS_DIR}/${plugin_slug}.zip"
  wget -O "$TMP_ZIP" "https://downloads.wordpress.org/plugin/${plugin_slug}.latest-stable.zip"

  # Extract plugin and remove the ZIP file
  unzip -q "$TMP_ZIP" -d "$PLUGINS_DIR"
  rm "$TMP_ZIP"

done < "$PLUGINS_FILE"

# Fix permissions
sudo chown -R $USER:www-data "$PLUGINS_DIR"

echo "Plugin download and permission setup completed."

