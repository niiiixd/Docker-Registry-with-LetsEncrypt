# Secure docker registry with LetsEncrypt
Deploy a docker registry with letsencrypt certificates on CentOS 7.
The Registry is a stateless, highly scalable server side application that stores and lets you distribute Docker images. The Registry is open-source, under the permissive Apache license.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites
This shell script is customized for CentOS-7. In case you're using any of Debian distribution edit Pre RUN Registry section.

Creating certification by letsencrypt needs verifying through DNS. Make sure to submit a DNS record for the domain on this server before running the script.

Befor Doing any things Disable SELINUX or you cant read [SELINUX](https://wiki.centos.org/HowTos/SELinux) 
```
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
reboot
```
install the Prerequisites software:

```
yum update -y
yum install -y epel-release curl
yum install -y certbot
```
In case you didn't install Docker before you can use follow lines for installation:

### Installing Docker
``` 
curl -fsSL https://get.docker.com | sh
```
### Enabling and Start Docker service
```
systemctl restart dokcer
systemctl enable docker

```

## Deployment

Additional notes about how to deploy this on a live system [Docker Registry](https://docs.docker.com/registry/)

## Authors

* **Sadegh Khademi** - *DevOps Engineer* - [Sadegh Khademi](https://github.com/niiiixd)

See also the list of [contributors](https://github.com/niiiixd/Docker-Registry-with-LetsEncrypt/contributors) who participated in this project.

## License

This project is licensed under the GPL-v3 License - see the [LICENSE.md](LICENSE.md) file for details



