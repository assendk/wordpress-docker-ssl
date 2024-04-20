#Wordpress Installation Speedup Script for Linux
## By using Docker containers for the PHP + MySQL/MariaDB + phpmyadmin + wpcli + SSL (self cert), bash script for automations
The script/s can speedup a lot the WordPress site creation. It create a fresh wordpress installation, add some plugins

What will be done be done:
- insert a host name in your /etc/hosts
- create the required folders
- generate and move ssl files to the container, enable the mod
- download plugins from the wordpress.org
- install plugins from folder
- download the required docker files - Wordpress latest, MySQL/MariaDB, PhpMyAdmin, wpcli

## Create empty folder and Configure the required files:
1. Edit the .env file
Example .env file
```
IP=127.0.0.1
# Replace 83 and the mysite.local name
PORT=83
SSL_PORT=8443
MY_ADMIN_PORT=8083
MY_DB_PORT=33083
DB_ROOT_PASSWORD=pasword83
DB_NAME=wp_mysslsite83
MY_SITE_NAME=mysite.local
MY_USER=adk
CONTAINER_UID=1000
CONTAINER_GID=1000
#FULL_URL=https://mysite.local:8443 to easy copy/paste in future
```
2. Add zip plugins in the install-plugins/ folder if you want them automatically installed
3. Edit plugins-download-list.txt file and add remove files for download from wordpress.org
4. Change the permission of setup-wordpress.sh
5. Open new terminal window and run it (./setup-wordpress.sh)
6. Wait to the plugins and containers be installed/downloaded
7. Open the url configured in you .env file (for example https://mysite.local:8443)
   > Note the port is important

