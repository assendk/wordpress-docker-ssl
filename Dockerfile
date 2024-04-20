FROM wordpress:latest
RUN echo "https://greenplace.local:487"
# Copy SSL certificates
COPY ssl_cert/mysslsite.crt /etc/apache2/ssl/mysslsite.crt
COPY ssl_cert/mysslsite.key /etc/apache2/ssl/mysslsite.key
# Copy the Apache configurations
COPY 000-default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf

# Enable SSL module and site
RUN a2enmod ssl && a2ensite 000-default-ssl.conf
RUN a2enmod headers
# Restart Apache to apply changes (optional here, depends on your setup)
