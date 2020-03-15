#!/usr/bin/env bash

# install letsencrypt
yum -y install epel-release
yum -y install certbot 

# Generate SSL certificate for domain
certbot certonly --keep-until-expiring --standalone -d domain.example.com --email info@example.com

# Setup letsencrypt certificates renewing
cron_line="30 2 * * 1 certbot renew >> /var/log/letsencrypt-renew.log"
(crontab -u root -l; echo "$cron_line" ) | crontab -u root -

# Rename SSL certificates
cd /etc/letsencrypt/live/domain.example.com/
cp privkey.pem domain.key
cat cert.pem chain.pem > domain.crt

# Create directory for images
mkdir /var/registry

# https://docs.docker.com/registry/deploying/
docker run -d -p 443:5000 --restart=always --name registry \
  -v /var/registry:/var/lib/registry \
  -v /etc/letsencrypt/live/domain.example.com:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry:latest
  
# List images
# https://domain.example.com/v2/_catalog