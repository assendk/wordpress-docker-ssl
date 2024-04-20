#!/bin/bash

# Load Environment Variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

##########################################################################
# Create directories
mkdir -p wp-app
mkdir -p wp-db/wp-data
mkdir -p wp-db/run_scripts
mkdir -p config
mkdir -p wp-app/wp-content/uploads/
mkdir -p wp-app/wp-content/plugins/
mkdir -p ssl_cert

# Change ownership
sudo chown -R $USER:www-data wp-app/
sudo chown -R $USER:www-data wp-db/
sudo chown -R $USER:mysql wp-db/wp-data
sudo chown -R $USER:www-data config/
sudo chown -R $USER:www-data wp-app/wp-content/uploads/
sudo chown -R $USER:www-data wp-app/wp-content/plugins/

# Ensure the plugins directory exists
PLUGIN_SUBFOLDER="install-plugins"
PLUGINS_DIR="wp-app/wp-content/plugins"
mkdir -p "$PLUGINS_DIR"

##########################################################################
# Generate SSL certificates using MY_SITE_NAME from .env file
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "ssl_cert/mysslsite.key" -out "ssl_cert/mysslsite.crt" -subj "/C=BG/ST=Sofia/L=Sofia/O=YourDev/CN=${MY_SITE_NAME}"


# Ask user if they want to build Docker containers
read -p "Do you want to build Docker containers without starting them? (y/n): " build_answer

case $build_answer in
    [Yy]* )
        docker compose build
        echo "Docker containers built."
        ;;
    [Nn]* )
        echo "Skipping Docker container build."
        ;;
    * )
        echo "Invalid input. Please answer y/n."
        ;;
esac


##### Updating /etc/hosts #################################################################################
HOST_ENTRY="${IP} ${MY_SITE_NAME}"
if ! grep -q "${HOST_ENTRY}" /etc/hosts; then
    echo "/nAdding ${MY_SITE_NAME} to /etc/hosts"
    echo "${HOST_ENTRY}" | sudo tee -a /etc/hosts > /dev/null
else
    echo "${MY_SITE_NAME} already in /etc/hosts"
fi


######## Define plugins directory and plugins list file ##########################################################################
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
sudo chown -R $USER:www-data wp-app/wp-content/


###### Check if unzip is installed #####################################################
if ! command -v unzip &> /dev/null; then
    echo "unzip could not be found. Please install unzip to proceed."
    exit 1
fi

# Loop through each ZIP file in the subfolder and extract them to the plugins directory
for plugin_zip in "$PLUGIN_SUBFOLDER"/*.zip; do
    if [[ -f "$plugin_zip" ]]; then
        echo "Extracting plugin: $plugin_zip"
        unzip -q "$plugin_zip" -d "$PLUGINS_DIR"
    else
        echo "No plugin ZIP files found in $PLUGIN_SUBFOLDER."
    fi
done

echo "Plugins extracted. They are now available for activation."

##### DONE #####################################
echo "WordPress setup completed."
echo "${MY_SITE_NAME}:${PORT}"
echo "https://${MY_SITE_NAME}:${SSL_PORT}"
docker compose up --build


