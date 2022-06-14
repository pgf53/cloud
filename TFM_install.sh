#!/bin/sh
yum install gcc-c++ flex bison yajl yajl-devel curl-devel curl GeoIP-devel doxygen zlib-devel pcre-devel
cd /opt/
git clone https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
git checkout -b v3/master origin/v3/master
sh build.sh
git submodule init
git submodule update
./configure
yum install https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/23/x86_64/b/bison-3.0.4-3.fc23.x86_64.rpm
make
make install
yum install -y inotify-tools sshpass python36 byobu dialog git
mkdir -p /opt/modsecurity-debug/var/log/
touch /opt/modsecurity-debug/var/log/debug.log
#Ruta para ModSecurity
mv /usr/local/modsecurity/lib/* /usr/lib64/

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

#IL snort y Nemesida
ln -s /usr/lib64/libpcre.so.1.2.0 /usr/lib64/libpcre.so.3
