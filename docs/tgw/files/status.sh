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

strongswan status
echo '****** bgp summary ******'
vtysh -c "sh ip bgp"
echo '****** Linux Routing table *******'
ip route

