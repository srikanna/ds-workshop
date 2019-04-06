#!/bin/sh
set -e
set -u

source /tmp/variables.txt

service strongswan stop
service bgpd stop
service zebra stop

sed -i "s/cgw-private-ip/$ipv4/g" "/tmp/ipsec.conf"
sed -i "s/vgw1-outside-ip/$vgw1/g" "/tmp/ipsec.conf"
sed -i "s/vgw2-outside-ip/$vgw2/g" "/tmp/ipsec.conf"

echo 'copying ipsec configuration'
/bin/cp /etc/strongswan/ipsec.conf /etc/strongswan/ipsec.conf.bkup 2>/dev/null || :
/bin/cp -f /tmp/ipsec.conf /etc/strongswan/ipsec.conf


sed -i "s/cgw1-inside-ip/$cgw1ip/g" "/tmp/ipsec-vti.sh"
sed -i "s/cgw2-inside-ip/$cgw2ip/g" "/tmp/ipsec-vti.sh"
sed -i "s/vgw1-inside-ip/$vgw1ip/g" "/tmp/ipsec-vti.sh"
sed -i "s/vgw2-inside-ip/$vgw2ip/g" "/tmp/ipsec-vti.sh"

echo 'copying ipsec up/down script'
/bin/cp /etc/strongswan/ipsec.conf /etc/strongswan/ipsec-vti.sh.bkup 2>/dev/null || :
/bin/cp -f /tmp/ipsec-vti.sh /etc/strongswan/ipsec-vti.sh
chmod +x /etc/strongswan/ipsec-vti.sh


sed -i "s/cgw-private-ip/$ipv4/g" "/tmp/ipsec.secrets"
sed -i "s/vgw1-outside-ip/$vgw1/g" "/tmp/ipsec.secrets"
sed -i "s/vgw2-outside-ip/$vgw2/g" "/tmp/ipsec.secrets"
sed -i "s/vgw1-psk/$vgw1psk/g" "/tmp/ipsec.secrets"
sed -i "s/vgw2-psk/$vgw2psk/g" "/tmp/ipsec.secrets"

echo 'copying ipsec.secretes configuration'
/bin/cp /etc/strongswan/ipsec.secrets /etc/strongswan/ipsec.secrets.bkup 2>/dev/null || :
/bin/cp -f /tmp/ipsec.secrets /etc/strongswan/ipsec.secrets

echo 'copying zebra configuration'
/bin/cp /etc/quagga/zebra.conf /etc/quagga/zebra.conf.bkup 2>/dev/null || :
/bin/cp -f /tmp/zebra.conf /etc/quagga/zebra.conf


sed -i "s/vgw1-inside-ip/$vgw1ip/g" "/tmp/bgpd.conf"
sed -i "s/vgw2-inside-ip/$vgw2ip/g" "/tmp/bgpd.conf"

sed -i "s/vgw-as/$vgwas/g" "/tmp/bgpd.conf"
sed -i "s/cgw-as/$cgwas/g" "/tmp/bgpd.conf"
sed -i "s/cgw-private-ip/$ipv4/g" "/tmp/bgpd.conf"

echo 'copying bgp configuration'
/bin/cp /etc/quagga/bgpd.conf /etc/quagga/bgpd.conf.bkup 2>/dev/null || :
/bin/cp -f /tmp/bgpd.conf /etc/quagga/bgpd.conf

chown quagga.quagga /etc/quagga/*.conf
chmod 640 /etc/quagga/*.conf

# start services

service strongswan restart
service bgpd restart
service zebra restart

# set ip tables

ipset create ipsecvpn hash:net
# TODO parameterize the VPC CIDRS for spokes below and loop for as many spokes.
ipset add ipsecvpn 10.10.0.0/16
ipset add ipsecvpn 10.20.0.0/16
iptables -t nat -A POSTROUTING -j MASQUERADE -m set ! --match-set ipsecvpn dst
