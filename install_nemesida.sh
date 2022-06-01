
#Instalación de dependencias de nemesida y nwaf

rpm -Uvh https://nemesida-security.com/repo/nw/centos/nwaf-release-centos-7-1-6.noarch.rpm
yum install epel-release
yum install rabbitmq-server
rm -f /etc/machine-id
/bin/systemd-machine-id-setup
setenforce 0
rpm -Uvh http://nginx.org/packages/centos/7/x86_64/RPMS/nginx-1.18.0-1.el7.ngx.x86_64.rpm
yum install python36 python36-devel python36-setuptools python36-pip openssl librabbitmq libcurl-devel rabbitmq-server gcc libmaxminddb memcached
yum install nwaf-dyn-1.18
