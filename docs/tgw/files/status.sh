#!/bin/sh
set -e
set -u

ipsec='/usr/sbin/strongswan'
bgpd='/usr/sbin/bgpd'
zebra='/usr/sbin/zebra'

if [ ! -x ${ipsec} ]; then
    echo '****** Strongswan is not installed. exiting..******'
exit 1
fi

echo -e '\n ****** IPSEC STATUS ******'
strongswan status
echo -e '\n ****** bgp summary ******'
vtysh -c "sh ip bgp"
echo -e '\n ****** Linux Routing table *******'
ip route

