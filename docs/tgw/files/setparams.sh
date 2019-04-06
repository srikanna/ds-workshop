#!/bin/sh
set -e
set -u
echo 'setparams sripted started running'
file='/tmp/vpn.xml'
if [ ! -f $file ]; then
    echo 'Did not find VPN Configuration file, check if the instance has permissions to download the config file, check run command logs'
exit 1
fi

tunnel1Path="/tmp/tunnel1.txt"
tunnel2Path="/tmp/tunnel2.txt"

cd /tmp/ && rm ipsec* tunnel* variables* zebra* bgpd* -f

wget https://workshop.awssri.com/tgw/files/ipsec-vti.sh -O /tmp/ipsec-vti.sh
wget https://workshop.awssri.com/tgw/files/ipsec.conf -O /tmp/ipsec.conf
wget https://workshop.awssri.com/tgw/files/ipsec.secrets -O /tmp/ipsec.secrets
wget https://workshop.awssri.com/tgw/files/zebra.conf -O /tmp/zebra.conf
wget https://workshop.awssri.com/tgw/files/bgpd.conf -O /tmp/bgpd.conf

xml2 < /tmp/vpn.xml >/tmp/vpn-parsed.txt
sed '/^\/vpn_connection\/ipsec_tunnel$/q' /tmp/vpn-parsed.txt > $tunnel1Path
sed -n '/^\/vpn_connection\/ipsec_tunnel$/,$ p' /tmp/vpn-parsed.txt > $tunnel2Path

ipv4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
echo "ipv4=$ipv4" >>/tmp/variables.txt

vgw1=$(grep -e '^.*vpn_gateway/tunnel_outside_address/ip_address' $tunnel1Path | cut -f2- -d=)
vgw2=$(grep -e '^.*vpn_gateway/tunnel_outside_address/ip_address' $tunnel2Path | cut -f2- -d=)
echo "vgw1=$vgw1" >>/tmp/variables.txt
echo "vgw2=$vgw2" >>/tmp/variables.txt

vgw1psk=$(grep -e '^.*pre_shared_key' $tunnel1Path | cut -f2- -d=)
vgw2psk=$(grep -e '^.*pre_shared_key' $tunnel2Path | cut -f2- -d=)
echo "vgw1psk=$vgw1psk" >>/tmp/variables.txt
echo "vgw2psk=$vgw2psk" >>/tmp/variables.txt

vgw1ip=$(grep -e '^.*vpn_gateway/tunnel_inside_address/ip_address' $tunnel1Path | cut -f2- -d=)
vgw2ip=$(grep -e '^.*vpn_gateway/tunnel_inside_address/ip_address' $tunnel2Path | cut -f2- -d=)
echo "vgw1ip=$vgw1ip" >>/tmp/variables.txt
echo "vgw2ip=$vgw2ip" >>/tmp/variables.txt

cgw1ip=$(grep -e '^.*customer_gateway/tunnel_inside_address/ip_address' $tunnel1Path | cut -f2- -d=)
cgw2ip=$(grep -e '^.*customer_gateway/tunnel_inside_address/ip_address' $tunnel2Path | cut -f2- -d=)
echo "cgw1ip=$cgw1ip" >>/tmp/variables.txt
echo "cgw2ip=$cgw2ip" >>/tmp/variables.txt

cgwas=$(grep -e '^.*customer_gateway/bgp/asn' $tunnel1Path | cut -f2- -d=)
vgwas=$(grep -e '^.*vpn_gateway/bgp/asn' $tunnel2Path | cut -f2- -d=)
echo "cgwas=$cgwas" >>/tmp/variables.txt
echo "vgwas=$vgwas" >>/tmp/variables.txt
