#!/usr/bin/env bash


    clear
    read -p "If you Didn't read README is better to do it first, If you read it befor press any key to start the installation." a
    echo "Start installing. This may take a while."
# Disable Selinux

    #sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
    
    #yum -y update
    #yum install -y epel-release
    #yum install -y certbot
    
# Installing Docker
    #curl -fsSL https://get.docker.com | sh

# Enabling and Start Docker service
    #systemctl restart docker
    #systemctl enable docker

# Set Domain 

    clear
    echo "Please enter your domain:"
    read domain
    str=`echo $domain | grep '^\([a-zA-Z0-9_\-]\{1,\}\.\)\{1,\}[a-zA-Z]\{2,5\}'`
    while [ ! -n "${str}" ]
    do
        echo "Invalid domain."
        echo "Please try again:"
        read -p domain
        str=`echo $domain | grep '^\([a-zA-Z0-9_\-]\{1,\}\.\)\{1,\}[a-zA-Z]\{2,5\}'`
    done
    echo "domain = ${domain}"

# Get certification

    clear
    if [ -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
        echo "cert already got, skip."
    else 
        certbot certonly --cert-name $domain -d $domain --standalone --agree-tos --register-unsafely-without-email
        if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
            echo "Failed to get cert."
            exit 1
        fi
    fi

# Setup letsencrypt certificates renewing
cron_line="30 2 * * 1 certbot renew >> /var/log/letsencrypt-renew.log"
(crontab -u root -l; echo "$cron_line" ) | crontab -u root -

# Rename SSL certificates
cd /etc/letsencrypt/live/$domain/
cp privkey.pem $domain.key
cat cert.pem chain.pem > $domain.crt

# Create directory for images
mkdir /var/registry

# https://docs.docker.com/registry/deploying/
docker run -d -p 443:443 --restart=always --name registry \
  -v /var/registry:/var/lib/registry \
  -v /etc/letsencrypt/live/$domain:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/$domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/$domain.key \
  registry:latest
  
# List images
# https://domain.example.com/v2/_catalog
