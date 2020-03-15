#!/usr/bin/env bash


# Disable Selinux
pre_install(){
    clear
    read -p "Press any key to start the installation." a
    echo "\033[1;34mStart installing. This may take a while.\033[0m"

    sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
    yum -y update
    yum install -y epel-release
    yum install -y certbot
}

# Set Domain 
set_domain(){
    clear
    echo "\033[1;34mPlease enter your domain:\033[0m"
    read domain
    str=`echo $domain | grep '^\([a-zA-Z0-9_\-]\{1,\}\.\)\{1,\}[a-zA-Z]\{2,5\}'`
    while [ ! -n "${str}" ]
    do
        echo "\033[1;31mInvalid domain.\033[0m"
        echo "\033[1;31mPlease try again:\033[0m"
        read -p domain
        str=`echo $domain | grep '^\([a-zA-Z0-9_\-]\{1,\}\.\)\{1,\}[a-zA-Z]\{2,5\}'`
    done
    echo "\033[1;35mdomain = ${domain}\033[0m"
}
# Get certification
get_cert(){
    clear
    if [ -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
        echo "\033[1;32mcert already got, skip.\033[0m"
    else 
        certbot certonly --cert-name $domain -d $domain --standalone --agree-tos --register-unsafely-without-email
        if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
            echo "\033[1;31mFailed to get cert.\033[0m"
            exit 1
        fi
    fi
}
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
