#!/bin/sh
set -e
set -u

ipsec='/usr/sbin/strongswan'
bgpd='/usr/sbin/bgpd'
zebra='/usr/sbin/zebra'
echo 'configuring epel'
yum-config-manager --enable epel

if [ ! -x ${ipsec} ]; then
    echo 'Strongswan is not installed. Installing..'
    yum install -y strongswan
fi

if [ ! -x ${bgpd} ]; then
    echo 'Quagga is not installed. Installing ...'
    yum install -y  quagga
fi

#echo "installing $package"
yum install -y xml2
echo 'installig ipset'
yum install -y ipset
echo 'install script finished'
yum install -y jq

# set to start at boot
chkconfig strongswan on
chkconfig zebra on
chkconfig bgpd on

# ip forwarding setu.
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv4.ip_forward=1




